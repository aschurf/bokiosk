class OrderDishesModel{
  String name;
  String id;
  num price;
  num dishCount;
  String imageUrl;
  List<OrderDishesModifiersModel> modifiers;

  OrderDishesModel({
    required this.name,
    required this.id,
    required this.price,
    required this.dishCount,
    required this.imageUrl,
    required this.modifiers,
  });

  @override
  String toString(){
    return 'name:' + name + ', id:' + id + ', price:' + price.toString() + ', dishCount:' + dishCount.toString();
  }
}

class OrderDishesModifiersModel {
  String name;
  String id;
  num price;

  OrderDishesModifiersModel({
    required this.name,
    required this.id,
    required this.price,
  });
}