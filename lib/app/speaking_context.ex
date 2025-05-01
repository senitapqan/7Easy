defmodule App.SpeakingContext do
  alias App.Repo
  alias App.Schemas.Speaking
  alias App.Schemas.SpeakingQuestion
  alias App.Schemas.SpeakingResult
  alias App.Schemas.SpeakingTestQuestion
  alias App.Speaking.ContinueSpeaking
  alias App.Speaking.History
  alias App.Speaking.SaveSpeaking
  alias App.Speaking.StartSpeaking

  import Ecto.Changeset

  def create_speaking_question!(attrs) do
    %SpeakingQuestion{}
    |> change(attrs)
    |> Repo.insert!()
  end

  def create_speaking_test!(attrs) do
    %Speaking{}
    |> change(attrs)
    |> Repo.insert!()
  end

  def create_speaking_result!(attrs) do
    %SpeakingResult{}
    |> change(attrs)
    |> Repo.insert!()
  end

  def update_speaking!(speaking, attrs) do
    speaking
    |> change(attrs)
    |> Repo.update!()
  end

  def update_speaking_result!(speaking_result, attrs) do
    speaking_result
    |> change(attrs)
    |> Repo.update!()
  end

  def get_speaking_question!(question_id) do
    SpeakingQuestion
    |> Repo.get!(question_id)
  end

  def get_speaking_test(speaking_id, opts \\ []) do
    {preload, opts} = Keyword.pop(opts, :preload, nil)
    [] = opts

    Speaking
    |> Repo.get(speaking_id)
    |> case do
      nil -> nil
      result when is_nil(preload) -> result
      result -> Repo.preload(result, preload)
    end
  end

  def get_speaking_result(speaking_result_id, opts \\ []) do
    {preload, opts} = Keyword.pop(opts, :preload, nil)
    [] = opts

    SpeakingResult
    |> Repo.get(speaking_result_id)
    |> case do
      nil -> nil
      result when is_nil(preload) -> result
      result -> Repo.preload(result, preload)
    end
  end

  def get_speaking_result_by_speaking_id(speaking_id, opts \\ []) do
    {preload, opts} = Keyword.pop(opts, :preload, nil)
    [] = opts

    SpeakingResult
    |> Repo.get_by(speaking_id: speaking_id)
    |> case do
      nil -> nil
      result when is_nil(preload) -> result
      result -> Repo.preload(result, preload)
    end
  end

  def insert_questions_to_speaking(speaking_id, questions) do
    questions
    |> Enum.map(fn question ->
      %{
        speaking_id: speaking_id,
        speaking_question_id: question.id,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    end)
    |> then(&Repo.insert_all(SpeakingTestQuestion, &1))
  end

  def start_speaking(user_id), do: StartSpeaking.start_speaking(user_id)

  def continue_speaking(user_id, speaking_id, content),
    do: ContinueSpeaking.continue_speaking(user_id, speaking_id, content)

  def save_speaking(user_id, speaking_id, content), do: SaveSpeaking.save_speaking(user_id, speaking_id, content)
  def history(user_id, result_id), do: History.history(user_id, result_id)
end
