// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;

/// Cross-platform web implementation for HTML5 image & live camera stream capture
Future<String?> pickImageCrossPlatform({bool isCamera = false}) async {
  if (isCamera) {
    try {
      final cameraDataUrl = await _captureLiveCamera();
      if (cameraDataUrl != null && cameraDataUrl.isNotEmpty) {
        return cameraDataUrl;
      }
    } catch (_) {
      // Fallback to standard input picker if live WebCam stream is unavailable
    }
  }

  final completer = Completer<String?>();
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  if (isCamera) {
    uploadInput.setAttribute('capture', 'environment');
  }
  uploadInput.click();

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        completer.complete(reader.result as String?);
      });
      reader.onError.listen((event) {
        completer.complete(null);
      });
    } else {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
  });

  return completer.future;
}

/// Captures a photo using the browser's live video camera stream (WebCam / Device Camera)
Future<String?> _captureLiveCamera() async {
  final mediaDevices = html.window.navigator.mediaDevices;
  if (mediaDevices == null) return null;

  html.MediaStream stream;
  try {
    stream = await mediaDevices.getUserMedia({'video': {'facingMode': 'environment'}});
  } catch (_) {
    try {
      stream = await mediaDevices.getUserMedia({'video': true});
    } catch (_) {
      return null;
    }
  }

  final completer = Completer<String?>();

  // Create Video element
  final video = html.VideoElement()
    ..srcObject = stream
    ..autoplay = true
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.objectFit = 'cover'
    ..style.borderRadius = '16px';

  // Create Overlay Dialog Elements
  final overlay = html.DivElement()
    ..style.position = 'fixed'
    ..style.top = '0'
    ..style.left = '0'
    ..style.width = '100vw'
    ..style.height = '100vh'
    ..style.backgroundColor = 'rgba(0, 0, 0, 0.85)'
    ..style.zIndex = '999999'
    ..style.display = 'flex'
    ..style.flexDirection = 'column'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.fontFamily = 'sans-serif';

  final modal = html.DivElement()
    ..style.width = '90%'
    ..style.maxWidth = '480px'
    ..style.backgroundColor = '#1E1E2E'
    ..style.borderRadius = '20px'
    ..style.padding = '20px'
    ..style.boxShadow = '0 10px 30px rgba(0,0,0,0.5)'
    ..style.display = 'flex'
    ..style.flexDirection = 'column'
    ..style.alignItems = 'center';

  final title = html.HeadingElement.h3()
    ..text = '📷 Receipt Camera Viewfinder'
    ..style.color = '#FFFFFF'
    ..style.margin = '0 0 16px 0'
    ..style.fontSize = '18px';

  final videoContainer = html.DivElement()
    ..style.width = '100%'
    ..style.height = '320px'
    ..style.position = 'relative'
    ..style.backgroundColor = '#000000'
    ..style.borderRadius = '16px'
    ..style.overflow = 'hidden'
    ..append(video);

  final buttonRow = html.DivElement()
    ..style.display = 'flex'
    ..style.gap = '16px'
    ..style.marginTop = '20px'
    ..style.width = '100%'
    ..style.justifyContent = 'center';

  final captureBtn = html.ButtonElement()
    ..text = '📸 Take Photo'
    ..style.backgroundColor = '#6750A4'
    ..style.color = '#FFFFFF'
    ..style.border = 'none'
    ..style.padding = '12px 24px'
    ..style.borderRadius = '24px'
    ..style.fontSize = '15px'
    ..style.fontWeight = 'bold'
    ..style.cursor = 'pointer';

  final cancelBtn = html.ButtonElement()
    ..text = 'Cancel'
    ..style.backgroundColor = 'transparent'
    ..style.color = '#CAC4D0'
    ..style.border = '1px solid #49454F'
    ..style.padding = '12px 20px'
    ..style.borderRadius = '24px'
    ..style.fontSize = '14px'
    ..style.cursor = 'pointer';

  buttonRow.append(cancelBtn);
  buttonRow.append(captureBtn);

  modal.append(title);
  modal.append(videoContainer);
  modal.append(buttonRow);
  overlay.append(modal);

  html.document.body?.append(overlay);

  void cleanup() {
    for (final track in stream.getTracks()) {
      track.stop();
    }
    overlay.remove();
  }

  captureBtn.onClick.listen((_) {
    final canvas = html.CanvasElement(
      width: video.videoWidth > 0 ? video.videoWidth : 1280,
      height: video.videoHeight > 0 ? video.videoHeight : 720,
    );
    final ctx = canvas.context2D;
    ctx.drawImage(video, 0, 0);
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.9);
    cleanup();
    if (!completer.isCompleted) {
      completer.complete(dataUrl);
    }
  });

  cancelBtn.onClick.listen((_) {
    cleanup();
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  });

  return completer.future;
}
