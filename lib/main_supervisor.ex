defmodule MainSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {PrinterPool, :ok},
      {LoadBalancer, 3},
      # {Htag, :ok},
      {ReaderActor, "localhost:4000/tweets/1"},
      # {
      #   WorkerManager,
      #   %{min_workers: 1, max_workers: 10, threshold: 100, task_count: 0}
      # }
      # %{
      #   start: {ReaderActor, :start_link, "localhost:4000/tweets/1"}
      # },
      # %{
      #   start: {ReaderActor, :start_link, "localhost:4000/tweets/2"}
      # }
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
