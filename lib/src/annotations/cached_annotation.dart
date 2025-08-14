// ignore_for_file: camel_case_types

import 'dart:io';

import 'package:annotation_example/src/src.dart';
import 'package:built_collection/built_collection.dart';
import 'package:super_annotations/super_annotations.dart';

part 'collect_embedded.dart';

typedef OneToManyRelation = ({
  String fieldName,
  String targetName,
  String? embeddedSymbol,
});

class Cached extends ClassAnnotation {
  static const String _cachedPrefix = 'Cached';

  /// Set of [OneToManyRelation] that is generated prior to code
  /// generation and allows to update classes that are user
  /// as an embedded iterable inside a parent class
  static Set<OneToManyRelation> embeddeOneToManyRelations = {};

  const Cached();

  @override
  void apply(Class target, LibraryBuilder builder) {
    for (final field in target.fields) {
      if (_isEmbeddedIterable(field)) {
        final embeddedSymbol = _getSymbolOfIterableFields(field);
        final relation = (
          fieldName: field.name,
          targetName: target.name,
          embeddedSymbol: embeddedSymbol,
        );
        embeddeOneToManyRelations.add(relation);
      }
    }

    Class generatedClass = _buildClass(
      target,
      fields: _buildFields(target),
      methods: ListBuilder([_buildToModelMethod(target)]),
    );

    // Add the class to the library builder
    builder
      ..directives = buildDirectives()
      ..body.add(generatedClass);
  }

  /// returns all [Directive]s such as imports
  ListBuilder<Directive> buildDirectives() {
    return ListBuilder<Directive>([
      Directive.import('package:objectbox/objectbox.dart'),
      Directive.import('package:annotation_example/src/src.dart'),
    ]);
  }

  /// will return a BackLink decorator if
  /// this field is iterable
  Expression? _buildBacklinkDecorator(Field f) {
    if (!_isEmbeddedIterable(f)) {
      return null;
    }
    return refer('Backlink(\'${f.name}\')');
  }

  /// Generate the new class based on the [target]
  ///
  /// it will create a constructor and add a factory method
  Class _buildClass(
    Class target, {
    ListBuilder<Field>? fields,
    ListBuilder<Method>? methods,
  }) {
    final hasEmbeddedFields = target.fields.any((e) => _isEmbedded(e));
    return Class(
      (c) => c
        ..name = '$_cachedPrefix${target.name}'
        ..annotations = ListBuilder([refer('Entity()')])
        ..mixins = ListBuilder([refer('HashMixin')])
        ..constructors = ListBuilder([
          Constructor(
            (c) => c
              ..external = false
              ..optionalParameters.addAll(
                target.fields.where((f) => !_isEmbedded(f)).map((t) {
                  return Parameter(
                    (p) => p
                      ..name = t.name
                      ..toThis = true
                      ..named = true
                      ..required = _isFieldNonNullable(t),
                  );
                }).toList(),
              ),
          ),
          if (hasEmbeddedFields) _factoryWithEmbedded(target),
          if (!hasEmbeddedFields) _factoryWithoutEmbedded(target),
        ])
        ..fields = fields ?? ListBuilder([])
        ..methods = methods ?? ListBuilder([]),
    );
  }

  /// build all properties of the generated class
  ListBuilder<Field> _buildFields(Class target) {
    final fields = target.fields.map((f) {
      return Field(
        (field) => field
          ..name = f.name
          ..modifier = FieldModifier.final$
          ..assignment = _buildRelations(f)
          ..annotations = ListBuilder([
            ..._buildIndexDecorators(f),
            ?_buildBacklinkDecorator(f),
          ])
          ..type = !_isEmbedded(f) ? f.type : null,
      );
    }).toBuiltList();

    final idField = Field(
      (field) => field
        ..name = 'databaseId'
        ..type = refer('int')
        ..assignment = Code('0')
        ..annotations = ListBuilder([refer('Id()')]),
    );

    // no let's add the toOne relation in the embedded class to
    // link it to it's parent.

    final embeddedRelations = embeddeOneToManyRelations.where(
      (rel) => rel.embeddedSymbol == target.name,
    );

    final relationFields = embeddedRelations.map(
      (e) => Field(
        (f) => f
          ..name = e.fieldName
          ..modifier = FieldModifier.final$
          ..assignment = Code('ToOne<$_cachedPrefix${e.targetName}>()'),
      ),
    );
    return ListBuilder([idField, ...fields, ...relationFields]);
  }

