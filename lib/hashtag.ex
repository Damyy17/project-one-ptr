defmodule Htag do
  use GenServer

  def start_link(state \\ %{}) do
    IO.puts("Htag Actor is starting!")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_args) do
    start_timer()
    {:ok, %{hashtags: []}}
  end

  def handle_info(:print_most_popular_hashtag, state) do
    print_most_popular_hashtag(state)
    {:noreply, %{hashtags: []}}
  end

  def handle_info(json, state) do
    hashtags = extract_hashtags(json["message"]["tweet"]["entities"])
    {:noreply, %{state | hashtags: state.hashtags ++ hashtags}}
  end

  def extract_hashtags(format) do
    hashtags = format["hashtags"]
    Enum.map(hashtags, fn %{ "text" => text } ->
      text
    end)
  end

  defp print_most_popular_hashtag(%{hashtags: hashtag_list}) do
    hashtag_map = Enum.frequencies(hashtag_list)
    sorted_hashtags = Enum.sort_by(hashtag_map, & &1 |> elem(1)) |> Enum.reverse()
    most_common_hashtag = List.first(sorted_hashtags) |> elem(0)
    # IO.puts("Most popular hashtag: #{most_common_hashtag}")
    start_timer()
  end

  def start_timer() do
    Process.send_after(self(), :print_most_popular_hashtag, 5000)
  end
end
