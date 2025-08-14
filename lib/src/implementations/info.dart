// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:annotation_example/src/src.dart';

@Cached()
class Info implements CachedModel {
  @override
  @unique()
  final String id;

  final String? firstName;

  @indexed()
  final String lastName;

  int databaseId;

  Info({
    required this.id,
    required this.lastName,
    this.firstName,
    this.databaseId = 0,
  });

  @override
  String toString() => 'Info(firstName: $firstName, lastName: $lastName)';
}
