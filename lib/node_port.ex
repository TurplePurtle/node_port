defmodule NodePort do
  def start_pool(args) do
    pool_name = Keyword.fetch!(args, :name)
    command = Keyword.fetch!(args, :command)
    poolboy_config = [
      name: {:local, pool_name},
      worker_module: NodePort.Worker,
      size: Keyword.get(args, :size, 2),
      max_overflow: Keyword.get(args, :max_overflow, 2),
    ]
    children = [
      :poolboy.child_spec(pool_name, poolboy_config, command)
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def stop_pool(pid) when is_pid(pid) do
    Supervisor.stop(pid)
  end

  def request(pool_name, data) do
    callback = fn pid -> NodePort.Worker.request(pid, data) end
    :poolboy.transaction(pool_name, callback, 5000)
  end

  def request_async(pool_name, data) do
    Task.async(fn -> request(pool_name, data) end)
  end

  def request_await(task) do
    Task.await(task)
  end
end
