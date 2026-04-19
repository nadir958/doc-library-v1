import 'package:isar/isar.dart';

part 'models.g.dart';

@collection
class FolderModel {
  Id? id;

  @Index(unique: true, replace: true)
  late String name;

  @Index()
  late DateTime createdAt;
}

@collection
class DocumentModel {
  Id? id;

  @Index(type: IndexType.value)
  late String title;

  @Index()
  late DateTime createdAt;

  @Index(type: IndexType.value)
  List<String> tags = [];

  @Index(type: IndexType.value)
  String? fullOcrSearchText;

  final folder = IsarLink<FolderModel>();
}

@collection
class PageModel {
  Id? id;

  late String imagePath;
  late String originalPath;
  
  String? ocrText;
  
  @Index()
  late int order;

  final document = IsarLink<DocumentModel>();
}
