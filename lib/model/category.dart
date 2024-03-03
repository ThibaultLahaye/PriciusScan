class Category {
  const Category({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  @override
  String toString() => '$name (id=$id)';

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.parse(json['categorie_id']),
      name: json['name'],
    );
  }
}
