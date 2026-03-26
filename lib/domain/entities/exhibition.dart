class Exhibition {
  final String id;
  final String title;
  final String venue;
  final String imageUrl;
  final String dateRange;
  final String priceLabel;
  final double distanceMiles;
  final String? badge; // "Editor's Choice", "New", etc.
  final bool isSaved;
  final String? description;
  final String? openingHours;
  final String? closedDays;
  final String? address;
  final double? studentPrice;
  final double? generalPrice;
  final double? latitude;
  final double? longitude;

  const Exhibition({
    required this.id,
    required this.title,
    required this.venue,
    required this.imageUrl,
    required this.dateRange,
    required this.priceLabel,
    required this.distanceMiles,
    this.badge,
    this.isSaved = false,
    this.description,
    this.openingHours,
    this.closedDays,
    this.address,
    this.studentPrice,
    this.generalPrice,
    this.latitude,
    this.longitude,
  });

  Exhibition copyWith({bool? isSaved}) {
    return Exhibition(
      id: id,
      title: title,
      venue: venue,
      imageUrl: imageUrl,
      dateRange: dateRange,
      priceLabel: priceLabel,
      distanceMiles: distanceMiles,
      badge: badge,
      isSaved: isSaved ?? this.isSaved,
      description: description,
      openingHours: openingHours,
      closedDays: closedDays,
      address: address,
      studentPrice: studentPrice,
      generalPrice: generalPrice,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
