import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fasalmitra/services/cursor_service.dart';

class Hoverable extends StatefulWidget {
  final Widget child;

  const Hoverable({super.key, required this.child});

  @override
  State<Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<Hoverable> {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return widget.child;
    }

    return MouseRegion(
      onEnter: (_) => CursorService.instance.enterHover(),
      onExit: (_) => CursorService.instance.exitHover(),
      child: widget.child,
    );
  }
}
