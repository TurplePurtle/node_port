defmodule NodePort.Worker do
  use GenServer

  ## Client API

  def start_link(cmd) do
    GenServer.start_link(__MODULE__, cmd)
  end

  def request(pid, msg) when is_binary(msg) do
    GenServer.call(pid, msg)
  end

  ## Server Callbacks

  def init(cmd) do
    {:ok, {init_vm(cmd)}}
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

  defp init_vm(cmd) do
    Port.open({:spawn, cmd}, [:binary, {:packet, 4}])
  end
end
