defmodule NodePort do
  def start_link(args) do
    start_pool(args)
  end

  def start_pool(args) do
    pool_name = Keyword.fetch!(args, :name)
    command = Keyword.fetch!(args, :command)
    use_stdio = Keyword.get(args, :use_stdio, true)

    poolboy_config = [
      name: {:local, pool_name},
      worker_module: NodePort.Worker,
      size: Keyword.get(args, :size, 2),
      max_overflow: Keyword.get(args, :max_overflow, 2),
    ]

    children = [
      :poolboy.child_spec(pool_name, poolboy_config, {command, use_stdio})
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def stop_pool(pid) when is_pid(pid) do
    Supervisor.stop(pid)
  end

  def request(pool_name, data, timeout \\ 5000) do
    callback = fn pid -> NodePort.Worker.request(pid, data) end
    :poolboy.transaction(pool_name, callback, timeout)
  end

  def request_async(pool_name, data, timeout \\ 5000) do
    Task.async(fn -> request(pool_name, data, timeout) end)
  end

  def request_await(task) do
    Task.await(task)
  end
end
