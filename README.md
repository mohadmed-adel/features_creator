# Feature & Core Structure Generator

This Dart package generates a folder and file structure for Flutter applications, allowing you to quickly scaffold both core and feature-specific modules. It supports the creation of core utility folders and feature-specific directories, along with abstract classes and their implementations.

## Features

- Generates core directories and files (e.g., `shared_widgets`, `constants`, etc.).
- Creates feature-specific folder structures (e.g., `data`, `domain`, `presentation`, etc.).
- Dynamically creates abstract classes and their corresponding implementation files for feature-specific `DataSource` layers.

## Usage

To use this package, you need to call the `main()` function, providing a `featureName` and an optional `createCore` flag. The `featureName` is required and is used to generate feature-specific directories and files.

### Example

```dart
dart run features_creator:features_creator --featureName=user --createCore
```

This will generate the following structure:

```bash
lib/
├── core/
│   ├── constants/
│   ├── di/
│   ├── enums/
│   ├── helpers/
│   ├── network/
│   ├── router/
│   ├── shared_widgets/
│   └── theme/
│       └── app_colors.dart
└── features/
    └── user/
        ├── data/
        │   ├── datasources/
        │   │   ├── base_user_datasource.dart
        │   │   └── user_datasource_impl.dart
        │   ├── models/
        │   └── repositories/
        │       └── user_repository_impl.dart
        ├── domain/
        │   ├── repositories/
        │   │   └── base_user_repository.dart
        │   └── usecase/
        └── presentation/

```

### Parameters

- `featureName`: The name of the feature for which to generate the folder structure. This will be used to create directories like `lib/<featureName>/home/data/...`.
- `createCore` (optional): A boolean flag that indicates whether to generate core directories (default is `false`).

### Core Directories

If `createCore: true` is passed, the following core folders will be created:

```bash
lib/core/
├── constants/
├── di/
├── enums/
├── helpers/extensions/
├── network/
├── router/
├── shared_widgets/
└── theme/
```

In addition, the file `app_colors.dart` will be created inside `lib/core/theme` with an example class:

```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  static const color = Color(0xFF);
}
```

### Feature-Specific Files

The package will automatically create files and directories based on the provided `featureName`. For example, for `featureName: 'user'`, the following files are generated:

- `base_user_datasource.dart`: Contains an abstract class `BaseUserDataSource`.
- `user_datasource_impl.dart`: Implements the `BaseUserDataSource` class.

Example `base_user_datasource.dart`:

```dart
abstract class BaseUserDataSource {
  // Define abstract methods here
}
```

Example `user_datasource_impl.dart`:

```dart
import 'base_user_datasource.dart';

class UserDataSourceImpl implements BaseUserDataSource {
  // Implement abstract methods here
}
```

## Installation

To integrate this into your project, clone or download this package, and modify the `main()` function as needed to suit your project requirements.

```bash
git clone <repo-url>
```

Then, in your project, simply call the `main()` function as shown above to generate the folder structure.

## License

This project is licensed under the MIT License.

---

## Contribution

Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request.
