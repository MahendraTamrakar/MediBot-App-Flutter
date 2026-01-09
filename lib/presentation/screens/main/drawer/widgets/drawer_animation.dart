import 'package:flutter/material.dart';
import 'package:medibot/presentation/screens/main/drawer/drawer.dart';

/// Simple slide-only animated drawer wrapper.
/// Keeps screens UI-only by providing a toggle callback to the child.
class AnimatedDrawerScaffold extends StatefulWidget {
  const AnimatedDrawerScaffold({
    super.key,
    required this.builder,
    this.slide = 250,
    this.duration = const Duration(milliseconds: 250),
    this.backgroundColor = const Color(0xFF202123),
  });

  final Widget Function(BuildContext context, VoidCallback toggleDrawer)
  builder;
  final double slide;
  final Duration duration;
  final Color backgroundColor;

  @override
  State<AnimatedDrawerScaffold> createState() => _AnimatedDrawerScaffoldState();
}

class _AnimatedDrawerScaffoldState extends State<AnimatedDrawerScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  Animation<double>? _slide;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Calculate 80% of screen width for drawer slide
    final screenWidth = MediaQuery.of(context).size.width;
    final slideAmount = screenWidth * 0.75;
    _slide = Tween<double>(
      begin: 0.0,
      end: slideAmount,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _toggle() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  void _closeDrawer() {
    if (_controller.isCompleted || _controller.isAnimating) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: [
          // Drawer layer (stays behind)
          DrawerMenu(
            onChatSelected: _closeDrawer,
            onNewChat: _closeDrawer,
          ),

          // Content layer with simple slide animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_slide!.value, 0),
                child: GestureDetector(
                  onTap: () {
                    if (_controller.isCompleted) _toggle();
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0) {
                      _controller.forward();
                    } else if (details.delta.dx < 0) {
                      _controller.reverse();
                    }
                  },
                  child: widget.builder(context, _toggle),
                ),
              );
            },
          ),

          // Grey scrim overlay over the sliding content when drawer is open
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final opacity = (_controller.value * 0.35).clamp(0.0, 0.35);
              if (opacity == 0) return const SizedBox.shrink();
              return Transform.translate(
                offset: Offset(_slide!.value, 0),
                child: GestureDetector(
                  onTap: _toggle,
                  child: Container(color: Colors.black.withOpacity(opacity)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
