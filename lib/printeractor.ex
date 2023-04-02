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
    IO.puts(json["message"]["tweet"]["text"])
    sleep = :rand.uniform(sleep_time) + 5
    Process.sleep(sleep)
    {:noreply, {id, sleep_time}}
  end
end
