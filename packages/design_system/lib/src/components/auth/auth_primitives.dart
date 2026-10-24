import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../icons/app_icon.dart';
import '../../identity/element_identity.dart';
import '../../theme/skin_theme.dart';
import '../../tokens/field_spec.dart';
import '../../tokens/generated/auth_entry_tokens.g.dart';
import '../fields/app_radio.dart';

const _file = '7PGTHT5CQzbTsWZQnPIQce';

ElementIdentity _identity(
  BuildContext context,
  String id,
  String component,
  Widget child, {
  String? node,
  String? slot,
  Map<String, Object?> declared = const {},
  Map<String, Object?> resolved = const {},
}) => ElementIdentity(
  elementId: id,
  runtimeLocator: slot == null
      ? UiIdentityScope.resolve(context)
      : UiIdentityScope.resolve(context)?.slot(slot),
  componentId: component,
  structureRef: component,
  fileKey: node == null ? '' : _file,
  variantId: node,
  componentSetId: null,
  rawSetName: '',
  rawVariantName: '',
  variants: {
    if (declared['enabled'] is bool) 'enabled': declared['enabled'].toString(),
  },
  resolved: resolved,
  declared: declared,
  child: child,
);

/// D-056: the existing Radio artwork with independent checkbox behavior.
class AppToggle extends StatefulWidget {
  const AppToggle({
    super.key,
    required this.elementId,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String elementId, label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  @override
  State<AppToggle> createState() => _AppToggleState();
}

class _AppToggleState extends State<AppToggle> {
  final node = FocusNode();
  bool hover = false, focused = false;
  Duration duration = Duration.zero;
  void toggle() {
    if (widget.onChanged == null) {
      return;
    }
    duration = Duration.zero;
    widget.onChanged!(!widget.value);
  }

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.value
        ? (hover || focused
              ? FieldVisualState.selectedHover
              : FieldVisualState.selected)
        : (hover || focused
              ? FieldVisualState.notSelectedHover
              : FieldVisualState.notSelected);
    final spec = FieldSpec.lookup(
      FieldFamily.radio,
      state,
      Theme.of(context).brightness,
    );
    final enabled = widget.onChanged != null;
    return _identity(
      context,
      widget.elementId,
      'toggle.checkbox',
      Semantics(
        checked: widget.value,
        enabled: enabled,
        label: widget.label,
        onTap: enabled ? toggle : null,
        child: FocusableActionDetector(
          focusNode: node,
          enabled: enabled,
          onFocusChange: (v) => setState(() => focused = v),
          onShowHoverHighlight: (v) => setState(() {
            hover = v;
            duration = FieldMotion.hover;
          }),
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                toggle();
                return null;
              },
            ),
          },
          child: GestureDetector(
            excludeFromSemantics: true,
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? toggle : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: FieldMotion.tapExtent),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: ExcludeSemantics(
                  child: AppRadioPresentation(
                    spec: spec,
                    label: widget.label,
                    duration: duration,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      node: focused && !hover ? null : spec.sourceId,
      declared: {
        'sourceUsageNodeId': '18618:11599',
        'checked': widget.value,
        'enabled': enabled,
        'focused': focused,
      },
      resolved: {
        'sourceVisual': 'radio',
        'sourceBasisNodeId': spec.basisId,
        'minimumHitExtent': FieldMotion.tapExtent,
      },
    );
  }
}

class LabeledDivider extends StatelessWidget {
  const LabeledDivider({
    super.key,
    required this.elementId,
    required this.label,
  });
  final String elementId, label;
  @override
  Widget build(BuildContext context) {
    final roles = SkinTheme.of(context).valuesFor(Theme.of(context).brightness);
    return _identity(
      context,
      elementId,
      'divider.labeled',
      Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AuthEntryTokens.dividerInset,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: _DividerStroke(roles.color('Outline/Variant')),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      (constraints.maxWidth -
                              2 * AuthEntryTokens.dividerStrokeWidth)
                          .clamp(0, double.infinity),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AuthEntryTokens.dividerGap,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AuthTextTokens.byName['English/Muted/Label-Small']!
                        .copyWith(color: roles.color('On Surface/Muted')),
                  ),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  painter: _DividerStroke(roles.color('Outline/Variant')),
                ),
              ),
            ],
          ),
        ),
      ),
      node: '18613:11493',
    );
  }
}

