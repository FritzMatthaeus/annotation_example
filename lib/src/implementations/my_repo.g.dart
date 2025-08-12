part of 'my_repo.dart';

extension $MyRepo on MyRepo {
  Future<User?> getUserById({required String id}) {
    return storageService.get(id);
  }
}
