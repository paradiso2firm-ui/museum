class UserProfile {
  final String id;
  final String name;
  final String bio;
  final String avatarUrl;
  final int savedCount;
  final int visitedCount;
  final int followingCount;
  final bool exhibitionAlerts;
  final bool publicProfile;

  const UserProfile({
    required this.id,
    required this.name,
    required this.bio,
    required this.avatarUrl,
    required this.savedCount,
    required this.visitedCount,
    required this.followingCount,
    this.exhibitionAlerts = true,
    this.publicProfile = false,
  });
}
