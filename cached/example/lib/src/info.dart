import 'package:cached/cached.dart';

@Cached()
class Info extends CachedModel {
  final String? firstName;

  @indexed()
  final String lastName;

  Info({required super.id, required this.lastName, this.firstName});

  @override
  String toString() =>
      'Info(firstName: $firstName, lastName: $lastName, ${super.id})';
}
