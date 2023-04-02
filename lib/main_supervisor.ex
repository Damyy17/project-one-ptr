defmodule MainSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {PrinterPool, :ok},
      {LoadBalancer, 3},
      {ReaderActor, "localhost:4000/tweets/1"},
      {Htag, :ok}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
