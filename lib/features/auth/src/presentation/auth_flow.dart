import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/identifier.dart';
import '../domain/models.dart';
part 'auth_flow.g.dart';

enum AuthStep { otp, password, createPassword }

sealed class AuthFlowResult {
  const AuthFlowResult(this.rememberDevice);
  final bool rememberDevice;
  AuthStep get step;
}

final class PhoneFlowResult extends AuthFlowResult {
  const PhoneFlowResult(this.challenge, super.rememberDevice);
  final OtpChallenge challenge;
  @override
  AuthStep get step => AuthStep.otp;
}

final class EmailFlowResult extends AuthFlowResult {
  const EmailFlowResult(this.email, this.accountStatus, super.rememberDevice);
  final Email email;
  final EmailAccountStatus accountStatus;
  @override
  AuthStep get step => accountStatus == EmailAccountStatus.registered
      ? AuthStep.password
      : AuthStep.createPassword;
}

/// Auto-dispose: only auth controller/routes listen; no global keepAlive or extra.
@riverpod
class AuthFlow extends _$AuthFlow {
  @override
  AuthFlowResult? build() => null;
  void accept(AuthFlowResult result) => state = result;
}
