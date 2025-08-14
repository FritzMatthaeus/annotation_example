import 'package:annotation_example/src/src.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CachedInfo with HashMixin {
  @Id()
  int databaseId;

  @Unique(onConflict: ConflictStrategy.replace)
  final String id;

  final String? firstName;

  @Index()
  final String lastName;

  final infos = ToOne<CachedUserWithInfos>();

  CachedInfo({
    required this.id,
    this.firstName,
    required this.lastName,
    this.databaseId = 0,
  });

  factory CachedInfo.fromModel(Info model) {
    return CachedInfo(
      id: model.id,
      firstName: model.firstName,
      lastName: model.lastName,
      databaseId: model.databaseId,
    );
  }

  Info toModel() {
    return Info(
      id: id,
      firstName: firstName,
      lastName: lastName,
      databaseId: databaseId,
    );
  }
}

@Entity()
class CachedUser with HashMixin {
  @Id()
  int databaseId;

  final info = ToOne<CachedInfo>();

  final String? name;

  @Unique(onConflict: ConflictStrategy.replace)
  final String id;

  CachedUser({this.name, required this.id, this.databaseId = 0});

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

  void remove(Store store) {
    final entry = store.box<CachedUser>().get(databaseId);
    store.box<CachedInfo>().remove(entry!.info.targetId);
    store.box<CachedUser>().remove(entry.databaseId);
  }

  User toModel() {
    return User(
      name: name,
      id: id,
      info: info.target!.toModel(),
      databaseId: databaseId,
    );
  }
}

@Entity()
class CachedUserWithInfos with HashMixin {
  @Id()
  int databaseId;

  @Backlink('infos')
  final infos = ToMany<CachedInfo>();

  final String? name;

  @Unique(onConflict: ConflictStrategy.replace)
  final String id;

  CachedUserWithInfos({this.name, required this.id, this.databaseId = 0});

  factory CachedUserWithInfos.fromModel(UserWithInfos model) {
    final cached = CachedUserWithInfos(
      name: model.name,
      id: model.id,
      databaseId: model.databaseId,
    );

    for (final el in model.infos) {
      final embeddedElement = CachedInfo.fromModel(el);
      cached.infos.add(embeddedElement);
    }

    return cached;
  }

  void remove(Store store) {
    store.box<CachedUserWithInfos>().remove(databaseId);
    store.box<CachedInfo>().removeMany(infos.map((e) => e.databaseId).toList());
  }

  UserWithInfos toModel() {
    return UserWithInfos(
      name: name,
      id: id,
      infos: infos.map((e) => e.toModel()).toList(),
      databaseId: databaseId,
    );
  }
}
