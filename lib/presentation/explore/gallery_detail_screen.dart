import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';
import '../exhibitions/widgets/exhibition_card.dart';

class GalleryDetailScreen extends ConsumerWidget {
  final String galleryId;

  const GalleryDetailScreen({super.key, required this.galleryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(galleryProvider(galleryId));
    final exhibitionsAsync = ref.watch(exhibitionsProvider);
    final textTheme = Theme.of(context).textTheme;

    return galleryAsync.when(
      data: (gallery) => Scaffold(
        backgroundColor: AppColors.surface,
        body: CustomScrollView(
          slivers: [
            // Hero image
            SliverAppBar(
              expandedHeight: 380,
              pinned: true,
              backgroundColor: AppColors.surfaceContainerLowest,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: AppColors.surfaceContainerLowest.withValues(
                    alpha: 0.8,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerLowest
                        .withValues(alpha: 0.8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.share_outlined,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        Share.share(
                          '${gallery.name} — ${gallery.description}\n${gallery.priceLabel}',
                        );
                      },
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: gallery.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppColors.surfaceContainerLow),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.surfaceContainerLow),
                    ),
                    // Bottom gradient
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 160,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.surface, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating header card
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 8),
                          blurRadius: 24,
                          color: AppColors.ambientShadow,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'GALLERY',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onPrimaryContainer,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              gallery.priceLabel,
                              style: textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          gallery.name,
                          style: GoogleFonts.newsreader(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          gallery.description,
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: gallery.tags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    tag.toUpperCase(),
                                    style: textTheme.labelSmall?.copyWith(
                                      fontSize: 10,
                                      color: AppColors.onSurfaceVariant,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Info tiles
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.near_me_outlined,
                        label: 'DISTANCE',
                        value: '${gallery.distanceMiles} miles',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.palette_outlined,
                        label: 'SPECIALTY',
                        value: gallery.tags.isNotEmpty
                            ? gallery.tags.first
                            : 'Art',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(top: 32)),

            // Current Exhibitions header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Current Exhibitions',
                      style: GoogleFonts.newsreader(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(top: 16)),

            // Exhibition cards from this gallery
            exhibitionsAsync.when(
              data: (exhibitions) {
                // Show first 2 exhibitions as related content
                final related = exhibitions.take(2).toList();
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList.separated(
                    itemCount: related.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 32),
                    itemBuilder: (context, index) {
                      return ExhibitionCard(
                        exhibition: related[index],
                        onTap: () {
                          context.push(
                            '/explore/exhibition/${related[index].id}',
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // Location section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixedDim.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: GoogleFonts.newsreader(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Map image — tappable to open maps app
                      GestureDetector(
                        onTap: () {
                          if (gallery.latitude != null && gallery.longitude != null) {
                            final uri = Uri.parse(
                              'https://maps.apple.com/?q=${Uri.encodeComponent(gallery.name)}&ll=${gallery.latitude},${gallery.longitude}',
                            );
                            launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (gallery.latitude != null && gallery.longitude != null)
                                CachedNetworkImage(
                                  imageUrl:
                                      'https://maps.googleapis.com/maps/api/staticmap?center=${gallery.latitude},${gallery.longitude}&zoom=15&size=600x280&scale=2&maptype=roadmap&style=feature:all|saturation:-100&markers=color:0xA43C12|${gallery.latitude},${gallery.longitude}&key=',
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => const Center(
                                    child: Icon(Icons.map_outlined, size: 40, color: AppColors.outline),
                                  ),
                                )
                              else
                                const Center(
                                  child: Icon(Icons.map_outlined, size: 40, color: AppColors.outline),
                                ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.open_in_new, size: 12, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Open in Maps',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${gallery.distanceMiles} miles away',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Visit button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: FilledButton(
                  onPressed: () {
                    if (gallery.latitude != null && gallery.longitude != null) {
                      final uri = Uri.parse(
                        'https://maps.apple.com/?daddr=${gallery.latitude},${gallery.longitude}&dirflg=w',
                      );
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: const StadiumBorder(),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  child: Text(
                    'PLAN YOUR VISIT',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 2,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
