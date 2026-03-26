import '../../domain/entities/gallery.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../datasources/mock_data.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  @override
  Future<List<Gallery>> getGalleries() async {
    return MockData.galleries;
  }

  @override
  Future<Gallery> getGalleryById(String id) async {
    return MockData.galleries.firstWhere((g) => g.id == id);
  }
}
