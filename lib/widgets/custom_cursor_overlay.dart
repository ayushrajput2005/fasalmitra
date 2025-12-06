import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fasalmitra/services/cursor_service.dart';

class CustomCursorOverlay extends StatefulWidget {
  final Widget child;

  const CustomCursorOverlay({super.key, required this.child});

  @override
  State<CustomCursorOverlay> createState() => _CustomCursorOverlayState();
}

class _CustomCursorOverlayState extends State<CustomCursorOverlay>
    with SingleTickerProviderStateMixin {
  Offset _mousePosition = Offset.zero;
  Offset _cursorPosition = Offset.zero;
  bool _isVisible = false;
  late Ticker _ticker;

  // Configuration
  static const double _friction = 0.15; // Lower = more delay/smoothness
  static const double _defaultSize = 40.0;
  static const double _hoverSize = 80.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    if (kIsWeb) {
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    if (!_isVisible) return;

    // Lerp towards target
    final double dx =
        _cursorPosition.dx +
        (_mousePosition.dx - _cursorPosition.dx) * _friction;
    final double dy =
        _cursorPosition.dy +
        (_mousePosition.dy - _cursorPosition.dy) * _friction;

    // Only rebuild if moved significantly to save resources
    if ((dx - _cursorPosition.dx).abs() > 0.1 ||
        (dy - _cursorPosition.dy).abs() > 0.1) {
      setState(() {
        _cursorPosition = Offset(dx, dy);
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return widget.child;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.none, // Hide system cursor
      onHover: (event) {
        _mousePosition = event.position;
        if (!_isVisible) {
          setState(() {
            _isVisible = true;
            // Snap to position on first appear so it doesn't fly in from 0,0
            _cursorPosition = _mousePosition;
          });
        }
      },
      onExit: (event) {
        setState(() {
          _isVisible = false;
        });
        CursorService.instance.exitHover();
      },
      child: Stack(
        children: [
          widget.child,
          if (_isVisible)
            ListenableBuilder(
              listenable: CursorService.instance,
              builder: (context, _) {
                final isHovering = CursorService.instance.isHovering;
                // Config
                final theme = Theme.of(context);
                final color = theme.colorScheme.primary;
                // Config
                final double size = isHovering ? _hoverSize : _defaultSize;
                final double opacity = isHovering ? 0.3 : 1.0;

                return Positioned(
                  left: _cursorPosition.dx,
                  top: _cursorPosition.dy,
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: size,
                      height: size,
                      transform: Matrix4.translationValues(
                        -size / 2,
                        -size / 2,
                        0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withOpacity(opacity),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
