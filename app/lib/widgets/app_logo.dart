import 'package:flutter/material.dart';
import '../theme.dart';

/// Marca de la app: una mancuerna estilizada dentro de un cuadrado con
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
        borderRadius: BorderRadius.circular(rounded ? size * 0.28 : 0),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: size * 0.25, offset: Offset(0, size * 0.08)),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.62,
          height: size * 0.62,
          child: CustomPaint(painter: _DumbbellPainter()),
        ),
      ),
    );
  }
}

class _DumbbellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final h = size.height;
    final w = size.width;
    final barHeight = h * 0.22;

    // Barra central
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, (h - barHeight) / 2, w * 0.64, barHeight),
        Radius.circular(barHeight / 2),
      ),
      paint,
    );

    // Discos izquierdos
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.1, w * 0.16, h * 0.8), Radius.circular(w * 0.05)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.04, 0, w * 0.10, h), Radius.circular(w * 0.04)),
      paint,
    );

    // Discos derechos
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.84, h * 0.1, w * 0.16, h * 0.8), Radius.circular(w * 0.05)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.86, 0, w * 0.10, h), Radius.circular(w * 0.04)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Logo + nombre de marca, usado en pantallas de auth y splash.
class AppWordmark extends StatelessWidget {
  final double logoSize;
  const AppWordmark({super.key, this.logoSize = 72});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppLogo(size: logoSize),
        const SizedBox(height: 14),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.ink),
            children: [
              TextSpan(text: 'Pulso'),
              TextSpan(text: 'Fit', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 2),
        const Text('Gestion de entrenamiento personal', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
