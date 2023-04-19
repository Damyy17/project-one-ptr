# defmodule WorkerManager do
#   use GenServer

#   def start_link(args) do
#     IO.puts("Worker Manager is starting!")
#     GenServer.start_link(__MODULE__, args, name: __MODULE__)
#   end

#   def init(args) do
#     {:ok, %{args | min_workers: 1, max_workers: 10, threshold: 100, task_count: 0}}
#   end

#   def handle_info({:new_task}, state) do
#     add_task_count = state.task_count + 1
#     IO.puts("Received new task count: #{state.task_count}")
#     new_state = %{state | task_count: add_task_count}
#     {:noreply, new_state}
#   end

#   def handle_info({:delete_task}, state) do
#     delete_task_count = state.task_count - 1
#     new_state = %{state | task_count: _task_count}
#     {:noreply, new_state}
#   end

#   # def handle_info({:new_task}, state) do
#   #   IO.puts("Received new task count: #{state.task_count}")

#   #   # new_state = adjust_worker_count(task_count, state)
#   #   {:noreply, state}
#   # end

#   defp adjust_worker_count(task_count, state) do
#     cond do
#       task_count > state.threshold and state.num_workers < state.max_workers ->
#         new_num_workers = min(state.num_workers + 1, state.max_workers)
#         IO.puts("Increasing worker count to #{new_num_workers}")
#         # Supervisor.start_child(PrinterPool, {PrinterActor, "printer#{new_num_workers}", 50})
#         Supervisor.start_child(PrinterPool, %{
#           id: :"printer#{new_num_workers}",
#           start: {Printer, :start_link, [:"printer#{new_num_workers}", 5, 50]}
#         })
#         %{state | num_workers: new_num_workers}

#       task_count < state.threshold and state.num_workers > state.min_workers ->
#         new_num_workers = max(state.num_workers - 1, state.min_workers)
#         IO.puts("Decreasing worker count to #{new_num_workers}")
#         # printer_name = "printer#{new_num_workers + 1}"
#         case Supervisor.which_children(PrinterPool) do
#           [{_, worker, _, _} | _] ->
#             Supervisor.terminate_child(PrinterPool, worker)
#             # Supervisor.start_child(PrinterPool, {PrinterActor, printer_name, 50})
#             Supervisor.start_child(PrinterPool, %{
#               id: :"printer#{new_num_workers}",
#               start: {Printer, :start_link, [:"printer#{new_num_workers + 1}", 5, 50]}
#             })
#           _ ->
#             IO.puts("Cannot reduce worker count below minimum")
#         end
#         %{state | num_workers: new_num_workers}

#       true ->
#         state
#     end
#   end
# end
