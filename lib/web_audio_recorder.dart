// This file should only be imported and used in web builds
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/foundation.dart';

class WebAudioRecorder {
  html.MediaRecorder? _webMediaRecorder;
  List<Uint8List> _webAudioChunks = [];
  Uint8List? _webAudioData;
  Completer<void>? _recordingCompleter;

  Future<void> startRecording() async {
    if (kDebugMode) {
      print("Starting web recording");
    }
    try {
      final stream = await html.window.navigator.mediaDevices
          ?.getUserMedia({'audio': true});
      if (stream == null) {
        throw Exception("Failed to get audio stream");
      }

      final options = {'mimeType': 'audio/webm;codecs=opus'};

      try {
        _webMediaRecorder = html.MediaRecorder(stream, options);
      } catch (e) {
        if (kDebugMode) {
          print("Opus codec not supported, using default");
        }
        _webMediaRecorder = html.MediaRecorder(stream);
      }

      if (kDebugMode) {
        print("Recording using MIME type: ${_webMediaRecorder!.mimeType}");
      }

      _webAudioChunks = [];
      _recordingCompleter = Completer<void>();

      _webMediaRecorder!.addEventListener('dataavailable',
          js.allowInterop((event) {
        if (kDebugMode) {
          print("Data available event fired");
        }
        final data = (event as html.BlobEvent).data;
        if (data != null) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(data);
          reader.onLoadEnd.listen((_) {
            if (reader.result is Uint8List) {
              _webAudioChunks.add(reader.result as Uint8List);
              if (kDebugMode) {
                print(
                    "Added audio chunk. Total chunks: ${_webAudioChunks.length}. Chunk size: ${(reader.result as Uint8List).length} bytes");
              }
            } else {
              if (kDebugMode) {
                print(
                    "Reader result is not Uint8List: ${reader.result.runtimeType}");
              }
            }
          });
        } else {
          if (kDebugMode) {
            print("Data in dataavailable event is null");
          }
        }
      }));

      _webMediaRecorder!.addEventListener('stop', js.allowInterop((_) {
        if (kDebugMode) {
          print("Stop event fired");
        }
        _recordingCompleter?.complete();
      }));

      _webMediaRecorder!.addEventListener('error', js.allowInterop((event) {
        if (kDebugMode) {
          print("MediaRecorder error: ${(event).type}");
        }
        _recordingCompleter?.completeError("MediaRecorder error");
      }));

      _webMediaRecorder!.start();
      if (kDebugMode) {
        print("Web recording started");
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error in startRecording: $e");
      }
      if (kDebugMode) {
        print("Stack trace: $stackTrace");
      }
      throw Exception("Failed to start web recording");
    }
  }

  Future<void> stopRecording() async {
    if (kDebugMode) {
      print("Attempting to stop web recording");
    }
    if (_webMediaRecorder != null && _webMediaRecorder!.state == 'recording') {
      _webMediaRecorder!.stop();
      if (kDebugMode) {
        print("Stop called on MediaRecorder");
      }

      await _recordingCompleter?.future;

      _webMediaRecorder!.stream?.getTracks().forEach((track) {
        track.stop();
        if (kDebugMode) {
          print("Audio track stopped");
        }
      });

      await Future.delayed(const Duration(milliseconds: 100));

      if (_webAudioChunks.isNotEmpty) {
        _webAudioData =
            Uint8List.fromList(_webAudioChunks.expand((x) => x).toList());
        if (kDebugMode) {
          print(
              "Audio data compiled. Total size: ${_webAudioData!.length} bytes");
        }
      } else {
        if (kDebugMode) {
          print("Warning: No audio chunks recorded");
        }
        throw Exception("No audio data captured");
      }

      _webMediaRecorder = null;
      _webAudioChunks.clear();
      if (kDebugMode) {
        print("Web recording stopped and cleaned up");
      }
    } else {
      if (kDebugMode) {
        print("MediaRecorder is not in recording state or is null");
      }
      throw Exception("Recording was not properly started");
    }
  }

  Future<Uint8List> getAudioData() async {
    if (_webAudioData == null || _webAudioData!.isEmpty) {
      throw Exception("No audio data available");
    }
    return _webAudioData!;
  }
}
