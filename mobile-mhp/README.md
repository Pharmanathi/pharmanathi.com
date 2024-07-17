# Pharmanathi MP client

This repository contains the Flutter-based client for the Pharmanathi MP client.
## Table of Contents

- [Getting Started](#getting-started)
- [Directory Structure](#directory-structure)
- [Dependencies](#dependencies)
- [Useful Links ](#useful-links)

## Getting Started

To get started with this project, follow the steps below.

### Prerequisites

Make sure you have the following software installed on your local machine:

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/)
- [Xcode](https://developer.apple.com/xcode/) _**if your are running MacOs**_

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
├── android
├── assets
├── ios
├── lib
  ├── blocs
  │   ├── appointment_bloc.dart
  │   └── user_bloc.dart
  ├── config
  │   └── color_const.dart
  ├── firebase_options.dart
  ├── helpers
  │   └── http_helpers.dart
  ├── logging.dart
  ├── main.dart
  ├── models
  │   ├── appointment.dart
  │   └── user.dart
  ├── repositories
  │   ├── appointment_repository.dart
  │   └── user_repository.dart
  ├── routes
  │   └── app_routes.dart
  ├── screens
  │   ├── components
  │   │   ├── UserProvider.dart
  │   │   ├── bargraph
  │   │   ├── forms
  │   │   └── image_data.dart
  │   └── pages
  │       ├── onboard_page.dart
  │       ├── signIn.dart
  │       └── working_hours.dart
  ├── services
  │   ├── api_provider.dart
  │   ├── manage_appointment_api.dart
  │   ├── onboard_api.dart
  │   └── working_hours_api.dart
  └── views
      ├── screens
      │   ├── account.dart
      │   ├── appointments.dart
      │   ├── earnings.dart
      │   ├── home_page.dart
      │   ├── manage_appointment.dart
      │   ├── patient_list.dart
      │   └── profile.dart
      └── widjets
          ├── WorkingHoursInput.dart
          ├── appiontment_details.dart
          ├── appointment_tile.dart
          ├── buttons.dart
          ├── navigationbar.dart
          ├── patiant_profile_tile.dart
          ├── upcoming_appointment_tile.dart
          └── weekdays.dart

```

### Explanation

**lib/main.dart:** The entry point of the application.

**.env.development/:** hold all our secrets for local dev

**.env.production/:** hold all our secrets for production release

**ios/:** Contains build for ios

**android/:** Contains build for Android

**assets/:** Contains project assets like images and vectors


**Lib/**

 - **config/:** Contains configuration files like constants,fire and themes.

 - **models/:** Contains data models for the application.

 - **logging.dart** holds configuration for our logging framework

- **repositories/:** Handles data operations and communication with data sources.

- **services/:** 
    - **api_provider.dart :** encapsulate reusable logic that may not necessarily be tied to data access or storage. They can perform operations such as making HTTP requests

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


## Useful Links

- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)


