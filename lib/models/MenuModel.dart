class MenuModel {
  String name;
  String id;
  List<MenuItemModel> items;

  MenuModel({
    required this.name,
    required this.id,
    required this.items,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    List<MenuItemModel> items = <MenuItemModel>[];
    if (json['items'] != null) {
      List result = json['items'];
      result.forEach((element) {
        print(element);
        items.add(MenuItemModel.fromJson(element));
      });
    }

    return MenuModel(
      name: json['name'],
      id: json['id'],
      items: items,
    );

  }
}

class MenuItemModel {
  String sku;
  String name;
  String description;
  String itemId;
  bool outerEanCode;
  bool stopList;
  num count;
  List<MenuItemSize> itemSizes;
  List<Labels> labels;
  List<Tags> tags;

  MenuItemModel({
    required this.sku,
    required this.name,
    required this.description,
    required this.itemId,
    required this.outerEanCode,
    required this.stopList,
    required this.count,
    required this.itemSizes,
    required this.tags,
    required this.labels,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    List<MenuItemSize> itemSizes = <MenuItemSize>[];
    if (json['itemSizes'] != null) {
      List result = json['itemSizes'];
      result.forEach((element) {
        print(element);
        itemSizes.add(MenuItemSize.fromJson(element));
      });
    }

    List<Tags> tagsItems = <Tags>[];
    if (json['tags'] != null) {
      List resultLabels = json['tags'];
      resultLabels.forEach((element) {
        tagsItems.add(Tags.fromJson(element));
      });
    }

    List<Labels> labelsItems = <Labels>[];
    if (json['labels'] != null) {
      List resultLabels = json['labels'];
      resultLabels.forEach((element) {
        labelsItems.add(Labels.fromJson(element));
      });
    }

    return MenuItemModel(
      sku: json['sku'],
      name: json['name'],
      description: json['description'],
      itemId: json['itemId'],
      outerEanCode: json['outerEanCode'] != null ? true : false,
      stopList: json['stopList'],
      count: json['count'],
      itemSizes: itemSizes,
      labels: labelsItems,
      tags: tagsItems,
    );

  }

}

class Labels {
  String name;

  Labels({
    required this.name
  });

  factory Labels.fromJson(Map<String, dynamic> json) {
    return Labels(
      name: json['name'],
    );

  }
}

class Tags {
  String name;

  Tags({
    required this.name
  });

  factory Tags.fromJson(Map<String, dynamic> json) {
    return Tags(
      name: json['name'],
    );

  }
}

class MenuItemSize {
  String sku;
  String buttonImageUrl;
  num portionWeightGrams;
  List<MenuItemSizePrice> itemSizesPrices;
  List<MenuItemSizeModifiers> itemSizesModifiers;

  MenuItemSize({
    required this.sku,
    required this.buttonImageUrl,
    required this.portionWeightGrams,
    required this.itemSizesPrices,
    required this.itemSizesModifiers,
  });

  factory MenuItemSize.fromJson(Map<String, dynamic> json) {
    List<MenuItemSizePrice> itemSizePrice = <MenuItemSizePrice>[];
    if (json['prices'] != null) {
      List result = json['prices'];
      result.forEach((element) {
        itemSizePrice.add(MenuItemSizePrice.fromJson(element));
      });
    }

    List<MenuItemSizeModifiers> itemSizesModifier = <MenuItemSizeModifiers>[];
    if (json['itemModifierGroups'] != null) {
      List result = json['itemModifierGroups'];
      result.forEach((element) {
        itemSizesModifier.add(MenuItemSizeModifiers.fromJson(element));
      });
    }

    return MenuItemSize(
      sku: json['sku'],
      portionWeightGrams: json['portionWeightGrams'],
      buttonImageUrl: json['buttonImageUrl'] ?? '',
      itemSizesPrices: itemSizePrice,
      itemSizesModifiers: itemSizesModifier,
    );
  }

}

class MenuItemSizePrice {
  String organizationId;
  num price;

  MenuItemSizePrice({
    required this.organizationId,
    required this.price,
  });

  factory MenuItemSizePrice.fromJson(Map<String, dynamic> json) {

    return MenuItemSizePrice(
      organizationId: json['organizationId'],
      price: json['price'],
    );
  }
}

class MenuItemSizeModifiers {
  String name;
  String description;
  List<MenuItemSizeModifiersItems> menuItemSizeModifiersItems;

  MenuItemSizeModifiers({
    required this.name,
    required this.description,
    required this.menuItemSizeModifiersItems,
  });

  factory MenuItemSizeModifiers.fromJson(Map<String, dynamic> json) {

    List<MenuItemSizeModifiersItems> menuItemSizeModifiersIt = <MenuItemSizeModifiersItems>[];
    if (json['items'] != null) {
      List result = json['items'];
      result.forEach((element) {
        menuItemSizeModifiersIt.add(MenuItemSizeModifiersItems.fromJson(element));
      });
    }


    return MenuItemSizeModifiers(
      name: json['name'],
      description: json['description'],
      menuItemSizeModifiersItems: menuItemSizeModifiersIt,
    );
  }

}

class MenuItemSizeModifiersItems {
  String sku;
  String name;
  String description;
  String itemId;
  String buttonImageUrl;
  bool isChecked;
  List<MenuItemSizeModifiersItemPrices> enuItemSizeModifiersItemPrice;

  MenuItemSizeModifiersItems({
    required this.sku,
    required this.name,
    required this.description,
    required this.itemId,
    required this.buttonImageUrl,
    required this.enuItemSizeModifiersItemPrice,
    required this.isChecked,
  });

  factory MenuItemSizeModifiersItems.fromJson(Map<String, dynamic> json) {

    List<MenuItemSizeModifiersItemPrices> enuItemSizeModifiersItemPr = <MenuItemSizeModifiersItemPrices>[];
    if (json['prices'] != null) {
      List result = json['prices'];
      result.forEach((element) {
        enuItemSizeModifiersItemPr.add(MenuItemSizeModifiersItemPrices.fromJson(element));
      });
    }

    return MenuItemSizeModifiersItems(
      sku: json['sku'],
      name: json['name'],
      description: json['description'],
      itemId: json['itemId'],
      isChecked: false,
      buttonImageUrl: json['buttonImageUrl'] ?? '',
      enuItemSizeModifiersItemPrice: enuItemSizeModifiersItemPr,
    );
  }

}

class MenuItemSizeModifiersItemPrices {
  String organizationId;
  num price;

  MenuItemSizeModifiersItemPrices({
    required this.organizationId,
    required this.price,
  });

  factory MenuItemSizeModifiersItemPrices.fromJson(Map<String, dynamic> json) {

    return MenuItemSizeModifiersItemPrices(
      organizationId: json['organizationId'],
      price: json['price'],
    );
  }
}