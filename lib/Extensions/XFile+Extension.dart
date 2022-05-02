
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

extension ByteDataExtension on ByteData {
  convertToXFile() async {
    var frontBuffer = this.buffer;
    Uint8List _list = await frontBuffer.asUint8List(this.offsetInBytes, buffer.lengthInBytes);
    XFile file = XFile.fromData(_list);
    return file;
  }
}