class _DividerStroke extends CustomPainter {
  const _DividerStroke(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) => canvas.drawLine(
    Offset.zero,
    Offset(size.width, 0),
    Paint()
      ..color = color
      ..strokeWidth = AuthEntryTokens.dividerStrokeWidth
      ..strokeCap = StrokeCap.round,
  );
  @override
  bool shouldRepaint(_DividerStroke oldDelegate) => color != oldDelegate.color;
}

/// D-059: inline prose links use the WCAG2.5.8 inline exception. Each retains
/// its own native keyboard control and link semantics without target padding.
class LinkTextSegment {
  const LinkTextSegment(this.text, {this.onTap});
  final String text;
  final VoidCallback? onTap;
}

/// The idle source Body includes its inside stroke in child layout (D-059).
class AuthEntryBodyFrame extends StatelessWidget {
  const AuthEntryBodyFrame({
    super.key,
    required this.elementId,
    required this.child,
  });
  final String elementId;
  final Widget child;
  @override
  Widget build(BuildContext context) => _identity(
    context,
    elementId,
    'auth.body',
    DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AuthBrandTokens.bodyOutline,
          width: AuthEntryTokens.bodyStroke,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AuthEntryTokens.bodyStroke),
        child: child,
      ),
    ),
    node: '18608:11454',
  );
}

class LinkText extends StatelessWidget {
  const LinkText({
    super.key,
    required this.elementId,
    required this.segments,
    this.enabled = true,
  });
  final String elementId;
  final List<LinkTextSegment> segments;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final roles = SkinTheme.of(context).valuesFor(Theme.of(context).brightness);
    final style = AuthTextTokens.byName['English/Muted/Label-Small']!;
    return _identity(
      context,
      elementId,
      'text.links',
      FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Text.rich(
          TextSpan(
            children: [
              for (final (index, segment) in segments.indexed)
                if (segment.onTap == null)
                  TextSpan(text: segment.text)
                else
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: FocusTraversalOrder(
                      order: NumericFocusOrder(index.toDouble()),
                      child: _identity(
                        context,
                        elementId,
                        'text.link',
                        Semantics(
                          container: true,
                          link: true,
                          onTap: enabled ? segment.onTap : null,
                          label: segment.text,
                          button: false,
                          child: ExcludeSemantics(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: AuthTextTokens
                                    .byName['English/Baseline/Label-Small'],
                                foregroundColor: roles.actionAccent,
                                padding: EdgeInsetsDirectional.zero,
                              ),
                              onPressed: enabled ? segment.onTap : null,
                              child: Text(segment.text),
                            ),
                          ),
                        ),
                        node: '18618:11677',
                        slot: 'link$index',
                        declared: {'enabled': enabled},
                      ),
                    ),
                  ),
            ],
          ),
          textAlign: TextAlign.center,
          style: style.copyWith(color: roles.color('On Surface/Base')),
        ),
      ),
      node: '18618:11677',
      declared: {'enabled': enabled},
    );
  }
}

/// Original exported illustration with the source SVG's elliptical alpha mask.
/// The source matrix is generated; current skin surface remains behind alpha.
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, required this.elementId});
  final String elementId;
  @override
  Widget build(BuildContext context) => _identity(
    context,
    elementId,
    'hero.banner',
    ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        final matrix =
            Matrix4.diagonal3Values(
              AuthHeroMaskTokens.radiusX *
                  bounds.width /
                  AuthHeroMaskTokens.width,
              AuthHeroMaskTokens.radiusY *
                  bounds.height /
                  AuthHeroMaskTokens.height,
              1,
            )..setTranslationRaw(
              AuthHeroMaskTokens.centerX *
                  bounds.width /
                  AuthHeroMaskTokens.width,
              AuthHeroMaskTokens.centerY *
                  bounds.height /
                  AuthHeroMaskTokens.height,
              0,
            );
        return ui.Gradient.radial(
          Offset.zero,
          1,
          const [AuthHeroMaskTokens.opaque, AuthHeroMaskTokens.transparent],
          const [0, 1],
          TileMode.clamp,
          matrix.storage,
        );
      },
      child: Image.asset(
        'assets/images/auth/entry_illustration.png',
        package: 'p2e_design_system',
        width: double.infinity,
        height: AuthEntryTokens.artworkHeight,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
    ),
    node: '18618:12122',
  );
}

enum SocialAuthBrand { playStation, xbox, google }

