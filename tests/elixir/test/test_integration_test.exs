ExUnit.start()

Code.require_file("test_helpers.exs", __DIR__)

defmodule BeamBpyIntegrationTest do
  @moduledoc """
  Integration Tests organized by Dependency Hierarchy

  Level 1: Infrastructure/Setup (setup_all, setup)
  Level 2: Core Handler Tests
  Level 3: Advanced Handler Tests  
  Level 4: Error Handling Tests
  Level 5: Data Type & Edge Case Tests
  """

  use ExUnit.Case, async: false

  @beam_bpy_node :"beam_bpy@127.0.0.1"
  @test_node :"test_integration@127.0.0.1"
  @cookie :beam_bpy_cookie

  # ============================================================================
  # LEVEL 1: Infrastructure/Setup
  # ============================================================================

  setup_all do
    case BeamBpyTestHelpers.setup_test_node(@test_node, @cookie) do
      {:ok, _} ->
        {:ok, []}

      {:error, {:already_started, _}} ->
        {:ok, []}

      {:error, reason} ->
        {:skip, "Failed to start node: #{inspect(reason)}"}
    end
  end

  setup do
    case BeamBpyTestHelpers.connect_to_beam_bpy(@beam_bpy_node) do
      true ->
        {:ok, connected: true}

      false ->
        {:skip, "beam-bpy server not running"}

      :ignored ->
        {:skip, "Node connection ignored"}
    end
  end

  # ============================================================================
  # LEVEL 1: Node Connection Tests
  # ============================================================================

  describe "Level 1: Infrastructure Tests" do
    test "beam-bpy node is connected" do
      assert @beam_bpy_node in Node.list()
    end

    test "node is alive" do
      assert Node.alive?()
    end

    test "node has valid cookie" do
      assert Node.get_cookie() == @cookie
    end
  end

  # ============================================================================
  # LEVEL 2: Core Handler Tests (Basic Functionality)
  # ============================================================================

  describe "Level 2: Core Handler Tests" do
    test "ping handler returns pong" do
      assert BeamBpyTestHelpers.test_ping_handler() == true
    end

    test "echo handler echoes message" do
      assert BeamBpyTestHelpers.test_echo_handler("test") == true
    end

    test "add handler adds positive numbers" do
      assert BeamBpyTestHelpers.test_add_handler(5, 3) == true
    end
  end

  # ============================================================================
  # LEVEL 3: Advanced Handler Tests
  # ============================================================================

  describe "Level 3: Advanced Handler Tests" do
    test "info handler returns server info" do
      assert BeamBpyTestHelpers.test_info_handler() == true
    end
  end

  # ============================================================================
  # LEVEL 4: Error Handling Tests
  # ============================================================================

  describe "Level 4: Error Handling Tests" do
    test "unknown handler returns error gracefully" do
      assert BeamBpyTestHelpers.test_unknown_handler() == true
    end

    test "invalid arguments handled gracefully" do
      assert BeamBpyTestHelpers.test_invalid_arguments() == true
    end
  end

  # ============================================================================
  # LEVEL 5: Data Type & Edge Case Tests
  # ============================================================================

  describe "Level 5: Data Type & Edge Case Tests" do
    test "handles string arguments" do
      assert BeamBpyTestHelpers.test_echo_handler("hello world") == true
    end

    test "handles negative numbers" do
      assert BeamBpyTestHelpers.test_negative_numbers() == true
    end

    test "handles large numbers" do
      assert BeamBpyTestHelpers.test_large_numbers() == true
    end

    test "echo handler with multiple test strings" do
      assert BeamBpyTestHelpers.test_echo_handler("test_string_123") == true
    end

    test "add handler with mixed positive and negative" do
      assert BeamBpyTestHelpers.test_add_handler(-10, 15) == true
    end
  end

  # ============================================================================
  # Integration Scenario Tests
  # ============================================================================

  describe "Integration Scenarios" do
    test "handler sequence: ping then echo" do
      ping_ok = BeamBpyTestHelpers.test_ping_handler()
      echo_ok = BeamBpyTestHelpers.test_echo_handler("sequence_test")
      assert ping_ok and echo_ok
    end

    test "handler sequence: multiple adds" do
      add1 = BeamBpyTestHelpers.test_add_handler(1, 2)
      add2 = BeamBpyTestHelpers.test_add_handler(10, 20)
      add3 = BeamBpyTestHelpers.test_add_handler(-5, 5)
      assert add1 and add2 and add3
    end

    test "all core handlers work together" do
      ping_ok = BeamBpyTestHelpers.test_ping_handler()
      echo_ok = BeamBpyTestHelpers.test_echo_handler("integration")
      add_ok = BeamBpyTestHelpers.test_add_handler(7, 8)
      info_ok = BeamBpyTestHelpers.test_info_handler()
      assert ping_ok and echo_ok and add_ok and info_ok
    end

    test "error handling doesn't crash system" do
      unknown_ok = BeamBpyTestHelpers.test_unknown_handler()
      invalid_ok = BeamBpyTestHelpers.test_invalid_arguments()
      # System should still be responsive after errors
      ping_ok = BeamBpyTestHelpers.test_ping_handler()
      assert unknown_ok and invalid_ok and ping_ok
    end
  end
end

ExUnit.run()
