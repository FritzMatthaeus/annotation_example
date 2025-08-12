import 'package:annotation_example/src/src.dart';

void main() async {
  final myRepo = MyRepo(MyStorageService());
  final user = await myRepo.getUserById(id: "fritz");
  print(user);
  myRepo.dispose();
}
