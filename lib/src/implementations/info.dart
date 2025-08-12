// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:annotation_example/src/src.dart';

@Cached()
class Info {
  final String? firstName;
  final String lastName;

  const Info({required this.lastName, this.firstName});

  @override
  String toString() => 'Info(firstName: $firstName, lastName: $lastName)';
}