  /// Returns the annotations that have been set
  /// on the [origin] field as [cachedIndexDecorator]s
  List<Expression> _buildIndexDecorators(Field origin) {
    final annotations = <Expression>[];
    for (final decorator
        in origin.resolvedAnnotationsOfType<cachedIndexDecorator>()) {
      annotations.add(decorator.toExpression());
    }
    return annotations;
  }

  /// if the Field [f] is an embedded field,
  /// it will generate the relations else it will
  /// return null that results in the same assignement as the
  /// target class field
  Code? _buildRelations(Field f) {
    Code? code;

    if (_isEmbeddedIterable(f)) {
      final symbol = _getSymbolOfIterableFields(f);
      code = Code('ToMany<$_cachedPrefix$symbol>()');
    } else if (_isEmbedded(f)) {
      code = Code('ToOne<$_cachedPrefix${f.type?.symbol}>()');
    }

    return code;
  }

  /// returns a [Method] that will allow
  /// to copy a database model into a [CachedModel]
  Method _buildToModelMethod(Class target) {
    return Method(
      (m) => m
        ..name = 'toModel'
        ..returns = refer(target.name)
        ..body = Block.of([
          refer(target.name)
              .call([], {
                for (final f in target.fields.where((f) => !_isEmbedded(f)))
                  f.name: refer(f.name),
                for (final f in target.fields.where(
                  (f) =>
                      _isEmbedded(f) &&
                      !_isEmbeddedIterable(f) &&
                      _isFieldNonNullable(f),
                ))
                  f.name: refer('${f.name}.target!.toModel()'),
                for (final f in target.fields.where(
                  (f) =>
                      _isEmbedded(f) &&
                      !_isEmbeddedIterable(f) &&
                      !_isFieldNonNullable(f),
                ))
                  f.name: refer('${f.name}.target?.toModel()'),
                for (final f in target.fields.where(
                  (f) => _isEmbeddedIterable(f) && _isFieldNonNullable(f),
                ))
                  f.name: refer(
                    '${f.name}.map((e) => e.toModel()).to${f.type?.symbol}()',
                  ),
              })
              .returned
              .statement,
        ]),
    );
  }

  Code _destructureEmbeddedField(Field f) {
    List<Code> code = [];

    if (_isEmbeddedIterable(f)) {
      final String? symbol = _getSymbolOfIterableFields(f);
      code = [
        Code(''),
        Code('for (final el in model.${f.name}) {'),
        Code('final embeddedElement = $_cachedPrefix$symbol.fromModel(el);'),
        Code('cached.${f.name}.add(embeddedElement);'),
        Code('}'),
      ];
    } else if (_isEmbedded(f)) {
      code = [
        Code(''),
        Code(
          'final ${f.name} = $_cachedPrefix${f.type?.symbol}.fromModel(model.${f.name});',
        ),
        Code('cached.${f.name}.target = ${f.name};'),
      ];
    }

    return Block.of(code);
  }

