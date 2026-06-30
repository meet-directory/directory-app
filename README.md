# Directory App
This is the code behind the [Directory App](https://meet.directory).

It is a [Godot](https://godotengine.org/) project that compiles the Directory app to all platforms. Directory is currently available in the Browswer and on Android.


## Contributing
We are currently working on describing and making the public contribution process more accessable. Please reach out to cecilia@meet.directory if you are interested in contributing.

### Setting up for development

1. Email me at cecilia@meet.directory for access to the development server and database. 
2. Download the relevant Godot version [here](https://godotengine.org/). Directory is on Godot 4.7
3. You should be able to press F5 or the Play button in the upper right to run it immediately.
4. Sometimes the font setting doesn't import correctly. If the font or emojis
   on buttons aren't rendering correctly, go to `Project->Project
   Settings->General->GUI->Theme`. Add the font path to the Custom Font field.
   It should be `res://resources/fonts/Open_Sans/static/OpenSans-Regular.ttf`.
5. Happy editing!

### Mobile Development and Testing
If you are interested in joining Android or iOS internal testing please email me! This will allow you to download the latest releases from app stores before they are public.

See the [android
documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
or [iOS
documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html)
depending on which platform you are targeting. Godot also supports [one-click
deploy](https://docs.godotengine.org/en/stable/tutorials/export/one-click_deploy.html)
for mobile devices.

Android is a little easier to set up for testing. For iOS, setting up XCode can
be a little tricky the first time, feel free to reach out if you have
questions.




## Security
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
