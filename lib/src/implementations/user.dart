import 'package:annotation_example/src/interfaces/model.dart';

class User extends Model {
  final String name;
  final String id;

  User({required this.name, required this.id});

  @override
  String toString() => "User(name: $name, id: $id)";
}
