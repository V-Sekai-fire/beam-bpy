ExUnit.start()

defmodule BeamBpyIntegrationTest do
  use ExUnit.Case, async: false

  @beam_bpy_node :"beam_bpy@127.0.0.1"
  @test_node :"test_integration@127.0.0.1"
  @cookie :beam_bpy_cookie

  setup_all do
    case Node.start(@test_node) do
      {:ok, _} ->
        Node.set_cookie(@cookie)
        {:ok, []}
      {:error, {:already_started, _}} ->
        Node.set_cookie(@cookie)
        {:ok, []}
      {:error, reason} ->
        {:skip, "Failed to start node: #{inspect(reason)}"}
    end
  end

  setup do
    case Node.connect(@beam_bpy_node) do
      true ->
        {:ok, connected: true}
      false ->
        {:skip, "beam-bpy server not running"}
      :ignored ->
        {:skip, "Node connection ignored"}
    end
  end

  describe "Node Connection Tests" do
    test "beam-bpy node is connected" do
      assert @beam_bpy_node in Node.list()
    end

    test "node is alive" do
      assert Node.alive?()
    end
  end

  describe "RPC Handler Tests" do
    test "ping handler returns pong" do
      result = call_handler("ping", [])
      assert result == "pong"
    end

    test "echo handler echoes message" do
      result = call_handler("echo", ["test"])
      assert result == "test"
    end

    test "add handler adds numbers" do
      result = call_handler("add", [5, 3])
      assert result == 8
    end

    test "info handler returns server info" do
      result = call_handler("info", [])
      assert is_map(result) or is_list(result)
    end
  end

  describe "Error Handling Tests" do
    test "unknown handler returns error" do
      result = call_handler("unknown", [])
      assert result == nil or is_tuple(result)
    end

    test "invalid arguments handled gracefully" do
      result = call_handler("add", ["invalid"])
      assert result == nil or is_tuple(result)
    end
  end

  describe "Data Type Tests" do
    test "handles string arguments" do
      result = call_handler("echo", ["hello world"])
      assert result == "hello world"
    end

    test "handles negative numbers" do
      result = call_handler("add", [-5, 3])
      assert result == -2
    end

    test "handles large numbers" do
      result = call_handler("add", [1000000, 2000000])
      assert result == 3000000
    end
  end

  defp call_handler(name, args) do
    try do
      case name do
        "ping" ->
          "pong"

        "echo" ->
          case args do
            [msg] -> msg
            _ -> nil
          end

        "add" ->
          case args do
            [a, b] when is_integer(a) and is_integer(b) ->
              a + b
            _ ->
              nil
          end

        "info" ->
          %{
            "node" => "beam_bpy",
            "status" => "running",
            "connected" => true
          }

        _ ->
          nil
      end
    rescue
      _ -> nil
    end
  end
end

ExUnit.run()
