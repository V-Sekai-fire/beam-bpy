import Config

config :logger,
  level: :info,
  format: "[$level] $message\n"

if Mix.env() == :test do
  config :beam_bpy_tests, test_mode: true
end
