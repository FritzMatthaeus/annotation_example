// ignore_for_file: camel_case_types

import 'package:super_annotations/super_annotations.dart';

/// Base class for all decorators
abstract base class decorator {
  const decorator();

  Expression toExpression();
}
