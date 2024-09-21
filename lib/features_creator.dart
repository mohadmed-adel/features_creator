library features_creator;

import 'dart:developer';
import 'dart:io';

void main({String? featureName, bool createCore = false}) {
  print("createCore: $createCore");

  if (featureName == null || featureName.isEmpty) {
    log('Error: featureName is required.');
    return;
  }

  // Core folders and feature-specific folders
  final coreDirectories = [
    'lib/core/shared_widgets',
    'lib/core/constants',
    'lib/core/enums',
    'lib/core/network',
    'lib/core/router',
    'lib/core/di',
    'lib/core/theme',
    'lib/core/helpers/extensions',
  ];

  final featureDirectories = [
    'lib/features/$featureName/data',
    'lib/features/$featureName/data/datasources',
    'lib/features/$featureName/data/models',
    'lib/features/$featureName/data/repositories',
    'lib/features/$featureName/domain',
    'lib/features/$featureName/domain/repositories',
    'lib/features/$featureName/domain/usecase',
    'lib/features/$featureName/presentation',
  ];

  // Files to generate for the core (if createCore is true)
  final coreFiles = {
    'lib/core/theme/app_colors.dart': '''
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  // Add more colors as needed
}
''',
    'lib/core/di/injection.dart': '''
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async {
  getIt.init();
}
''',
  };

  // Files to generate dynamically based on feature name
  final featureFiles = {
    // Datasources
    'lib/features/$featureName/data/datasources/base_${featureName}_datasource.dart':
        '''
abstract class Base${capitalize(featureName)}DataSource {
  // Define the abstract methods here for your data source.
}
''',
    // Implementation of the abstract class
    'lib/features/$featureName/data/datasources/${featureName}_datasource_impl.dart':
        '''
import 'base_${featureName}_datasource.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: Base${capitalize(featureName)}DataSource)
class ${capitalize(featureName)}DataSourceImpl implements Base${capitalize(featureName)}DataSource {
  // Implement abstract methods here
}
''',
    // Repositories
    'lib/features/$featureName/domain/repositories/base_${featureName}_repository.dart':
        '''
abstract class Base${capitalize(featureName)}Repository {
  // Define the abstract methods here for your repository.
}
''',
    // Implementation of the abstract class
    'lib/features/$featureName/data/repositories/${featureName}_repository_impl.dart':
        '''
import '../../domain/repositories/base_${featureName}_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: Base${capitalize(featureName)}Repository)
class ${capitalize(featureName)}RepositoryImpl implements Base${capitalize(featureName)}Repository {
  // Implement abstract methods here
}
''',
  };

  // Generate directories and files based on the flag
  final directories = [
    if (createCore) ...coreDirectories,
    ...featureDirectories,
  ];

  final files = {
    if (createCore) ...coreFiles,
    ...featureFiles, // Adds the dynamic feature-specific files
  };

  // Creating folders
  for (var dir in directories) {
    Directory(dir).createSync(recursive: true);
    log('Folder $dir created successfully ✅');
  }

  // Creating files
  files.forEach((filePath, content) {
    File(filePath).createSync(recursive: true);
    File(filePath).writeAsStringSync(content);
    log('File $filePath created successfully ✅');
  });
}

// Helper function to capitalize the feature name for class name generation
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
