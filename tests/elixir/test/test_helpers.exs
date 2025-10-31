#!/usr/bin/env elixir
"""
Shared test helpers for beam-bpy Elixir tests
Provides common utilities following dependency hierarchy
"""

defmodule BeamBpyTestHelpers do
  @moduledoc """
  Shared helper functions for beam-bpy tests organized by dependency hierarchy.

  Hierarchy Levels:
  1. Infrastructure - Node setup and connection management
  2. Core Handlers - Basic handler testing (ping, echo, add)
  3. Advanced Handlers - Complex handlers (info)
  4. Error Handling - Invalid inputs and edge cases
  5. Integration - End-to-end scenarios
  """

  # ============================================================================
  # Level 1: Infrastructure/Setup Functions
  # ============================================================================

  @doc """
  Initialize test node with name and cookie.
  Returns {:ok, node_name} or {:error, reason}
  """
  def setup_test_node(node_name, cookie) do
    case Node.start(node_name) do
      {:ok, _} ->
        Node.set_cookie(cookie)
        {:ok, node_name}

      {:error, {:already_started, _}} ->
        Node.set_cookie(cookie)
        {:ok, node_name}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Connect to beam-bpy server node.
  Returns true if connected, false otherwise
  """
  def connect_to_beam_bpy(target_node) do
    case Node.connect(target_node) do
      true -> true
      false -> false
      :ignored -> false
    end
  end

  @doc """
  Get current node status information
  """
  def get_node_status do
    %{
      "self" => Node.self(),
      "alive" => Node.alive?(),
      "cookie" => Node.get_cookie(),
      "connected_nodes" => Node.list()
    }
  end

  # ============================================================================
  # Level 2: Core Handler Tests (Basic Functionality)
  # ============================================================================

  @doc """
  Test ping handler - most basic handler
  Expected: returns "pong"
  """
  def test_ping_handler do
    call_handler("ping", []) == "pong"
  end

  @doc """
  Test echo handler with simple string
  Expected: echoes back the input string
  """
  def test_echo_handler(message) do
    call_handler("echo", [message]) == message
  end

  @doc """
  Test add handler with two integers
  Expected: returns sum of two numbers
  """
  def test_add_handler(a, b) do
    call_handler("add", [a, b]) == a + b
  end

  # ============================================================================
  # Level 3: Advanced Handler Tests
  # ============================================================================

  @doc """
  Test info handler - returns server information
  Expected: returns map or list with server details
  """
  def test_info_handler do
    result = call_handler("info", [])
    is_map(result) or is_list(result)
  end

  # ============================================================================
  # Level 4: Error Handling & Edge Cases
  # ============================================================================

  @doc """
  Test unknown handler graceful failure
  Expected: returns nil or error tuple
  """
  def test_unknown_handler do
    result = call_handler("unknown_handler", [])
    result == nil or is_tuple(result)
  end

  @doc """
  Test invalid arguments to handler
  Expected: returns nil or error tuple (not crash)
  """
  def test_invalid_arguments do
    result = call_handler("add", ["invalid"])
    result == nil or is_tuple(result)
  end

  @doc """
  Test add handler with negative numbers
  Expected: correctly handles negative arithmetic
  """
  def test_negative_numbers do
    call_handler("add", [-5, 3]) == -2
  end

  @doc """
  Test add handler with large numbers
  Expected: handles large integer arithmetic
  """
  def test_large_numbers do
    call_handler("add", [1_000_000, 2_000_000]) == 3_000_000
  end

  # ============================================================================
  # Level 5: Integration / Helper Functions
  # ============================================================================

  @doc """
  Mock handler call for local testing
  Simulates RPC handler behavior
  """
  def call_handler(name, args) do
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
            "version" => "0.1.0"
          }

        _ ->
          nil
      end
    rescue
      _ -> nil
    end
  end

  @doc """
  Format test result with status indicator
  """
  def format_test_result(test_name, passed?) do
    status = if passed?, do: "✓ PASS", else: "✗ FAIL"
    "Test: #{test_name}... #{status}"
  end

  @doc """
  Print test summary
  """
  def print_summary(passed, failed) do
    IO.puts("\n" <> String.duplicate("-", 60))
    IO.puts("Test Results: #{passed} passed, #{failed} failed")
    IO.puts(String.duplicate("-", 60))

    if failed == 0 do
      IO.puts("✓ ALL TESTS PASSED\n")
      0
    else
      IO.puts("✗ #{failed} TESTS FAILED\n")
      1
    end
  end
end
