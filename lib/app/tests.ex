defmodule App.Tests do
  alias App.OpenAi.Gpt
  alias App.Parser.ListeningParser
  alias App.Parser.ReadingParser
  alias App.Parser.WritingParser
  alias App.Repo
  alias App.Schemas.Listening
  alias App.Schemas.ListeningResult
  alias App.Schemas.Question
  alias App.Schemas.Reading
  alias App.Schemas.ReadingResult
  alias App.Schemas.Writing
  alias App.Schemas.WritingResult
  alias App.Users

  require Ecto.Query

  def get_reading_test(id, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    Reading
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  def get_listening_test(id, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    Listening
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  def get_writing_test(id, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    Writing
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  def get_question(id, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    Question
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  def get_questions(id, type) do
    Repo.all(Ecto.Query.from(q in Question, where: q.test_id == ^id and q.test_type == ^type))
  end

  def pass_reading_test(test_id) do
    Reading
    |> Repo.get(test_id)
    |> case do
      nil ->
        {:error, :test_not_found}

      test ->
        questions = get_questions(test_id, "reading")
        test = %{test | questions: questions}

        ReadingParser.parse_test(test)
    end
  end

  def pass_listening_test(test_id) do
    Listening
    |> Repo.get(test_id)
    |> case do
      nil ->
        {:error, :test_not_found}

      test ->
        questions = get_questions(test_id, "listening")
        dbg(questions)
        test = %{test | questions: questions}

        ListeningParser.parse_test(test)
    end
  end

  def pass_writing_test(nil) do
    {:ok, writing} = Gpt.generate_essay()

    writing
    |> Repo.insert!()
    |> WritingParser.parse_test()
  end

  def pass_writing_test(test_id) do
    Writing
    |> Repo.get(test_id)
    |> case do
      nil ->
        {:error, :test_not_found}

      test ->
        WritingParser.parse_test(test)
    end
  end

  def pull_reading_tests(user_id) do
    Reading
    |> Repo.all()
    |> ReadingParser.parse_tests(user_id)
  end

  def pull_listening_tests(user_id) do
    Listening
    |> Repo.all()
    |> ListeningParser.parse_tests(user_id)
  end

  def pull_writing_tests(user_id) do
    Writing
    |> Repo.all()
    |> WritingParser.parse_tests(user_id)
  end

  def pull_writing_history(user_id, writing_result_id) do
    WritingResult
    |> Repo.get_by(user_id: user_id, id: writing_result_id)
    |> case do
      nil ->
        {:error, :user_didnt_pass_test}

      result ->
        result
        |> Repo.preload(:writing)
        |> WritingParser.parse_history()
    end
  end

  def pull_listening_history(user_id, listening_result_id) do
    ListeningResult
    |> Repo.get_by(user_id: user_id, id: listening_result_id)
    |> case do
      nil ->
        {:error, :user_didnt_pass_test}

      result ->
        result
        |> Repo.preload(:listening)
        |> ListeningParser.parse_history()
    end
  end

  def pull_reading_history(user_id, reading_result_id) do
    ReadingResult
    |> Repo.get_by(user_id: user_id, id: reading_result_id)
    |> case do
      nil ->
        {:error, :user_didnt_pass_test}

      result ->
        result
        |> Repo.preload(:reading)
        |> ReadingParser.parse_history()
    end
  end

  def save_writing_test(user_id, writing_id, essay) do
    writing = get_writing_test(writing_id)
    question = writing.task

    case Gemini.mark_essay(essay, question) do
      {:ok, writing_result} ->
        {:ok, writing_result} =
          App.Repo.transaction(fn ->
            Users.update_avg_score(user_id, :writing, writing_result.score)

            writing_result
            |> Map.put(:user_id, user_id)
            |> Map.put(:writing_id, writing_id)
            |> Map.put(:user_essay, essay)
            |> Repo.insert!()
          end)

        WritingParser.parse_result(writing_result)

      {:error, error} ->
        {:error, error}
    end
  end

  def save_listening_test(user_id, listening_id, answers) do
    listening = get_listening_test(listening_id)

    if listening.question_count != length(answers) do
      {:error, :invalid_number_of_answers}
    else
      {correct_count, score, content} = calculate_score(listening, answers)

      App.Repo.transaction(fn ->
        Users.update_avg_score(user_id, :listening, score)

        %ListeningResult{
          content: content,
          user_id: user_id,
          listening_id: listening_id,
          correct_count: correct_count,
          score: score
        }
        |> Repo.insert!()
      end)

      {:ok, %{score: score}}
    end
  end

  def save_reading_test(user_id, reading_id, answers) do
    reading = get_reading_test(reading_id)

    if reading.question_count != length(answers) do
      {:error, :invalid_number_of_answers}
    else
      {correct_count, score, content} = calculate_score(reading, answers)

      App.Repo.transaction(fn ->
        Users.update_avg_score(user_id, :reading, score)

        %ReadingResult{
          content: content,
          user_id: user_id,
          reading_id: reading_id,
          correct_count: correct_count,
          score: score
        }
        |> Repo.insert!()
      end)

      {:ok, %{score: score}}
    end
  end

  defp calculate_score(test, answers) do
    {correct_count, content} =
      Enum.reduce(answers, {0, []}, fn %{question_id: question_id, answer: answer}, acc ->
        {correct_count, content} = acc
        question = get_question(question_id)

        given_answer = String.downcase(answer)
        expected_answer = String.downcase(question.correct_answer)

        if given_answer == expected_answer do
          {correct_count + 1,
           [
             %{
               question_id: question_id,
               question: question.question,
               part: question.part,
               answers: question.answers,
               correct_answer: question.correct_answer,
               chosen_answer: answer,
               is_correct: true
             }
             | content
           ]}
        else
          {correct_count,
           [
             %{
               question_id: question_id,
               question: question.question,
               part: question.part,
               answers: question.answers,
               correct_answer: question.correct_answer,
               chosen_answer: answer,
               is_correct: false
             }
             | content
           ]}
        end
      end)

    score = get_score(test.question_count, correct_count)

    {correct_count, score, content}
  end

  defp get_score(question_count, correct_count) do
    scaled = correct_count / question_count * 40

    cond do
      scaled >= 39 -> 9.0
      scaled >= 37 -> 8.5
      scaled >= 35 -> 8.0
      scaled >= 33 -> 7.5
      scaled >= 30 -> 7.0
      scaled >= 26 -> 6.5
      scaled >= 23 -> 6.0
      scaled >= 18 -> 5.5
      scaled >= 16 -> 5.0
      scaled >= 13 -> 4.5
      scaled >= 10 -> 4.0
      scaled >= 6 -> 3.5
      scaled >= 3 -> 3.0
      scaled >= 1 -> 2.5
      true -> 2.0
    end
  end
end
