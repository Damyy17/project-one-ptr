defmodule LoadBalancer do
  use GenServer

  def start_link(wrk_id) do
    IO.puts("Load Balancer is starting!")
    GenServer.start_link(__MODULE__, wrk_id, name: __MODULE__)
  end

  def init(wrk_id) do
    {:ok, {0, wrk_id}}
  end

  def handle_info(message, {curr, wrk_id}) do
    id = :"printer#{rem(curr + 1, wrk_id)}"
    # worker_manager_pid = Process.whereis(WorkerManager)
    case Process.whereis(id) do
      nil -> {:noreply, {rem(curr + 1, wrk_id), wrk_id}}
      pid ->
        send(pid, message)
        # send(worker_manager_pid, {:new_task})
        {:noreply, {rem(curr + 1, wrk_id), wrk_id}}
    end
  end

end
