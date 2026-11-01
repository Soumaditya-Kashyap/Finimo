import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/deep_dive_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class AnimatedDonutChartHero extends StatefulWidget {
  final DeepDiveSummaryData data;
  final bool isActive;

  const AnimatedDonutChartHero({
    super.key,
    required this.data,
    this.isActive = true,
  });

  @override
  State<AnimatedDonutChartHero> createState() => _AnimatedDonutChartHeroState();
}

class _AnimatedDonutChartHeroState extends State<AnimatedDonutChartHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.isActive) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedDonutChartHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && (!oldWidget.isActive || widget.data != oldWidget.data)) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.ghostBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient Glows
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryFixed.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Donut Chart Canvas
              SizedBox(
                width: 240,
                height: 240,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final progress = _animation.value;
                    return CustomPaint(
                      painter: _DonutChartPainter(
                        categories: widget.data.categories,
                        animationProgress: progress,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'TOTAL EXPENSES',
                              style: AppTypography.labelSm(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ).copyWith(
                                fontSize: 9.5,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.formatInr(
                                widget.data.totalOutflow * progress,
                              ),
                              style: AppTypography.displayLg(
                                color: AppColors.textPrimary,
                              ).copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface02,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryFixed,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryFixed.withValues(alpha: 0.8),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.data.statusLabel,
                                    style: AppTypography.labelSm(
                                      color: const Color(0xFFA6CF00),
                                      fontWeight: FontWeight.w700,
                                    ).copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Footer: Paced at & Days Monitored
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Average ${CurrencyFormatter.formatInr(widget.data.dailyPace)}/day',
                    style: AppTypography.bodySm(color: AppColors.textMuted),
                  ),
                  Text(
                    '${widget.data.daysMonitored} DAYS RECORDED',
                    style: AppTypography.labelSm(
                      color: AppColors.primaryFixed,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 10, letterSpacing: 0.8),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<InsightCategoryBurn> categories;
  final double animationProgress;

  _DonutChartPainter({
    required this.categories,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 18.0;
    final radius = (size.width / 2) - strokeWidth;

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.surface02
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (categories.isEmpty || animationProgress <= 0) return;

    // Segments starting from top-center (-pi/2)
    var currentAngle = -math.pi / 2;
    const gapAngle = 0.04; // Visual micro gap between segments

    for (final cat in categories) {
      final sweepAngle = (cat.percentage / 100) * 2 * math.pi * animationProgress;
      if (sweepAngle <= 0) continue;

      final segmentPaint = Paint()
        ..color = cat.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final effectiveSweep = (sweepAngle - gapAngle).clamp(0.01, sweepAngle);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle + (gapAngle / 2),
        effectiveSweep,
        false,
        segmentPaint,
      );

      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.categories != categories;
  }
}