  Constructor _factoryWithEmbedded(Class target) {
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
          refer('final cached = $_cachedPrefix${target.name}').call([], {
            for (final f in target.fields.where((f) => !_isEmbedded(f)))
              f.name: refer('model').property(f.name),
          }).statement,
          ...target.fields.map(_destructureEmbeddedField),
          ...[Code(''), Code('return cached;')],
        ]),
    );
  }

  Constructor _factoryWithoutEmbedded(Class target) {
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
          refer('$_cachedPrefix${target.name}')
              .call([], {
                for (final f in target.fields.where((f) => !_isEmbedded(f)))
                  f.name: refer('model').property(f.name),
              })
              .returned
              .statement,
        ]),
    );
  }

  String? _getSymbolOfIterableFields(Field f) =>
      (f.type as TypeReference).types.first.symbol;

  /// Check if the [f] field is annotated with [embedded]
  bool _isEmbedded(Field f) =>
      f.resolvedAnnotationsOfType<embedded>().isNotEmpty;

  /// Check if the [f] field is annotated with [embedded]
  /// and is implementing [Iterable], which means it it is
  /// some sort of [List], [Map], [Set]
  bool _isEmbeddedIterable(Field f) =>
      _isEmbedded(f) && {"List", "Map", "Set"}.contains(f.type?.symbol);

  /// Check if the [f] is non-nullable
  bool _isFieldNonNullable(Field f) {
    if (f.type == null) return false;

    // Use the emitter to get the proper string representation
    final emitter = DartEmitter.scoped(useNullSafetySyntax: true);
    final typeCode = f.type!.accept(emitter);
    return !typeCode.toString().endsWith('?');
  }

  /// Check if the [f] field is annotated with [indexed]
  bool _isIndexed(Field f) => f.resolvedAnnotationsOfType<indexed>().isNotEmpty;

  /// Check if the [f] field is annotated with [unique]
  bool _isUnique(Field f) => f.resolvedAnnotationsOfType<unique>().isNotEmpty;

  /// Run this pre-gen hook before code generation.
  ///
  /// It will collect information about all @Cached annotated classes
  /// that have embedded iterable fields. In order to link parent and embedded
  /// class, we need to edit both. This is an information that we do not have
  /// during code generation. So we collect this prior and store it in
  /// [embeddeOneToManyRelations].
  static void collectEmbeddedOneToManyRelations(LibraryBuilder builder) =>
      _collectEmbeddedOneToManyRelations();
}

class CachedAnnotationException implements Exception {
  final String message;
  final StackTrace stackTrace;
  const CachedAnnotationException(this.message, this.stackTrace);

  @override
  String toString() => 'CachedAnnotationException(message: $message)';
}

/// Base class for all decorators that are used on
/// [CachedModel]s
abstract base class cachedDecorator extends decorator {
  const cachedDecorator();

  @override
  Expression toExpression();
}

/// Base class for all [cachedDecorator] that are used
/// for indexing
abstract base class cachedIndexDecorator extends cachedDecorator {
  const cachedIndexDecorator();

  @override
  Expression toExpression();
}

/// This decorator marks a field as embedded
///
/// decorate a class field with this decorator
/// so that the database knows this is embedded
/// and will be stored as a sub-entity or linked entity
final class embedded extends cachedDecorator {
  const embedded();

  @override
  Expression toExpression() {
    return refer('Embedded()');
  }
}

mixin HashMixin {
  /// FNV-1a 64bit hash algorithm optimized for Dart Strings
  int fastHash(String string) {
    var hash = 0xcbf29ce484222325;

    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }

    return hash;
  }
}

/// This decorator marks a field as indexed
///
/// decorate a class field with this decorator
/// so that the database knows this is indexed
/// and improves search performance
///
/// this will not create a unique index and
/// entitys with the same field value will not overwrite each other.
/// If you want to create a unique index, use the [unique] decorator.
final class indexed extends cachedIndexDecorator {
  const indexed();

  @override
  Expression toExpression() {
    return refer('Index()');
  }
}

/// This decorator marks a field as unique
///
/// decorate a class field with this decorator
/// so that the database knows this is unique
///
/// by default [replaceOnConflict] is true so
/// that database entries with the same unique
/// index will be overwritten. Set this to false
/// to disable overwrite.
final class unique extends cachedIndexDecorator {
  final bool replaceOnConflict;
  const unique({this.replaceOnConflict = true});

  @override
  Expression toExpression() {
    return refer(
      'Unique(onConflict: ConflictStrategy.${replaceOnConflict ? 'replace' : 'fail'})',
    );
  }
}
