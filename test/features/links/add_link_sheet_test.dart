import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart' hide Category;
import 'package:sambalinks/core/l10n/app_localizations.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/core/theme/app_theme.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/link_card.dart';
import 'package:sambalinks/features/links/domain/link_repository.dart';
import 'package:sambalinks/features/links/presentation/add_link_sheet.dart';
import 'package:sambalinks/features/metadata/data/metadata_enrichment_service.dart';
import 'package:sambalinks/features/metadata/domain/metadata_image_store.dart';
import 'package:sambalinks/features/metadata/domain/metadata_refresh_outcome.dart';

import '../../core/database/database_test_helpers.dart';

/// El enriquecimiento se sustituye por un doble: guardar no debe depender de
/// la red, y el test tampoco.
class _RecordingEnrichment implements MetadataEnrichmentService {
  // Sólo se usa refreshCard; el resto de la interfaz no interviene aquí.
  final List<String> refreshed = <String>[];

  @override
  Future<MetadataRefreshOutcome> refreshCard(String cardId) async {
    refreshed.add(cardId);
    return MetadataRefreshCardNotFound(cardId);
  }

  @override
  Future<OrphanImageCleanupResult> cleanupOrphanedImages({
    Duration timeLimit = const Duration(milliseconds: 250),
  }) async => const OrphanImageCleanupResult(
    scanned: 0,
    deleted: 0,
    timedOut: false,
  );
}

int clipboardReads = 0;

void main() {
  late AppDatabase db;
  late _RecordingEnrichment enrichment;

  setUp(() {
    db = openTestDatabase();
    enrichment = _RecordingEnrichment();
  });
  tearDown(() => db.close());

  late ProviderContainer container;

  /// Abre la hoja como modal, que es como se usa de verdad: montarla como
  /// `home` deja al `Navigator.pop` posterior sin ruta que cerrar.
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          metadataEnrichmentServiceProvider.overrideWithValue(enrichment),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () => AddLinkSheet.show(context),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    container = ProviderScope.containerOf(
      tester.element(find.text('abrir')),
      listen: false,
    );
    await tester.tap(find.text('abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.text('Guardar'));
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  setUpAll(() {
    // El portapapeles no existe en el entorno de test. Ya no se lee al abrir
    // la hoja, pero sí al pulsar "Pegar del portapapeles".
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'Clipboard.getData') {
            clipboardReads++;
            return <String, dynamic>{'text': ''};
          }
          return null;
        });
  });

  group('Guardar un enlace a mano', () {
    testWidgets('normaliza la URL antes de guardarla', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await type(tester, 'https://www.instagram.com/usuario/p/ABC123/?igshid=x');
      await tapSave(tester);

      final LinkRepository repository = container.read(linkRepositoryProvider);

      final LinkCard? saved = await repository.findByCanonicalUrl(
        'https://instagram.com/p/ABC123',
      );
      expect(saved, isNotNull);
      expect(saved!.platform, LinkPlatform.instagram);
      expect(saved.domain, 'instagram.com');
      // Capture first: nace en Pendiente y sin categoría, o sea, en la Bandeja.
      expect(saved.status, CardStatus.pending);
    });

    testWidgets('conserva la URL original junto a la canónica', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await type(tester, 'https://youtu.be/dQw4w9WgXcQ?si=abc');
      await tapSave(tester);

      final LinkCard saved = (await container
          .read(linkRepositoryProvider)
          .findByCanonicalUrl('https://youtube.com/watch?v=dQw4w9WgXcQ'))!;

      expect(saved.url, contains('youtu.be'));
    });

    testWidgets('pide la metadata sin bloquear el guardado', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await type(tester, 'https://flutter.dev');
      await tapSave(tester);

      expect(enrichment.refreshed, hasLength(1));
    });

    testWidgets('no lee el portapapeles al abrir la hoja', (
      WidgetTester tester,
    ) async {
      clipboardReads = 0;
      await pump(tester);

      // Android avisa al usuario cada vez que una app lee el portapapeles:
      // hacerlo sin que lo pida contradice el principio de privacidad.
      expect(clipboardReads, 0);

      await tester.tap(find.text('Pegar del portapapeles'));
      await tester.pump();
      expect(clipboardReads, 1);
    });

    testWidgets('rechaza un texto que no es una URL', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await type(tester, 'esto no es un enlace');
      await tapSave(tester);

      expect(find.text('Eso no parece un enlace válido'), findsOneWidget);
      expect(enrichment.refreshed, isEmpty);
    });

    testWidgets('avisa del duplicado en lugar de crear una copia', (
      WidgetTester tester,
    ) async {
      await pump(tester);
      await type(tester, 'https://instagram.com/p/ABC123');
      await tapSave(tester);

      final LinkRepository repository = container.read(linkRepositoryProvider);
      final String? originalId = (await repository.findByCanonicalUrl(
        'https://instagram.com/p/ABC123',
      ))?.id;
      expect(originalId, isNotNull);

      // Segunda vez, con la misma publicación pero otra forma de la URL.
      await pump(tester);
      await type(tester, 'https://www.instagram.com/otro/p/ABC123/?igshid=y');
      await tapSave(tester);

      expect(find.text('Este enlace ya está en SambaLinks'), findsOneWidget);

      // Sigue siendo el mismo registro: no se creó una copia ni se sobrescribió.
      // Se comprueba con un Future y no con `watchCount()`, porque los streams
      // de Drift no resuelven dentro del reloj simulado de testWidgets.
      final LinkCard? stored = await repository.findByCanonicalUrl(
        'https://instagram.com/p/ABC123',
      );
      expect(stored!.id, originalId);
    });
  });
}
