defmodule NodePort.Worker do
  use GenServer

  ## Client API

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def request(pid, msg) when is_binary(msg) do
    GenServer.call(pid, msg)
  end

  ## Server Callbacks

  def init({cmd, use_stdio}) do
    {:ok, {init_vm(cmd, use_stdio)}}
  end

  def handle_call(msg, _from, {port} = state) do
    Port.command(port, msg)
    result = receive do
      {^port, {:data, response}} -> response
    end
    {:reply, result, state}
  end

  def terminate(_reason, {port}) do
    Port.close(port)
  end

  defp init_vm(cmd, use_stdio) do
    opt_stdio = if use_stdio, do: :use_stdio, else: :nouse_stdio
    Port.open({:spawn, cmd}, [:binary, {:packet, 4}, opt_stdio])
  end
end
