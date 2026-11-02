import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

const Color _primary = Color(0xFF6855E8);
const Color _secondary = Color(0xFF9B8CFF);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = animation;

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(animation);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
            children: [
              Text(
                'Personalize your space',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Make TaskFlow work the way you like.',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
              ),

              const SizedBox(height: 22),

              const _BrandHeader(),

              const SizedBox(height: 28),

              const _SectionHeading(
                title: 'Appearance',
                icon: Icons.palette_outlined,
              ),

              const SizedBox(height: 12),

              // Material is used as the card surface.
              // This prevents ListTile ink rendering assertions.
              _SettingsCard(
                child: SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  secondary: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: _IconTile(
                      key: ValueKey(isDarkMode),
                      icon: isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: _primary,
                    ),
                  ),
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      isDarkMode
                          ? 'Dark theme is enabled'
                          : 'Light theme is enabled',
                      key: ValueKey(isDarkMode),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  value: isDarkMode,
                  activeThumbColor: _primary,
                  onChanged: (value) {
                    context.read<ThemeProvider>().toggleTheme(value);
                  },
                ),
              ),

              const SizedBox(height: 28),

              const _SectionHeading(
                title: 'About TaskFlow',
                icon: Icons.info_outline_rounded,
              ),

              const SizedBox(height: 12),

              _SettingsCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: const _IconTile(
                        icon: Icons.check_circle_outline_rounded,
                        color: _primary,
                      ),
                      title: const Text(
                        'TaskFlow',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Your personal productivity companion',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 72,
                      color: scheme.outlineVariant,
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: const _IconTile(
                        icon: Icons.verified_outlined,
                        color: _primary,
                      ),
                      title: const Text(
                        'Version',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'See pubspec.yaml for the current version',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 72,
                      color: scheme.outlineVariant,
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: const _IconTile(
                        icon: Icons.code_rounded,
                        color: _primary,
                      ),
                      title: const Text(
                        'Developed by',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Dultrix Technologies',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const _SectionHeading(
                title: 'Productivity Features',
                icon: Icons.auto_awesome_outlined,
              ),

              const SizedBox(height: 12),

              const _SettingsCard(
                child: Column(
                  children: [
                    _FeatureTile(
                      icon: Icons.task_alt_rounded,
                      title: 'Task Management',
                      subtitle: 'Organize and complete your daily tasks',
                    ),
                    _FeatureDivider(),
                    _FeatureTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Smart Reminders',
                      subtitle: 'Stay informed about upcoming tasks',
                    ),
                    _FeatureDivider(),
                    _FeatureTile(
                      icon: Icons.calendar_month_outlined,
                      title: 'Calendar Planning',
                      subtitle: 'Keep track of your schedule',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              Center(
                child: Column(
                  children: [
                    const Text(
                      'TASKFLOW',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'BY DULTRIX TECHNOLOGIES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Plan. Organize. Achieve.',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// GRADIENT BRAND HEADER
// =====================================================

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, Color(0xFF806DF5), _secondary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.09),
              ),
            ),
          ),
          Positioned(
            right: 35,
            bottom: -65,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your App,\nYour Style',
                        style: TextStyle(
                          fontSize: 24,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Stay focused and productive.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.tune_rounded, size: 62, color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// SECTION HEADING
// =====================================================

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeading({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _primary),
        const SizedBox(width: 9),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

// =====================================================
// SETTINGS CARD - MATERIAL FIX
// =====================================================

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: child,
      ),
    );
  }
}

// =====================================================
// ICON TILE
// =====================================================

class _IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconTile({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

// =====================================================
// FEATURE TILE
// =====================================================

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _IconTile(icon: icon, color: _primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 72,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
