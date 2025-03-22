alias App.Schemas.Question
alias App.Schemas.Reading

defmodule App.Seeds do
  alias App.Repo

  def run do
    load_reading_tests()
    load_reading_questions()
  end

  defp load_reading_tests do
    File.read!("priv/repo/seeds/reading_tests.json")
    |> Jason.decode!()
    |> insert_reading_tests()
  end

  defp load_reading_questions do
    File.read!("priv/repo/seeds/reading_questions.json")
    |> Jason.decode!()
    |> insert_reading_questions()
  end

  defp insert_reading_questions(questions) do
    Enum.each(questions, fn question ->
      %Question{
        question: question["question"],
        answers: question["answers"],
        correct_answer: question["correct_answer"],
        part: question["part"],
        test_type: question["test_type"],
        test_id: question["test_id"]
      }
      |> App.Repo.insert!()
    end)
  end

  defp insert_reading_tests(tests) do
    Enum.each(tests, fn test ->
      %Reading{
        titles: test["titles"],
        texts: test["texts"],
        question_count: test["question_count"]
      }
      |> Repo.insert!()
    end)
  end
end

App.Seeds.run()
