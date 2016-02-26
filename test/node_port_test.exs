defmodule NodePortTest do
  use ExUnit.Case
  doctest NodePort, async: true

  setup do
    pool_name = :test_pool
    options = [
      name: pool_name,
      command: "node js/example.js",
      size: 5,
      max_overflow: 5,
      use_stdio: false,
    ]
    {:ok, pid} = NodePort.start_pool(options)
    {:ok, pid: pid, pool_name: pool_name}
  end

  test "Pool starts and stops", %{pid: pid} do
    assert Process.alive? pid
    NodePort.stop_pool(pid)
    refute Process.alive? pid
  end

  test "Sync request to node script", %{pool_name: pool_name} do
    response = NodePort.request(pool_name, "{\"x\": \"qwerty\"}")
    assert response == "x was qwerty"
  end

  test "Async request to node script", %{pool_name: pool_name} do
    request = NodePort.request_async(pool_name, "{\"x\": \"qwerty\"}")
    response = NodePort.request_await(request)
    assert response == "x was qwerty"
  end

  test "Long input text in request", %{pool_name: pool_name} do
    value = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    response = NodePort.request(pool_name, "{\"x\": \"#{value}\"}")
    assert response == "x was #{value}"
  end

  test "Multiple requests to node script", %{pool_name: pool_name} do
    [
      "qwerty",
      "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
      "YOLO SWAG",
    ]
    |> Enum.each(&assert(NodePort.request(pool_name, "{\"x\": \"#{&1}\"}") == "x was #{&1}"))
  end
end
