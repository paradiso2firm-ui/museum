import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';

class ProfileScreen extends ConsumerWidget {
  final void Function(String exhibitionId)? onExhibitionTap;

  const ProfileScreen({super.key, this.onExhibitionTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final savedAsync = ref.watch(savedExhibitionsProvider);
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        // Profile Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceContainerLowest,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 8),
                            blurRadius: 24,
                            color: AppColors.ambientShadow,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: profile.avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.surfaceContainerLow),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceContainerLow,
                          child: const Icon(Icons.person, size: 48),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 14, color: AppColors.onPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  style: GoogleFonts.newsreader(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.bio,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatItem(count: profile.savedCount, label: 'Saved'),
                    const SizedBox(width: 36),
                    _StatItem(count: profile.visitedCount, label: 'Visited'),
                    const SizedBox(width: 36),
                    _StatItem(count: profile.followingCount, label: 'Following'),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Saved Exhibitions Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Exhibitions',
                  style: GoogleFonts.newsreader(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'View All',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(top: 16)),

        // Saved Grid
        savedAsync.when(
          data: (exhibitions) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final exhibition = exhibitions[index];
                  return GestureDetector(
                    onTap: () => onExhibitionTap?.call(exhibition.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.surfaceContainerLow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: exhibition.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      Container(color: AppColors.surfaceContainerLow),
                                  errorWidget: (_, __, ___) =>
                                      Container(color: AppColors.surfaceContainerLow),
                                ),
                                // Favorite icon
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest
                                          .withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                // Badge
                                if (exhibition.badge != null)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      color: AppColors.primaryContainer,
                                      child: Text(
                                        exhibition.badge!.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onPrimaryContainer,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          exhibition.title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${exhibition.venue} • ${exhibition.dateRange}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
                childCount: exhibitions.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.6,
              ),
            ),
          ),
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
          error: (e, _) => SliverFillRemaining(
            child: Center(child: Text('Error: $e')),
          ),
        ),

        // Preferences Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Preferences',
                    style: GoogleFonts.newsreader(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PreferenceRow(
                    icon: Icons.notifications_outlined,
                    label: 'Exhibition Alerts',
                    isOn: true,
                  ),
                  const SizedBox(height: 12),
                  _PreferenceRow(
                    icon: Icons.visibility_outlined,
                    label: 'Public Profile',
                    isOn: false,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          count.toString(),
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 2,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOn;

  const _PreferenceRow({
    required this.icon,
    required this.label,
    required this.isOn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          // Toggle
          Container(
            width: 40,
            height: 22,
            decoration: BoxDecoration(
              color: isOn ? AppColors.primary : AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(11),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(3),
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
