//модель секции меню
class MenuSectionModel {

  final String section;

  MenuSectionModel({required this.section});

  factory MenuSectionModel.fromJson(Map<String, dynamic> json) {
    return MenuSectionModel(section: json['section']);
  }

  Map<String, dynamic> toJson() {
    return {'section' : this.section};
  }
}