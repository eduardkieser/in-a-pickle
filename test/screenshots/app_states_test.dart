import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/community/community_screens.dart';
import 'package:in_a_pickle/src/community/community_state.dart';
import 'package:in_a_pickle/src/domain/community.dart';
import 'package:in_a_pickle/src/domain/profile.dart';
import 'package:in_a_pickle/src/home/home_screen.dart';
import 'package:in_a_pickle/src/onboarding/onboarding_flow_screen.dart';
import 'package:in_a_pickle/src/state.dart';
import 'package:in_a_pickle/src/storage.dart';
import 'package:in_a_pickle/src/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const captureScreenshots = bool.fromEnvironment('CAPTURE_SCREENSHOTS');
  const screenshotFontDirectory =
      String.fromEnvironment('SCREENSHOT_FONT_DIRECTORY');

  setUpAll(() async {
    if (!captureScreenshots) return;
    final loader = FontLoader('ScreenshotRoboto');
    for (final name in [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf'
    ]) {
      final bytes = await File('$screenshotFontDirectory/$name').readAsBytes();
      loader.addFont(
        Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)),
      );
    }
    await loader.load();
    final iconBytes = await File(
      '$screenshotFontDirectory/MaterialIcons-Regular.otf',
    ).readAsBytes();
    await (FontLoader('MaterialIcons')
          ..addFont(
            Future.value(
              ByteData.view(Uint8List.fromList(iconBytes).buffer),
            ),
          ))
        .load();
  });

  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Widget host(
    Widget screen, {
    CommunitySnapshot? community,
    Profile? profile,
  }) =>
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(InMemoryStore()),
          profileProvider.overrideWith(
            () => ProfileController(seed: profile),
          ),
          offerProvider.overrideWith(OfferController.new),
          outboxProvider.overrideWith(OutboxController.new),
          if (community != null)
            communityProvider.overrideWith(
              () => CommunityController(seed: community),
            ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildTheme(fontFamily: 'ScreenshotRoboto'),
          home: screen,
        ),
      );

  Future<void> capture(
    WidgetTester tester,
    String filename,
    Widget screen, {
    CommunitySnapshot? community,
    Profile? profile,
  }) async {
    await tester.pumpWidget(
      host(screen, community: community, profile: profile),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../tmp/screenshots/latest/$filename'),
    );
  }

  testWidgets('01 trust gate', (tester) async {
    await capture(
      tester,
      '01-trusted-circle.png',
      const OnboardingFlowScreen(preview: true),
    );
  }, skip: !captureScreenshots);

  testWidgets('02 address pin', (tester) async {
    await capture(
      tester,
      '02-address-pin.png',
      const OnboardingFlowScreen(initialStep: 1, preview: true),
    );
  }, skip: !captureScreenshots);

  testWidgets('03 verified home', (tester) async {
    await capture(
      tester,
      '03-home-verified.png',
      const OnboardingFlowScreen(
        initialStep: 2,
        preview: true,
        initialVerificationStatus: AddressVerificationStatus.verifiedAtHome,
      ),
    );
  }, skip: !captureScreenshots);

  testWidgets('04 helper incoming call', (tester) async {
    await capture(
      tester,
      '04-helper-incoming.png',
      const NearbyPicklesScreen(helperId: 'marius'),
      community: CommunitySnapshot.demo(),
    );
  }, skip: !captureScreenshots);

  testWidgets('05 helper waiting for approval', (tester) async {
    await capture(
      tester,
      '05-helper-waiting.png',
      const ResponderJourneyScreen(
        pickleId: 'pickle-clinic',
        helperId: 'marius',
      ),
      community: CommunitySnapshot.demo(
        status: CommunityPickleStatus.awaitingApproval,
      ),
    );
  }, skip: !captureScreenshots);

  testWidgets('06 requester approval', (tester) async {
    await capture(
      tester,
      '06-requester-approval.png',
      const RequesterStatusScreen(pickleId: 'pickle-clinic'),
      community: CommunitySnapshot.demo(
        status: CommunityPickleStatus.awaitingApproval,
      ),
    );
  }, skip: !captureScreenshots);

  testWidgets('07 helper route', (tester) async {
    await capture(
      tester,
      '07-helper-route.png',
      const ResponderJourneyScreen(
        pickleId: 'pickle-clinic',
        helperId: 'marius',
      ),
      community: CommunitySnapshot.demo(status: CommunityPickleStatus.active),
    );
  }, skip: !captureScreenshots);

  testWidgets('08 matched chat', (tester) async {
    await capture(
      tester,
      '08-matched-chat.png',
      const MatchChatScreen(
        pickleId: 'pickle-clinic',
        viewerId: 'marius',
      ),
      community: CommunitySnapshot.demo(status: CommunityPickleStatus.active),
    );
  }, skip: !captureScreenshots);

  testWidgets('09 requester tracking', (tester) async {
    await capture(
      tester,
      '09-requester-tracking.png',
      const RequesterStatusScreen(pickleId: 'pickle-clinic'),
      community: CommunitySnapshot.demo(status: CommunityPickleStatus.active),
    );
  }, skip: !captureScreenshots);

  testWidgets('10 cleared helper', (tester) async {
    await capture(
      tester,
      '10-call-cleared.png',
      const NearbyPicklesScreen(helperId: 'fatima'),
      community: CommunitySnapshot.demo(
        status: CommunityPickleStatus.awaitingApproval,
      ),
    );
  }, skip: !captureScreenshots);

  testWidgets('11 captain fallback', (tester) async {
    await capture(
      tester,
      '11-captain-fallback.png',
      const OnboardingFlowScreen(
        initialStep: 2,
        preview: true,
        initialVerificationStatus: AddressVerificationStatus.captainPending,
      ),
    );
  }, skip: !captureScreenshots);

  testWidgets('12 capability questions', (tester) async {
    await capture(
      tester,
      '12-capabilities.png',
      const OnboardingFlowScreen(initialStep: 3, preview: true),
    );
  }, skip: !captureScreenshots);

  testWidgets('13 verified home screen', (tester) async {
    await capture(
      tester,
      '13-home.png',
      const HomeScreen(),
      profile: Profile(
        name: 'Sue',
        address: '10 Jane Road, Pringle Bay',
        homeLocation: const GeoPoint(-34.3477, 18.8281),
        capabilityIds: const {'driving', 'dogs', 'errands'},
        verificationStatus: AddressVerificationStatus.verifiedAtHome,
        onboardingComplete: true,
      ),
    );
  }, skip: !captureScreenshots);
}
