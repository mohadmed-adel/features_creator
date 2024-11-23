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
import 'package:tellme/core/base-models/base-success-response-model/base_success_response_model.dart';
import 'package:tellme/core/network/network_helper.dart';
import 'package:tellme/core/network/token_handler.dart';

import '../../core/network/api_strings.dart';
import '../../injection.dart';
import '../storage/storage_keys.dart';
import '../storage/storage_services.dart';
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
      "App-id": ApiStrings.appId,
      if (token != null) "Authorization": "Bearer " +token,
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

  @override
  Future<BaseSuccessResponseModel> delete(String endPoint, int id) async {
    try {
      await _buildHeader();
      final response = await dio.delete( endPoint+/+id);

      return BaseSuccessResponseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw await NetworkUtils.networkExceptions(error);
    }
  }

  @override
  Future<BaseSuccessResponseModel> post(String endPoint,
      {Map<String, dynamic>? data, ProgressCallback? progressCallback}) async {
    try {
      await _buildHeader();
      final response = await dio.post(endPoint,
          data: data, onReceiveProgress: progressCallback);

      return BaseSuccessResponseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw await NetworkUtils.networkExceptions(error);
    }
  }

  @override
  Future<BaseSuccessResponseModel> update(String endPoint,
      {Map<String, dynamic>? data}) async {
    try {
      await _buildHeader();
      final response = await dio.patch(endPoint, data: data);

      return BaseSuccessResponseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw await NetworkUtils.networkExceptions(error);
    }
  }

  @override
  Future<BaseSuccessResponseModel> uploadImages(
      String endPoint, Map<String, File> data) async {
    try {
      await _buildHeader();
      FormData formData = FormData.fromMap(data);
      formData.files.add(MapEntry(data.entries.first.key,
          await MultipartFile.fromFile(data.entries.first.value.path)));
      final response = await dio.post(endPoint, data: formData);

      return BaseSuccessResponseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw await NetworkUtils.networkExceptions(error);
    }
  }
}
''',
    'lib/core/network/network_interface.dart': '''
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tellme/core/base-models/base-success-response-model/base_success_response_model.dart';

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
    'lib/core/network/token_handler.dart': '''
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../storage/secure_storage.dart';
import '../storage/storage_keys.dart';

class TokenHandler {
  TokenHandler._();

  static Future<String?> getUserToken() async {
    try {
      final token =
          await SecureStorage.getInstance().getValue(StorageKeys.accessToken);
      return token;
    } catch (e) {
      return null;
    }
  }

  static clearToken() async {
    await SecureStorage.getInstance().deleteValue(StorageKeys.accessToken);
  }
}
''',
    'lib/core/network/api_strings.dart': '''
class ApiStrings {
  static const String apiUrl = '';
  static const String appId = 'your_app_id_here';
}
''',
  };

  // Files to generate dynamically based on feature name
  final featureFiles = {
    'lib/features/$featureName/data/datasources/base_${featureName}_datasource.dart':
        '''
abstract class Base${capitalize(featureName)}DataSource {
  // Define the abstract methods here for your data source.
}
''',
  };

  final directories = [
    if (createCore) ...coreDirectories,
    ...featureDirectories,
  ];

  final files = {
    if (createCore) ...coreFiles,
    ...featureFiles,
  };

  for (var dir in directories) {
    Directory(dir).createSync(recursive: true);
    log('Folder $dir created successfully ✅');
  }

  files.forEach((filePath, content) {
    File(filePath).createSync(recursive: true);
    File(filePath).writeAsStringSync(content);
    log('File $filePath created successfully ✅');
  });
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
