defmodule App.Speaking.StartSpeaking do
  alias App.Parser.SpeakingParser
  alias App.Repo
  alias App.Schemas.SpeakingQuestion
  alias App.SpeakingContext

  import Ecto.Query

  def start_speaking(user_id) do
    speaking =
      SpeakingContext.create_speaking_test!(%{
        status: "started",
        user_id: user_id
      })

    questions_part_1 = get_random_questions_first_part()
    questions_part_2 = get_random_questions_second_part()

    SpeakingContext.insert_questions_to_speaking(speaking.id, [questions_part_2 | questions_part_1])
    speaking = SpeakingContext.get_speaking_test(speaking.id, preload: [:speaking_questions, :user])

    SpeakingContext.update_speaking!(speaking, %{
      question_count: length(questions_part_1) + 1
    })

    {:ok, SpeakingParser.parse_speaking_test(speaking, part_3: false)}
  end

  defp get_random_questions_first_part do
    SpeakingQuestion
    |> where([q], q.part == 1)
    |> order_by(fragment("RANDOM()"))
    |> limit(2)
    |> Repo.all()
  end

  defp get_random_questions_second_part do
    SpeakingQuestion
    |> where([q], q.part == 2)
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
  end
end
