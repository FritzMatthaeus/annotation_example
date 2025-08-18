@CodeGen(
  runBefore: [Cached.collectEmbeddedOneToManyRelations],
  targets: ['gen'],
)
library;

import 'package:cached/cached.dart';

export 'models/info.dart';
export 'models/user.dart';
