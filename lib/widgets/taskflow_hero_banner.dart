import 'package:flutter/material.dart';

class TaskFlowHeroBanner extends StatefulWidget {
  const TaskFlowHeroBanner({super.key});

  @override
  State<TaskFlowHeroBanner> createState() => _TaskFlowHeroBannerState();
}

class _TaskFlowHeroBannerState extends State<TaskFlowHeroBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = curvedAnimation;

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curvedAnimation);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6855E8)
                    .withValues(alpha: isDarkMode ? 0.18 : 0.12),
                blurRadius: 22,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                'assets/images/taskflow_home_hero.webp',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                semanticLabel:
                    'TaskFlow productivity banner by Dultrix Technologies',
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF6855E8),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.task_alt_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'TaskFlow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Plan. Organize. Achieve.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
