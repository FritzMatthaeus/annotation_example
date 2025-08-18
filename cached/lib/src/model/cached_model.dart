/// Each model that is supposed to be stored in a [Box]
/// must implement this class
///
/// it would be great if we could just extend this class
/// but unfortunately this is not working with super_annotations
/// as we cannot access parent class fields in code generation
abstract interface class CachedModel<T> {
  /// unique identifier provided by the [Box]
  /// after the model has first been inserted into
  /// the database
  int? get databaseId;

  /// unique identifier provided by the server
  /// that is used to query data and to
  /// overwrite data
  ///
  /// this field will automatically be indexed
  /// as unique
  String get id;

  T copyWith();

  @override
  String toString() => 'id: $id, databaseId: $databaseId';
}
