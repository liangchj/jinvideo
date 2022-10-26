abstract class BaseFileModel {
  BaseFileModel(
      {required this.path,
      required this.name,
      required this.fileSystemType});

  final String path; // 文件路径
  String name; // 文件名称
  final FileSystemType fileSystemType;
}

/// 文件类型
enum FileSystemType {
  all, // 全部
  file, // 文件
  directory // 目录
}
