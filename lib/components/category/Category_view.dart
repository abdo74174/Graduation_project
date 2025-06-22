import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/core/constants/constant.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({
    super.key,
    required this.category,
    required this.onTap,
    required this.borderColor,
  });

  final CategoryModel category;
  final VoidCallback onTap;
  final Color borderColor;

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Hover animation controller
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Scale animation for hover effect
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    // Elevation animation for 3D depth
    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for 3D effect
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Start subtle rotation animation
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  ImageProvider getImageProvider(String? image) {
    if (image == null || image.isEmpty) {
      return const AssetImage("assets/images/category.jpg");
    }

    if (image.startsWith('/9j/')) {
      try {
        return MemoryImage(base64Decode(image));
      } catch (e) {
        return const AssetImage("assets/images/category.jpg");
      }
    }

    if (Uri.tryParse(image)?.isAbsolute == true) {
      return NetworkImage(image);
    }

    return AssetImage(image);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _hoverController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _hoverController.reverse();
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleAnimation,
              _elevationAnimation,
              _rotationAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  children: [
                    // 3D Container with perspective transformation
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspective
                        ..rotateY(_isHovered
                            ? math.sin(_rotationAnimation.value) * 0.1
                            : 0)
                        ..rotateX(_isHovered
                            ? math.cos(_rotationAnimation.value) * 0.05
                            : 0),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            // Primary shadow for depth
                            BoxShadow(
                              color: widget.borderColor.withOpacity(0.3),
                              blurRadius: _elevationAnimation.value,
                              offset: Offset(
                                math.sin(_rotationAnimation.value) * 2,
                                _elevationAnimation.value / 2,
                              ),
                            ),
                            // Secondary shadow for more depth
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(isDark ? 0.6 : 0.1),
                              blurRadius: _elevationAnimation.value * 1.5,
                              offset: Offset(
                                -math.sin(_rotationAnimation.value) * 1,
                                _elevationAnimation.value / 3,
                              ),
                            ),
                            // Highlight shadow for 3D pop effect
                            if (_isHovered)
                              BoxShadow(
                                color: widget.borderColor.withOpacity(0.2),
                                blurRadius: _elevationAnimation.value * 2,
                                offset: const Offset(0, -2),
                              ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Main image container
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.borderColor,
                                  width: _isHovered ? 1 : .5,
                                ),
                                image: DecorationImage(
                                  image:
                                      getImageProvider(widget.category.image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Gradient overlay for 3D effect
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  center: Alignment(-0.3, -0.3),
                                  radius: 1.2,
                                  colors: [
                                    Colors.white
                                        .withOpacity(_isHovered ? 0.3 : 0.1),
                                    Colors.transparent,
                                    Colors.black
                                        .withOpacity(_isHovered ? 0.2 : 0.05),
                                  ],
                                  stops: const [0.0, 0.6, 1.0],
                                ),
                              ),
                            ),
                            // Animated highlight ring
                            if (_isHovered)
                              AnimatedBuilder(
                                animation: _rotationAnimation,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: widget.borderColor.withOpacity(
                                          0.5 +
                                              math.sin(
                                                      _rotationAnimation.value *
                                                          2) *
                                                  0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Enhanced text with shadow and animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()
                        ..translate(0.0, _isHovered ? -2.0 : 0.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _isHovered ? 8 : 4,
                          vertical: _isHovered ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? widget.borderColor.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _isHovered
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          widget.category.name.tr(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isHovered
                                ? widget.borderColor
                                : (isDark ? Colors.white : psColor),
                            fontWeight:
                                _isHovered ? FontWeight.w800 : FontWeight.bold,
                            fontSize: _isHovered ? 14 : 13,
                            shadows: _isHovered
                                ? [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
