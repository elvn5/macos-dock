import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, isHovered, scale) {
              return Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  constraints: BoxConstraints(
                    minWidth: 48 * scale,
                  ),
                  height: 48 * scale,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.primaries[icon.hashCode % Colors.primaries.length].withOpacity(0.8),
                    boxShadow: isHovered
                        ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : [],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24 * scale,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;

  final Widget Function(T, bool isHovered, double scale) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();

  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return LongPressDraggable<IconData>(
            data: item as IconData,
            feedback: Material(
              color: Colors.transparent,
              child: widget.builder(item, true, 1.2),
            ),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: widget.builder(item, false, 1.0),
            ),
            onDragStarted: () => setState(() => _hoveredIndex = null),
            onDraggableCanceled: (_, __) => setState(() => _hoveredIndex = null),
            onDragCompleted: () => setState(() => _hoveredIndex = null),
            child: DragTarget<IconData>(
              onAccept: (receivedItem) {
                setState(() {
                  final fromIndex = _items.indexOf(receivedItem as dynamic);
                  if (fromIndex != index) {
                    _items.removeAt(fromIndex);
                    _items.insert(index, receivedItem as dynamic);
                  }
                });
              },
              onWillAccept: (receivedItem) => true,
              builder: (context, candidateData, rejectedData) {
                double scale = 1.0;
                if (_hoveredIndex != null) {
                  final distance = (index - _hoveredIndex!).abs();
                  scale = distance == 0
                      ? 1.2
                      : distance == 1
                      ? 1.1
                      : 1.0;
                }
                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: widget.builder(item, _hoveredIndex == index, scale),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
