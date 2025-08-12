@CodeGen(runAfter: [CodeGen.addPartOfDirective])
import 'package:annotation_example/src/src.dart';
import 'package:super_annotations/super_annotations.dart';

part 'user.g.dart';

@Cached()
class User implements CachedModel {
  final String name;

  @override
  final String id;

  const User({required this.name, required this.id});

  @override
  Future<void> delete(CachedModel m, StorageService st) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<CachedModel?> get(CachedModel m, StorageService st) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  String toString() => "User(name: $name, id: $id)";
}
