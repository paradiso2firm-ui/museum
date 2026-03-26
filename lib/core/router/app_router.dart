import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/shell/app_shell.dart';
import '../../presentation/explore/explore_screen.dart';
import '../../presentation/map/map_screen.dart';
import '../../presentation/saved/saved_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/exhibitions/exhibition_detail_screen.dart';
import '../../presentation/explore/gallery_detail_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/explore',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Explore Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreScreen(),
              routes: [
                GoRoute(
                  path: 'exhibition/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => ExhibitionDetailScreen(
                    exhibitionId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'gallery/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => GalleryDetailScreen(
                    galleryId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Map Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        // Saved Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              builder: (context, state) => SavedScreen(
                onExhibitionTap: (id) => context.push('/saved/exhibition/$id'),
              ),
              routes: [
                GoRoute(
                  path: 'exhibition/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => ExhibitionDetailScreen(
                    exhibitionId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Profile Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => ProfileScreen(
                onExhibitionTap: (id) => context.push('/profile/exhibition/$id'),
              ),
              routes: [
                GoRoute(
                  path: 'exhibition/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => ExhibitionDetailScreen(
                    exhibitionId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
