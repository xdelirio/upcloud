import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/ui.dart';

import 'helpers.dart';

void main() {
  test('detects SVG URLs', () {
    expect(
      ProviderAvatar.isSvgUrl(Uri.parse('https://x.test/logo.SVG?v=2')),
      isTrue,
    );
    expect(
      ProviderAvatar.isSvgUrl(Uri.parse('data:image/svg+xml;base64,AAAA')),
      isTrue,
    );
    expect(
      ProviderAvatar.isSvgUrl(Uri.parse('https://x.test/favicon.ico')),
      isFalse,
    );
  });

  testWidgets('SVG logos fall back to the initial until they load', (
    tester,
  ) async {
    await pumpApp(
      tester,
      ProviderAvatar(
        info: ProviderInfo(
          id: 'x',
          name: 'Example',
          iconUrl: Uri.parse('https://x.test/logo.svg'),
        ),
      ),
    );
    // While loading (and when the URL is not a valid SVG, as in tests
    // where HTTP fails) the initial is shown instead of an error.
    await tester.pumpAndSettle();
    expect(find.text('E'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders raster icons with Image', (tester) async {
    await pumpApp(
      tester,
      ProviderAvatar(
        info: ProviderInfo(
          id: 'x',
          name: 'Example',
          iconUrl: Uri.parse('https://x.test/favicon.png'),
        ),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('retries an SVG download that failed', (tester) async {
    final previous = ProviderAvatar.svgLoader;
    addTearDown(() => ProviderAvatar.svgLoader = previous);
    var downloads = 0;
    ProviderAvatar.svgLoader = (_) async {
      downloads++;
      return null;
    };
    final avatar = ProviderAvatar(
      info: ProviderInfo(
        id: 'x',
        name: 'Example',
        iconUrl: Uri.parse('https://x.test/retried.svg'),
      ),
    );

    await pumpApp(tester, avatar);
    await tester.pumpAndSettle();
    await pumpApp(tester, const SizedBox());
    await pumpApp(tester, avatar);
    await tester.pumpAndSettle();

    expect(downloads, 2);
    expect(find.text('E'), findsOneWidget);
  });
}
