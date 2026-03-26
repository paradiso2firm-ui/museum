import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';
import 'widgets/exhibition_card.dart';

class ExhibitionsListScreen extends ConsumerWidget {
  final void Function(String exhibitionId)? onExhibitionTap;

  const ExhibitionsListScreen({super.key, this.onExhibitionTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exhibitionsAsync = ref.watch(exhibitionsProvider);
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        // Editorial Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
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
                  'Exhibitions',
                  style: GoogleFonts.newsreader(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.05,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Text(
                    "Explore the season's most compelling visual narratives across the city's premier cultural institutions.",
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Exhibition Feed
        exhibitionsAsync.when(
          data: (exhibitions) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList.separated(
              itemCount: exhibitions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 48),
              itemBuilder: (context, index) {
                return ExhibitionCard(
                  exhibition: exhibitions[index],
                  onTap: () => onExhibitionTap?.call(exhibitions[index].id),
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
