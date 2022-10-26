
import 'package:jinvideo/model/directory_model.dart';
import 'package:jinvideo/model/file_model.dart';

class MediaData {
  static bool loadedLocalDirectoryList = false;
  static List<DirectoryModel> localDirectoryList = [];
  static Map<String, List<FileModel>> videoFileListMap = {};
  static bool loadedPlayDirectoryList = false;
  static List<DirectoryModel> playDirectoryList = [];
  static Map<String, List<FileModel>> playFileListMap = {};
}