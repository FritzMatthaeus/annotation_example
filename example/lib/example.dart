import 'package:cached/cached.dart';
import 'package:example/objectbox.g.dart';

import 'src/src.dart';
import 'src/src.gen.dart';

void test() {
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

  cachedUserToBeDeleted.remove(store);
  cachedUserWithInfosToBeDeleted.remove(store);

  final userCount = userBox.count();
  final userWithInfosCount = userWithInfosBox.count();
  final infoCount = store.box<CachedInfo>().count();

  print(
    'userCount: $userCount / userWithInfosCount: $userWithInfosCount / infoCount: $infoCount',
  );
}

void testWithManager() async {
  final dbService = await DatabaseService.create(getStore: openStore);
  dbService.registerManagerFactory(UserWithInfosManager.new);
  final userWithInfosManager = dbService.getManager<UserWithInfosManager>();

  final userWithInfos = UserWithInfos(
    id: '1',
    name: 'Fritze',
    infos: [
      Info(id: 'info_1', lastName: 'Matthäus', firstName: 'Fritz'),
      Info(id: 'info_2', lastName: 'Matthäus', firstName: 'Max'),
      Info(id: 'info_3', lastName: 'Matthäus', firstName: 'Evi'),
    ],
  );

  final userWithInfosId = userWithInfosManager.put(
    CachedUserWithInfos.fromModel(userWithInfos),
  );

  final foundUserWithInfos = userWithInfosManager.getByFirstName('Fritz');
  final foundUserWithInfosByDatabaseId = userWithInfosManager.getByDatabaseId(
    userWithInfosId,
  );

  final foundUserById = userWithInfosManager.getById(
    userWithInfos.id,
    CachedUserWithInfos_.id,
  );

  print(foundUserWithInfos);
  print(foundUserWithInfosByDatabaseId);
  print(foundUserById);
}

class UserWithInfosManager
    extends CachedModelManager<UserWithInfos, CachedUserWithInfos> {
  UserWithInfosManager(super.store);

  UserWithInfos? getByFirstName(String firstName) {
    final query = store
        .box<CachedInfo>()
        .query(CachedInfo_.firstName.equals(firstName))
        .build();
    final info = query.findFirst();
    final user = info?.userWithInfos.target;
    return user?.toModel();
  }
}
