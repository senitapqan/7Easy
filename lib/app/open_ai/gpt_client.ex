defmodule App.OpenAi.GptClient do
  @behaviour App.OpenAi.Gpt
  @moduledoc """
  Модуль для работы с OpenAI для задач IELTS Writing и Speaking через Req.
  """
  alias App.OpenAi.GptParser
  alias App.Schemas.Writing
  alias App.Schemas.WritingResult

  defp api_key, do: System.get_env("OPENAI_API_KEY")
  defp model, do: "gpt-4o"
  defp url, do: "https://api.openai.com/v1/chat/completions"

  def req() do
    Req.new(
      base_url: url(),
      headers: [
        {"Authorization", "Bearer #{api_key()}"},
        {"Content-Type", "application/json"}
      ],
      json: true
    )
  end

  @impl true
  def generate_essay() do
    prompt = """
    Generate a realistic IELTS Writing Task 2 question. Output ONLY the question. Do not include any additional text or explanations.
    """

    body = build_body(prompt)

    with {:ok, json} <- post(body),
         {:ok, %Writing{} = writing} <- GptParser.parse_essay_task(json) do
      {:ok, writing}
    end
  end

  @impl true
  def mark_essay(essay, question) do
    prompt = """
    You are an IELTS Writing examiner.

    Evaluate the following essay based on the question: #{question}.

    Output STRICTLY in this JSON format:

    {
      "score": number,               // Overall Band Score (0.0 - 9.0)
      "grammar": string,              // Feedback about grammar
      "vocabulary": string,           // Feedback about vocabulary
      "structure": string,            // Feedback about structure
      "overall_feedback": string,     // General overall feedback
      "ai_essay": string              // Your own improved essay
    }

    - DO NOT include any explanations or extra text.
    - DO NOT write anything outside JSON.
    - Even if the essay is very bad, always return valid JSON.

    Essay: #{essay}
    """

    body = build_body(prompt)

    with {:ok, json} <- post(body),
         {:ok, %WritingResult{} = result} <- GptParser.parse_essay_mark(json) do
      {:ok, result}
    end
  end

  @impl true
  def mark_speaking_test(answers) do
    prompt = """
    You are an IELTS Speaking examiner.

    The user provided answers to several questions. Evaluate the user's speaking exam performance based on:
    - Fluency and Coherence
    - Lexical Resource
    - Grammatical Range and Accuracy

    Please return the evaluation strictly in the following JSON format:

    {
      "score": number,     // Overall Band Score (0.0 - 9.0)
      "strengths": string,              // Feedback about strengths
      "areas_for_improvement": string,  // Feedback about areas for improvement
      "recommendations": string         // Your own recommendations about answers
    }

    Candidate's Answers:
    #{format_content(answers)}
    """

    body = build_body(prompt)

    with {:ok, json} <- post(body),
         {:ok, result} <- GptParser.parse_speaking_mark(json) do
      {:ok, result}
    end
  end

  @impl true
  def generate_speaking_question(content) do
    prompt = """
    You are an IELTS Speaking examiner.

    Based on the candidate's answers below, generate exactly 2 relevant follow-up questions that logically continue the conversation, as in IELTS Speaking Part 3.

    Return the result strictly in JSON format like this:

    {
      "follow_ups": [
        "First follow-up question here",
        "Second follow-up question here"
      ]
    }

    Candidate's Answers:
    #{format_content(content)}
    """

    body = build_body(prompt)

    with {:ok, json} <- post(body),
         {:ok, result} <- GptParser.parse_speaking_question(json) do
      {:ok, result}
    end
  end

  defp format_content(content) do
    Enum.map_join(content, "\n\n", fn %{question: question, answer: answer} ->
      "Q: #{question}\nA: #{answer}"
    end)
  end

  # =========================
  # Вспомогательные функции
  # =========================

  defp build_body(prompt, opts \\ %{}) do
    base = %{
      model: model(),
      temperature: 0.0,
      messages: [%{role: "user", content: prompt}]
    }

    Map.merge(base, opts)
  end

  defp post(body) do
    case Req.post(req(), json: body) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: status, body: body}} -> {:error, {:http_error, "HTTP error #{status}: #{inspect(body)}"}}
      {:error, error} -> {:error, {:http_error, "HTTP error: #{inspect(error)}"}}
    end
  end
end
