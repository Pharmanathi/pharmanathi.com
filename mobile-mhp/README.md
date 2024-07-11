# Pharma Nathi

Welcome to PharmaNathi! This application is designed to help medical professional to streamline and bring closer their practice to their patient.
## Table of Contents

- [Getting Started](#getting-started)
- [Directory Structure](#directory-structure)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [Flutter CookBook](#flutter-cook-book)

## Getting Started

To get started with this project, follow the steps below.

### Prerequisites

Make sure you have the following software installed on your local machine:

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/)

### Installation

after Cloning the repository to your local machine:

```bash
cd mobile-mhp
```

```bash
flutter pub get
```

## Directory-structure

```bash
lib/
  main.dart
  .env.developent
  .env.production
  ios/
  android/
  assets/
    images/
  lib/
    logging.dart
    config/
      color_const.dart
    models/
      appointment.dart
      user.dart
    repositories/
      appointment_repository.dart
      user_repository.dart
    services/
      api_provider.dart
      auth_service.dart
    blocs/
      appointment_bloc.dart
      user_bloc.dart
    views/
      screens/
        appointment_screen.dart
        login_screen.dart
      widgets/
        appointment_tile.dart
        upcoming_appointment_tile.dart
    helpers/
      http_helpers.dart
    routes/
      app_routes.dart

```

### Explanation

**lib/main.dart:** The entry point of the application.

**.env.development/:** hold all our secrets for local dev

**.env.production/:** hold all our secrets for production release

**ios/:** Contains build for ios

**models/:** Contains build for android

**assets/:** Contains project assets like images and vectors

**logging.dart** holds configuration for our logging framework

**Lib/**

 - **config/:** Contains configuration files like constants,fire and themes.

 - **models/:** Contains data models for the application.

- **repositories/:** Handles data operations and communication with data sources.

- **services/:** Provides core services like API interaction and authentication.

- **blocs/:** Contains BLoC (Business Logic Component) files for managing state.

- **views/:** Contains UI elements including screens and widgets.

- **helper/:** Utility functions and helpers.

- **routes/:** Defines application routes.


## Dependencies

### **This project uses the following dependencies:**

- [flutter](https://flutter.dev): SDK for building mobile apps.
- [image_picker](https://pub.dev/packages/image_picker): ^1.0.4
- [permission_handler](https://pub.dev/packages/permission_handler): ^11.0.1
- [cupertino_icons](https://pub.dev/packages/cupertino_icons): ^1.0.2
- [fl_chart](https://pub.dev/packages/fl_chart): ^0.65.0
- [google_sign_in](https://pub.dev/packages/google_sign_in): ^6.2.0
- [provider](https://pub.dev/packages/provider): ^6.1.1
- [path_provider](https://pub.dev/packages/path_provider): ^2.0.15
- [shared_preferences](https://pub.dev/packages/shared_preferences): ^2.0.9
- [firebase_core](https://pub.dev/packages/firebase_core): ^2.24.2
- [firebase_auth](https://pub.dev/packages/firebase_auth): ^4.16.0
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage): ^9.0.0
- [http](https://pub.dev/packages/http): ^1.2.0
- [device_info](https://pub.dev/packages/device_info): ^2.0.3
- [location](https://pub.dev/packages/location): ^5.0.3
- [icons_launcher](https://pub.dev/packages/icons_launcher): ^2.1.7
- [logger](https://pub.dev/packages/logger): ^2.0.2+1
- [intl](https://pub.dev/packages/intl): ^0.19.0
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv): ^5.1.0
- [multi_select_flutter](https://pub.dev/packages/multi_select_flutter): ^4.1.3
- [flutter_svg](https://pub.dev/packages/flutter_svg): ^2.0.10+1
- [sentry_flutter](https://pub.dev/packages/sentry_flutter): ^8.3.0

### Dev Dependencies

- [flutter_test](https://pub.dev/packages/flutter_test): SDK for running tests in Flutter.
- [flutter_lints](https://pub.dev/packages/flutter_lints): ^3.0.1
- [change_app_package_name](https://pub.dev/packages/change_app_package_name): ^1.1.0

## Contributing

- Allways keep main up-to-date (git pull)
- Create a new branch (git checkout -b feature-branch).
- Commit your changes (git commit -m 'Add some feature').
- Push to the branch (git push origin feature-branch).
- Create a new Pull Request.
- Wait for a review

## Flutter CookBook

- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)


