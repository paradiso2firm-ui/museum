import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/utils/dev_snackbar.dart';

import '../../domain/entities/exhibition.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleriesAsync = ref.watch(galleriesProvider);
    final exhibitionsAsync = ref.watch(exhibitionsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        // Map placeholder background
        Positioned.fill(
          child: Container(
            color: AppColors.surfaceContainerLow,
            child: Stack(
              children: [
                // Grid pattern to simulate map
                CustomPaint(size: Size.infinite, painter: _MapGridPainter()),
                // Mock markers
                galleriesAsync.when(
                  data: (galleries) => Stack(
                    children: [
                      for (var i = 0; i < galleries.length; i++)
                        Positioned(
                          top: 120.0 + (i * 100) + (i.isEven ? 40 : 0),
                          left: 40.0 + (i * 70),
                          child: _MapMarker(
                            label: galleries[i].name,
                            isSelected: i == 0,
                          ),
                        ),
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),

        // Floating search bar
        Positioned(
          top: 12,
          left: 20,
          right: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(
                    alpha: 0.9,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 16,
                      color: AppColors.ambientShadow,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search museums or areas...',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                    const Icon(Icons.tune, color: AppColors.outline, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Filter chips
        Positioned(
          top: 72,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(label: 'Nearby', isSelected: true),
                const SizedBox(width: 8),
                _FilterChip(label: 'Contemporary Art'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Sculpture Garden'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Photography'),
              ],
            ),
          ),
        ),

        // Bottom sheet peek
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _BottomSheetPeek(exhibitionsAsync: exhibitionsAsync),
        ),

        // My location FAB
        Positioned(
          bottom: 260,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  color: AppColors.ambientShadow,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => showDevSnackBar(context, '현재 위치'),
              icon: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _MapMarker({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSelected ? 40 : 32,
          height: isSelected ? 40 : 32,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceContainerLowest,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? AppColors.surfaceContainerLowest
                  : AppColors.primary.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 8,
                color: AppColors.ambientShadow,
              ),
            ],
          ),
          child: Icon(
            isSelected ? Icons.palette : Icons.museum,
            color: isSelected ? AppColors.onPrimary : AppColors.primary,
            size: isSelected ? 18 : 14,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? AppColors.onPrimary
                  : AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: isSelected
            ? null
            : Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
        ),
      ),
    );
  }
}

class _BottomSheetPeek extends StatelessWidget {
  final AsyncValue<List<Exhibition>> exhibitionsAsync;

  const _BottomSheetPeek({required this.exhibitionsAsync});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -12),
                blurRadius: 40,
                color: AppColors.onSurface.withValues(alpha: 0.1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 16),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FEATURED NEAR YOU',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.outline,
                            letterSpacing: 3,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Exhibition Walk',
                          style: GoogleFonts.newsreader(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'View all',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Carousel
              exhibitionsAsync.when(
                data: (exhibitions) => SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: exhibitions.length > 3 ? 3 : exhibitions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final exhibition = exhibitions[index];
                      return _CarouselCard(exhibition: exhibition);
                    },
                  ),
                ),
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (_, __) => const SizedBox(height: 220),
              ),
              const SizedBox(height: 80), // nav bar space
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final dynamic exhibition;

  const _CarouselCard({required this.exhibition});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 260,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              SizedBox(
                height: 130,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: exhibition.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppColors.surfaceContainerLow),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.surfaceContainerLow),
                ),
              ),
              if (exhibition.badge != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      exhibition.badge!,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryContainer,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exhibition.title,
                        style: GoogleFonts.newsreader(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      exhibition.isSaved
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: exhibition.isSaved
                          ? AppColors.primary
                          : AppColors.surfaceDim,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.near_me,
                      size: 12,
                      color: AppColors.outline,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${exhibition.distanceMiles} miles away • ${exhibition.venue}',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.outline,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceContainer.withValues(alpha: 0.6)
      ..strokeWidth = 0.5;

    // Draw subtle grid lines to simulate map
    for (var x = 0.0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw some "road" lines
    final roadPaint = Paint()
      ..color = AppColors.surfaceContainerHighest.withValues(alpha: 0.4)
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.35),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.25, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.55, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.65),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
