import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

/// Product composition: display numbers are already localized by the caller.
class RewardPill extends StatelessWidget {
  const RewardPill({
    super.key,
    required this.amount,
    required this.unit,
    required this.label,
  });
  final String amount, unit, label;
  @override
  Widget build(BuildContext context) {
    final roles = SkinTheme.of(context).valuesFor(Theme.of(context).brightness);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ElementIdentity(
        elementId: 'auth.entry.reward',
        runtimeLocator: UiIdentityScope.resolve(context),
        componentId: 'reward.pill',
        structureRef: 'reward.pill',
        fileKey: '7PGTHT5CQzbTsWZQnPIQce',
        variantId: '18618:11749',
        componentSetId: null,
        rawSetName: '',
        rawVariantName: '',
        variants: const {},
        declared: const {},
        resolved: const {},
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: roles.color('Surface Container/Base'),
            borderRadius: const BorderRadiusDirectional.all(
              Radius.circular(AuthEntryTokens.pillRadius),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AuthEntryTokens.pillStart,
              end: AuthEntryTokens.pillEnd,
              top: AuthEntryTokens.pillStart,
              bottom: AuthEntryTokens.pillStart,
            ),
            child: Wrap(
              spacing: AuthEntryTokens.pillGap,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: roles.color('Countainer/Pink'),
                    borderRadius: const BorderRadiusDirectional.all(
                      Radius.circular(AuthEntryTokens.pillRadius),
                    ),
                  ),
                  child: SizedBox(
                    width: AuthEntryTokens.crownContainer,
                    height: AuthEntryTokens.crownContainer,
                    child: Center(
                      child: AssetAppIcon(
                        AppIconId.crown,
                        size: AuthEntryTokens.crownSize,
                        color: roles.color('Primary/Pink'),
                      ),
                    ),
                  ),
                ),
                Wrap(
                  spacing: AuthEntryTokens.amountUnitGap,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      amount,
                      textDirection: TextDirection.ltr,
                      style: AuthTextTokens
                          .byName['English/Baseline/Number-Large']!
                          .copyWith(color: roles.color('On Surface/Emphasis')),
                    ),
                    Text(
                      unit,
                      style: AuthTextTokens.byName['English/Muted/Label-Small']!
                          .copyWith(color: roles.color('On Surface/Variant')),
                    ),
                  ],
                ),
                Text(
                  label,
                  style: AuthTextTokens.byName['English/Baseline/Label-Medium']!
                      .copyWith(color: roles.color('On Surface/Emphasis')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
