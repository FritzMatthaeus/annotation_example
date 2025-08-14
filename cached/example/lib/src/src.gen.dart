import 'package:cached/cached.dart';

import 'src.dart';

@Entity()
class CachedInfo with HashMixin {
  String? firstName;

  @Index()
  String lastName;

  @Unique(onConflict: ConflictStrategy.replace)
  String id;

  @Id()
  int databaseId;

  final infos = ToOne<CachedUserWithInfos>();

  CachedInfo({
    this.firstName,
    required this.lastName,
    required this.id,
    required this.databaseId,
  });

  factory CachedInfo.fromModel(Info model) {
    return CachedInfo(
      firstName: model.firstName,
      lastName: model.lastName,
      id: model.id,
      databaseId: model.databaseId,
    );
  }

  Info toModel() {
    return Info(
      firstName: firstName,
      lastName: lastName,
      id: id,
      databaseId: databaseId,
    );
  }
}

@Entity()
class CachedUser with HashMixin {
  var info = ToOne<CachedInfo>();

  String? name;

  @Unique(onConflict: ConflictStrategy.replace)
  String id;

  @Id()
  int databaseId;

  CachedUser({this.name, required this.id, required this.databaseId});

  factory CachedUser.fromModel(User model) {
    final cached = CachedUser(
      name: model.name,
      id: model.id,
      databaseId: model.databaseId,
    );

    final info = CachedInfo.fromModel(model.info);
    cached.info.target = info;

    return cached;
  }

  User toModel() {
    return User(
      name: name,
      id: id,
      databaseId: databaseId,
      info: info.target!.toModel(),
    );
  }
}

@Entity()
class CachedUserWithInfos with HashMixin {
  @Unique(onConflict: ConflictStrategy.replace)
  String id;

  @Id()
  int databaseId;

  @Backlink('infos')
  var infos = ToMany<CachedInfo>();

  String? name;

  CachedUserWithInfos({required this.id, required this.databaseId, this.name});

  factory CachedUserWithInfos.fromModel(UserWithInfos model) {
    final cached = CachedUserWithInfos(
      id: model.id,
      databaseId: model.databaseId,
      name: model.name,
    );

    for (final el in model.infos) {
      final embeddedElement = CachedInfo.fromModel(el);
      cached.infos.add(embeddedElement);
    }

    return cached;
  }

  UserWithInfos toModel() {
    return UserWithInfos(
      id: id,
      databaseId: databaseId,
      name: name,
      infos: infos.map((e) => e.toModel()).toList(),
    );
  }
}
