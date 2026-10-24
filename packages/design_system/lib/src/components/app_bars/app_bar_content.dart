import '../../theme/skin_theme.dart';

import 'package:flutter/material.dart';

import '../../icons/app_icon.dart';
import '../../identity/element_identity.dart';
import '../../interaction/press_action.dart';
import '../../tokens/app_bar_spec.dart';
import '../../tokens/generated/readiness_tokens.g.dart';
import 'app_bar_configuration.dart';
import 'app_bar_layout.dart';

/// Transparent 64-high content, with no system inset or product side effects.
class AppBarContent extends StatelessWidget {
  const AppBarContent({
    super.key,
    required this.elementId,
    this.runtimeLocator,
    required this.configuration,
  });
  final String elementId;
  final UiRuntimeLocator? runtimeLocator;
  final AppBarConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    final spec = AppBarSpec.lookup(
      configuration.category,
      Theme.of(context).brightness,
    )?.withSkin(SkinTheme.of(context));
    if (spec == null) {
      throw UnsupportedError(
        'Back Light has no source variant; check AppBarSpec.lookup before rendering.',
      );
    }
    final scaler = MediaQuery.textScalerOf(context)
        .clamp(maxScaleFactor: chromeTextScaleCap);
    final persian = Localizations.maybeLocaleOf(context)?.languageCode == 'fa';
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: chromeTextScaleCap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedWidth) {
            throw FlutterError('AppBarContent requires bounded width');
          }
          final layout = AppBarLayout.resolve(
            spec: spec,
            configuration: configuration,
            width: constraints.maxWidth,
            scaler: scaler,
            persian: persian,
          );
          final presenter = _AppBarPresentation(
            spec: spec,
            configuration: configuration,
            layout: layout,
            elementId: elementId,
            runtimeLocator: UiIdentityScope.resolve(
              context,
              override: runtimeLocator,
            ),
            persian: persian,
          );
          final content = SizedBox(
            key: ValueKey('$elementId.content'),
            height: spec.contentHeight,
            child: layout.scrolls
                ? _OverflowCanvas(width: layout.canvasWidth, child: presenter)
                : presenter,
          );
          return ElementIdentity(
            elementId: elementId,
            runtimeLocator: UiIdentityScope.resolve(
              context,
              override: runtimeLocator,
            ),
            componentId: 'app-bar.container',
            structureRef:
                'app-bar.${configuration.category.name == 'downloadableGame' ? 'downloadable-game' : configuration.category.name}',
            fileKey: spec.fileKey,
            variantId: spec.id,
            componentSetId: spec.setId,
            rawSetName: spec.setName,
            rawVariantName: spec.rawName,
            variants: {
              'category': configuration.category.name,
              'theme': spec.brightness.name,
            },
            declared: {
              'actions': {
                for (final e in configuration.actions.entries)
                  e.key: {
                    'available': e.value.onPressed != null,
                    'label': e.value.label,
                  },
              },
              'notification':
                  configuration is DownloadableGameAppBar &&
                  (configuration as DownloadableGameAppBar).showNotification,
            },
            resolved: {
              'appBar': {
                'value': {
                  ...spec.resolved(persian: persian),
                  'layout': layout.toJson(),
                },
                'origin': 'runtime-resolver',
              },
            },
            child: content,
          );
        },
      ),
    );
  }
}

class _OverflowCanvas extends StatefulWidget {
  const _OverflowCanvas({required this.width, required this.child});
  final double width;
  final Widget child;
  @override
  State<_OverflowCanvas> createState() => _OverflowCanvasState();
}

class _OverflowCanvasState extends State<_OverflowCanvas> {
  final controller = ScrollController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scrollbar(
    controller: controller,
    thumbVisibility: true,
    child: SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      child: SizedBox(width: widget.width, child: widget.child),
    ),
  );
}

class _AppBarPresentation extends StatelessWidget {
  const _AppBarPresentation({
    required this.spec,
    required this.configuration,
    required this.layout,
    required this.elementId,
    this.runtimeLocator,
    required this.persian,
  });
  final AppBarSpec spec;
  final AppBarConfiguration configuration;
  final AppBarLayout layout;
  final String elementId;
  final UiRuntimeLocator? runtimeLocator;
  final bool persian;

