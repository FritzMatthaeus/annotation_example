import 'package:annotation_example/src/src.dart';

@Cached()
class User implements CachedModel {
  @embedded()
  final Info info;

  final String? name;

  @unique()
  @override
  final String id;

  int databaseId;

  User({required this.id, required this.info, this.name, this.databaseId = 0});

  @override
  String toString() => "User(name: $name, id: $id, info: $info)";
}

@Cached()
class UserWithInfos implements CachedModel {
  @embedded()
  final List<Info> infos;

  final String? name;

  @unique()
  @override
  final String id;

  int databaseId;

  UserWithInfos({
    required this.id,
    required this.infos,
    this.name,
    this.databaseId = 0,
  });

  @override
  String toString() => "User(name: $name, id: $id, info: $infos)";
}
