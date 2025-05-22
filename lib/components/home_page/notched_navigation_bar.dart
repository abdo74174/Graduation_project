import 'package:flutter/material.dart';

enum NotchSmoothness {
  sharpEdge,
  defaultEdge,
  softEdge,
  smoothEdge,
  verySmoothEdge
}

enum GapLocation { none, center, end }

class NotchedNavigationBar extends StatefulWidget {
  final int activeIndex;
  final Function(int) onTap;
  final List<IconData> icons;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? height;
  final double? elevation;
  final NotchSmoothness notchSmoothness;
  final GapLocation gapLocation;
  final double gapWidth;
  final double? iconSize;
  final bool blurEffect;
  final double cornerRadius;

  const NotchedNavigationBar({
    Key? key,
    required this.activeIndex,
    required this.onTap,
    required this.icons,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.height,
    this.elevation,
    this.notchSmoothness = NotchSmoothness.defaultEdge,
    this.gapLocation = GapLocation.end,
    this.gapWidth = 72,
    this.iconSize,
    this.blurEffect = false,
    this.cornerRadius = 16,
  }) : super(key: key);

  @override
  State<NotchedNavigationBar> createState() => _NotchedNavigationBarState();
}

class _NotchedNavigationBarState extends State<NotchedNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NotchedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeIndex != oldWidget.activeIndex) {
      _previousIndex = oldWidget.activeIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        widget.backgroundColor ?? (isDark ? Colors.grey[900] : Colors.white);
    final activeColor = widget.activeColor ?? Theme.of(context).primaryColor;
    final inactiveColor =
        widget.inactiveColor ?? (isDark ? Colors.grey[400] : Colors.grey[600]);

    return Container(
      height: widget.height ?? kBottomNavigationBarHeight + 16,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.cornerRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: widget.elevation ?? 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.icons.length, (index) {
          final isActive = index == widget.activeIndex;
          return _buildNavItem(
            index,
            widget.icons[index],
            isActive,
            activeColor!,
            inactiveColor!,
          );
        }),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    bool isActive,
    Color activeColor,
    Color inactiveColor,
  ) {
    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = isActive ? _scaleAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isActive ? activeColor : inactiveColor,
                    size: widget.iconSize ?? 24,
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    width: isActive ? 20 : 0,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(2),
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
