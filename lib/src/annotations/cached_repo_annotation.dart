import 'package:super_annotations/super_annotations.dart';

class CachedRepo extends ClassAnnotation {
  final String modelName;

  const CachedRepo({required this.modelName});

  @override
  void apply(Class target, LibraryBuilder output) {
    final get = Method(
      (m) => m
        ..name = 'get${modelName}ById'
        ..returns = refer('Future<$modelName?>')
        ..optionalParameters.add(
          Parameter(
            (p) => p
              ..name = 'id'
              ..named = true
              ..required = true
              ..type = refer('String'),
          ),
        )
        ..body = Code('return storageService.get(id);'),
    );

    final extension = Extension(
      (e) => e
        ..name = '\$${target.name}'
        ..on = refer(target.name)
        ..methods.add(get),
    );

    output.body.add(extension);
  }
}
