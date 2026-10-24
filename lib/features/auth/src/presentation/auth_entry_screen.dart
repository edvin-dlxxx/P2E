import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:p2e_design_system/design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/formatting/rewards.dart';
import '../../../../shared/platform/external_links.dart';
import '../../../../shared/widgets/auth_intro.dart';
import '../../../../shared/widgets/complete_tap_envelope.dart';
import '../../../../shared/widgets/reward_pill.dart';
import '../domain/identifier.dart';
import '../domain/models.dart';
import 'auth_entry_controller.dart';
import 'auth_flow.dart';
import 'auth_messages.dart';

class AuthEntryScreen extends ConsumerStatefulWidget {
  const AuthEntryScreen({super.key});
  @override
  ConsumerState<AuthEntryScreen> createState() => _AuthEntryScreenState();
}

class _AuthEntryScreenState extends ConsumerState<AuthEntryScreen> {
  late final TextEditingController editing;
  final focus = FocusNode();
  // Keep the editor/autofill subtree when the keyboard removes the idle frame.
  final formKey = GlobalKey();
  AuthMessage? localToast;
  int toastKey = 0;
  @override
  void initState() {
    super.initState();
    editing = TextEditingController(
      text: ref.read(authEntryControllerProvider).raw,
    );
    focus.addListener(_focusChanged);
  }

