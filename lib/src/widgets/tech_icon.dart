import 'package:flutter/material.dart';

enum TechIconType {
  activity,
  alert,
  bot,
  chart,
  check,
  chevronDown,
  chevronRight,
  clipboard,
  close,
  download,
  grid,
  lock,
  logout,
  mail,
  menu,
  plus,
  refresh,
  search,
  shield,
  thumbDown,
  thumbUp,
  upload,
  user,
}

/// Легкие кастомные line-icons без внешних icon packs.
class TechIcon extends StatelessWidget {
  const TechIcon(
    this.type, {
    this.color,
    this.size = 22,
    super.key,
  });

  final TechIconType type;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TechIconPainter(
        color: color ?? IconTheme.of(context).color ?? Colors.white,
        type: type,
      ),
      size: Size.square(size),
    );
  }
}

class _TechIconPainter extends CustomPainter {
  _TechIconPainter({
    required this.color,
    required this.type,
  });

  final Color color;
  final TechIconType type;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas
      ..save()
      ..scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..strokeWidth = 1.5;

    void line(double x1, double y1, double x2, double y2) {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    void rect(double left, double top, double width, double height) {
      canvas.drawRect(Rect.fromLTWH(left, top, width, height), paint);
    }

    void circle(double x, double y, double radius) {
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    Path path(List<Offset> points) {
      final value = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        value.lineTo(point.dx, point.dy);
      }
      return value;
    }

    switch (type) {
      case TechIconType.activity:
        canvas.drawPath(
          path([
            const Offset(3, 12),
            const Offset(7, 12),
            const Offset(9, 6),
            const Offset(13, 18),
            const Offset(15, 12),
            const Offset(21, 12),
          ]),
          paint,
        );
      case TechIconType.alert:
        canvas.drawPath(
          path([
            const Offset(12, 3),
            const Offset(21, 20),
            const Offset(3, 20),
            const Offset(12, 3),
          ]),
          paint,
        );
        line(12, 9, 12, 14);
        line(12, 17, 12, 17.1);
      case TechIconType.bot:
        rect(7, 8, 10, 9);
        line(12, 8, 12, 4);
        line(4, 12, 7, 12);
        line(17, 12, 20, 12);
        line(10, 15, 14, 15);
        circle(9.5, 12, 0.2);
        circle(14.5, 12, 0.2);
      case TechIconType.chart:
        line(4, 4, 4, 20);
        line(4, 20, 20, 20);
        line(8, 16, 8, 12);
        line(12, 16, 12, 8);
        line(16, 16, 16, 9);
      case TechIconType.check:
        canvas.drawPath(
          path([
            const Offset(4, 12),
            const Offset(9, 17),
            const Offset(20, 6),
          ]),
          paint,
        );
      case TechIconType.chevronDown:
        canvas.drawPath(
          path([
            const Offset(7, 9),
            const Offset(12, 14),
            const Offset(17, 9),
          ]),
          paint,
        );
      case TechIconType.chevronRight:
        canvas.drawPath(
          path([
            const Offset(9, 6),
            const Offset(15, 12),
            const Offset(9, 18),
          ]),
          paint,
        );
      case TechIconType.clipboard:
        rect(8, 5, 8, 3);
        line(6, 7, 4, 7);
        line(4, 7, 4, 21);
        line(4, 21, 20, 21);
        line(20, 21, 20, 7);
        line(20, 7, 18, 7);
        line(8, 13, 16, 13);
        line(8, 17, 13, 17);
      case TechIconType.close:
        line(6, 6, 18, 18);
        line(18, 6, 6, 18);
      case TechIconType.download:
        line(12, 3, 12, 15);
        canvas.drawPath(
          path([
            const Offset(7, 10),
            const Offset(12, 15),
            const Offset(17, 10),
          ]),
          paint,
        );
        line(5, 21, 19, 21);
      case TechIconType.grid:
        rect(4, 4, 6, 6);
        rect(14, 4, 6, 6);
        rect(4, 14, 6, 6);
        rect(14, 14, 6, 6);
      case TechIconType.lock:
        rect(6, 10, 12, 10);
        canvas.drawPath(
          path([
            const Offset(8, 10),
            const Offset(8, 7),
            const Offset(9, 5),
            const Offset(12, 4),
            const Offset(15, 5),
            const Offset(16, 7),
            const Offset(16, 10),
          ]),
          paint,
        );
      case TechIconType.logout:
        line(10, 5, 5, 5);
        line(5, 5, 5, 19);
        line(5, 19, 10, 19);
        line(14, 8, 18, 12);
        line(18, 12, 14, 16);
        line(18, 12, 9, 12);
      case TechIconType.mail:
        rect(4, 6, 16, 12);
        canvas.drawPath(
          path([
            const Offset(4, 7),
            const Offset(12, 13),
            const Offset(20, 7),
          ]),
          paint,
        );
      case TechIconType.menu:
        line(4, 7, 20, 7);
        line(4, 12, 20, 12);
        line(4, 17, 20, 17);
      case TechIconType.plus:
        line(12, 5, 12, 19);
        line(5, 12, 19, 12);
      case TechIconType.refresh:
        canvas.drawArc(const Rect.fromLTWH(5, 5, 14, 14), 3.9, 4.2, false, paint);
        line(5, 5, 5, 9);
        line(5, 9, 9, 9);
        line(19, 19, 19, 15);
        line(19, 15, 15, 15);
      case TechIconType.search:
        circle(10.5, 10.5, 7);
        line(16, 16, 21, 21);
      case TechIconType.shield:
        canvas.drawPath(
          path([
            const Offset(12, 3),
            const Offset(20, 6),
            const Offset(20, 12),
            const Offset(18, 17),
            const Offset(12, 21),
            const Offset(6, 17),
            const Offset(4, 12),
            const Offset(4, 6),
            const Offset(12, 3),
          ]),
          paint,
        );
        canvas.drawPath(
          path([
            const Offset(8, 12),
            const Offset(11, 15),
            const Offset(16, 9),
          ]),
          paint,
        );
      case TechIconType.thumbDown:
        rect(4, 4, 3, 10);
        line(7, 14, 14, 14);
        line(14, 14, 13, 20);
        line(13, 20, 18, 14);
        line(18, 14, 18, 4);
        line(18, 4, 7, 4);
      case TechIconType.thumbUp:
        rect(4, 10, 3, 10);
        line(7, 10, 14, 10);
        line(14, 10, 13, 4);
        line(13, 4, 18, 10);
        line(18, 10, 18, 20);
        line(18, 20, 7, 20);
      case TechIconType.upload:
        line(12, 21, 12, 9);
        canvas.drawPath(
          path([
            const Offset(7, 14),
            const Offset(12, 9),
            const Offset(17, 14),
          ]),
          paint,
        );
        line(5, 5, 19, 5);
      case TechIconType.user:
        circle(12, 8, 4);
        canvas.drawArc(const Rect.fromLTWH(4, 13, 16, 14), 3.6, 2.2, false, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TechIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
