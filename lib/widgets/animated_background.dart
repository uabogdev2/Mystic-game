import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_constants.dart';
import '../theme/theme_controller.dart';
import 'dart:math';

class AnimatedBackground extends ConsumerStatefulWidget {
  final Widget child;
  
  const AnimatedBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends ConsumerState<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentGradientIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..addListener(() {
      if (_controller.value == 1.0) {
        setState(() {
          _currentGradientIndex = (_currentGradientIndex + 1) % 3;
          _controller.reset();
          _controller.forward();
        });
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeControllerProvider);
    final gradients = isDarkMode 
        ? ThemeConstants.nightBackgroundGradients 
        : ThemeConstants.dayBackgroundGradients;
    
    final currentGradient = gradients[_currentGradientIndex];
    final nextGradient = gradients[(_currentGradientIndex + 1) % gradients.length];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  currentGradient[0],
                  nextGradient[0],
                  _controller.value,
                )!,
                Color.lerp(
                  currentGradient[1],
                  nextGradient[1],
                  _controller.value,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: ThemeConstants.animationDuration,
                  opacity: isDarkMode ? 0.3 : 0.0,
                  child: const _Stars(),
                ),
              ),
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: ThemeConstants.animationDuration,
                  opacity: isDarkMode ? 0.0 : 0.2,
                  child: const _Clouds(),
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _Stars extends StatefulWidget {
  const _Stars({Key? key}) : super(key: key);

  @override
  State<_Stars> createState() => _StarsState();
}

class _StarsState extends State<_Stars> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<StarData> _stars = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    // Initialiser les étoiles avec des positions aléatoires
    for (int i = 0; i < 100; i++) {
      _stars.add(StarData(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2 + 1,
        speed: _random.nextDouble() * 0.2 + 0.1,
        opacity: _random.nextDouble() * 0.5 + 0.3,
      ));
    }
  }

  final _random = Random();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarsPainter(stars: _stars, animationValue: _controller.value),
        );
      },
    );
  }
}

class StarData {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;

  StarData({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class StarsPainter extends CustomPainter {
  final List<StarData> stars;
  final double animationValue;

  StarsPainter({required this.stars, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      // Mettre à jour la position Y pour créer l'effet de chute
      star.y = (star.y + star.speed * 0.02) % 1.0;
      
      // Effet de dérive horizontale légère
      star.x = (star.x + sin(animationValue * 2 * pi + star.y * 10) * 0.001) % 1.0;
      
      final paint = Paint()
        ..color = Colors.white.withOpacity(star.opacity * (0.7 + sin(animationValue * 2 * pi + star.y * 5) * 0.3))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => true;
}

class _Clouds extends StatelessWidget {
  const _Clouds({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CloudsPainter(),
    );
  }
}

class CloudsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    void drawCloud(double x, double y, double scale) {
      final path = Path();
      path.moveTo(x, y);
      path.addOval(Rect.fromCircle(center: Offset(x, y), radius: 20 * scale));
      path.addOval(Rect.fromCircle(center: Offset(x + 15 * scale, y - 10 * scale), radius: 15 * scale));
      path.addOval(Rect.fromCircle(center: Offset(x + 30 * scale, y), radius: 20 * scale));
      canvas.drawPath(path, paint);
    }

    final random = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 5; i++) {
      final x = (random + i * 7919) % size.width;
      final y = (random + i * 6037) % (size.height / 2);
      final scale = ((random + i * 3067) % 5 + 5) / 10;
      drawCloud(x, y, scale);
    }
  }

  @override
  bool shouldRepaint(CloudsPainter oldDelegate) => false;
} 