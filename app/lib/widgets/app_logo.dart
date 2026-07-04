import 'package:flutter/material.dart';
import '../theme.dart';

/// Marca de la app: una flecha de progreso dentro de un circulo con
/// degrade, dibujada a mano con formas simples para un look distintivo.
class AppLogo extends StatelessWidget {
  final double size;
  final bool rounded;

  const AppLogo({super.key, this.size = 64, this.rounded = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: size * 0.25, offset: Offset(0, size * 0.08)),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.56,
          height: size * 0.56,
          child: CustomPaint(painter: _AscentPainter()),
        ),
      ),
    );
  }
}

class _AscentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;

    // Linea ascendente de progreso (barras crecientes conectadas)
    final path = Path()
      ..moveTo(0, h * 0.78)
      ..lineTo(w * 0.32, h * 0.46)
      ..lineTo(w * 0.56, h * 0.66)
      ..lineTo(w, h * 0.14);
    canvas.drawPath(path, paint);

    // Punta de flecha
    final headPaint = Paint()..color = Colors.white;
    final head = Path()
      ..moveTo(w, h * 0.14)
      ..lineTo(w * 0.72, h * 0.14)
      ..lineTo(w, h * 0.42)
      ..close();
    canvas.drawPath(head, headPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Logo + nombre de marca, usado en pantallas de auth y splash.
class AppWordmark extends StatelessWidget {
  final double logoSize;
  final bool light;
  const AppWordmark({super.key, this.logoSize = 72, this.light = false});

  @override
  Widget build(BuildContext context) {
    final titleColor = light ? Colors.white : AppColors.ink;
    final accentColor = light ? Colors.white : AppColors.primary;
    final subtitleColor = light ? Colors.white70 : Colors.grey;
    return Column(
      children: [
        AppLogo(size: logoSize),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: titleColor),
            children: [
              const TextSpan(text: 'Super'),
              TextSpan(text: 'fit', style: TextStyle(color: accentColor)),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text('Coaching y seguimiento de entrenamiento', style: TextStyle(color: subtitleColor)),
      ],
    );
  }
}
