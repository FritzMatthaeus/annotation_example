import 'package:annotation_example/objectbox.g.dart';
import 'package:annotation_example/src/src.dart';
import 'package:annotation_example/src/src.gen.dart';

void main() async {
  final store = openStore();
  final user = User(
    id: '1',
    name: 'Fritze',
    info: Info(id: 'info_1', lastName: 'Matthäus', firstName: 'Fritz'),
  );

  final userWithInfos = UserWithInfos(
    id: '2',
    name: "Max",
    infos: [
      Info(id: 'info_2', lastName: 'Matthäus', firstName: 'Max'),
      Info(id: 'info_3', lastName: 'Matthäus', firstName: 'Evi'),
    ],
  );
  final userWithInfos2 = UserWithInfos(
    id: '2',
    name: "Max",
    infos: [Info(id: 'info_4', lastName: 'Matthäus', firstName: 'Bernd')],
  );

  final userBox = store.box<CachedUser>();
  final userWithInfosBox = store.box<CachedUserWithInfos>();

  userBox.put(CachedUser.fromModel(user));
  final userWithInfosId = userWithInfosBox.put(
    CachedUserWithInfos.fromModel(userWithInfos),
  );

  final cachedUser = userBox
      .query(CachedUser_.id.equals(user.id))
      .build()
      .find();
  for (final u in cachedUser) {
    print(u.toModel());
  }

  final cachedUserWithInfos = userWithInfosBox.get(userWithInfosId)?.toModel();

  if (cachedUserWithInfos == null) {
    print("cached user with infos is null");
    return;
  }
  for (final info in cachedUserWithInfos.infos) {
    print("cached user: $info");
  }

  userWithInfosBox
      .query(CachedUserWithInfos_.id.equals(user.id))
      .build()
      .remove();

  final userWithInfos2Id = userWithInfosBox.put(
    CachedUserWithInfos.fromModel(userWithInfos2),
  );

  final cachedUserWithInfos2 = userWithInfosBox
      .get(userWithInfos2Id)
      ?.toModel();

  if (cachedUserWithInfos2 == null) {
    print("cached user2 with infos is null");
    return;
  }
  for (final info in cachedUserWithInfos2.infos) {
    print("cached user2: $info");
  }

  final cachedInfos = store.box<CachedInfo>().getAll();
  for (final cachedInfo in cachedInfos) {
    print("info: ${cachedInfo.toModel()}");
  }
}
