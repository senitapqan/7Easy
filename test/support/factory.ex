defmodule App.Factory do
  use ExMachina.Ecto, repo: App.Repo

  alias App.Schemas.Listening
  alias App.Schemas.Question
  alias App.Schemas.Reading
  alias App.Schemas.User
  alias App.Schemas.Writing

  defdelegate sequence(name), to: ExMachina

  def user_factory do
    %User{
      email: sequence(:email, &"user-#{&1}@example.com"),
      password: "password123",
      current_score: 5.0
    }
  end

  def reading_test_factory do
    %Reading{
      question_count: 1,
      titles: ["Title 1"],
      texts: ["GREAT BRITAIN\n\nLondon is the capital of Great Britain"]
    }
  end

  def question_factory() do
    %Question{
      question: "What is the capital of Great Britain?",
      answers: ["London", "Paris", "Berlin", "Madrid"],
      correct_answer: "London",
      part: 1
    }
  end
end
