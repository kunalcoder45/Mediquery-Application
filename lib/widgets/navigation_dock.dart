import 'package:flutter/material.dart';

class NavigationDock extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavigationDock({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<NavigationDock> createState() => _NavigationDockState();
}

class _NavigationDockState extends State<NavigationDock>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey[900]?.withOpacity(0.95) 
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark 
              ? Colors.grey[800]! 
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDockItem(
            icon: Icons.home_rounded,
            label: 'Home',
            index: 0,
            isActive: widget.currentIndex == 0,
            isDark: isDark,
          ),
          const SizedBox(width: 20),
          _buildDockItem(
            icon: Icons.info_rounded,
            label: 'About',
            index: 1,
            isActive: widget.currentIndex == 1,
            isDark: isDark,
          ),
          const SizedBox(width: 20),
          _buildDockItem(
            icon: Icons.contact_mail_rounded,
            label: 'Contact',
            index: 2,
            isActive: widget.currentIndex == 2,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDockItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onTap(index);
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isActive ? _scaleAnimation.value : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? (isDark ? Colors.green[400] : Colors.green[600])
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isActive
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}