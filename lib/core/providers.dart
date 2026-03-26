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

// Refresh trigger for saved state changes
final _savedRefreshProvider = StateProvider<int>((_) => 0);

// Data providers
final galleriesProvider = FutureProvider<List<Gallery>>((ref) {
  return ref.watch(galleryRepositoryProvider).getGalleries();
});

final galleryProvider = FutureProvider.family<Gallery, String>((ref, id) {
  return ref.watch(galleryRepositoryProvider).getGalleryById(id);
});

final exhibitionsProvider = FutureProvider<List<Exhibition>>((ref) {
  ref.watch(_savedRefreshProvider);
  return ref.watch(exhibitionRepositoryProvider).getExhibitions();
});

final exhibitionProvider = FutureProvider.family<Exhibition, String>((ref, id) {
  ref.watch(_savedRefreshProvider);
  return ref.watch(exhibitionRepositoryProvider).getExhibitionById(id);
});

final savedExhibitionsProvider = FutureProvider<List<Exhibition>>((ref) {
  ref.watch(_savedRefreshProvider);
  return ref.watch(exhibitionRepositoryProvider).getSavedExhibitions();
});

final userProfileProvider = Provider<UserProfile>(
  (_) => MockData.userProfile,
);

// Toggle saved and refresh all dependent providers
Future<void> toggleSaved(WidgetRef ref, String exhibitionId) async {
  await ref.read(exhibitionRepositoryProvider).toggleSaved(exhibitionId);
  ref.read(_savedRefreshProvider.notifier).state++;
}

// Navigation state
final selectedTabProvider = StateProvider<int>((_) => 0);
