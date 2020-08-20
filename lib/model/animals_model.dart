class Animals {
  final String animalName;

  Animals({this.animalName});

  factory Animals.fromJson(Map<String, dynamic> json) {
    return new Animals(
      animalName: json['animalName'] as String,
    );
  }
}
