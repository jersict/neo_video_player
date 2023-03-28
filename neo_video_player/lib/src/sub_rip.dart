// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:neo_video_player/src/closed_caption_file.dart';

/// Represents a [ClosedCaptionFile], parsed from the SubRip file format.
/// See: https://en.wikipedia.org/wiki/SubRip
class SubRipCaptionFile extends ClosedCaptionFile {
  /// Parses a string into a [ClosedCaptionFile], assuming [fileContents] is in
  /// the SubRip file format.
  /// * See: https://en.wikipedia.org/wiki/SubRip
  SubRipCaptionFile(this.fileContents)
      : _captions = _parseCaptionsFromSubRipString(fileContents);

  /// The entire body of the SubRip file.
  // TODO(cyanglaz): Remove this public member as it doesn't seem need to exist.
  // https://github.com/flutter/flutter/issues/90471
  final String fileContents;

  @override
  List<Caption> get captions => _captions;

  final List<Caption> _captions;
}

List<Caption> _parseCaptionsFromSubRipString(String file) {
  final captions = <Caption>[];
  for (final captionLines in _readSubRipFile(file)) {
    if (captionLines.length < 3) {
      break;
    }

    final captionNumber = int.parse(captionLines[0]);
    final captionRange = _CaptionRange.fromSubRipString(captionLines[1]);

    final text = captionLines.sublist(2).join('\n');

    final newCaption = Caption(
      number: captionNumber,
      start: captionRange.start,
      end: captionRange.end,
      text: text,
    );
    if (newCaption.start != newCaption.end) {
      captions.add(newCaption);
    }
  }

  return captions;
}

class _CaptionRange {
  _CaptionRange(this.start, this.end);

  final Duration start;
  final Duration end;

  // Assumes format from an SubRip file.
  // For example:
  // 00:01:54,724 --> 00:01:56,760
  // ignore: prefer_constructors_over_static_methods
  static _CaptionRange fromSubRipString(String line) {
    final format = RegExp(_subRipTimeStamp + _subRipArrow + _subRipTimeStamp);

    if (!format.hasMatch(line)) {
      return _CaptionRange(Duration.zero, Duration.zero);
    }

    final times = line.split(_subRipArrow);

    final start = _parseSubRipTimestamp(times[0]);
    final end = _parseSubRipTimestamp(times[1]);

    return _CaptionRange(start, end);
  }
}

// Parses a time stamp in an SubRip file into a Duration.
// For example:
//
// _parseSubRipTimestamp('00:01:59,084')
// returns
// Duration(hours: 0, minutes: 1, seconds: 59, milliseconds: 084)
Duration _parseSubRipTimestamp(String timestampString) {
  if (!RegExp(_subRipTimeStamp).hasMatch(timestampString)) {
    return Duration.zero;
  }

  final commaSections = timestampString.split(',');
  final hoursMinutesSeconds = commaSections[0].split(':');

  final hours = int.parse(hoursMinutesSeconds[0]);
  final minutes = int.parse(hoursMinutesSeconds[1]);
  final seconds = int.parse(hoursMinutesSeconds[2]);
  final milliseconds = int.parse(commaSections[1]);

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
  );
}

// Reads on SubRip file and splits it into Lists of strings where each list is
// one caption.
List<List<String>> _readSubRipFile(String file) {
  final lines = LineSplitter.split(file).toList();

  final captionStrings = <List<String>>[];
  var currentCaption = <String>[];
  var lineIndex = 0;
  for (final line in lines) {
    final isLineBlank = line.trim().isEmpty;
    if (!isLineBlank) {
      currentCaption.add(line);
    }

    if (isLineBlank || lineIndex == lines.length - 1) {
      captionStrings.add(currentCaption);
      currentCaption = <String>[];
    }

    lineIndex += 1;
  }

  return captionStrings;
}

const String _subRipTimeStamp = r'\d\d:\d\d:\d\d,\d\d\d';
const String _subRipArrow = ' --> ';
