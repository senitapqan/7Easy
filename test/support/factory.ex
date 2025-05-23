defmodule App.Factory do
  alias App.Schemas.Speaking
  alias App.Schemas.SpeakingQuestion
  alias App.Schemas.SpeakingResult
  alias App.Schemas.SpeakingTestQuestion

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

  def speaking_test_factory do
    %Speaking{
      status: "started",
      question_count: 0,
      user_id: user_factory().id
    }
  end

  def speaking_question_factory do
    %SpeakingQuestion{
      question: "What is the capital of Great Britain?",
      part: 1,
      test_type: "speaking",
      sub_questions: []
    }
  end

  def speaking_test_question_factory do
    %SpeakingTestQuestion{
      speaking_id: speaking_test_factory().id,
      speaking_question_id: speaking_question_factory().id
    }
  end

  def speaking_result_factory do
    %SpeakingResult{
      speaking_id: speaking_test_factory().id,
      user_id: user_factory().id,
      content: [],
      score: 0,
      strengths: "",
      areas_for_improvement: "",
      recommendations: ""
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