  Widget surface(String role, Widget child) => DecoratedBox(
    key: ValueKey('$elementId.$role.surface'),
    decoration: BoxDecoration(
      color: spec.color(role),
      borderRadius: BorderRadiusDirectional.all(
        Radius.circular(spec.metric(role, 'cornerRadius')),
      ),
    ),
    child: child,
  );
  Widget icon(String role) => AssetAppIcon(
    spec.icon(role).id,
    key: ValueKey('$elementId.$role.artwork'),
    style: spec.iconStyle(role),
    size: spec.iconExtent(role),
    color: spec.iconColor(role),
  );
  Widget avatar(AppBarAvatar data) => surface(
    'avatar',
    SizedBox(
      width: spec.metric('avatar', 'width'),
      height: spec.metric('avatar', 'height'),
      child: ClipOval(
        clipBehavior: Clip.antiAlias,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child:
              data.content ??
              Text(
                data.text,
                style: spec.textStyle('avatarText', persian: persian),
              ),
        ),
      ),
    ),
  );

  Widget action(
    String role,
    AppBarAction data,
    Widget artwork, {
    String? label,
  }) {
    final nodeRole = role == 'profile'
        ? 'avatarAction'
        : role == 'addCoins'
        ? 'addSurface'
        : '${role}Action';
    final foreground = role == 'profile'
        ? spec.color('avatarText')
        : spec.iconColor(role);
    final focusColor = foreground!;
    final style = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(focusColor.withValues(alpha: 0)),
      surfaceTintColor: WidgetStatePropertyAll(focusColor.withValues(alpha: 0)),
      shadowColor: WidgetStatePropertyAll(focusColor.withValues(alpha: 0)),
      elevation: const WidgetStatePropertyAll(0),
      animationDuration: Duration.zero,
      padding: const WidgetStatePropertyAll(EdgeInsetsDirectional.zero),
      minimumSize: WidgetStatePropertyAll(Size.square(spec.actionExtent)),
      maximumSize: WidgetStatePropertyAll(Size.square(spec.actionExtent)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.all(
            Radius.circular(spec.metric(nodeRole, 'cornerRadius')),
          ),
        ),
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? BorderSide(
                color: focusColor,
                width: (AppBarSpec.engineering['focusWidth'] as num).toDouble(),
              )
            : BorderSide.none,
      ),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => focusColor.withValues(
          alpha:
              states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)
              ? (AppBarSpec.engineering['interactionOverlayAlpha'] as num)
                    .toDouble()
              : 0,
        ),
      ),
      splashFactory: NoSplash.splashFactory,
    );
    final text = label ?? data.label;
    if (text.trim().isEmpty) {
      throw ArgumentError('App Bar action needs a nonblank localized label');
    }
    return ElementIdentity(
      elementId: '$elementId.${role == 'addCoins' ? 'add-coins' : role}',
      runtimeLocator: runtimeLocator,
      componentId: 'app-bar.action',
      structureRef: 'app-bar.action.${role == 'addCoins' ? 'add-coins' : role}',
      fileKey: spec.fileKey,
      variantId: spec.part(nodeRole)['id'],
      componentSetId: spec.setId,
      rawSetName: spec.setName,
      rawVariantName: spec.part(nodeRole)['name'],
      variants: {'role': role, 'enabled': (data.onPressed != null).toString()},
      declared: {'available': data.onPressed != null, 'label': text},
      resolved: {
        'hitRegion': {
          'value': Size.square(spec.actionExtent).toString(),
          'origin': 'source-envelope / D-030 Add Coins extension',
        },
      },
      child: Tooltip(
        message: text,
        excludeFromSemantics: true,
        child: SizedBox(
          key: ValueKey('$elementId.$role.hit'),
          width: spec.actionExtent,
          height: spec.actionExtent,
          child: Semantics(
            label: text,
            button: true,
            enabled: data.onPressed != null,
            excludeSemantics: true,
            onTap: data.onPressed,
            child: PressAction(
              onPressed: data.onPressed,
              style: style,
              child: IgnorePointer(child: ExcludeSemantics(child: artwork)),
            ),
          ),
        ),
      ),
    );
  }

  Widget backArtwork() {
    // Nested source surface = action's first child; resolved separately from hit region.
    final source = spec.part('backSurface');
    return DecoratedBox(
      key: ValueKey('$elementId.back.surface'),
      decoration: BoxDecoration(
        color: spec.paint(source),
        borderRadius: BorderRadiusDirectional.all(
          Radius.circular((source['cornerRadius'] as num).toDouble()),
        ),
      ),
      child: Padding(padding: spec.padding('backSurface'), child: icon('back')),
    );
  }

  Widget downloads(DownloadableGameAppBar game) => action(
    'downloads',
    game.downloads,
    SizedBox.expand(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          icon('downloads'),
          if (game.showNotification)
            PositionedDirectional(
              start: spec.metric('overlay', 'x'),
              top: spec.metric('overlay', 'y'),
              width: spec.metric('overlay', 'width'),
              height: spec.metric('overlay', 'height'),
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Center(
                    child: surface(
                      'dot',
                      SizedBox(
                        key: ValueKey('$elementId.notification'),
                        width: spec.metric('dot', 'width'),
                        height: spec.metric('dot', 'height'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    label: game.showNotification ? game.notificationLabel : null,
  );

  Widget value(
    String role,
    String text, {
    required double width,
    TextDirection? direction,
  }) => SizedBox(
    width: width,
    child: Text(
      text,
      style: spec.textStyle(role, persian: persian),
      softWrap: false,
      textDirection: direction,
      textAlign: TextAlign.start,
    ),
  );
  Widget wallet(BuildContext context, HomeAppBar home) {
    final scaler = MediaQuery.textScalerOf(context);
    double textWidth(String role, String text) => AppBarLayout.textWidth(
      text,
      spec.textStyle(role, persian: persian),
      scaler,
    );
    Widget currency(String role, String artwork) => surface(
      role,
      SizedBox(
        width: spec.metric(role, 'width'),
        height: spec.metric(role, 'height'),
        child: Center(child: icon(artwork)),
      ),
    );
    final points = Semantics(
      label: home.wallet.pointsSemanticLabel,
      excludeSemantics: true,
      child: surface(
        'points',
        SizedBox(
          key: ValueKey('$elementId.points.pill'),
          width: layout.pointsWidth,
          height: layout.pillHeight,
          child: Padding(
            padding: spec.padding('points'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                currency('pointsIcon', 'crown'),
                SizedBox(width: spec.metric('points', 'itemSpacing')),
                value(
                  'pointsValue',
                  layout.points,
                  width: textWidth('pointsValue', layout.points),
                  direction: TextDirection.ltr,
                ),
                if (layout.showUnit) ...[
                  SizedBox(width: spec.metric('pointsAmount', 'itemSpacing')),
                  value(
                    'pointsUnit',
                    home.wallet.unit,
                    width: textWidth('pointsUnit', home.wallet.unit),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    final coins = SizedBox(
      key: ValueKey('$elementId.coins.envelope'),
      width: layout.coinsWidth,
      height: spec.actionExtent,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Semantics(
            label: home.wallet.coinsSemanticLabel,
            excludeSemantics: true,
            child: surface(
              'coins',
              SizedBox(
                key: ValueKey('$elementId.coins.pill'),
                width: layout.coinsWidth,
                height: layout.pillHeight,
                child: Padding(
                  padding: spec.padding('coins'),
                  child: Row(
                    children: [
                      currency('coinsIcon', 'currency'),
                      SizedBox(width: spec.metric('coins', 'itemSpacing')),
                      Expanded(
                        child: value(
                          'coinsValue',
                          layout.coins,
                          width: textWidth('coinsValue', layout.coins),
                          direction: TextDirection.ltr,
                        ),
                      ),
                      SizedBox(
                        width:
                            spec.metric('coins', 'itemSpacing') +
                            spec.metric('addSurface', 'width'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: 0,
            child: action(
              'addCoins',
              home.addCoins,
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: spec.metric('coins', 'paddingRight'),
                  ),
                  child: surface(
                    'addSurface',
                    SizedBox(
                      width: spec.metric('addSurface', 'width'),
                      height: spec.metric('addSurface', 'height'),
                      child: Center(child: icon('addCoins')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return SizedBox(
      key: ValueKey('$elementId.wallet'),
      width: layout.walletWidth,
      height: spec.actionExtent,
      child: Row(
        children: [
          points,
          SizedBox(width: spec.metric('wallet', 'itemSpacing')),
          coins,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: spec.padding('body'),
    child: Row(
      children: switch (configuration) {
        final HomeAppBar home => [
          action('profile', home.profile, avatar(home.avatar)),
          const Spacer(),
          wallet(context, home),
          action('help', home.help, icon('help')),
        ],
        final DownloadableGameAppBar game => [
          action('back', game.back, backArtwork()),
          const Spacer(),
          downloads(game),
          action('bookmark', game.bookmark, icon('bookmark')),
          action('profile', game.profile, avatar(game.avatar)),
        ],
        final BackAppBar bar => [
          action('back', bar.back, backArtwork()),
          const Spacer(),
          action('help', bar.help, icon('help')),
        ],
      },
    ),
  );
}
