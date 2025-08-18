import 'package:cached/cached.dart';

@Cached()
class Info implements CachedModel {
  final String? firstName;

  @indexed()
  final String lastName;

  @override
  String id;

  @override
  int databaseId;

  Info({
    required this.id,
    required this.lastName,
    this.databaseId = 0,
    this.firstName,
  });

  @override
  Info copyWith({
    String? id,
    String? firstName,
    String? lastName,
    int? databaseId,
  }) {
    return Info(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      databaseId: databaseId ?? this.databaseId,
      firstName: firstName ?? this.firstName,
    );
  }

  @override
  String toString() =>
      'Info(firstName: $firstName, lastName: $lastName, ${super.toString()})';
}
