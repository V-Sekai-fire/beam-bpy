ExUnit.start()

# Setup Mox global mode
Mox.defmock(BeamBpyHandlerMock, for: BeamBpy.Handlers)

Application.put_env(:beam_bpy_tests, :handler_mock, BeamBpyHandlerMock)
