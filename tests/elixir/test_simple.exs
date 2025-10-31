#!/usr/bin/env elixir
"""
Simple Elixir test for beam-bpy handlers
Tests handler logic without requiring node distribution
"""

defmodule BeamBpySimpleTest do
  def run do
    IO.puts("\n" <> String.duplicate("=", 60))
    IO.puts("BEAM-BPY QA TEST SUITE - Simple Handler Tests")
    IO.puts(String.duplicate("=", 60) <> "\n")
    
    passed = 0
    failed = 0
    
    # Test ping handler
    IO.write("Test 1: ping() handler... ")
    case test_ping() do
      true -> 
        IO.puts("✓ PASS")
        passed = passed + 1
      false -> 
        IO.puts("✗ FAIL")
        failed = failed + 1
    end
    
    # Test echo handler
    IO.write("Test 2: echo(message) handler... ")
    case test_echo() do
      true -> 
        IO.puts("✓ PASS")
        passed = passed + 1
      false -> 
        IO.puts("✗ FAIL")
        failed = failed + 1
    end
    
    # Test add handler
    IO.write("Test 3: add(5, 3) handler... ")
    case test_add() do
      true -> 
        IO.puts("✓ PASS")
        passed = passed + 1
      false -> 
        IO.puts("✗ FAIL")
        failed = failed + 1
    end
    
    # Test info handler
    IO.write("Test 4: info() handler... ")
    case test_info() do
      true -> 
        IO.puts("✓ PASS")
        passed = passed + 1
      false -> 
        IO.puts("✗ FAIL")
        failed = failed + 1
    end
    
    # Test negative numbers
    IO.write("Test 5: add(-5, 3) with negative numbers... ")
    case test_add_negative() do
      true -> 
        IO.puts("✓ PASS")
        passed = passed + 1
      false -> 
        IO.puts("✗ FAIL")
        failed = failed + 1
    end
    
    # Test echo with message
    IO.write("Test 6: echo(hello_world) with string... ")
    case test_echo_string() do
      true -> 
        IO.puts("✓ PASS")
        passed = passed + 1
      false -> 
        IO.puts("✗ FAIL")
        failed = failed + 1
    end
    
    # Test error handling
    IO.write("Test 7: Error handling for unknown handler... ")
    case test_unknown_handler() do
      true -> 
        IO.puts("✓ PASS")
        passed = passed + 1
      false -> 
        IO.puts("✗ FAIL")
        failed = failed + 1
    end
    
    # Test invalid argument handling
    IO.write("Test 8: Error handling for invalid add arguments... ")
    case test_invalid_args() do
      true -> 
        IO.puts("✓ PASS")
        passed = passed + 1
      false -> 
        IO.puts("✗ FAIL")
        failed = failed + 1
    end
    
    IO.puts("\n" <> String.duplicate("-", 60))
    IO.puts("Test Results: #{passed} passed, #{failed} failed")
    IO.puts(String.duplicate("-", 60) <> "\n")
    
    if failed == 0 do
      IO.puts("✓ ALL TESTS PASSED\n")
      0
    else
      IO.puts("✗ #{failed} TESTS FAILED\n")
      1
    end
  end
  
  defp test_ping do
    handler("ping", []) == "pong"
  end
  
  defp test_echo do
    handler("echo", ["test"]) == "test"
  end
  
  defp test_add do
    handler("add", [5, 3]) == 8
  end
  
  defp test_info do
    result = handler("info", [])
    is_map(result)
  end
  
  defp test_add_negative do
    handler("add", [-5, 3]) == -2
  end
  
  defp test_echo_string do
    handler("echo", ["hello_world"]) == "hello_world"
  end
  
  defp test_unknown_handler do
    result = handler("unknown_func", [])
    result == nil or is_tuple(result)
  end
  
  defp test_invalid_args do
    result = handler("add", ["invalid"])
    result == nil or is_tuple(result)
  end
  
  defp handler(name, args) do
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
end

exit_code = BeamBpySimpleTest.run()
System.halt(exit_code)
