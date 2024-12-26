class Iikolocaldishesmodel {
  String id;
  int dishCount;
  bool isMark;
  List<iikoLocalDishesModifiersModel> modifiers;

  Iikolocaldishesmodel({
    required this.id,
    required this.dishCount,
    required this.isMark,
    required this.modifiers,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dishCount': dishCount,
      'isMark': isMark,
      'modifiers': modifiers,
    };
  }
}


class iikoLocalDishesModifiersModel {
  String id;

  iikoLocalDishesModifiersModel({
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}