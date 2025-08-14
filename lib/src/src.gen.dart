import 'package:objectbox/objectbox.dart';
import 'package:annotation_example/src/src.dart';

@Entity()
class CachedInfo with HashMixin {
  CachedInfo({required this.id, this.firstName, required this.lastName});

  factory CachedInfo.fromModel(Info model) {
    return CachedInfo(
      id: model.id,
      firstName: model.firstName,
      lastName: model.lastName,
    );
  }

  @Id()
  int databaseId = 0;

  @Unique(onConflict: ConflictStrategy.replace)
  final String id;

  final String? firstName;

  @Index()
  final String lastName;

  final infos = ToOne<CachedUserWithInfos>();

  Info toModel() {
    return Info(id: id, firstName: firstName, lastName: lastName);
  }
}

@Entity()
class CachedUser with HashMixin {
  CachedUser({this.name, required this.id});

  factory CachedUser.fromModel(User model) {
    final cached = CachedUser(name: model.name, id: model.id);

    final info = CachedInfo.fromModel(model.info);
    cached.info.target = info;

    return cached;
  }

  @Id()
  int databaseId = 0;

  final info = ToOne<CachedInfo>();

  final String? name;

  @Unique(onConflict: ConflictStrategy.replace)
  final String id;

  User toModel() {
    return User(name: name, id: id, info: info.target!.toModel());
  }
}

@Entity()
class CachedUserWithInfos with HashMixin {
  CachedUserWithInfos({this.name, required this.id});

  factory CachedUserWithInfos.fromModel(UserWithInfos model) {
    final cached = CachedUserWithInfos(name: model.name, id: model.id);

    for (final el in model.infos) {
      final embeddedElement = CachedInfo.fromModel(el);
      cached.infos.add(embeddedElement);
    }

    return cached;
  }

  @Id()
  int databaseId = 0;

  @Backlink('infos')
  final infos = ToMany<CachedInfo>();

  final String? name;

  @Unique(onConflict: ConflictStrategy.replace)
  final String id;

  UserWithInfos toModel() {
    return UserWithInfos(
      name: name,
      id: id,
      infos: infos.map((e) => e.toModel()).toList(),
    );
  }
}
