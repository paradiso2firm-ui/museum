import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class GlassmorphicAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const GlassmorphicAppBar({
    super.key,
    this.title = 'Digital Gallery',
    this.leading,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: AppColors.surfaceDim.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  leading ??
                      IconButton(
                        onPressed: () => _showAppMenu(context),
                        icon: const Icon(Icons.menu, color: AppColors.primary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  Text(
                    title,
                    style: GoogleFonts.newsreader(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (actions != null)
                    Row(children: actions!)
                  else
                    IconButton(
                      onPressed: () => _showSearchOverlay(context),
                      icon: const Icon(Icons.search, color: AppColors.primary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAppMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceDim.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Digital Gallery',
              style: GoogleFonts.newsreader(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            _MenuTile(
              icon: Icons.explore_outlined,
              label: 'Explore Galleries',
              onTap: () => Navigator.of(ctx).pop(),
            ),
            _MenuTile(
              icon: Icons.palette_outlined,
              label: 'Exhibitions',
              onTap: () => Navigator.of(ctx).pop(),
            ),
            _MenuTile(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () {
                Navigator.of(ctx).pop();
                showAboutDialog(
                  context: context,
                  applicationName: 'Digital Gallery',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2026 Digital Gallery',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => _QuickSearchSheet(
          scrollController: controller,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
      onTap: onTap,
    );
  }
}

class _QuickSearchSheet extends StatefulWidget {
  final ScrollController scrollController;

  const _QuickSearchSheet({required this.scrollController});

  @override
  State<_QuickSearchSheet> createState() => _QuickSearchSheetState();
}

class _QuickSearchSheetState extends State<_QuickSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  final _suggestions = [
    'Contemporary Art',
    'Sculpture',
    'Photography',
    'Impressionism',
    'Modern Art',
    'Renaissance',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filtered = _query.isEmpty
        ? _suggestions
        : _suggestions
            .where((s) => s.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
        children: [
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
                hintText: 'Search art, exhibitions, galleries...',
                hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.outline),
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
          Text(
            _query.isEmpty ? 'POPULAR SEARCHES' : 'SUGGESTIONS',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filtered
                .map((s) => ActionChip(
                      label: Text(s),
                      labelStyle: textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface,
                      ),
                      backgroundColor: AppColors.surfaceContainerLow,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
