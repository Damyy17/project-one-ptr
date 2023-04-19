defmodule ReaderActor do
  use GenServer

  def start_link(url) do
    IO.puts("Reader Actor is starting!")
    GenServer.start_link(__MODULE__, url, name: __MODULE__)
  end

  def init(url) do
    options = [
      stream_to: self(),
      recv_timeout: :infinity
    ]
    HTTPoison.get(url, [], options)
    {:ok, nil}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: ""}, url) do
    options = [
      stream_to: self(),
      recv_timeout: :infinity
    ]
    HTTPoison.get(url, [], options)
    {:noreply, url}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: "event: \"message\"\n\ndata: {\"message\": panic}\n\n"}, url) do
    send(LoadBalancer, :kill_msg)
    {:noreply, url}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: data}, url) do
    case Regex.run(~r/data: ({.+})\n\n$/, data) do
      nil -> {:noreply, url}
      [_, json] ->
        case Poison.decode(json) do
          {:ok, result} ->
            send(LoadBalancer, result)
            # send(Htag, result)
            # worker_manager_pid = Process.whereis(WorkerManager)
            # send(worker_manager_pid, {:new_task})
            {:noreply, url}
          _ -> {:noreply, url}
        end
    end
  end

  def handle_info(_, url) do
    {:noreply, url}
  end
end
