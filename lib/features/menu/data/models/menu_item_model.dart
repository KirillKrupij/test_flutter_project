//модель меню айтема
class MenuItemModel {

  final String icon;
  final String text;
  final String page;

  MenuItemModel({
    required this.icon, 
    required this.text, 
    required this.page, 
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      icon: json['icon'],
      text: json['text'],
      page: json["page"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon' : this.icon, 
      'text' : this.text, 
      'paghe' : this.page, 
    };
  }
}