import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/gallery_repository_impl.dart';
import '../data/repositories/exhibition_repository_impl.dart';
import '../domain/entities/gallery.dart';
import '../domain/entities/exhibition.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/gallery_repository.dart';
import '../domain/repositories/exhibition_repository.dart';
import '../data/datasources/mock_data.dart';

// Repository providers
final galleryRepositoryProvider = Provider<GalleryRepository>(
  (_) => GalleryRepositoryImpl(),
);

final exhibitionRepositoryProvider = Provider<ExhibitionRepository>(
  (_) => ExhibitionRepositoryImpl(),
);

// Data providers
final galleriesProvider = FutureProvider<List<Gallery>>((ref) {
  return ref.watch(galleryRepositoryProvider).getGalleries();
});

final exhibitionsProvider = FutureProvider<List<Exhibition>>((ref) {
  return ref.watch(exhibitionRepositoryProvider).getExhibitions();
});

final exhibitionProvider = FutureProvider.family<Exhibition, String>((ref, id) {
  return ref.watch(exhibitionRepositoryProvider).getExhibitionById(id);
});

final savedExhibitionsProvider = FutureProvider<List<Exhibition>>((ref) {
  return ref.watch(exhibitionRepositoryProvider).getSavedExhibitions();
});

final userProfileProvider = Provider<UserProfile>(
  (_) => MockData.userProfile,
);

// Navigation state
final selectedTabProvider = StateProvider<int>((_) => 0);
