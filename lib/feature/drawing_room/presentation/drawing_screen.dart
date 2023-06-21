import 'package:flutter/material.dart';
import 'package:machine_test/core/theme/app_color.dart';
import 'package:machine_test/feature/drawing_room/model/drawing_point.dart';

class DrawingRoomScreen extends StatefulWidget {
  const DrawingRoomScreen({super.key});

  @override
  State<DrawingRoomScreen> createState() => _DrawingRoomScreenState();
}

class _DrawingRoomScreenState extends State<DrawingRoomScreen> {
  var availableColors = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.brown
  ];

  var historyDrawingPoint = <DrawingPointModel>[];
  var drawingPoints = <DrawingPointModel>[];

  var selectedColor = Colors.black;
  var selectedWidth = 2.0;

  DrawingPointModel? currentDrawingPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Canvas here we draw
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                currentDrawingPoint = DrawingPointModel(
                    id: DateTime.now().microsecondsSinceEpoch,
                    offsets: [details.localPosition],
                    color: selectedColor,
                    width: selectedWidth);

                if (currentDrawingPoint == null) return;
                drawingPoints.add(currentDrawingPoint!);
                historyDrawingPoint = List.of(drawingPoints);
              });
            },
            onPanUpdate: (details) {
              setState(() {
                if (currentDrawingPoint == null) {
                  return;
                }
                currentDrawingPoint = currentDrawingPoint?.copyWith(
                  offsets: currentDrawingPoint!.offsets
                    ..add(details.localPosition),
                );
                drawingPoints.last = currentDrawingPoint!;
                historyDrawingPoint = List.of(drawingPoints);
              });
            },
            onPanEnd: (_) {
              currentDrawingPoint = null;
            },
            child: CustomPaint(
              painter: DrawingPainter(drawingPoints),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = availableColors[index];
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: availableColors[index],
                          shape: BoxShape.circle),
                      foregroundDecoration: BoxDecoration(
                          border: selectedColor == availableColors[index]
                              ? Border.all(
                                  color: AppColor.primaryColor, width: 4)
                              : null,
                          shape: BoxShape.circle),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  width: 10,
                ),
                itemCount: availableColors.length,
              ),
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              right: 0,
              bottom: 150,
              child: RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  value: selectedWidth,
                  min: 1,
                  max: 20,
                  onChanged: (value) {
                    setState(() {
                      selectedWidth = value;
                    });
                  },
                ),
              ))
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (drawingPoints.isNotEmpty && historyDrawingPoint.isNotEmpty) {
                setState(() {
                  drawingPoints.removeLast();
                });
              }
            },
            heroTag: "undo",
            child: const Icon(Icons.undo),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            onPressed: () {
              if (drawingPoints.length < historyDrawingPoint.length) {
                final index = drawingPoints.length;
                drawingPoints.add(historyDrawingPoint[index]);
              }
            },
            heroTag: "Redo",
            child: const Icon(Icons.redo),
          )
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPointModel> DrawingPointModels;
  DrawingPainter(this.DrawingPointModels);

  @override
  void paint(Canvas canvas, Size size) {
    for (var DrawingPointModel in DrawingPointModels) {
      final paint = Paint()
        ..color = DrawingPointModel.color
        ..isAntiAlias = true
        ..strokeWidth = DrawingPointModel.width
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < DrawingPointModel.offsets.length; i++) {
        var notLastOffset = i != DrawingPointModel.offsets.length - 1;

        if (notLastOffset) {
          final current = DrawingPointModel.offsets[i];
          final next = DrawingPointModel.offsets[i + 1];
          canvas.drawLine(current, next, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
