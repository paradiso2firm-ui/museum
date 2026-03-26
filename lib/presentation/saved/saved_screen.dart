import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';

class SavedScreen extends ConsumerWidget {
  final void Function(String exhibitionId)? onExhibitionTap;

  const SavedScreen({super.key, this.onExhibitionTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedExhibitionsProvider);
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR COLLECTION',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Saved',
                  style: GoogleFonts.newsreader(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.05,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Saved exhibitions list
        savedAsync.when(
          data: (exhibitions) => exhibitions.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark_border, size: 48, color: AppColors.outline),
                        const SizedBox(height: 12),
                        Text(
                          'No saved exhibitions yet',
                          style: textTheme.bodyLarge?.copyWith(color: AppColors.outline),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList.separated(
                    itemCount: exhibitions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final exhibition = exhibitions[index];
                      return GestureDetector(
                        onTap: () => onExhibitionTap?.call(exhibition.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 8),
                                blurRadius: 24,
                                color: AppColors.ambientShadow,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 110,
                                height: 140,
                                child: CachedNetworkImage(
                                  imageUrl: exhibition.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      Container(color: AppColors.surfaceContainerLow),
                                  errorWidget: (_, __, ___) =>
                                      Container(color: AppColors.surfaceContainerLow),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exhibition.title,
                                        style: GoogleFonts.newsreader(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        exhibition.venue,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 12, color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              exhibition.dateRange,
                                              style: textTheme.bodySmall?.copyWith(
                                                color: AppColors.onSurfaceVariant,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              await toggleSaved(ref, exhibition.id);
                                            },
                                            child: const Icon(Icons.favorite,
                                                size: 16, color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
          error: (e, _) => SliverFillRemaining(
            child: Center(child: Text('Error: $e')),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}
