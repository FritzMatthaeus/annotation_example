import 'package:annotation_example/src/src.dart';

final class MyCachedRepo<T extends CachedModel>
    extends CachedRepositoryBase<T> {
  final Api<T> api;
  MyCachedRepo({required super.storageService, required this.api});

  @override
  Future<void> post(T model) async {
    await api.save(model);
    super.post(model);
  }
}
