import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

class AuthIntro extends StatelessWidget {
  const AuthIntro({super.key, required this.title, required this.subtitle});
  final String title, subtitle;
  Widget identified(
    BuildContext context,
    String slot,
    String node,
    Widget child,
  ) => ElementIdentity(
    elementId: 'auth.entry.$slot',
    runtimeLocator: UiIdentityScope.resolve(context),
    componentId: 'text.auth-intro',
    structureRef: 'text.auth-intro',
    fileKey: '7PGTHT5CQzbTsWZQnPIQce',
    variantId: node,
    componentSetId: null,
    rawSetName: '',
    rawVariantName: '',
    variants: const {},
    declared: const {},
    resolved: const {},
    child: child,
  );
  @override
  Widget build(BuildContext context) {
    final roles = SkinTheme.of(context).valuesFor(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsetsDirectional.all(AuthEntryTokens.pageInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          identified(
            context,
            'title',
            '18613:11489',
            Text(
              title,
              key: const ValueKey('auth.title'),
              style: AuthTextTokens.byName['English/Baseline/Headline-Large']!
                  .copyWith(color: roles.color('On Surface/Emphasis')),
            ),
          ),
          const SizedBox(height: AuthEntryTokens.headingGap),
          identified(
            context,
            'subtitle',
            '18613:11491',
            Text(
              subtitle,
              key: const ValueKey('auth.subtitle'),
              style: AuthTextTokens.byName['English/Variant/Title-Small']!
                  .copyWith(color: roles.color('On Surface/Base')),
            ),
          ),
        ],
      ),
    );
  }
}
