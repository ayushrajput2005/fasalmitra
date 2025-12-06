import 'package:flutter/foundation.dart';

class CursorService extends ChangeNotifier {
  static final CursorService instance = CursorService._();

  CursorService._();

  bool _isHovering = false;
  bool get isHovering => _isHovering;

  void enterHover() {
    if (!_isHovering) {
      _isHovering = true;
      notifyListeners();
    }
  }

  void exitHover() {
    if (_isHovering) {
      _isHovering = false;
      notifyListeners();
    }
  }
}
