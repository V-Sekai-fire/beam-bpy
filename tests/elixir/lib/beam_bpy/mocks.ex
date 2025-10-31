defmodule BeamBpy.Mocks do
  @moduledoc """
  Defines mox mocks for beam-bpy handler testing
  Allows mocking the handler behavior for isolated unit testing
  """

  import Mox

  @doc """
  Setup mocks for a test
  Returns the mock pid
  """
  def setup_mocks do
    Mox.defmock(BeamBpyHandlerMock, for: BeamBpy.Handlers)
    :ok
  end

  @doc """
  Setup default handler behaviors
  """
  def setup_default_behaviors do
    # Setup ping handler
    Mox.stub(BeamBpyHandlerMock, :ping, fn _args -> "pong" end)

    # Setup echo handler
    Mox.stub(BeamBpyHandlerMock, :echo, fn args ->
      case args do
        [msg] -> msg
        _ -> nil
      end
    end)

    # Setup add handler
    Mox.stub(BeamBpyHandlerMock, :add, fn args ->
      case args do
        [a, b] when is_integer(a) and is_integer(b) -> a + b
        _ -> nil
      end
    end)

    # Setup info handler
    Mox.stub(BeamBpyHandlerMock, :info, fn _args ->
      %{
        "node" => "beam_bpy",
        "status" => "running",
        "version" => "0.1.0"
      }
    end)

    :ok
  end

  @doc """
  Verify all mocks were called as expected
  """
  def verify_mocks do
    Mox.verify!(BeamBpyHandlerMock)
    :ok
  end
end
