import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart' as domain;
import 'package:sambalinks/shared/widgets/link_card.dart';

domain.LinkCard buildCard({String? imageUrl, String? title}) {
  final DateTime now = DateTime.utc(2026, 8, 13);
  return domain.LinkCard(
    id: 'c1',
    url: 'https://www.instagram.com/usuario/p/ABC123/?igshid=xyz',
    canonicalUrl: 'https://instagram.com/p/ABC123',
    domain: 'instagram.com',
    title: title,
    imageUrl: imageUrl,
    platform: LinkPlatform.instagram,
    status: CardStatus.pending,
    metadataStatus: MetadataStatus.partial,
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> pumpCard(
  WidgetTester tester,
  domain.LinkCard card, {
  LinkCardDensity density = LinkCardDensity.mobile,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      locale: const Locale('es'),
      home: Scaffold(
        body: LinkCard(card: card, density: density),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Tarjeta sin vista previa', () {
    testWidgets('no reserva el bloque de imagen', (WidgetTester tester) async {
      // Instagram, X y Facebook caen al fallback casi siempre. Si la tarjeta
      // dibujara igualmente el bloque 16:7, la biblioteca sería una hilera de
      // rectángulos vacíos.
      await pumpCard(tester, buildCard());

      expect(find.byType(AspectRatio), findsNothing);
    });

    testWidgets('sigue mostrando plataforma, dominio y estado', (
      WidgetTester tester,
    ) async {
      await pumpCard(tester, buildCard());

      expect(find.textContaining('instagram.com'), findsWidgets);
      expect(find.text('Pendiente'), findsOneWidget);
    });

    testWidgets('cae al dominio cuando no hay título', (
      WidgetTester tester,
    ) async {
      await pumpCard(tester, buildCard());

      expect(find.text('instagram.com'), findsWidgets);
    });
  });

  group('Tarjeta con vista previa', () {
    testWidgets('sí reserva el bloque de imagen', (WidgetTester tester) async {
      await pumpCard(
        tester,
        buildCard(
          imageUrl: 'https://ejemplo.com/foto.jpg',
          title: 'Una publicación',
        ),
      );

      expect(find.byType(AspectRatio), findsOneWidget);
      expect(find.text('Una publicación'), findsOneWidget);
    });
  });
}
