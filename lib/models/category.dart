class Category {
  final String name;
  final int? recommendedPercentage;
  final bool isFixed;

  Category({required this.name, this.recommendedPercentage, required this.isFixed});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      recommendedPercentage: json['recommendedPercentage'] as int?,
      isFixed: json['isFixed'] as bool,
    );
  }
}