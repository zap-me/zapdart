// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

String _platformPath(String name, {String path}) {
  if (path == null) path = "";
  if (Platform.isLinux || Platform.isAndroid)
    return path + "lib" + name + ".so";
  if (Platform.isIOS)
    return path + name + ".framework/" + name;
  if (Platform.isMacOS)
    return path + "lib" + name + ".dylib";
  if (Platform.isWindows)
    return path + "lib" + name + ".dll";
  throw Exception("Platform not implemented");
}

ffi.DynamicLibrary dlopenPlatformSpecific(String name, {String path}) {
  // we open this process on iOS because we need to distribute as a framework (appstore does not allow dylibs)
  // and the framework is linked into the main image
  //if (Platform.isIOS)
  //  return ffi.DynamicLibrary.process();
  String fullPath = _platformPath(name, path: path);
  return ffi.DynamicLibrary.open(fullPath);
}
