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
  String toString() =>
      'Info(firstName: $firstName, lastName: $lastName, ${super.toString()})';
}
