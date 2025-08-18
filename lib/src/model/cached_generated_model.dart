import 'package:cached/cached.dart';

abstract interface class CachedGeneratedModel<T extends CachedModel> {
  /// This identifier is used to reference [databaseId] for
  /// code generation purposes.
  static const String databaseIdentifier = 'databaseId';

  /// This identifier is used to reference [id] for code
  /// generation purposes.
  static const String idIdentifier = 'id';

  int get databaseId;

  String get id;

  void remove(Store store);

  void removeAll(Store store);

  T toModel();
}
