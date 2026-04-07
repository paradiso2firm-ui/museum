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

final userProfileProvider = Provider<UserProfile>((_) => MockData.userProfile);

// Toggle saved and refresh all dependent providers
Future<void> toggleSaved(WidgetRef ref, String exhibitionId) async {
  await ref.read(exhibitionRepositoryProvider).toggleSaved(exhibitionId);
  ref.read(_savedRefreshProvider.notifier).state++;
}

// Navigation state
final selectedTabProvider = StateProvider<int>((_) => 0);

// Search & filter state — Explore (Galleries)
final gallerySearchQueryProvider = StateProvider<String>((_) => '');
final galleryTagFilterProvider = StateProvider<String?>((_) => null);

final filteredGalleriesProvider = Provider<AsyncValue<List<Gallery>>>((ref) {
  final galleriesAsync = ref.watch(galleriesProvider);
  final query = ref.watch(gallerySearchQueryProvider).toLowerCase().trim();
  final tag = ref.watch(galleryTagFilterProvider);

  return galleriesAsync.whenData((galleries) {
    return galleries.where((g) {
      final matchesQuery = query.isEmpty ||
          g.name.toLowerCase().contains(query) ||
          g.description.toLowerCase().contains(query) ||
          g.tags.any((t) => t.toLowerCase().contains(query));
      final matchesTag = tag == null || g.tags.contains(tag);
      return matchesQuery && matchesTag;
    }).toList();
  });
});

// Search & filter state — Exhibitions
final exhibitionSearchQueryProvider = StateProvider<String>((_) => '');
final exhibitionBadgeFilterProvider = StateProvider<String?>((_) => null);

final filteredExhibitionsProvider = Provider<AsyncValue<List<Exhibition>>>((ref) {
  final exhibitionsAsync = ref.watch(exhibitionsProvider);
  final query = ref.watch(exhibitionSearchQueryProvider).toLowerCase().trim();
  final badge = ref.watch(exhibitionBadgeFilterProvider);

  return exhibitionsAsync.whenData((exhibitions) {
    return exhibitions.where((e) {
      final matchesQuery = query.isEmpty ||
          e.title.toLowerCase().contains(query) ||
          e.venue.toLowerCase().contains(query);
      final matchesBadge = badge == null ||
          (badge == 'Free' && e.priceLabel.toLowerCase().contains('free')) ||
          (e.badge == badge);
      return matchesQuery && matchesBadge;
    }).toList();
  });
});
