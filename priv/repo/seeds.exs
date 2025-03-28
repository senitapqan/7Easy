alias App.Repo
alias App.Schemas.Question
alias App.Schemas.Reading
alias App.Schemas.User

defmodule App.Seeds do
  alias App.Schemas.Listening

  def run do
    load_users()
    load_reading_tests()
    load_reading_questions()
    load_listening_tests()
    load_listening_questions()
  end

  defp load_users do
    File.read!("priv/repo/seeds/users.json")
    |> Jason.decode!()
    |> insert_users()
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

  defp load_listening_tests do
    File.read!("priv/repo/seeds/listening_tests.json")
    |> Jason.decode!()
    |> insert_listening_tests()
  end

  defp load_listening_questions do
    File.read!("priv/repo/seeds/listening_questions.json")
    |> Jason.decode!()
    |> insert_listening_questions()
  end

  defp insert_users(users) do
    Enum.each(users, fn user ->
      unless Repo.get_by(User, email: user["email"]) do
        %User{
          email: user["email"],
          password: Bcrypt.hash_pwd_salt(user["password"]),
          avg_listening_score: user["avg_listening_score"],
          avg_reading_score: user["avg_reading_score"],
          avg_writing_score: user["avg_writing_score"],
          avg_speaking_score: user["avg_speaking_score"]
        }
        |> Repo.insert!()
      end
    end)
  end

  defp insert_reading_questions(questions) do
    Enum.each(questions, fn question ->
      unless Repo.get_by(Question,
               question: question["question"],
               part: question["part"],
               test_type: question["test_type"],
               test_id: question["test_id"]
             ) do
        %Question{
          question: question["question"],
          answers: question["answers"],
          correct_answer: question["correct_answer"],
          part: question["part"],
          test_type: question["test_type"],
          test_id: question["test_id"]
        }
        |> Repo.insert!()
      end
    end)
  end

  defp insert_reading_tests(tests) do
    Enum.each(tests, fn test ->
      unless Repo.get_by(Reading, titles: test["titles"]) do
        %Reading{
          titles: test["titles"],
          texts: test["texts"],
          question_count: test["question_count"]
        }
        |> Repo.insert!()
      end
    end)
  end

  defp insert_listening_tests(tests) do
    Enum.each(tests, fn test ->
      unless Repo.get_by(Listening, titles: test["titles"]) do
        %Listening{
          titles: test["titles"],
          audio_urls: test["audio_urls"],
          question_count: test["question_count"]
        }
        |> Repo.insert!()
      end
    end)
  end

  defp insert_listening_questions(questions) do
    Enum.each(questions, fn question ->
      unless Repo.get_by(Question,
               question: question["question"],
               part: question["part"],
               test_type: question["test_type"],
               test_id: question["test_id"]
             ) do
        %Question{
          question: question["question"],
          answers: question["answers"],
          correct_answer: question["correct_answer"],
          part: question["part"],
          test_type: question["test_type"],
          test_id: question["test_id"]
        }
        |> Repo.insert!()
      end
    end)
  end
end

App.Seeds.run()
