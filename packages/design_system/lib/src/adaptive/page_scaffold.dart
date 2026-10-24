import 'package:flutter/material.dart';

import '../identity/element_identity.dart';
import '../theme/skin_theme.dart';
import '../tokens/generated/adaptive_tokens.g.dart';
import 'size_class.dart';

enum PageScaffoldLayout { scrolling, viewport }

/// Provisional engineering scaffold, without navigation chrome (D-039).
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.elementId,
    required this.child,
    this.runtimeLocator,
    this.layout = PageScaffoldLayout.scrolling,
  });
  final String elementId;
  final UiRuntimeLocator? runtimeLocator;
  final Widget child;

  /// D-056: bounded viewport for edge-to-edge hero and keyboard-pinned actions.
  /// The default retains the original SafeArea/scroll/content-cap behavior.
  final PageScaffoldLayout layout;
  @override
  Widget build(BuildContext context) {
    final sizeClass = SizeClass.of(context);
    return ElementIdentity(
      elementId: elementId,
      runtimeLocator: UiIdentityScope.resolve(
        context,
        override: runtimeLocator,
      ),
      componentId: 'layout.page-scaffold',
      structureRef: 'layout.page-scaffold',
      fileKey: '',
      variantId: null,
      componentSetId: null,
      rawSetName: '',
      rawVariantName: '',
      variants: {
        'sizeClass': sizeClass.name,
        if (layout == PageScaffoldLayout.viewport) 'layout': layout.name,
      },
      resolved: {'sizeClass': sizeClass.name},
      declared: const {},
      child: Scaffold(
        backgroundColor: layout == PageScaffoldLayout.viewport
            ? SkinTheme.of(context)
                  .valuesFor(Theme.of(context).brightness)
                  .color('Surface/Base')
            : null,
        resizeToAvoidBottomInset: true,
        body: layout == PageScaffoldLayout.viewport
            ? child
            : SafeArea(
                child: Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: sizeClass == SizeClass.compact
                          ? double.infinity
                          : AdaptiveTokens.contentMaxWidth,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(child: child),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
