import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';
import 'widgets/gallery_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  late final TextEditingController _searchController;

  static const _allTags = [
    'Sculpture', 'Minimalist', 'Workshop', 'Oil Paint', 'Library', 'History',
    'Canvas', 'Modern', 'Installation', 'Glass', 'Photography', 'Darkroom',
    'Ceramics', 'Handmade', 'Digital', 'AI Art', 'Mosaic', 'Classical',
    'Calligraphy', 'Print', 'Sound', 'Immersive', 'Outdoor',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(gallerySearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredGalleriesProvider);
    final query = ref.watch(gallerySearchQueryProvider);
    final selectedTag = ref.watch(galleryTagFilterProvider);
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        // Editorial Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURATED SELECTION',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Artisan Spaces',
                  style: GoogleFonts.newsreader(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      ref.read(gallerySearchQueryProvider.notifier).state = v,
                  decoration: InputDecoration(
                    hintText: 'Search galleries...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(gallerySearchQueryProvider.notifier)
                                  .state = '';
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Tag filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _TagChip(
                        label: 'All',
                        selected: selectedTag == null,
                        onTap: () => ref
                            .read(galleryTagFilterProvider.notifier)
                            .state = null,
                      ),
                      const SizedBox(width: 8),
                      ..._allTags.map((tag) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _TagChip(
                              label: tag,
                              selected: selectedTag == tag,
                              onTap: () => ref
                                  .read(galleryTagFilterProvider.notifier)
                                  .state = selectedTag == tag ? null : tag,
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Gallery Cards
        filteredAsync.when(
          data: (galleries) => galleries.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No galleries found.',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: galleries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return GalleryCard(
                        gallery: galleries[index],
                        onTap: () {
                          context.push('/explore/gallery/${galleries[index].id}');
                        },
                      );
                    },
                  ),
                ),
          loading: () => const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (e, _) =>
              SliverFillRemaining(child: Center(child: Text('Error: $e'))),
        ),
        // Bottom padding for nav bar
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TagChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
