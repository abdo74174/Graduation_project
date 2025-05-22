import 'package:flutter/material.dart';
import 'wave_painter.dart';

class AnimatedBottomNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isDark;

  const AnimatedBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isDark,
  }) : super(key: key);

  @override
  State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<AnimatedBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  int? _lastSelectedIndex;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Start curve animation when selected index changes
    if (_lastSelectedIndex != widget.selectedIndex) {
      _waveController.reset();
      _waveController.forward(from: 0.0).then((_) {
        _waveController.reverse();
      });
      _lastSelectedIndex = widget.selectedIndex;
    }

    return Container(
      height: 65,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Wave Animation Layer
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 65),
                painter: WavePainter(
                  animationValue: _waveController.value,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  width: MediaQuery.of(context).size.width,
                ),
              );
            },
          ),
          // Navigation Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(
                  1, Icons.category_outlined, Icons.category, 'Categories'),
              _buildNavItem(
                  2, Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () {
        widget.onItemSelected(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (widget.isDark
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.1))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0, end: isSelected ? 1.0 : 0.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * 0.2),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : widget.isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : widget.isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
