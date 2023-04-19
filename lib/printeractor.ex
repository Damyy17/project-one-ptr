defmodule PrinterActor do
  use GenServer

  def start_link(id, sleep_time) do
    IO.puts("Actor #{id} is starting!")
    GenServer.start_link(__MODULE__, {id, sleep_time}, name: id)
  end

  def init({id, sleep_time}) do
    {:ok, {id, sleep_time}}
  end

  def handle_info(:kill_msg, {id, sleep_time}) do
    IO.puts("Actor #{id} is killed!")
    exit(:kill_msg)
    {:noreply, {id, sleep_time}}
  end

  def handle_info(json, {id, sleep_time}) do
    tweet = json["message"]["tweet"]["text"]
    censoredTweet = censorWord(tweet)
    IO.puts(censoredTweet)

    sentiment_score = sentimentScore(tweet)
    enagement_ratio = engagementRatio(json)
    IO.puts("Emotion value: #{sentiment_score}, Engagement Ratio: #{enagement_ratio}")

    sleep = :rand.uniform(sleep_time) + 5
    Process.sleep(sleep)
    # pid = Process.whereis(WorkerManager)
    # send(pid, {:delete_task})
    {:noreply, {id, sleep_time}}
  end

  #bad words impl
  def censorWord(tweet) do
    json_bad_words = File.read!("lib/bad_words.json")
    bad_words = Poison.decode!(json_bad_words)

    splitTweet = String.split(tweet, " ");

    censored_words = Enum.map(splitTweet, fn word ->
      if Enum.member?(bad_words, word) do
        String.duplicate("*", String.length(word))
      else
        word
      end
    end)
    Enum.join(censored_words, " ")
  end

  #sentiment score impl
  def sentimentScore(tweet) do
    emotion_words_values = HTTPoison.get!("http://localhost:4000/emotion_values").body
    emotion_words_values = emotion_words_values
      |> String.trim()
      |> String.split("\r\n")
      |> Enum.map(fn x -> String.split(x, "\t")
    end)

    splitTweet = String.split(tweet, " ")

    score = Enum.reduce(splitTweet, 0, fn word, acc ->
      emotion_word = emotion_words_values |> Enum.find(fn [w, _v] -> String.contains?(word, w) end)
      if emotion_word != nil do
        acc + String.to_integer(Enum.at(emotion_word, 1))
      else
        acc
      end
    end)

    score
  end

  #engagement ratio
  def engagementRatio(json) do
    favourites = json["message"]["tweet"]["retweeted_status"]["favorite_count"] || 0
    retweets = json["message"]["tweet"]["retweeted_status"]["retweet_count"] || 0
    followers = json["message"]["tweet"]["user"]["followers_count"]

    engage_ratio =
      if followers == 0 do
        0
      else
        (favourites + retweets) / followers
      end

    engage_ratio
  end


end