/// Original Figma Special Logos, deliberately not tinted by skins.
class BrandAppIcon extends AppIcon {
  const BrandAppIcon(this.brand, {super.key});
  final SocialAuthBrand brand;
  @override
  String get iconId => 'brand.${brand.name.toLowerCase()}';
  @override
  AppIcon withStyle(AppIconStyle style) =>
      throw UnsupportedError('Brand artwork has no Outline/Fill variants');
  @override
  Widget build(BuildContext context) {
    final name = switch (brand) {
      SocialAuthBrand.playStation => 'playstation',
      SocialAuthBrand.xbox => 'xbox',
      SocialAuthBrand.google => 'google',
    };
    final size = brand == SocialAuthBrand.google
        ? AuthEntryTokens.googleSize
        : AuthEntryTokens.brandSize;
    return SvgPicture.asset(
      'assets/icons/brands/$name.svg',
      package: 'p2e_design_system',
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}

class SocialAuthTile extends StatelessWidget {
  const SocialAuthTile({
    super.key,
    required this.elementId,
    required this.brand,
    required this.label,
    required this.onPressed,
  });
  final String elementId, label;
  final SocialAuthBrand brand;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final roles = SkinTheme.of(context).valuesFor(Theme.of(context).brightness);
    final color = switch (brand) {
      SocialAuthBrand.playStation => AuthBrandTokens.playStation,
      SocialAuthBrand.xbox => AuthBrandTokens.xbox,
      SocialAuthBrand.google => AuthBrandTokens.google,
    };
    return _identity(
      context,
      elementId,
      'social.auth-tile',
      TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsetsDirectional.zero,
          minimumSize: Size(FieldMotion.tapExtent, FieldMotion.tapExtent),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadiusDirectional.all(
                  Radius.circular(AuthEntryTokens.socialRadius),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: AuthEntryTokens.socialHeight,
                child: Center(
                  child: brand == SocialAuthBrand.google
                      ? BrandAppIcon(brand)
                      : OverflowBox(
                          minWidth: AuthEntryTokens.brandSize,
                          maxWidth: AuthEntryTokens.brandSize,
                          minHeight: AuthEntryTokens.brandSize,
                          maxHeight: AuthEntryTokens.brandSize,
                          child: BrandAppIcon(brand),
                        ),
                ),
              ),
            ),
            const SizedBox(height: AuthEntryTokens.socialLabelGap),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AuthTextTokens.byName['English/Baseline/Label-Small']!
                  .copyWith(color: roles.color('On Surface/Emphasis')),
            ),
          ],
        ),
      ),
      node: switch (brand) {
        SocialAuthBrand.playStation => '18613:11500',
        SocialAuthBrand.xbox => '18613:11505',
        SocialAuthBrand.google => '18613:11516',
      },
      declared: {'brand': brand.name, 'enabled': onPressed != null},
    );
  }
}

/// A keyboard/safe-area-aware transient live region. The surrounding Stack
/// owns placement; disposal cancels the timer and never leaves a stale overlay.
class AppToast extends StatefulWidget {
  const AppToast({
    super.key,
    required this.elementId,
    required this.message,
    required this.onDismiss,
  });
  final String elementId, message;
  final VoidCallback onDismiss;
  @override
  State<AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<AppToast> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    _schedule();
  }

  void _schedule() {
    timer?.cancel();
    timer = Timer(AuthToastTokens.duration, widget.onDismiss);
  }

  @override
  void didUpdateWidget(AppToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) _schedule();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roles = SkinTheme.of(context).valuesFor(Theme.of(context).brightness);
    return _identity(
      context,
      widget.elementId,
      'toast.transient',
      SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AuthEntryTokens.formInset),
          child: Semantics(
            liveRegion: true,
            label: widget.message,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: roles.color('Surface Container/Base'),
                borderRadius: const BorderRadiusDirectional.all(
                  Radius.circular(AuthEntryTokens.socialRadius),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(
                  AuthEntryTokens.formInset,
                ),
                child: SingleChildScrollView(
                  child: ExcludeSemantics(
                    child: Text(
                      widget.message,
                      style: AuthTextTokens
                          .byName['English/Muted/Label-Medium']!
                          .copyWith(color: roles.color('On Surface/Emphasis')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      declared: {'engineeringDecision': 'D-056'},
      resolved: {
        'autoDismissMilliseconds': AuthToastTokens.duration.inMilliseconds,
        'surfaceRole': 'Surface Container/Base',
        'motion': 'none',
      },
    );
  }
}
