import 'package:annotation_example/src/src.dart';
import 'package:built_collection/built_collection.dart';
import 'package:super_annotations/super_annotations.dart';

class Cached extends ClassAnnotation {
  const Cached();

  @override
  void apply(Class target, LibraryBuilder builder) {
    final hasEmbeddedFields = target.fields.any((e) => isEmbedded(e));

    final fields = buildFields(target);

    final cachedClass = buildClass(target, fields, hasEmbeddedFields);

    // Add the class to the library builder
    builder
      ..directives = buildDirectives()
      ..body.add(cachedClass);
  }

  Class buildClass(
    Class target,
    BuiltList<Field> fields, [
    bool hasEmbeddedFields = false,
  ]) {
    return Class(
      (c) => c
        ..name = 'Cached${target.name}'
        ..annotations = ListBuilder([refer('Entity()')])
        ..constructors = ListBuilder([
          Constructor(
            (c) => c
              ..constant = !hasEmbeddedFields
              ..external = false
              ..name = '_'
              ..optionalParameters.addAll(
                target.fields.where((f) => !isEmbedded(f)).map((t) {
                  return Parameter(
                    (p) => p
                      ..name = t.name
                      ..toThis = true
                      ..named = true
                      ..required = isFieldNonNullable(t),
                  );
                }).toList(),
              ),
          ),
          if (hasEmbeddedFields) factoryWithEmbedded(target, fields),
          if (!hasEmbeddedFields) factoryWithoutEmbedded(target, fields),
        ])
        ..fields.addAll(fields),
    );
  }

  ListBuilder<Directive> buildDirectives() {
    return ListBuilder<Directive>([
      Directive.import('package:objectbox/objectbox.dart'),
      Directive.import('package:annotation_example/src/src.dart'),
    ]);
  }

  BuiltList<Field> buildFields(Class target) {
    return target.fields.map((value) {
      return Field(
        (field) => field
          ..name = value.name
          ..modifier = FieldModifier.final$
          ..assignment = isEmbedded(value)
              ? Code('ToOne<Cached${value.type?.symbol}>()')
              : null
          ..annotations = isIndexed(value)
              ? ListBuilder([refer('Index()')])
              : ListBuilder([])
          ..type = !isEmbedded(value) ? value.type : null,
      );
    }).toBuiltList();
  }

  Constructor factoryWithEmbedded(Class target, BuiltList<Field> fields) {
    return Constructor(
      (c) => c
        ..external = false
        ..constant = false
        ..name = 'fromModel'
        ..factory = true
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'model'
              ..type = refer(target.name),
          ),
        )
        ..body = Block.of([
          // Create the return statement
          refer('final cached = Cached${target.name}._').call([], {
            for (final f in target.fields.where((f) => !isEmbedded(f)))
              f.name: refer('model').property(f.name),
          }).statement,
          ...target.fields
              .where((f) => isEmbedded(f))
              .map(
                (f) => Block.of([
                  Code(''),
                  Code(
                    'final ${f.name} = Cached${f.type?.symbol}.fromModel(model.${f.name});',
                  ),
                  Code('cached.${f.name}.target = ${f.name};'),
                ]),
              )
              .toBuiltList(),
          ...[Code(''), Code('return cached;')],
        ]),
    );
  }

  Constructor factoryWithoutEmbedded(Class target, BuiltList<Field> fields) {
    return Constructor(
      (c) => c
        ..external = false
        ..constant = false
        ..name = 'fromModel'
        ..factory = true
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'model'
              ..type = refer(target.name),
          ),
        )
        ..body = Block.of([
          // Create the return statement
          refer('Cached${target.name}._')
              .call([], {
                for (final f in target.fields.where((f) => !isEmbedded(f)))
                  f.name: refer('model').property(f.name),
              })
              .returned
              .statement,
        ]),
    );
  }

  bool isEmbedded(Field f) =>
      f.resolvedAnnotationsOfType<embedded>().isNotEmpty;

  // Helper method to check if a field is non-nullable
  bool isFieldNonNullable(Field field) {
    if (field.type == null) return false;

    // Use the emitter to get the proper string representation
    final emitter = DartEmitter.scoped(useNullSafetySyntax: true);
    final typeCode = field.type!.accept(emitter);
    return !typeCode.toString().endsWith('?');
  }

  bool isIndexed(Field f) => f.resolvedAnnotationsOfType<indexed>().isNotEmpty;
}
