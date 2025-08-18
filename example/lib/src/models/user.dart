import 'package:cached/cached.dart';
import 'package:example/src/models/info.dart';

@Cached()
class User implements CachedModel {
  @embedded()
  Info? info;

  final String? name;

  @override
  String id;

  @override
  int databaseId;

  User({required this.id, required this.info, this.name, this.databaseId = 0});

  @override
  User copyWith({String? id, int? databaseId, Info? info, String? name}) {
    return User(
      id: id ?? this.id,
      databaseId: databaseId ?? this.databaseId,
      info: info ?? this.info,
      name: name ?? this.name,
    );
  }

  @override
  String toString() =>
      "User(name: $name, id: $id, info: $info, ${super.toString()})";
}

@Cached()
class UserWithInfos implements CachedModel {
  @override
  String id;

  @override
  int databaseId;

  @embedded()
  final List<Info> infos;

  final String? name;

  UserWithInfos({
    required this.id,
    required this.infos,
    this.name,
    this.databaseId = 0,
  });

  @override
  UserWithInfos copyWith({
    String? id,
    int? databaseId,
    List<Info>? infos,
    String? name,
  }) {
    return UserWithInfos(
      id: id ?? this.id,
      databaseId: databaseId ?? this.databaseId,
      infos: infos ?? this.infos,
      name: name ?? this.name,
    );
  }

  @override
  String toString() =>
      "User(name: $name, id: $id, info: $infos, ${super.toString()})";
}
