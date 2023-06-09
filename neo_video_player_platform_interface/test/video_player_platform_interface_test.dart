// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:neo_video_player_platform_interface/neo_video_player_platform_interface.dart';

void main() {
  // Store the initial instance before any tests change it.
  final VideoPlayerPlatform initialInstance = VideoPlayerPlatform.instance;

  test('default implementation throws unimplemented', () async {
    await expectLater(() => initialInstance.init(), throwsUnimplementedError);
  });
}
