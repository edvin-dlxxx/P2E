import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/testing.dart';

import '../l10n/generated/viewer_localizations.dart';

class AuthPrimitivesGallery extends StatelessWidget {
  const AuthPrimitivesGallery({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = ViewerLocalizations.of(context);
    return SingleChildScrollView(
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: SizedBox(
          width: 402,
          child: UiIdentityScope(
            routeName: 'gallery.auth',
            child: AuthPrimitivesFixture(
              label: strings.authContinue,
              divider: strings.authDivider,
              remember: strings.authRemember,
              terms: strings.authTerms,
              privacy: strings.authPrivacy,
              playStation: strings.authPlayStation,
              xbox: strings.authXbox,
              google: strings.authGoogle,
            ),
          ),
        ),
      ),
    );
  }
}
