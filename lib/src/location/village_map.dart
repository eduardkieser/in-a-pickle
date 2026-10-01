import 'package:flutter/material.dart';

import '../theme.dart';

class VillageMap extends StatelessWidget {
  const VillageMap({
    super.key,
    this.showRoute = false,
    this.label = 'Your home pin',
    this.height = 190,
  });

  final bool showRoute;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: showRoute
          ? 'Simple route map to $label'
          : 'Simple map with a pin at $label',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _VillageMapPainter(showRoute: showRoute),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.ocean,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VillageMapPainter extends CustomPainter {
  const _VillageMapPainter({required this.showRoute});

  final bool showRoute;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFDCE8DF));

    final water = Path()
      ..moveTo(size.width * .73, 0)
      ..quadraticBezierTo(
          size.width * .66, size.height * .48, size.width * .82, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(water, Paint()..color = const Color(0xFFB7D8DF));

    final minorRoad = Paint()
      ..color = const Color(0xFFF8F4EB)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final roadEdge = Paint()
      ..color = const Color(0xFF9EAAA5)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final roads = <Path>[
      Path()
        ..moveTo(-10, size.height * .28)
        ..cubicTo(size.width * .3, size.height * .12, size.width * .52,
            size.height * .56, size.width * .82, size.height * .48),
      Path()
        ..moveTo(size.width * .18, -10)
        ..cubicTo(size.width * .15, size.height * .35, size.width * .52,
            size.height * .56, size.width * .42, size.height + 10),
      Path()
        ..moveTo(-10, size.height * .76)
        ..quadraticBezierTo(
            size.width * .34, size.height * .63, size.width * .68, size.height),
    ];
    for (final road in roads) {
      canvas.drawPath(road, roadEdge);
      canvas.drawPath(road, minorRoad);
    }

    final home = Offset(size.width * .62, size.height * .47);
    if (showRoute) {
      final start = Offset(size.width * .16, size.height * .76);
      final route = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(size.width * .28, size.height * .64, size.width * .39,
            size.height * .54, home.dx, home.dy);
      canvas.drawPath(
        route,
        Paint()
          ..color = AppColors.pickle
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(start, 9, Paint()..color = AppColors.ocean);
      canvas.drawCircle(start, 4, Paint()..color = Colors.white);
    }
    canvas.drawCircle(home, 16, Paint()..color = AppColors.coral);
    canvas.drawCircle(home, 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _VillageMapPainter oldDelegate) =>
      oldDelegate.showRoute != showRoute;
}
