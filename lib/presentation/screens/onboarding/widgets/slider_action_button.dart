import 'package:flutter/material.dart';


class SlideActionButton extends StatefulWidget {
  final VoidCallback onSubmit;
  final String text;
  final double height;
  final double width;

  const SlideActionButton({
    super.key,
    required this.onSubmit,
    this.text = "Get Started",
    this.height = 60,
    this.width = double.infinity,
  });

  @override
  State<SlideActionButton> createState() => _SlideActionButtonState();
}

class _SlideActionButtonState extends State<SlideActionButton> {
  double _position = 0.0;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final knobSize = widget.height - 10;
        final draggableWidth = maxWidth - knobSize - 10;

        double progress = _position / draggableWidth;
        double textOpacity = (1.0 - progress).clamp(0.0, 1.0);

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Opacity(
                  opacity: textOpacity,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.keyboard_arrow_right, color: Colors.white54, size: 20),
                        const Icon(Icons.keyboard_arrow_right, color: Colors.white38, size: 20),
                        const Icon(Icons.keyboard_arrow_right, color: Colors.white24, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 5 + _position,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_submitted) return;
                    setState(() {
                      double newPos = _position + details.delta.dx;
                      if (newPos < 0) newPos = 0;
                      if (newPos > draggableWidth) newPos = draggableWidth;
                      _position = newPos;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_submitted) return;
                    if (_position > draggableWidth * 0.8) {
                      setState(() {
                        _position = draggableWidth;
                        _submitted = true;
                      });
                      widget.onSubmit();
                    } else {
                      setState(() {
                        _position = 0;
                      });
                    }
                  },
                  child: Container(
                    height: knobSize,
                    width: knobSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 85, 51, 51),
                          blurRadius: 1,
                          offset: const Offset(1,1 ),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.start_rounded,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}