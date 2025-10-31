#!/usr/bin/env elixir
"""
Elixir Test Client for Beam-BPy
Tests beam-bpy CNode connection from Elixir
Organized by Dependency Hierarchy (Level 1: Infrastructure/Setup)
"""

Code.require_file("test_helpers.exs", __DIR__)

defmodule BeamBpyTest do
  @moduledoc """
  Infrastructure/Setup Tests - Level 1 of Dependency Hierarchy
  
  Tests node initialization, connection, and availability.
  These are prerequisites for all higher-level tests.
  """

  def run do
    IO.puts("=" <> String.duplicate("=", 48))
    IO.puts("Beam-BPy Elixir Test Client")
    IO.puts("Level 1: Infrastructure/Setup Tests")
    IO.puts("=" <> String.duplicate("=", 48))
    IO.puts("")

    passed = 0
    failed = 0

    # ========================================================================
    # LEVEL 1: Infrastructure/Setup Tests
    # ========================================================================
    IO.puts("LEVEL 1: Infrastructure & Setup Tests\n")

    # Test 1: Node initialization
    IO.write("Test 1: Starting Elixir node... ")

    case BeamBpyTestHelpers.setup_test_node(:"test_client@127.0.0.1", :beam_bpy_cookie) do
      {:ok, node_name} ->
        IO.puts("✓ PASS")
        IO.puts("   Node: #{node_name}")
        passed = passed + 1

      {:error, reason} ->
        IO.puts("✗ FAIL")
        IO.puts("   Reason: #{inspect(reason)}")
        failed = failed + 1
    end

    # Test 2: Node status verification
    IO.write("Test 2: Node alive and active... ")

    status = BeamBpyTestHelpers.get_node_status()

    if status["alive"] do
      IO.puts("✓ PASS")
      IO.puts("   Self: #{status["self"]}")
      IO.puts("   Cookie: #{status["cookie"]}")
      passed = passed + 1
    else
      IO.puts("✗ FAIL")
      IO.puts("   Node not alive")
      failed = failed + 1
    end

    # Test 3: Connection to beam-bpy server
    IO.write("Test 3: Connecting to beam-bpy node... ")

    target_node = :"beam_bpy@127.0.0.1"

    case BeamBpyTestHelpers.connect_to_beam_bpy(target_node) do
      true ->
        IO.puts("✓ PASS")
        IO.puts("   Connected to: #{target_node}")
        IO.puts("   Connected nodes: #{inspect(Node.list())}")
        passed = passed + 1

      false ->
        IO.puts("✗ FAIL")
        IO.puts("   Could not connect to #{target_node}")
        IO.puts("   Make sure beam-bpy server is running at 127.0.0.1")
        failed = failed + 1
    end

    # Print summary
    exit_code = BeamBpyTestHelpers.print_summary(passed, failed)
    exit_code
  end
end

BeamBpyTest.run()
