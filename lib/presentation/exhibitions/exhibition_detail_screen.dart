import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/utils/dev_snackbar.dart';

class ExhibitionDetailScreen extends ConsumerWidget {
  final String exhibitionId;

  const ExhibitionDetailScreen({super.key, required this.exhibitionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exhibitionAsync = ref.watch(exhibitionProvider(exhibitionId));
    final textTheme = Theme.of(context).textTheme;

    return exhibitionAsync.when(
      data: (exhibition) => Scaffold(
        backgroundColor: AppColors.surface,
        body: CustomScrollView(
          slivers: [
            // Hero image with back button
            SliverAppBar(
              expandedHeight: 450,
              pinned: true,
              backgroundColor: AppColors.surfaceContainerLowest,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: AppColors.primary),
                      onPressed: () => showDevSnackBar(context, '공유'),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: exhibition.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.surfaceContainerLow),
                      errorWidget: (_, __, ___) => Container(color: AppColors.surfaceContainerLow),
                    ),
                    // Bottom gradient
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 120,
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

            // Floating Header Card
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 4),
                          blurRadius: 16,
                          color: AppColors.ambientShadow,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CURRENT EXHIBITION',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 3,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => toggleSaved(ref, exhibition.id),
                              child: Icon(
                                exhibition.isSaved ? Icons.favorite : Icons.favorite_border,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: exhibition.title,
                                style: GoogleFonts.newsreader(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exhibition.venue,
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About section
                    if (exhibition.description != null) ...[
                      Row(
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
                            'About the Collection',
                            style: GoogleFonts.newsreader(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        exhibition.description!,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Info Grid
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.schedule,
                            label: 'OPENING HOURS',
                            value: exhibition.openingHours ?? 'N/A',
                            subtitle: exhibition.closedDays != null
                                ? 'Closed ${exhibition.closedDays}'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.payments_outlined,
                            label: 'ADMISSION',
                            value: exhibition.generalPrice != null
                                ? '\$${exhibition.generalPrice!.toStringAsFixed(2)} General'
                                : 'Free',
                            subtitle: exhibition.studentPrice != null
                                ? '\$${exhibition.studentPrice!.toStringAsFixed(2)} Students'
                                : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Location
                    if (exhibition.address != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixedDim.withValues(alpha: 0.1),
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
                            // Map placeholder
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(Icons.map, size: 48, color: AppColors.outline),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              exhibition.address!,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action buttons
                    FilledButton(
                      onPressed: () => showDevSnackBar(context, '티켓 구매'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: const StadiumBorder(),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        'GET TICKETS',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => showDevSnackBar(context, '캘린더 추가'),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        'ADD TO CALENDAR',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: AppColors.onSurfaceVariant,
                        side: BorderSide.none,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        shape: const StadiumBorder(),
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
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
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
