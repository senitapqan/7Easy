defmodule App.GeminiApi.GeminiClient do
  @behaviour App.GeminiApi.Gemini

  defp api_key(), do: System.get_env("GEMINI_API_KEY")
  defp base_url(), do: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

  @impl true
  def generate_essay() do
    task = generate_task()

    {:ok, task}
  end

  defp generate_task() do
    prompt =
      "Generate a realistic IELTS Writing Task 2 question. Output ONLY the question. Do not include any additional text or explanations"

    params = %{contents: [%{parts: [%{text: prompt}]}]}

    with {:ok, json} <- post(base_url(), params) do
      App.GeminiApi.GeminiParser.parse_essay_task(json)
    end
  end

  @impl true
  def mark_essay(essay, question) do
    prompt = """
    Evaluate the following IELTS essay based on the question: #{question}.
    And never answer like "N/A" or "No feedback" and so on.

    Also write your own essay based on this question and my essay. Try to improve my essay.
    please give score really strictly for my essay. You can easily give 2.0 or 3.0 for my essay.
    Also consider that minimum count of words in my essay needs to be 250.

    Give answer only in this format. Doesn't matter if I didn't send you any logical essay.
    Format:
    Score: $$$[Overall Score]$$$
    Grammar: [Feedback on grammar]
    Vocabulary: [Feedback on vocabulary]
    Structure: [Feedback on structure]
    Overall Feedback: [General feedback]
    AI Essay: ***[Your own essay].
    Output ONLY the structured feedback. Do not include any additional text or explanations.
    Essay: #{essay}
    """

    params = %{contents: [%{parts: [%{text: prompt}]}]}

    with {:ok, json} <- post(base_url(), params) do
      App.GeminiApi.GeminiParser.parse_essay_mark(json)
    end
  end

  def post(url, params), do: request(:post, url, params)

  defp request(method, url, params) do
    url_with_key = "#{url}?key=#{api_key()}"

    req()
    |> Req.request(method: method, url: url_with_key, json: params)
    |> case do
      {:ok, %Req.Response{status: 200, body: json}} ->
        {:ok, json}

      {:ok, response} ->
        IO.inspect(response, label: "RESPONSE")
        {:error, :unknown_response}

      {:error, error} ->
        IO.inspect(error, label: "ERROR")
        {:error, :unknown_error}
    end
  end

  defp req() do
    Req.new(
      json: true,
      receive_timeout: 60_000
    )
  end
end
