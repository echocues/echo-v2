import 'package:flutter/material.dart';

class IdleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double idleOpacity;

  const IdleButton({super.key, required this.onPressed, required this.child, this.idleOpacity = 0.3});

  @override
  State<IdleButton> createState() => _IdleButtonState();
}

class _IdleButtonState extends State<IdleButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: _isHovering ? widget.idleOpacity : 1.0, end: _isHovering ? 1.0 : widget.idleOpacity),
        duration: const Duration(milliseconds: 200),
        builder: (_, value, __) {
          return Opacity(
            opacity: value,
            child: TextButton(
              onPressed: widget.onPressed,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}