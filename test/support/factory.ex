defmodule App.Factory do
  use ExMachina.Ecto, repo: App.Repo

  alias App.Schemas.Listening
  alias App.Schemas.Question
  alias App.Schemas.Reading
  alias App.Schemas.User

  def user_factory do
    %User{
      email: sequence(:email, &"user-#{&1}@example.com"),
      password: "password123"
    }
  end

  def reading_test_factory do
    %Reading{
      question_count: 1,
      titles: ["GREAT BRITAIN"],
      texts: ["London is the capital of Great Britain"]
    }
  end

  def listening_test_factory do
    %Listening{
      question_count: 1,
      titles: ["Part 1"],
      audio_urls: ["https://example.com/audio.mp3"]
    }
  end

  def question_factory() do
    %Question{
      test_id: nil,
      test_type: nil,
      question: "What is the capital of Great Britain?",
      answers: ["London", "Paris", "Berlin", "Madrid"],
      correct_answer: "London",
      part: 1
    }
  end
end
