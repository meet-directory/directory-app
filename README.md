# Directory App
This is a godot project that compiles the Directory app to all platforms.


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
