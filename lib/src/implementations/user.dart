import 'package:annotation_example/src/src.dart';

@Cached()
class User implements Model {
  @embedded()
  final Info info;

  final String? name;

  @indexed()
  @override
  final String id;

  const User({required this.id, required this.info, this.name});

  @override
  String toString() => "User(name: $name, id: $id, info: $info)";
}
