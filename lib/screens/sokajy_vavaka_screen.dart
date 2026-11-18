import 'package:flutter/material.dart';

import '../models/vavaka_category.dart';
import '../services/vavaka_service.dart';
import '../theme/app_colors.dart';
import 'vavaka_by_category_screen.dart';

/// Pejy grid mampiseho ny sokajin'ny Vavaka (Fototra, Finoana, sns.)
/// miaraka amin'ny icon mifanaraka aminy — mitovy fomba amin'ny [SokajyScreen].
/// Misy animation staggered (fade + slide) sy scale feedback amin'ny card.
class SokajyVavakaScreen extends StatefulWidget {
  const SokajyVavakaScreen({super.key});

  @override
  State<SokajyVavakaScreen> createState() => _SokajyVavakaScreenState();
}

class _SokajyVavakaScreenState extends State<SokajyVavakaScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  int _isaAmin(String kategoria) {
    return VavakaService.instance.rehetra
        .where((v) => v.kategoria == kategoria)
        .length;
  }

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  /// Interval staggered isaky ny index (0 → 1).
  Animation<double> _itemAnimation(int index, int total) {
    final start = (index / total) * 0.55;
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = vavakaCategories.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.vavakaPrimary,
        foregroundColor: AppColors.vavakaOnPrimary,
        title: const Text('Sokajin\'ny Vavaka'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          int crossAxisCount = 2;
          if (width >= 1200) {
            crossAxisCount = 4;
          } else if (width >= 900) {
            crossAxisCount = 4;
          } else if (width >= 600) {
            crossAxisCount = 3;
          } else if (width >= 400) {
            crossAxisCount = 2;
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: width > 600 ? 24 : 16,
                  vertical: 16,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: width > 600 ? 16 : 12,
                  mainAxisSpacing: width > 600 ? 16 : 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: total,
                itemBuilder: (context, index) {
                  final category = vavakaCategories[index];
                  final isa = _isaAmin(category.label);
                  final anim = _itemAnimation(index, total);

                  return AnimatedBuilder(
                    animation: anim,
                    builder: (context, child) {
                      return Opacity(
                        opacity: anim.value,
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - anim.value)),
                          child: Transform.scale(
                            scale: 0.92 + (0.08 * anim.value),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: _VavakaSokajyTile(
                      category: category,
                      isa: isa,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, animation, __) =>
                                VavakaByCategoryScreen(category: category),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.05, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 320),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VavakaSokajyTile extends StatefulWidget {
  final VavakaCategory category;
  final int isa;
  final VoidCallback onTap;

  const _VavakaSokajyTile({
    required this.category,
    required this.isa,
    required this.onTap,
  });

  @override
  State<_VavakaSokajyTile> createState() => _VavakaSokajyTileState();
}

class _VavakaSokajyTileState extends State<_VavakaSokajyTile>
    with TickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;
  late final AnimationController _iconController;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_iconController);
  }

  @override
  void dispose() {
    _pressController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    _iconController.forward(from: 0);
    widget.onTap();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnim, _iconScale]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: Material(
        color: AppColors.vavakaLight,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          splashColor: AppColors.vavakaPrimary.withValues(alpha: 0.12),
          highlightColor: AppColors.vavakaPrimary.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: AppColors.vavakaLight,
                        alignment: Alignment.center,
                        child: ScaleTransition(
                          scale: _iconScale,
                          child: Icon(
                            widget.category.icon,
                            color: AppColors.vavakaPrimary,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.category.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.vavakaPrimaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isa == 1 ? '1 vavaka' : '${widget.isa} vavaka',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
