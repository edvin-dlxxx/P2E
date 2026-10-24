import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/repositories.dart';
part 'dependencies.g.dart';

@riverpod
WelcomeOfferRepository welcomeOfferRepository(Ref ref) =>
    throw StateError('Auth composition missing');
@riverpod
PhoneSignInRepository phoneSignInRepository(Ref ref) =>
    throw StateError('Auth composition missing');
@riverpod
EmailSignInRepository emailSignInRepository(Ref ref) =>
    throw StateError('Auth composition missing');
@riverpod
SocialSignInRepository socialSignInRepository(Ref ref) =>
    throw StateError('Auth composition missing');
