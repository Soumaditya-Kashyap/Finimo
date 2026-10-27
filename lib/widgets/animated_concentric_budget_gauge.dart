import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/targets_dashboard_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class AnimatedConcentricBudgetGauge extends StatefulWidget {
  final TargetsDashboardData data;
  final bool isActive;

  const AnimatedConcentricBudgetGauge({
    super.key,
    required this.data,
    this.isActive = true,
  });

  @override
  State<AnimatedConcentricBudgetGauge> createState() =>
      _AnimatedConcentricBudgetGaugeState();
}

class _AnimatedConcentricBudgetGaugeState
    extends State<AnimatedConcentricBudgetGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _curveAnimation;

  @override
  void initState() {
    super.initState();
    // Smooth 1.3s ease-out animation lasting approximately 1.2–1.5s
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _curveAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    if (widget.isActive) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedConcentricBudgetGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation every time the user navigates to this page!
    if (widget.isActive && (!oldWidget.isActive || widget.data != oldWidget.data)) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
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
          // Ambient Radial Glows (top-right lime glow, bottom-left cyan glow)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
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
            bottom: -50,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.tertiaryFixed.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Top Status Pill: Optimal Pacing (18 Days Left)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'OPTIMAL PACING (${widget.data.daysLeft} DAYS LEFT)',
                      style: AppTypography.labelSm(
                        color: AppColors.primaryFixed,
                        fontWeight: FontWeight.w700,
                      ).copyWith(
                        letterSpacing: 0.8,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Animated Dual Concentric Arcs Gauge with Center Text
              SizedBox(
                width: 230,
                height: 230,
                child: AnimatedBuilder(
                  animation: _curveAnimation,
                  builder: (context, child) {
                    final progress = _curveAnimation.value;
                    return CustomPaint(
                      painter: _ConcentricGaugePainter(
                        runwayProgress: widget.data.runwayProgress * progress,
                        pacingProgress: widget.data.pacingProgress * progress,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(widget.data.budgetRemainingPct * progress).round()}%',
                              style: AppTypography.displayLg(
                                color: AppColors.textPrimary,
                              ).copyWith(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.2,
                              ),
                            ),
                            Text(
                              'BUDGET REMAINING',
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
                              '${CurrencyFormatter.formatInr(widget.data.budgetRemainingAmount)} left',
                              style: AppTypography.labelMd(
                                color: AppColors.primaryFixed,
                                fontWeight: FontWeight.w700,
                              ).copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Micro Legend & Safe Cap Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface02.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryFixed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pacing',
                          style: AppTypography.bodySm(color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.tertiaryFixed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Runway',
                          style: AppTypography.bodySm(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Safe Cap: ',
                          style: AppTypography.bodySm(color: AppColors.textMuted),
                        ),
                        Text(
                          CurrencyFormatter.formatInr(widget.data.safeCapAmount),
                          style: AppTypography.bodySm(
                            color: AppColors.textPrimary,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConcentricGaugePainter extends CustomPainter {
  final double runwayProgress; // Outer Cyber Cyan
  final double pacingProgress; // Inner Electric Lime

  _ConcentricGaugePainter({
    required this.runwayProgress,
    required this.pacingProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.0;
    final outerRadius = (size.width / 2) - strokeWidth;
    final innerRadius = outerRadius - 16.0;

    // Background track paint
    final trackPaint = Paint()
      ..color = AppColors.surface02
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background tracks
    canvas.drawCircle(center, outerRadius, trackPaint);
    canvas.drawCircle(center, innerRadius, trackPaint);

    // Starting from top-center (-90 degrees / -pi / 2)
    const startAngle = -math.pi / 2;

    // Outer Arc: Cyber Cyan (Runway)
    if (runwayProgress > 0) {
      final outerPaint = Paint()
        ..color = AppColors.tertiaryFixed
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * runwayProgress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweepAngle,
        false,
        outerPaint,
      );
    }

    // Inner Arc: Electric Lime (Pacing)
    if (pacingProgress > 0) {
      final innerPaint = Paint()
        ..color = AppColors.primaryFixed
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * pacingProgress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        sweepAngle,
        false,
        innerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConcentricGaugePainter oldDelegate) {
    return oldDelegate.runwayProgress != runwayProgress ||
        oldDelegate.pacingProgress != pacingProgress;
  }
}
