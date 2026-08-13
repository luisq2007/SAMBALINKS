import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/network/http_client.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/metadata/data/direct_metadata_provider.dart';
import 'package:sambalinks/features/metadata/data/html_meta_strategy.dart';
import 'package:sambalinks/features/metadata/data/oembed_strategy.dart';
import 'package:sambalinks/features/metadata/domain/metadata_provider.dart';

import 'metadata_test_helpers.dart';

String _fixture(String name) =>
    File('test/fixtures/metadata/$name').readAsStringSync();

DirectMetadataProvider _provider(
  SafeHttpClient client, {
  OEmbedEndpointResolver? oEmbedEndpoint,
  UrlResolver? resolveUrl,
}) {
  return DirectMetadataProvider(
    oEmbed: OEmbedStrategy(
      client,
      endpointResolver: oEmbedEndpoint ?? (_) => null,
    ),
    html: HtmlMetaStrategy(client),
    httpClient: client,
    resolveUrl: resolveUrl,
  );
}

void main() {
  group('HtmlMetaStrategy', () {
    test('prioriza Open Graph y resuelve URLs relativas', () async {
      final FixtureAdapter adapter = FixtureAdapter(
        (_) => FixtureResponse.text(_fixture('og_full.html')),
      );
      final SafeHttpClient client = SafeHttpClient(fixtureDio(adapter));

      final MetadataResult? result = await HtmlMetaStrategy(
        client,
      ).fetch(Uri.parse('https://example.com/articles/1'));

      expect(result, isNotNull);
      expect(result!.title, 'Título Open Graph');
      expect(result.description, 'Descripción Open Graph');
      expect(result.imageUrl, 'https://example.com/preview.jpg');
      expect(result.faviconUrl, 'https://example.com/favicon.png');
      expect(result.siteName, 'Sitio de pruebas');
      expect(result.status, MetadataStatus.ok);
    });

    test('usa Twitter Cards cuando no hay Open Graph', () async {
      final FixtureAdapter adapter = FixtureAdapter(
        (_) => FixtureResponse.text(_fixture('twitter_only.html')),
      );
      final SafeHttpClient client = SafeHttpClient(fixtureDio(adapter));

      final MetadataResult? result = await HtmlMetaStrategy(
        client,
      ).fetch(Uri.parse('https://example.com/post'));

      expect(result!.title, 'Título Twitter');
      expect(result.description, 'Descripción Twitter');
      expect(result.imageUrl, 'https://cdn.example/twitter.webp');
      expect(result.status, MetadataStatus.ok);
    });

    test('cae a title y normaliza sus espacios', () async {
      final FixtureAdapter adapter = FixtureAdapter(
        (_) => FixtureResponse.text(_fixture('title_only.html')),
      );
      final SafeHttpClient client = SafeHttpClient(fixtureDio(adapter));

      final MetadataResult? result = await HtmlMetaStrategy(
        client,
      ).fetch(Uri.parse('https://example.com/simple'));

      expect(result!.title, 'Un título con espacios');
      expect(result.description, isNull);
      expect(result.imageUrl, isNull);
      expect(result.status, MetadataStatus.partial);
    });

    test('recupera metadata de HTML malformado', () async {
      final FixtureAdapter adapter = FixtureAdapter(
        (_) => FixtureResponse.text(_fixture('malformed.html')),
      );
      final SafeHttpClient client = SafeHttpClient(fixtureDio(adapter));

      final MetadataResult? result = await HtmlMetaStrategy(
        client,
      ).fetch(Uri.parse('https://example.com/broken'));

      expect(result, isNotNull);
      expect(result!.title, 'Título recuperado');
    });

    test('descarta el muro de login de Instagram', () async {
      final FixtureAdapter adapter = FixtureAdapter(
        (_) => FixtureResponse.text(_fixture('instagram_login_wall.html')),
      );
      final SafeHttpClient client = SafeHttpClient(fixtureDio(adapter));

      final MetadataResult? result = await HtmlMetaStrategy(
        client,
      ).fetch(Uri.parse('https://instagram.com/p/ABC'));

      expect(result, isNull);
    });
  });

  group('DirectMetadataProvider', () {
    test(
      'oEmbed gana y evita pedir el HTML cuando devuelve contenido',
      () async {
        final FixtureAdapter adapter = FixtureAdapter((RequestOptions request) {
          expect(request.uri.path, '/oembed');
          return FixtureResponse.text(
            '{"title":"Vídeo","description":"Una demo",'
            '"thumbnail_url":"https://cdn.example/video.jpg",'
            '"provider_name":"YouTube"}',
            headers: const <String, List<String>>{
              Headers.contentTypeHeader: <String>['application/json'],
            },
          );
        });
        final SafeHttpClient client = SafeHttpClient(fixtureDio(adapter));
        final DirectMetadataProvider provider = _provider(
          client,
          oEmbedEndpoint: (_) => Uri.parse('https://fixtures.test/oembed'),
        );

        final MetadataResult result = await provider.fetch(
          Uri.parse('https://youtube.com/watch?v=abc'),
        );

        expect(adapter.requests, 1);
        expect(result.title, 'Vídeo');
        expect(result.siteName, 'YouTube');
        expect(result.status, MetadataStatus.ok);
      },
    );

    test('una respuesta 403 termina en fallback parcial', () async {
      final FixtureAdapter adapter = FixtureAdapter(
        (_) => FixtureResponse.text('Prohibido', statusCode: 403),
      );
      final SafeHttpClient client = SafeHttpClient(fixtureDio(adapter));

      final MetadataResult result = await _provider(
        client,
      ).fetch(Uri.parse('https://example.com/private'));

      expect(result.title, 'example.com');
      expect(result.siteName, 'example.com');
      expect(result.status, MetadataStatus.partial);
    });

    test('un muro de Instagram termina en fallback de plataforma', () async {
      final FixtureAdapter adapter = FixtureAdapter(
        (_) => FixtureResponse.text(_fixture('instagram_login_wall.html')),
      );
      final SafeHttpClient client = SafeHttpClient(fixtureDio(adapter));

      final MetadataResult result = await _provider(
        client,
      ).fetch(Uri.parse('https://instagram.com/p/ABC'));

      expect(result.title, 'instagram.com');
      expect(result.siteName, 'Instagram');
      expect(result.status, MetadataStatus.partial);
    });

    test('resuelve short-links antes de ejecutar las estrategias', () async {
      final FixtureAdapter adapter = FixtureAdapter(
        (_) => FixtureResponse.text(_fixture('title_only.html')),
      );
      final SafeHttpClient client = SafeHttpClient(fixtureDio(adapter));
      bool resolved = false;
      final DirectMetadataProvider provider = _provider(
        client,
        resolveUrl: (Uri _) async {
          resolved = true;
          return Uri.parse('https://example.com/destination');
        },
      );

      final MetadataResult result = await provider.fetch(
        Uri.parse('https://t.co/short'),
      );

      expect(resolved, isTrue);
      expect(
        adapter.seen.single.uri,
        Uri.parse('https://example.com/destination'),
      );
      expect(result.resolvedUrl, Uri.parse('https://example.com/destination'));
    });

    test('un esquema no soportado no toca la red', () async {
      final FixtureAdapter adapter = FixtureAdapter(
        (_) => throw StateError('No debe pedir la red'),
      );
      final SafeHttpClient client = SafeHttpClient(fixtureDio(adapter));

      final MetadataResult result = await _provider(
        client,
      ).fetch(Uri.parse('mailto:persona@example.com'));

      expect(result.status, MetadataStatus.unsupported);
      expect(adapter.requests, 0);
    });
  });

  group('SafeHttpClient', () {
    test('corta una respuesta de 5 MB exactamente al superar 512 KB', () async {
      final FixtureAdapter adapter = FixtureAdapter(
        (_) => FixtureResponse(
          body: List<int>.filled(5 * 1024 * 1024, 65),
          chunkSize: 64 * 1024,
        ),
      );
      final SafeHttpClient client = SafeHttpClient(fixtureDio(adapter));

      await expectLater(
        client.get(Uri.parse('https://example.com/huge')),
        throwsA(
          isA<HttpBodyTooLargeException>().having(
            (HttpBodyTooLargeException error) => error.acceptedBytes,
            'bytes aceptados',
            512 * 1024,
          ),
        ),
      );
    });

    test('envía User-Agent y preferencia de idioma configurados', () async {
      final FixtureAdapter adapter = FixtureAdapter(
        (_) => FixtureResponse.text('<title>ok</title>'),
      );
      final Dio dio = createMetadataDio(userAgent: 'Agente de prueba');
      dio.httpClientAdapter = adapter;

      await SafeHttpClient(dio).get(Uri.parse('https://example.com'));

      expect(adapter.seen.single.headers['User-Agent'], 'Agente de prueba');
      expect(adapter.seen.single.headers['Accept-Language'], 'es-ES,es;q=0.9');
      expect(adapter.seen.single.maxRedirects, HttpLimits.redirects);
      expect(adapter.seen.single.connectTimeout, HttpLimits.timeout);
      expect(adapter.seen.single.receiveTimeout, HttpLimits.timeout);
    });

    test('sigue un redirect 301 y expone la URL final', () async {
      final HttpServer server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      addTearDown(() => server.close(force: true));
      server.listen((HttpRequest request) async {
        if (request.uri.path == '/inicio') {
          request.response.statusCode = HttpStatus.movedPermanently;
          request.response.headers.set(HttpHeaders.locationHeader, '/final');
        } else {
          request.response.headers.contentType = ContentType.html;
          request.response.write('<title>Destino</title>');
        }
        await request.response.close();
      });
      final Uri start = Uri.parse('http://127.0.0.1:${server.port}/inicio');

      final SafeHttpResponse response = await SafeHttpClient(
        createMetadataDio(),
      ).get(start);

      expect(response.statusCode, 200);
      expect(response.resolvedUri.path, '/final');
      expect(response.decodeText(), contains('Destino'));
    });

    test('acepta cinco redirects y rechaza el sexto', () async {
      final HttpServer server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      addTearDown(() => server.close(force: true));
      server.listen((HttpRequest request) async {
        final int step = int.parse(request.uri.path.substring(1));
        final int finalStep = int.parse(
          request.uri.queryParameters['final'] ?? '5',
        );
        if (step < finalStep) {
          request.response.statusCode = HttpStatus.found;
          request.response.headers.set(
            HttpHeaders.locationHeader,
            '/${step + 1}?final=$finalStep',
          );
        } else {
          request.response.write('final');
        }
        await request.response.close();
      });
      final SafeHttpClient client = SafeHttpClient(createMetadataDio());
      final String origin = 'http://127.0.0.1:${server.port}';

      final SafeHttpResponse accepted = await client.get(
        Uri.parse('$origin/0?final=5'),
      );
      expect(accepted.resolvedUri.path, '/5');
      await expectLater(
        client.get(Uri.parse('$origin/0?final=6')),
        throwsA(isA<DioException>()),
      );
    });
  });
}
