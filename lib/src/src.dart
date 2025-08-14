@CodeGen(
  runBefore: [Cached.collectEmbeddedOneToManyRelations],
  targets: ['gen'],
)
library;

import 'package:super_annotations/super_annotations.dart';

import 'annotations/annotations.dart';

export 'annotations/annotations.dart';
export 'implementations/implementations.dart';
export 'interfaces/interfaces.dart';
export 'main.dart';
