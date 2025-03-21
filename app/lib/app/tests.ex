defmodule App.Tests do

  alias App.Parser.WritingParser
  alias App.Parser.ReadingParser
  alias App.Parser.ListeningParser
  alias App.GeminiApi.Gemini
  alias App.Schemas.ReadingResult
  alias App.Schemas.ListeningResult
  alias App.Repo
  alias App.Schemas.Writing
  alias App.Schemas.Listening
  alias App.Schemas.Reading
  alias App.Schemas.Question

  require Ecto.Query
  import Ecto.Changeset

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

  def pull_reading_test(user_id) do
    Reading
    |> Repo.all()
    |> Enum.filter(fn test ->
      not Repo.exists?(
        Ecto.Query.from(
          r in ReadingResult,
          where: r.user_id == ^user_id and r.reading_id == ^test.id
        )
      )
    end)
    |> Enum.random()
    |> Repo.preload(:questions)
    |> ReadingParser.parse_test()
  end

  def pull_listening_test(user_id) do
    Listening
    |> Repo.all()
    |> Enum.filter(fn test ->
      not Repo.exists?(Ecto.Query.from(r in ListeningResult, where: r.user_id == ^user_id and r.listening_id == ^test.id))
    end)
    |> Enum.random()
    |> Repo.preload(:questions)
    |> ListeningParser.parse_test()
  end

  def pull_writing_test() do
    {:ok, writing} = Gemini.generate_essay()

    writing
    |> Repo.insert!()
    |> WritingParser.parse_test()
  end

  def save_writing_test(user_id, writing_id, essay) do
    writing = get_writing_test(writing_id)
    question = writing.task

    case Gemini.mark_essay(essay, question) do
      {:ok, writing_result} ->
        writing_result =
          writing_result
          |> Map.put(:user_id, user_id)
          |> Map.put(:writing_id, writing_id)
          |> Map.put(:user_essay, essay)
          |> Repo.insert!()

        WritingParser.parse_result(writing_result)

      {:error, _} ->
        {:error, "Failed to mark essay"}
    end

  end

  def save_listening_test(user_id, listening_id, answers) do
    listening = get_listening_test(listening_id)
    {correct_count, _incorrect_count, score, content} = calculate_score(listening, answers)

    %ListeningResult{
      content: content,
      user_id: user_id,
      listening_id: listening_id,
      correct_count: correct_count,
      score: score
    }
    |> Repo.insert!()
  end

  def save_reading_test(user_id, reading_id, answers) do
    reading = get_reading_test(reading_id)
    {correct_count, _incorrect_count, score, content} = calculate_score(reading, answers)

    %ReadingResult{
      content: content,
      user_id: user_id,
      reading_id: reading_id,
      correct_count: correct_count,
      score: score
    }
    |> Repo.insert!()
  end

  defp calculate_score(test, answers) do
    {correct_count, content} =
      Enum.reduce(answers, {0, []}, fn %{question_id: question_id, answer: answer}, acc ->
        {correct_count, content} = acc
        question = get_question(question_id)

        if question.correct_answer == answer do
          {correct_count + 1, [%{
            question_id: question_id,
            correct_answer: question.correct_answer,
            chosen_answer: answer,
            is_correct: true
          } | content]}
        else
          {correct_count, [%{
            question_id: question_id,
            correct_answer: question.correct_answer,
            chosen_answer: answer,
            is_correct: false
          } | content]}
        end
      end)

    incorrect_count = test.question_count - correct_count
    score = correct_count * 100 / test.question_count

    {correct_count, incorrect_count, score, content}
  end
end
