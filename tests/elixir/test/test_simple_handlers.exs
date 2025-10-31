#!/usr/bin/env elixir
"""
Simple Elixir test for beam-bpy handlers
Tests handler logic without requiring node distribution
Organized by Dependency Hierarchy using BeamBpyTestHelpers
"""

Code.require_file("test_helpers.exs", __DIR__)

defmodule BeamBpySimpleTest do
  @moduledoc """
  Simple handler tests organized by dependency hierarchy:
  
  Level 2: Core Handler Tests - Basic functionality
  Level 3: Advanced Handler Tests - Complex handlers
  Level 4: Error Handling & Edge Cases
  """

  def run do
    IO.puts("\n" <> String.duplicate("=", 60))
    IO.puts("BEAM-BPY QA TEST SUITE - Simple Handler Tests")
    IO.puts("Organized by Dependency Hierarchy")
    IO.puts(String.duplicate("=", 60) <> "\n")

    passed = 0
    failed = 0

    # ========================================================================
    # LEVEL 2: Core Handler Tests (Basic Functionality)
    # ========================================================================
    IO.puts("LEVEL 2: Core Handler Tests\n")

    # Test ping handler - most basic
    IO.write("Test 1: ping() handler... ")

    case BeamBpyTestHelpers.test_ping_handler() do
      true ->
        IO.puts("✓ PASS")
        passed = passed + 1

      false ->
        IO.puts("✗ FAIL")
        failed = failed + 1
    end

    # Test echo handler - simple parameter passing
    IO.write("Test 2: echo(message) handler... ")

    case BeamBpyTestHelpers.test_echo_handler("test") do
      true ->
        IO.puts("✓ PASS")
        passed = passed + 1

      false ->
        IO.puts("✗ FAIL")
        failed = failed + 1
    end

    # Test add handler - basic arithmetic
    IO.write("Test 3: add(5, 3) handler... ")

    case BeamBpyTestHelpers.test_add_handler(5, 3) do
      true ->
        IO.puts("✓ PASS")
        passed = passed + 1

      false ->
        IO.puts("✗ FAIL")
        failed = failed + 1
    end

    # ========================================================================
    # LEVEL 3: Advanced Handler Tests
    # ========================================================================
    IO.puts("\nLEVEL 3: Advanced Handler Tests\n")

    # Test info handler - returns server information
    IO.write("Test 4: info() handler... ")

    case BeamBpyTestHelpers.test_info_handler() do
      true ->
        IO.puts("✓ PASS")
        passed = passed + 1

      false ->
        IO.puts("✗ FAIL")
        failed = failed + 1
    end

    # ========================================================================
    # LEVEL 4: Error Handling & Edge Cases
    # ========================================================================
    IO.puts("\nLEVEL 4: Error Handling & Edge Cases\n")

    # Test add with negative numbers
    IO.write("Test 5: add(-5, 3) with negative numbers... ")

    case BeamBpyTestHelpers.test_negative_numbers() do
      true ->
        IO.puts("✓ PASS")
        passed = passed + 1

      false ->
        IO.puts("✗ FAIL")
        failed = failed + 1
    end

    # Test echo with string message
    IO.write("Test 6: echo(hello_world) with string... ")

    case BeamBpyTestHelpers.test_echo_handler("hello_world") do
      true ->
        IO.puts("✓ PASS")
        passed = passed + 1

      false ->
        IO.puts("✗ FAIL")
        failed = failed + 1
    end

    # Test unknown handler error handling
    IO.write("Test 7: Error handling for unknown handler... ")

    case BeamBpyTestHelpers.test_unknown_handler() do
      true ->
        IO.puts("✓ PASS")
        passed = passed + 1

      false ->
        IO.puts("✗ FAIL")
        failed = failed + 1
    end

    # Test invalid arguments error handling
    IO.write("Test 8: Error handling for invalid add arguments... ")

    case BeamBpyTestHelpers.test_invalid_arguments() do
      true ->
        IO.puts("✓ PASS")
        passed = passed + 1

      false ->
        IO.puts("✗ FAIL")
        failed = failed + 1
    end

    # Test large numbers
    IO.write("Test 9: add(1000000, 2000000) with large numbers... ")

    case BeamBpyTestHelpers.test_large_numbers() do
      true ->
        IO.puts("✓ PASS")
        passed = passed + 1

      false ->
        IO.puts("✗ FAIL")
        failed = failed + 1
    end

    # Print summary
    exit_code = BeamBpyTestHelpers.print_summary(passed, failed)
    exit_code
  end
end

exit_code = BeamBpySimpleTest.run()
System.halt(exit_code)
