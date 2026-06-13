import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/assistant/presentation/screens/assistant_screen.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  static const _tabs = [
    _NavTab(label: 'Accueil', icon: Icons.home_rounded, activeIcon: Icons.home_rounded),
    _NavTab(label: 'Dossiers', icon: Icons.folder_rounded, activeIcon: Icons.folder_rounded),
    _NavTab(label: 'Ndiogoye', icon: Icons.graphic_eq_rounded, activeIcon: Icons.graphic_eq_rounded, isSpecial: true),
    _NavTab(label: 'Documents', icon: Icons.article_rounded, activeIcon: Icons.article_rounded),
    _NavTab(label: 'Profil', icon: Icons.person_rounded, activeIcon: Icons.person_rounded),
  ];

  void _onTabTapped(BuildContext context, int index) {
    if (index == currentIndex && index != 2) return;
    if (index == 2) {
      context.push('/assistant');
      return;
    }
    if (index == 0) context.go('/home');
    if (index == 1) context.go('/dossiers');
    if (index == 3) context.go('/documents');
    if (index == 4) context.go('/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fond gris très clair ultra-moderne
      extendBody: true, // Permet au contenu de passer SOUS la nav bar
      body: child,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(1.0), // Opacité maximale demandée
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B285D).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_tabs.length, (i) {
                    final tab = _tabs[i];
                    final isActive = currentIndex == i;
                    final isSpecial = tab.isSpecial;

                    if (isSpecial) {
                      return GestureDetector(
                        onTap: () => _onTabTapped(context, i),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0B285D).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
                        ),
                      );
                    }

                    final color = isActive ? const Color(0xFF0B285D) : const Color(0xFF94A3B8);

                    return GestureDetector(
                      onTap: () => _onTabTapped(context, i),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isActive ? tab.activeIcon : tab.icon,
                              color: color,
                              size: 26,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tab.label,
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                fontFamily: 'Inter',
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
    );
  }
}

class _NavTab {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isSpecial;
  const _NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.isSpecial = false,
  });
}
