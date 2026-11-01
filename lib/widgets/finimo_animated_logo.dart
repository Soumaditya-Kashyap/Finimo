import 'package:flutter/material.dart';

/// A reusable animated Finimo logo widget that continuously cycles brand colours
/// across its three distinct geometric elements.
///
/// Features:
/// - Exact original shape, proportions, and three separate visual elements.
/// - The logo stays stationary: zero rotation, scale, movement, morphing, or distortion.
/// - No gradients, glow, shadows, or particles.
/// - Smooth continuous colour cycle between:
///     - Neon Lime (#C6FF00)
///     - Purple    (#8B2EFF)
///     - Cyan      (#24DDE8)
/// - Highly optimized with [RepaintBoundary] to prevent parent rebuilds.
class FinimoAnimatedLogo extends StatefulWidget {
  /// Brand colours
  static const Color neonLime = Color(0xFFC6FF00);
  static const Color purple = Color(0xFF8B2EFF);
  static const Color cyan = Color(0xFF24DDE8);

  /// Convenient square dimension (sets both width and height).
  final double? size;

  /// Explicit width (overrides [size]).
  final double? width;

  /// Explicit height (overrides [size]).
  final double? height;

  /// Total duration for one complete 3-phase colour rotation cycle.
  final Duration duration;

  /// Whether the animation should run continuously.
  /// If false, displays static logo with default brand colours.
  final bool animate;

  /// Transition curve applied to each phase.
  final Curve curve;

  const FinimoAnimatedLogo({
    super.key,
    this.size,
    this.width,
    this.height,
    this.duration = const Duration(milliseconds: 2400),
    this.animate = true,
    this.curve = Curves.easeInOutCubic,
  });

  @override
  State<FinimoAnimatedLogo> createState() => _FinimoAnimatedLogoState();
}

class _FinimoAnimatedLogoState extends State<FinimoAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const String _topAsset = 'assets/logos/finimo_element_top.png';
  static const String _midAsset = 'assets/logos/finimo_element_middle.png';
  static const String _botAsset = 'assets/logos/finimo_element_bottom.png';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(FinimoAnimatedLogo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      if (widget.animate && !_controller.isAnimating) {
        _controller.repeat();
      }
    }

    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Calculates the current colour for each of the 3 elements based on normalized progress [0.0, 1.0].
  ///
  /// Initial state (t = 0.0):
  ///   Top: Lime, Middle: Purple, Bottom: Cyan
  ///
  /// Phase 0 (0.00 <= t < 0.333):
  ///   Top: Lime -> Purple
  ///   Mid: Purple -> Cyan
  ///   Bot: Cyan -> Lime
  ///
  /// Phase 1 (0.333 <= t < 0.666):
  ///   Top: Purple -> Cyan
  ///   Mid: Cyan -> Lime
  ///   Bot: Lime -> Purple
  ///
  /// Phase 2 (0.666 <= t <= 1.000):
  ///   Top: Cyan -> Lime
  ///   Mid: Lime -> Purple
  ///   Bot: Purple -> Cyan
  (Color, Color, Color) _calculateColors(double progress) {
    if (!widget.animate) {
      return (
        FinimoAnimatedLogo.neonLime,
        FinimoAnimatedLogo.purple,
        FinimoAnimatedLogo.cyan,
      );
    }

    const c0 = FinimoAnimatedLogo.neonLime;
    const c1 = FinimoAnimatedLogo.purple;
    const c2 = FinimoAnimatedLogo.cyan;

    final double p = progress.clamp(0.0, 1.0);

    if (p < 1.0 / 3.0) {
      final double localT = p * 3.0;
      final double eased = widget.curve.transform(localT.clamp(0.0, 1.0));
      return (
        Color.lerp(c0, c1, eased)!,
        Color.lerp(c1, c2, eased)!,
        Color.lerp(c2, c0, eased)!,
      );
    } else if (p < 2.0 / 3.0) {
      final double localT = (p - 1.0 / 3.0) * 3.0;
      final double eased = widget.curve.transform(localT.clamp(0.0, 1.0));
      return (
        Color.lerp(c1, c2, eased)!,
        Color.lerp(c2, c0, eased)!,
        Color.lerp(c0, c1, eased)!,
      );
    } else {
      final double localT = (p - 2.0 / 3.0) * 3.0;
      final double eased = widget.curve.transform(localT.clamp(0.0, 1.0));
      return (
        Color.lerp(c2, c0, eased)!,
        Color.lerp(c0, c1, eased)!,
        Color.lerp(c1, c2, eased)!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double targetWidth = widget.width ?? widget.size ?? 72.0;
    final double targetHeight = widget.height ?? widget.size ?? 72.0;

    return RepaintBoundary(
      child: SizedBox(
        width: targetWidth,
        height: targetHeight,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final (topColor, midColor, botColor) =
                  _calculateColors(_controller.value);

              return Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  // Top wing element
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(topColor, BlendMode.srcIn),
                    child: Image.asset(
                      _topAsset,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),

                  // Middle element with curving tail
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(midColor, BlendMode.srcIn),
                    child: Image.asset(
                      _midAsset,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),

                  // Bottom-right rounded triangle element
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(botColor, BlendMode.srcIn),
                    child: Image.asset(
                      _botAsset,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A compact, drop-in loading indicator that renders the [FinimoAnimatedLogo].
///
/// Can be used wherever [CircularProgressIndicator] is typically placed,
/// such as button spinners, screen loading states, and modal loading sheets.
class FinimoLoader extends StatelessWidget {
  final double size;
  final Duration duration;

  const FinimoLoader({
    super.key,
    this.size = 36.0,
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FinimoAnimatedLogo(
        size: size,
        duration: duration,
      ),
    );
  }
}

