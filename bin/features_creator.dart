import 'package:args/args.dart';
import 'package:features_creator/features_creator.dart' as featuresCreator;

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('featureName',
        abbr: 'f', help: 'The name of the feature to create.')
    ..addFlag('createCore',
        defaultsTo: false, help: 'Whether to create core structure.');

  final argResults = parser.parse(arguments);

  final featureName = argResults['featureName'];
  final createCore = argResults['createCore'];

  if (featureName == null || featureName.isEmpty) {
    print('Error: --featureName is required.');
    return;
  }

  featuresCreator.main(
    featureName: featureName,
    createCore: createCore,
  );
}
