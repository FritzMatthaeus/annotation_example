part of 'user.dart';

extension $User on User {
  Future<User?> get(User m, StorageService<User> st) {
    return st.get(m.id);
  }

  Future<void> delete(User m, StorageService st) {
    return st.delete(m.id);
  }
}
