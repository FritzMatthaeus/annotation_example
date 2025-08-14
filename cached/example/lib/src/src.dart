@CodeGen(
  runBefore: [Cached.collectEmbeddedOneToManyRelations],
  targets: ['gen'],
)
library;

import 'package:cached/cached.dart';

export 'info.dart';
export 'user.dart';
