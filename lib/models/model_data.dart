class ModelData {
  final String id;
  final String modelUrl;
  final String thumbnailUrl;
  final String userId;
  final DateTime createdAt;
  final String? name;
  final String category;
  final List<String> tags;

  ModelData({
    required this.id,
    required this.modelUrl,
    required this.thumbnailUrl,
    required this.userId,
    required this.createdAt,
    this.name,
    required this.category,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modelUrl': modelUrl,
      'thumbnailUrl': thumbnailUrl,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
      'category': category,
      'tags': tags,
    };
  }

  factory ModelData.fromMap(Map<String, dynamic> map) {
    return ModelData(
      id: map['id'],
      modelUrl: map['modelUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt']),
      name: map['name'],
      category: map['category'],
      tags: List<String>.from(map['tags']),
    );
  }
}