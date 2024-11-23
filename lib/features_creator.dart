library features_creator;

import 'dart:developer';
import 'dart:io';

void main({String? featureName, bool createCore = false}) {
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
    'lib/core/base-models/base-success-response-model',
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
    'lib/core/router/router.dart': '''
part 'router.gr.dart';

@singleton
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
       // AutoRoute(page: SplashRoute.page, initial: true), 
      ];
}
''',
    'lib/core/network/dio_helper.dart': '''
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:network_logger/network_logger.dart';
import 'api_strings.dart';
import '../di/injection.dart';
import 'network_interface.dart';

@LazySingleton(as: BaseNetwork)
class DioHelper implements BaseNetwork {
  final Dio dio = Dio();

  DioHelper() {
    dio.options.baseUrl = ApiStrings.apiUrl;
    dio.options.receiveDataWhenStatusError = true;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);

    dio.interceptors.add(DioNetworkLogger());
  }

  _buildHeader() async {
    String? token = await TokenHandler.getUserToken();
    String langCode = getIt
            .get<StorageService>()
            .valueGetter(key: StorageKeys.activeLocale) ??
        'en';
    dio.options.headers = {
    if (token != null) "Authorization": "Bearer \$token",
      "LanguageCode": langCode,
    };
  }

  @override
  Future<BaseSuccessResponseModel> get(String endPoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      await _buildHeader();
      final response = await dio.get(ApiStrings.apiUrl + endPoint,
          queryParameters: queryParameters);

      return BaseSuccessResponseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw await NetworkUtils.networkExceptions(error);
    }
  }

  // Add other methods for post, update, delete, etc.
}
''',
    'lib/core/network/network_interface.dart': '''
import 'dart:io';

import 'package:dio/dio.dart';
import '../base-models/base-success-response-model/base_success_response_model.dart';

abstract class BaseNetwork {
  Future<BaseSuccessResponseModel> get(String endPoint,
      {Map<String, dynamic>? queryParameters});
  Future<BaseSuccessResponseModel> post(String endPoint,
      {Map<String, dynamic>? data, ProgressCallback? progressCallback});
  Future<BaseSuccessResponseModel> delete(String endPoint, int id);
  Future<BaseSuccessResponseModel> update(String endPoint,
      {Map<String, dynamic>? data});
  Future<BaseSuccessResponseModel> uploadImages(
      String endPoint, Map<String, File> data);
}
''',
    'lib/core/base-models/base-success-response-model/base_success_response_model.dart':
        '''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_success_response_model.freezed.dart';
part 'base_success_response_model.g.dart';

@freezed
class BaseSuccessResponseModel<T> with '_\$BaseSuccessResponseModel {
  const BaseSuccessResponseModel._(); // private constructor for the freezed union

  const factory BaseSuccessResponseModel({
    String? message,
    dynamic data,
  }) = _BaseSuccessResponseModel;

  factory BaseSuccessResponseModel.fromJson(Map<String, dynamic> json) =>
      _\$BaseSuccessResponseModelFromJson(json);
}
'''
  };

  // Files to generate dynamically based on feature name
  final featureFiles = {
    'lib/features/$featureName/data/datasources/base_${featureName}_datasource.dart':
        '''
abstract class Base${capitalize(featureName)}DataSource {
  // Define the abstract methods here for your data source.
}
''',
    'lib/features/$featureName/data/datasources/${featureName}_datasource_impl.dart':
        '''
import 'base_${featureName}_datasource.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: Base${capitalize(featureName)}DataSource)
class ${capitalize(featureName)}DataSourceImpl implements Base${capitalize(featureName)}DataSource {
  // Implement abstract methods here
}
''',
    // Add other feature files here...
  };

  // Generate directories and files based on the flag
  final directories = [
    if (createCore) ...coreDirectories,
    ...featureDirectories,
  ];

  final files = {
    if (createCore) ...coreFiles,
    ...featureFiles,
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
