import 'package:flutter/material.dart';

import '../../../design_system.dart';

/// Shared Gallery/golden composition, outside the product runtime barrel.
class AuthPrimitivesFixture extends StatefulWidget {
  const AuthPrimitivesFixture({
    super.key,
    required this.label,
    required this.divider,
    required this.remember,
    required this.terms,
    required this.privacy,
    required this.playStation,
    required this.xbox,
    required this.google,
  });
  final String label,
      divider,
      remember,
      terms,
      privacy,
      playStation,
      xbox,
      google;
  @override
  State<AuthPrimitivesFixture> createState() => _AuthPrimitivesFixtureState();
}

class _AuthPrimitivesFixtureState extends State<AuthPrimitivesFixture> {
  bool checked = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const HeroBanner(elementId: 'gallery.auth.hero'),
      AppButton(
        elementId: 'gallery.auth.accent',
        label: widget.label,
        tone: AppButtonTone.accent,
        family: AppButtonFamily.fill,
        onPressed: () {},
      ),
      AppButton(
        elementId: 'gallery.auth.loading',
        label: widget.label,
        tone: AppButtonTone.accent,
        family: AppButtonFamily.fill,
        loading: true,
        loadingSemanticsLabel: widget.label,
        onPressed: () {},
      ),
      AppToggle(
        elementId: 'gallery.auth.toggle',
        label: widget.remember,
        value: checked,
        onChanged: (value) => setState(() => checked = value),
      ),
      LabeledDivider(elementId: 'gallery.auth.divider', label: widget.divider),
      Row(
        children: [
          for (final brand in SocialAuthBrand.values)
            Expanded(
              child: SocialAuthTile(
                elementId: 'gallery.auth.brand.${brand.name.toLowerCase()}',
                brand: brand,
                label: switch (brand) {
                  SocialAuthBrand.playStation => widget.playStation,
                  SocialAuthBrand.xbox => widget.xbox,
                  SocialAuthBrand.google => widget.google,
                },
                onPressed: () {},
              ),
            ),
        ],
      ),
      LinkText(
        elementId: 'gallery.auth.links',
        segments: [
          LinkTextSegment(widget.terms, onTap: () {}),
          LinkTextSegment(widget.privacy, onTap: () {}),
        ],
      ),
      AppToast(
        elementId: 'gallery.auth.toast',
        message: widget.label,
        onDismiss: () {},
      ),
    ],
  );
}
