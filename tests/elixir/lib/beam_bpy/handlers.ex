defmodule BeamBpy.Handlers do
  @moduledoc """
  Handler behaviour for beam-bpy RPC handlers
  Defines the interface that all handlers must implement
  """

  @callback ping(list()) :: String.t()
  @callback echo(list()) :: any()
  @callback add(list()) :: integer() | nil
  @callback info(list()) :: map() | nil
end
