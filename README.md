# dance_club_comuna_8

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Useful commands:
To run: flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000
To update dependencies: flutter pub get

This project use app check from firebase, to use it you need to create a project in firebase and add the app check key in the web/index.html file.
When you have the debug key add it to dart-define in launch.json file in .vscode folder. DONT COMMIT THE KEY TO THE REPO.

{
  "configurations": [
    {
      "name": "Flutter (Chrome) devcontainer",
      "program": "lib/main.dart",
      "deviceId": "chrome",
      "request": "launch",
      "args": [
        "--web-port",
        "3000",
        "--dart-define=DEBUG_KEY=debug_key",
      ],
      "type": "dart"
    }
  ]
}
