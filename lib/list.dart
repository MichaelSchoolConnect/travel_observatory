import 'model/animals_model.dart';

class AnimalList {
  final List<Animals> animals;

  AnimalList({
    this.animals,
  });

  factory AnimalList.fromJson(List<dynamic> parsedJson) {
    List<Animals> photos = new List<Animals>();
    photos = parsedJson.map((i) => Animals.fromJson(i)).toList();

    return new AnimalList(animals: photos);
  }
}
