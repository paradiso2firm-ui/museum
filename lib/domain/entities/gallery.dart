class Gallery {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final double distanceMiles;
  final String priceLabel;
  final double? latitude;
  final double? longitude;

  const Gallery({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.tags,
    required this.distanceMiles,
    required this.priceLabel,
    this.latitude,
    this.longitude,
  });
}
