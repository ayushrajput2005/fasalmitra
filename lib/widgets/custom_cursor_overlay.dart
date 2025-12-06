import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fasalmitra/services/cursor_service.dart';

class CustomCursorOverlay extends StatefulWidget {
  final Widget child;

  const CustomCursorOverlay({super.key, required this.child});

  @override
  State<CustomCursorOverlay> createState() => _CustomCursorOverlayState();
}

class _CustomCursorOverlayState extends State<CustomCursorOverlay> {
  Offset _mousePosition = Offset.zero;
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return widget.child;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.none, // Hide system cursor
      onHover: (event) {
        setState(() {
          _mousePosition = event.position;
          if (!_isVisible) {
            _isVisible = true;
          }
        });
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
                final double size = isHovering ? 80.0 : 40.0;
                final double opacity = isHovering ? 0.3 : 1.0;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                  left: _mousePosition.dx - size / 2,
                  top: _mousePosition.dy - size / 2,
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: size,
                      height: size,
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
