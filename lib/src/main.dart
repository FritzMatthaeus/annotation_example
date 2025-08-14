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

  store.box<CachedUser>().removeAll();
  store.box<CachedInfo>().removeAll();
  store.box<CachedUserWithInfos>().removeAll();

  final userBox = store.box<CachedUser>();
  final userWithInfosBox = store.box<CachedUserWithInfos>();

  final userId = userBox.put(CachedUser.fromModel(user));
  final userWithInfosId = userWithInfosBox.put(
    CachedUserWithInfos.fromModel(userWithInfos),
  );

  final cachedUser = userBox.get(userId);
  final cachedUserWithInfos = userWithInfosBox.get(userWithInfosId);

  final cachedUserToModel = cachedUser?.toModel();
  final cachedUserWithInfosToModel = cachedUserWithInfos?.toModel();

  final cachedUserToBeDeleted = CachedUser.fromModel(cachedUserToModel!);
  final cachedUserWithInfosToBeDeleted = CachedUserWithInfos.fromModel(
    cachedUserWithInfosToModel!,
  );

  final cachedInfos = store.box<CachedInfo>().getAll();

  cachedUserToBeDeleted.remove(store);
  cachedUserWithInfosToBeDeleted.remove(store);

  final userCount = userBox.count();
  final userWithInfosCount = userWithInfosBox.count();
  final infoCount = store.box<CachedInfo>().count();

  print(
    'userCount: $userCount / userWithInfosCount: $userWithInfosCount / infoCount: $infoCount',
  );
}
