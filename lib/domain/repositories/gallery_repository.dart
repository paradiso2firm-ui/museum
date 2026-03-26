import '../entities/gallery.dart';

abstract class GalleryRepository {
  Future<List<Gallery>> getGalleries();
  Future<Gallery> getGalleryById(String id);
}
