import 'package:cached/src/src.dart';
import 'package:objectbox/objectbox.dart';

/// Each model that is supposed to be stored in a [Box]
/// must extend this class
abstract class CachedModel {
  /// This identifier is used to reference [databaseId] for
  /// code generation purposes.
  static const String databaseIdentifier = 'databaseId';

  /// unique identifier provided by the server
  /// that is used to query data and to
  /// overwrite data
  @unique()
  final String id;

  /// unique identifier provided by the [Box]
  /// after the model has first been inserted into
  /// the database
  ///
  /// it will default to 0 telling the database that
  /// this is a new entry
  @Id()
  int databaseId;

  CachedModel({required this.id, this.databaseId = 0});

  @override
  String toString() => 'id: $id, databaseId: $databaseId';
}
