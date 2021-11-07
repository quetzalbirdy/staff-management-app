import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;

class JsonStorage {
  final fileName;
  JsonStorage([this.fileName]);

  Future<String> get _localPath async {
    /* final directory = await getApplicationDocumentsDirectory(); */
    var directory = (await getApplicationDocumentsDirectory()).path;
    var tenantDirectory = Directory(directory + '/' + Constants.tenant);    

    return tenantDirectory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<String> readFile() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return 'no file';
    }
  }

  Future<File> writeFile(json) async {
    final file = await _localFile;    
    // Write the file
    return file.writeAsString(json);
  }
}