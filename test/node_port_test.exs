defmodule NodePortTest do
  use ExUnit.Case
  doctest NodePort, async: true

  setup context do
    pool_name = :test_pool
    options = [
      name: pool_name,
      command: "node js/example.js",
      size: 5,
      max_overflow: 5,
    ]
    {:ok, pid} = NodePort.start_pool(options)
    {:ok, pid: pid, pool_name: pool_name}
  end

  test "Pool starts and stops", %{pid: pid} do
    assert Process.alive? pid
    NodePort.stop_pool(pid)
    refute Process.alive? pid
  end

  test "Sync request to node script", %{pid: pid, pool_name: pool_name} do
    response = NodePort.request(pool_name, "{\"x\": \"qwerty\"}")
    assert response == "x was qwerty"
  end

  test "Async request to node script", %{pid: pid, pool_name: pool_name} do
    request = NodePort.request_async(pool_name, "{\"x\": \"qwerty\"}")
    response = NodePort.request_await(request)
    assert response == "x was qwerty"
  end
end
