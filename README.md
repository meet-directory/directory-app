# Directory App
This is the code behind the [Directory App](https://meet.directory).

It is a [Godot](https://godotengine.org/) project that compiles the Directory app to all platforms. Directory is a new organization and the app is currently in beta and only supported on the web platform. Coming soon to mobile devices.

We are currently working on describing and making the public contribution process more accessable, but if you want to contribute, by all means make a PR!

### Security
All files with network calls and security implications:
- [globals/api_server_autoload.gd](/globals/api_server_autoload.gd)
  All network calls to the API server (except for websocket connections).
- [globals/object_storage.gd](globals/object_storage.gd)
  All network calls made to the external blob storage provider.
- [globals/token_storage.gd](globals/token_storage.gd)
  JWT token storage.
- [globals/location_service.gd](main/globals/location_service.gd)
- [globals/websockets.gd](main/globals/websockets.gd)

If you notice a security issue, please report to contact@meet.directory.
