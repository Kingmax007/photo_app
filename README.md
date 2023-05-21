# photo_app

A new Flutter project.



## Photo Upload App
This is a simple photo upload app developed using the Flutter framework. The app allows users to capture or select photos from their device's gallery and upload them to a server. The user can also
upload a text along with the photo or just a text.

## Features

Capture or select photos from the device's gallery.
Preview selected photos before uploading.
Upload selected photos to a server.
Progress indicator for tracking upload progress.
Error handling for failed uploads.

## Getting Started
Clone the repository or download the source code.
Ensure Flutter SDK is installed on your system.
Open the project in your preferred IDE (e.g., Android studio).
Install the required dependencies by running flutter pub get in the terminal.
Connect your device or start an emulator/simulator.
Run the app using flutter run in the terminal.

## Project Structure
The project follows a standard Flutter project structure:

lib/: Contains the Dart source code for the app.
main.dart: Entry point of the application.
screens/: Contains the screens of the app.
components/: Contains reusable UI components.
models/: Contains data models used in the app.
services/: Contains the logic for interacting with the server.
assets/: Contains static assets such as images used in the app.

## Dependencies
The app relies on the following Flutter packages:

flutter_bloc: State management library.
http: HTTP client for making API requests.
image_picker: Plugin for capturing or selecting photos.
dio: Powerful HTTP client for handling file uploads.
cached_network_image: Caching library for efficient image loading.
You can find the specific versions of these packages in the pubspec.yaml file.

cupertino_icons: ^1.0.2
firebase_core: ^2.13.0
firebase_auth: ^4.6.1
cloud_firestore: ^4.7.1
firebase_storage: ^11.2.1
shared_preferences: ^2.1.1
font_awesome_flutter: ^10.4.0
google_sign_in: ^6.1.0
image_picker: ^0.8.7+5
palette_generator: ^0.3.3+2
image_fade: ^0.6.2
intl: ^0.18.1
flutter_facebook_auth: ^5.0.11

## Configuration
To use your own server for uploading photos, modify the server URL in the services/upload_service.dart file.

## dart
Copy code
static const String uploadUrl = 'https://github.com/Kingmax007/photo_app.git';

## Contributing
Contributions to this project are welcome. Feel free to open issues or submit pull requests to suggest improvements or report bugs.

## License
This project is licensed under the EUAS License. See the LICENSE file for more details.

#### Acknowledgments
This app was developed as a part of a Flutter personal project for Mobile app development  Special thanks to the Flutter community for their valuable contributions and resources.









