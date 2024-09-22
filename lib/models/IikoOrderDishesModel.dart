class iikoOrderDishesModel {
  String productId;
  int price;
  String type;
  int amount;
  List<iikoOrderDishesModifiersModel> modifiers;

  iikoOrderDishesModel({
    required this.productId,
    required this.price,
    required this.type,
    required this.amount,
    required this.modifiers,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'price': price,
      'type': type,
      'amount': amount,
      'modifiers': modifiers,
    };
  }
}


class iikoOrderDishesModifiersModel {
  String productId;
  int price;
  int amount;

  iikoOrderDishesModifiersModel({
    required this.productId,
    required this.price,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'price': price,
      'amount': amount,
    };
  }
}