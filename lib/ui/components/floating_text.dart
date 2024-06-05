import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class FloatingText extends AnimatedText {
  late AnimationController _controller;

  FloatingText({
    required super.text,
    super.textAlign,
    super.textStyle,
    super.duration = const Duration(milliseconds: 2500),
  });

  @override
  void initAnimation(AnimationController controller) {
    _controller = controller;

    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controller.repeat();
      }
    });
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    final double rotationAngle = sin(_controller.value * 2 * pi) * 0.005;
    const double amplitude = 30;

    return Transform.translate(
      offset: Offset(
        sin(_controller.value * 2 * pi) * amplitude,
        cos(_controller.value * 2 * pi) * amplitude,
      ),
      filterQuality: FilterQuality.high,
      child: Transform.rotate(
        angle: rotationAngle,
        filterQuality: FilterQuality.high,
        child: child,
      ),
    );
  }
}

class StarParticle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double rotation;
  late Color color;

  StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.color,
  });
}

class StarField extends StatefulWidget {
  final Widget child;

  const StarField({
    super.key,
    required this.child,
  });

  @override
  StarFieldState createState() => StarFieldState();
}

class StarFieldState extends State<StarField> with TickerProviderStateMixin {
  late List<StarParticle> particles;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    particles = _generateParticles();
    controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  List<StarParticle> _generateParticles() {
    Random random = Random();
    List<StarParticle> particles = [];

    for (int i = 0; i < 100; i++) {
      particles.add(StarParticle(
        x: random.nextDouble() * 400, // Adjust the range based on your needs
        y: random.nextDouble() * 400,
        size: random.nextDouble() * 2 + 1,
        speed: random.nextDouble() * 0.5 + 0.2,
        rotation: random.nextDouble() * 2 * pi,
        color: Colors.yellow,
      ));
    }

    return particles;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarFieldPainter(particles, controller.value),
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class StarFieldPainter extends CustomPainter {
  final List<StarParticle> particles;
  final double animationValue;

  StarFieldPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.x += particle.speed * cos(particle.rotation);
      particle.y += particle.speed * sin(particle.rotation);

      if (particle.x < 0 || particle.x > size.width || particle.y < 0 || particle.y > size.height) {
        // If the particle goes out of bounds, reset its position
        particle.x = size.width / 2;
        particle.y = size.height / 2;
      }

      double alpha = (1 - (particle.y / size.height)) * animationValue;
      Paint paint = Paint()..color = particle.color.withOpacity(alpha);
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