  void _focusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    focus.dispose();
    editing.dispose();
    super.dispose();
  }

  void showMessage(AuthMessage message) => setState(() {
    localToast = message;
    toastKey++;
  });
  Future<void> openLink(ExternalLink link) async {
    final result = await ref.read(externalLinkPortProvider).open(link);
    if (mounted && result is Failure<void>) {
      showMessage(
        AuthFailureMapper.map(result.error).toast ?? AuthMessage.unknown,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = ref.watch(authEntryControllerProvider);
    final controller = ref.read(authEntryControllerProvider.notifier);
    ref.listen(authEntryControllerProvider, (previous, next) {
      if (next.toast != null && previous?.toastSerial != next.toastSerial) {
        showMessage(next.toast!);
      }
      if (next.destination != null &&
          previous?.destination != next.destination) {
        TextInput.finishAutofillContext();
        focus.unfocus();
        context.push(switch (next.destination!) {
          AuthStep.otp => '/entry/otp',
          AuthStep.password => '/entry/password',
          AuthStep.createPassword => '/entry/create-password',
        });
      }
    });
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    final node = keyboard
        ? switch (state.identifier) {
            Phone() => '18618:12126',
            Email() => '18618:12651',
            _ => '18618:12447',
          }
        : '18608:11451';
    final helper = state.identifier is Phone
        ? strings.authPhoneHelper
        : state.identifier is Email
        ? strings.authEmailHelper
        : null;
    final cta = state.identifier is Phone
        ? strings.authContinuePhone
        : state.identifier is Email
        ? strings.authContinueEmail
        : strings.authContinue;
    final language = Localizations.localeOf(context).languageCode;
    final offer = state.welcomeOffer;
    final amount = offer == null
        ? ''
        : formatWelcomeBonus(offer.points, languageCode: language);
    Widget button() => CompleteTapEnvelope(
      child: AppButton(
        elementId: 'auth.entry.continue',
        key: const ValueKey('auth.continue'),
        family: AppButtonFamily.fill,
        tone: AppButtonTone.accent,
        label: cta,
        loading: state.busy,
        loadingSemanticsLabel: strings.authLoading,
        onPressed: state.canSubmit
            ? () => unawaited(controller.submit())
            : null,
      ),
    );
    Widget top() => Column(
      key: formKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthIntro(title: strings.authTitle, subtitle: strings.authSubtitle),
        if (offer != null)
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AuthEntryTokens.formInset,
              vertical: AuthEntryTokens.bonusInset,
            ),
            child: RewardPill(
              amount: amount,
              unit: strings.authPoints,
              label: strings.authWelcome,
            ),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.all(AuthEntryTokens.formInset),
          child: ButtonHitRegion(
            child: AutofillGroup(
              onDisposeAction: AutofillContextAction.cancel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    elementId: 'auth.entry.identifier',
                    label: strings.authIdentifier,
                    options: FieldInputOptions(
                      controller: editing,
                      focusNode: focus,
                      hint: strings.authHint,
                      supportingText: helper,
                      enabled: !state.busy,
                      feedback: state.fieldError == null
                          ? const FieldFeedback.neutral()
                          : FieldFeedback.error(
                              message(strings, state.fieldError!),
                            ),
                      identifierPrivacy: true,
                      wrapHint: true,
                      presentation: state.identifier is Phone
                          ? FieldInputPresentation.phoneNumber
                          : FieldInputPresentation.source,
                      textDirection: TextDirection.ltr,
                      // PHYSICAL: identifiers retain typed LTR editing in every locale.
                      textAlign: TextAlign.left,
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.go,
                      autofillHints: const [
                        AutofillHints.email,
                        AutofillHints.telephoneNumber,
                        AutofillHints.username,
                      ],
                      onChanged: controller.identifierChanged,
                      onSubmitted: (_) {
                        if (state.canSubmit) unawaited(controller.submit());
                      },
                    ),
                  ),
                  if (!keyboard) ...[
                    const SizedBox(height: AuthEntryTokens.fieldGap),
                    AppToggle(
                      elementId: 'auth.entry.remember',
                      label: strings.authRemember,
                      value: state.rememberDevice,
                      onChanged: state.busy
                          ? null
                          : (_) => controller.rememberToggled(),
                    ),
                    SizedBox(
                      height:
                          AuthEntryTokens.formGap -
                          (FieldMotion.tapExtent -
                              AuthEntryTokens.radioVisualHeight),
                    ),
                    button(),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (!keyboard) ...[
          LabeledDivider(
            elementId: 'auth.entry.divider',
            label: strings.authDivider,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AuthEntryTokens.socialSectionHeight,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(
                AuthEntryTokens.pageInset,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final brand in SocialAuthBrand.values) ...[
                    if (brand != SocialAuthBrand.playStation)
                      const SizedBox(width: AuthEntryTokens.socialGap),
                    Expanded(
                      child: SocialAuthTile(
                        elementId:
                            'auth.entry.social.${brand.name.toLowerCase()}',
                        brand: brand,
                        label: switch (brand) {
                          SocialAuthBrand.playStation =>
                            strings.authPlayStation,
                          SocialAuthBrand.xbox => strings.authXbox,
                          SocialAuthBrand.google => strings.authGoogle,
                        },
                        onPressed: state.busy
                            ? null
                            : () => unawaited(
                                controller.socialRequested(
                                  SocialProvider.values.byName(brand.name),
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.all(AuthEntryTokens.pageInset),
            child: LinkText(
              enabled: !state.busy,
              elementId: 'auth.entry.legal',
              segments: [
                LinkTextSegment(strings.authLegalStart),
                LinkTextSegment(
                  strings.authTerms,
                  onTap: () => unawaited(openLink(ExternalLink.terms)),
                ),
                LinkTextSegment(strings.authLegalAnd),
                LinkTextSegment(
                  strings.authPrivacy,
                  onTap: () => unawaited(openLink(ExternalLink.privacy)),
                ),
                LinkTextSegment(strings.authLegalEnd),
              ],
            ),
          ),
        ],
      ],
    );
    return ElementIdentity(
      elementId: 'auth.entry.screen',
      runtimeLocator: UiIdentityScope.resolve(context),
      componentId: 'screen.auth-entry',
      structureRef: 'screen.auth-entry',
      fileKey: '7PGTHT5CQzbTsWZQnPIQce',
      variantId: node,
      componentSetId: null,
      rawSetName: '',
      rawVariantName: '',
      variants: const {},
      declared: {'loading': state.busy},
      resolved: const {},
      child: PageScaffold(
        elementId: 'auth.entry.page',
        layout: PageScaffoldLayout.viewport,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: focus.unfocus,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      key: const ValueKey('auth.scroll'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!keyboard)
                            SizedBox(
                              height:
                                  MediaQuery.paddingOf(context).top +
                                  AuthEntryTokens.heroHeight,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  PositionedDirectional(
                                    top: 0,
                                    start: 0,
                                    end: 0,
                                    child: const HeroBanner(
                                      elementId: 'auth.entry.hero',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (keyboard)
                            SizedBox(height: MediaQuery.paddingOf(context).top),
                          Align(
                            alignment: AlignmentDirectional.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: AdaptiveTokens.contentMaxWidth,
                              ),
                              child: keyboard
                                  ? top()
                                  : AuthEntryBodyFrame(
                                      elementId: 'auth.entry.body',
                                      child: top(),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (keyboard)
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(
                          AuthEntryTokens.keyboardGap,
                        ),
                        child: ButtonHitRegion(
                          child: Align(
                            alignment: AlignmentDirectional.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: AdaptiveTokens.contentMaxWidth,
                              ),
                              child: button(),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (localToast != null)
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: AppToast(
                    key: ValueKey(toastKey),
                    elementId: 'auth.entry.toast',
                    message: message(strings, localToast!),
                    onDismiss: () {
                      if (mounted) setState(() => localToast = null);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String message(AppLocalizations strings, AuthMessage value) => switch (value) {
  AuthMessage.offline => strings.authOffline,
  AuthMessage.server => strings.authServer,
  AuthMessage.notConfigured => strings.authNotConfigured,
  AuthMessage.socialUnavailable => strings.authSocialUnavailable,
  AuthMessage.blocked => strings.authBlocked,
  AuthMessage.rateLimited => strings.authRateLimited,
  AuthMessage.unknown => strings.authUnknown,
  AuthMessage.urlMissing => strings.authUrlMissing,
  AuthMessage.urlFailed => strings.authUrlFailed,
};
