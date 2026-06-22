class LocationModel {
  final String name;
  final String country;
  final String description;
  final String imageUrl;
  final double rating;

  LocationModel({
    required this.name,
    required this.country,
    required this.description,
    required this.imageUrl,
    required this.rating,
  });

  factory LocationModel.fromMap(Map<String, dynamic> data) {
    return LocationModel(
      name: data['name'] ?? '',
      country: data['country'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] as num).toDouble(),
    );
  }
}