#!/usr/bin/env elixir
"""
Elixir Test Client for Beam-BPy
Tests beam-bpy CNode connection from Elixir
"""

defmodule BeamBpyTest do
  def run do
    IO.puts("=" <> String.duplicate("=", 48))
    IO.puts("Beam-BPy Elixir Test Client")
    IO.puts("=" <> String.duplicate("=", 48))
    IO.puts("")
    
    IO.puts("Starting Elixir node...")
    {:ok, _pid} = Node.start(:"test_client@127.0.0.1")
    Node.set_cookie(:beam_bpy_cookie)
    IO.puts("✓ Node started: #{Node.self()}")
    IO.puts("✓ Cookie set: #{Node.get_cookie()}")
    IO.puts("")
    
    target_node = :"beam_bpy@127.0.0.1"
    IO.puts("Connecting to beam-bpy node: #{target_node}")
    
    case Node.connect(target_node) do
      true ->
        IO.puts("✓ Connected to #{target_node}")
        IO.puts("✓ Connected nodes: #{inspect(Node.list())}")
        :ok
        
      false ->
        IO.puts("✗ Failed to connect to #{target_node}")
        IO.puts("Make sure beam-bpy server is running")
        System.halt(1)
        
      :ignored ->
        IO.puts("✗ Connection attempt was ignored")
        System.halt(1)
    end
  end
end

BeamBpyTest.run()
