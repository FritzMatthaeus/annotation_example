import 'package:super_annotations/super_annotations.dart';

class Cached extends ClassAnnotation {
  const Cached();
  @override
  void apply(Class target, LibraryBuilder output) {
    final get = Method(
      (m) => m
        ..name = 'get'
        // ..annotations = ListBuilder([Code('@override')])
        ..returns = refer('Future<${target.name}?>')
        ..requiredParameters.addAll([
          Parameter(
            (p) => p
              ..name = 'm'
              ..type = refer(target.name),
          ),
          Parameter(
            (p) => p
              ..name = 'st'
              ..type = refer('StorageService<${target.name}>'),
          ),
        ])
        ..body = Code('return st.get(m.id);'),
    );
    final delete = Method(
      (m) => m
        ..name = 'delete'
        // ..annotations = ListBuilder([Code('@override')])
        ..returns = refer('Future<void>')
        ..requiredParameters.addAll([
          Parameter(
            (p) => p
              ..name = 'm'
              ..type = refer(target.name),
          ),
          Parameter(
            (p) => p
              ..name = 'st'
              ..type = refer('StorageService'),
          ),
        ])
        ..body = Code('return st.delete(m.id);'),
    );

    final extension = Extension(
      (e) => e
        ..name = '\$${target.name}'
        ..on = refer(target.name)
        ..methods.addAll([get, delete]),
    );
    output.body.add(extension);
  }
}
