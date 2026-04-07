import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';
import 'widgets/exhibition_card.dart';

class ExhibitionsListScreen extends ConsumerStatefulWidget {
  final void Function(String exhibitionId)? onExhibitionTap;

  const ExhibitionsListScreen({super.key, this.onExhibitionTap});

  @override
  ConsumerState<ExhibitionsListScreen> createState() =>
      _ExhibitionsListScreenState();
}

class _ExhibitionsListScreenState extends ConsumerState<ExhibitionsListScreen> {
  late final TextEditingController _searchController;

  static const _filters = ['All', "Editor's Choice", 'New', 'Free'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(exhibitionSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredExhibitionsProvider);
    final query = ref.watch(exhibitionSearchQueryProvider);
    final selectedBadge = ref.watch(exhibitionBadgeFilterProvider);
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
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) => ref
                      .read(exhibitionSearchQueryProvider.notifier)
                      .state = v,
                  decoration: InputDecoration(
                    hintText: 'Search exhibitions or venues...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(exhibitionSearchQueryProvider.notifier)
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
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((f) {
                      final isAll = f == 'All';
                      final isSelected =
                          isAll ? selectedBadge == null : selectedBadge == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: f,
                          selected: isSelected,
                          onTap: () => ref
                              .read(exhibitionBadgeFilterProvider.notifier)
                              .state = isAll ? null : (isSelected ? null : f),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Exhibition Feed
        filteredAsync.when(
          data: (exhibitions) => exhibitions.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No exhibitions found.',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                )
              : SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  sliver: SliverList.separated(
                    itemCount: exhibitions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 48),
                    itemBuilder: (context, index) {
                      return ExhibitionCard(
                        exhibition: exhibitions[index],
                        onTap: () =>
                            onExhibitionTap?.call(exhibitions[index].id),
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
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
