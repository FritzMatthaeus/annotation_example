import 'package:objectbox/objectbox.dart';
import 'package:annotation_example/src/src.dart';

@Entity()
class CachedInfo {
  const CachedInfo._({this.firstName, required this.lastName});

  factory CachedInfo.fromModel(Info model) {
    return CachedInfo._(firstName: model.firstName, lastName: model.lastName);
  }

  final String? firstName;

  final String lastName;
}

@Entity()
class CachedUser {
  CachedUser._({this.name, required this.id});

  factory CachedUser.fromModel(User model) {
    final cached = CachedUser._(name: model.name, id: model.id);

    final info = CachedInfo.fromModel(model.info);
    cached.info.target = info;

    return cached;
  }

  final info = ToOne<CachedInfo>();

  final String? name;

  @Index()
  final String id;
}
