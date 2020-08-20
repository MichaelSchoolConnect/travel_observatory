class Animals {
  final String id;
  final String animalName;

  Animals({this.id, this.animalName});

  Animals.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        animalName = json['animalName'];
}
