import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';

import '../../domain/entities/exhibition.dart';

// Filter state provider
final _selectedFilterProvider = StateProvider<String>((_) => 'All');

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleriesAsync = ref.watch(galleriesProvider);
    final exhibitionsAsync = ref.watch(exhibitionsProvider);
    final selectedFilter = ref.watch(_selectedFilterProvider);

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
          child: GestureDetector(
            onTap: () => _showSearchSheet(context, ref),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                for (final filter in ['All', 'Nearby', 'Contemporary Art', 'Sculpture', 'Photography']) ...[
                  GestureDetector(
                    onTap: () => ref.read(_selectedFilterProvider.notifier).state = filter,
                    child: _FilterChip(
                      label: filter,
                      isSelected: selectedFilter == filter,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),

        // Bottom sheet peek
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _BottomSheetPeek(
            exhibitionsAsync: exhibitionsAsync,
            selectedFilter: selectedFilter,
          ),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Centering on your location...'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchSheet(BuildContext context, WidgetRef ref) {
    final galleriesAsync = ref.read(galleriesProvider);
    final exhibitionsAsync = ref.read(exhibitionsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => _SearchSheet(
          scrollController: controller,
          galleries: galleriesAsync.valueOrNull ?? [],
          exhibitions: exhibitionsAsync.valueOrNull ?? [],
        ),
      ),
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
  final String selectedFilter;

  const _BottomSheetPeek({
    required this.exhibitionsAsync,
    required this.selectedFilter,
  });

  List<Exhibition> _filtered(List<Exhibition> all) {
    if (selectedFilter == 'All') return all;
    if (selectedFilter == 'Nearby') {
      final sorted = List<Exhibition>.from(all)
        ..sort((a, b) => a.distanceMiles.compareTo(b.distanceMiles));
      return sorted;
    }
    // Simple keyword filter on title/venue/badge
    return all.where((e) {
      final text = '${e.title} ${e.venue} ${e.badge ?? ''}'.toLowerCase();
      return text.contains(selectedFilter.toLowerCase());
    }).toList();
  }

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
                data: (exhibitions) {
                  final filtered = _filtered(exhibitions);
                  final displayCount = filtered.length > 4 ? 4 : filtered.length;
                  return SizedBox(
                    height: 220,
                    child: displayCount == 0
                        ? Center(
                            child: Text(
                              'No results for this filter',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.outline,
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: displayCount,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final exhibition = filtered[index];
                              return GestureDetector(
                                onTap: () => context.push('/map/exhibition/${exhibition.id}'),
                                child: _CarouselCard(exhibition: exhibition),
                              );
                            },
                          ),
                  );
                },
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

class _SearchSheet extends StatefulWidget {
  final ScrollController scrollController;
  final List<dynamic> galleries;
  final List<dynamic> exhibitions;

  const _SearchSheet({
    required this.scrollController,
    required this.galleries,
    required this.exhibitions,
  });

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  List<dynamic> get _filteredGalleries => _query.isEmpty
      ? widget.galleries
      : widget.galleries.where((g) {
          final text = '${g.name} ${g.description}'.toLowerCase();
          return text.contains(_query.toLowerCase());
        }).toList();

  List<dynamic> get _filteredExhibitions => _query.isEmpty
      ? widget.exhibitions
      : widget.exhibitions.where((e) {
          final text = '${e.title} ${e.venue}'.toLowerCase();
          return text.contains(_query.toLowerCase());
        }).toList();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceDim.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Search field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search galleries & exhibitions...',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: AppColors.outline,
                ),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Galleries
          if (_filteredGalleries.isNotEmpty) ...[
            Text(
              'GALLERIES',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            for (final gallery in _filteredGalleries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.surfaceContainerLow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: gallery.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  gallery.name,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${gallery.distanceMiles} miles away',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/explore/gallery/${gallery.id}');
                },
              ),
            const SizedBox(height: 24),
          ],
          // Exhibitions
          if (_filteredExhibitions.isNotEmpty) ...[
            Text(
              'EXHIBITIONS',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            for (final exhibition in _filteredExhibitions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.surfaceContainerLow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: exhibition.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  exhibition.title,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  exhibition.venue,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/map/exhibition/${exhibition.id}');
                },
              ),
          ],
          if (_filteredGalleries.isEmpty && _filteredExhibitions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: AppColors.outline),
                    const SizedBox(height: 12),
                    Text(
                      'No results for "$_query"',
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.outline),
                    ),
                  ],
                ),
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
