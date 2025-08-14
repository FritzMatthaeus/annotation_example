// ignore_for_file: camel_case_types

import 'package:super_annotations/super_annotations.dart';

/// Base class for all decorators that are used on
/// [CachedModel]s
abstract base class cachedDecorator {
  const cachedDecorator();

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
