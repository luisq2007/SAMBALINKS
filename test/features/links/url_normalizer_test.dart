import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/features/links/domain/enums.dart';
import 'package:sambalinks/features/links/domain/url_normalizer.dart';

void main() {
  String? canonical(String input) => UrlNormalizer.normalize(input)?.canonical;

  /// Comprueba que dos entradas distintas producen la misma canónica, que es
  /// la propiedad de la que depende toda la detección de duplicados.
  void expectSame(String a, String b, {required String expected}) {
    expect(canonical(a), expected, reason: 'entrada A: $a');
    expect(canonical(b), expected, reason: 'entrada B: $b');
  }

  group('Pipeline general', () {
    test('añade el esquema cuando falta', () {
      expect(canonical('ejemplo.com/post'), 'https://ejemplo.com/post');
    });

    test('pasa esquema y anfitrión a minúsculas', () {
      expect(
        canonical('HTTPS://Ejemplo.COM/Post'),
        // La ruta conserva las mayúsculas: en muchos sitios es significativa.
        'https://ejemplo.com/Post',
      );
    });

    test('quita www., m. y mobile.', () {
      expect(canonical('https://www.ejemplo.com/a'), 'https://ejemplo.com/a');
      expect(canonical('https://m.ejemplo.com/a'), 'https://ejemplo.com/a');
      expect(canonical('https://mobile.ejemplo.com/a'), 'https://ejemplo.com/a');
    });

    test('quita el fragmento', () {
      expect(
        canonical('https://ejemplo.com/a#seccion'),
        'https://ejemplo.com/a',
      );
    });

    test('quita la barra final salvo en la raíz', () {
      expect(canonical('https://ejemplo.com/a/'), 'https://ejemplo.com/a');
      expect(canonical('https://ejemplo.com/'), 'https://ejemplo.com/');
    });

    test('quita el puerto por defecto pero conserva los demás', () {
      expect(canonical('https://ejemplo.com:443/a'), 'https://ejemplo.com/a');
      expect(canonical('http://ejemplo.com:80/a'), 'http://ejemplo.com/a');
      expect(
        canonical('https://ejemplo.com:8443/a'),
        'https://ejemplo.com:8443/a',
      );
    });

    test('conserva http sin convertirlo a https', () {
      // Convertirlo sería suponer que el sitio soporta TLS.
      expect(canonical('http://ejemplo.com/a'), 'http://ejemplo.com/a');
    });
  });

  group('Parámetros de seguimiento', () {
    test('quita los utm_*', () {
      expectSame(
        'https://blog.dev/post?utm_source=twitter&utm_medium=social',
        'https://blog.dev/post',
        expected: 'https://blog.dev/post',
      );
    });

    test('quita fbclid, gclid, igshid y si', () {
      for (final String param in <String>['fbclid', 'gclid', 'igshid', 'si']) {
        expect(
          canonical('https://blog.dev/post?$param=xyz'),
          'https://blog.dev/post',
          reason: param,
        );
      }
    });

    test('conserva los parámetros significativos de la web genérica', () {
      // `?page=2` es otro contenido, no el mismo con ruido.
      expect(
        canonical('https://blog.dev/archivo?page=2'),
        'https://blog.dev/archivo?page=2',
      );
    });

    test('ordena los parámetros para que el orden no genere duplicados', () {
      expectSame(
        'https://blog.dev/p?b=2&a=1',
        'https://blog.dev/p?a=1&b=2',
        expected: 'https://blog.dev/p?a=1&b=2',
      );
    });

    test('mezcla de seguimiento y significativos: sólo sobrevive el útil', () {
      expect(
        canonical('https://blog.dev/p?utm_source=x&page=3&fbclid=abc'),
        'https://blog.dev/p?page=3',
      );
    });
  });

  group('YouTube', () {
    const String expected = 'https://youtube.com/watch?v=dQw4w9WgXcQ';

    test('youtu.be y /watch son el mismo vídeo', () {
      expectSame(
        'https://youtu.be/dQw4w9WgXcQ',
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        expected: expected,
      );
    });

    test('/shorts y /embed también', () {
      expect(canonical('https://youtube.com/shorts/dQw4w9WgXcQ'), expected);
      expect(canonical('https://youtube.com/embed/dQw4w9WgXcQ'), expected);
    });

    test('m.youtube.com también', () {
      expect(
        canonical('https://m.youtube.com/watch?v=dQw4w9WgXcQ'),
        expected,
      );
    });

    test('el parámetro si del botón compartir no genera un duplicado', () {
      expect(canonical('https://youtu.be/dQw4w9WgXcQ?si=AbCdEf'), expected);
    });

    test('la marca de tiempo no hace que sea otro vídeo', () {
      expect(
        canonical('https://youtube.com/watch?v=dQw4w9WgXcQ&t=42'),
        expected,
      );
    });

    test('una URL de canal se deja como está', () {
      expect(
        canonical('https://youtube.com/@algúncanal'),
        startsWith('https://youtube.com/'),
      );
    });
  });

  group('X / Twitter', () {
    const String expected = 'https://x.com/usuario/status/1234567890';

    test('twitter.com y x.com son el mismo tuit', () {
      expectSame(
        'https://twitter.com/usuario/status/1234567890',
        'https://x.com/usuario/status/1234567890',
        expected: expected,
      );
    });

    test('mobile.twitter.com también', () {
      expect(
        canonical('https://mobile.twitter.com/usuario/status/1234567890'),
        expected,
      );
    });

    test('el sufijo /photo/1 apunta al mismo tuit', () {
      expect(
        canonical('https://x.com/usuario/status/1234567890/photo/1'),
        expected,
      );
    });

    test('el sufijo /video/1 también', () {
      expect(
        canonical('https://x.com/usuario/status/1234567890/video/1'),
        expected,
      );
    });

    test('los parámetros de X se descartan por completo', () {
      expect(
        canonical('https://x.com/usuario/status/1234567890?s=20&t=abc'),
        expected,
      );
    });
  });

  group('Instagram', () {
    const String expected = 'https://instagram.com/p/ABC123';

    test('con y sin usuario en la ruta son la misma publicación', () {
      expectSame(
        'https://instagram.com/algunusuario/p/ABC123/',
        'https://instagram.com/p/ABC123/',
        expected: expected,
      );
    });

    test('igshid no genera un duplicado', () {
      expect(
        canonical('https://www.instagram.com/p/ABC123/?igshid=MzRlODBiNWFlZA'),
        expected,
      );
    });

    test('reel y reels se unifican', () {
      expectSame(
        'https://instagram.com/usuario/reels/XYZ789/',
        'https://instagram.com/reel/XYZ789',
        expected: 'https://instagram.com/reel/XYZ789',
      );
    });

    test('un perfil se deja como está', () {
      expect(
        canonical('https://instagram.com/algunusuario/'),
        'https://instagram.com/algunusuario',
      );
    });
  });

  group('Reddit', () {
    const String expected = 'https://reddit.com/r/flutterdev/comments/abc123';

    test('el slug del título no identifica el hilo', () {
      expectSame(
        'https://reddit.com/r/flutterdev/comments/abc123/un_titulo_cualquiera/',
        'https://reddit.com/r/flutterdev/comments/abc123',
        expected: expected,
      );
    });

    test('old.reddit.com y www.reddit.com son lo mismo', () {
      expect(
        canonical('https://old.reddit.com/r/flutterdev/comments/abc123/x/'),
        expected,
      );
      expect(
        canonical('https://www.reddit.com/r/flutterdev/comments/abc123/x/'),
        expected,
      );
    });

    test('la portada de un subreddit se deja como está', () {
      expect(
        canonical('https://reddit.com/r/flutterdev/'),
        'https://reddit.com/r/flutterdev',
      );
    });
  });

  group('Facebook', () {
    test('web.facebook.com se unifica y fbclid desaparece', () {
      expectSame(
        'https://web.facebook.com/algo/posts/123?fbclid=abc',
        'https://www.facebook.com/algo/posts/123',
        expected: 'https://facebook.com/algo/posts/123',
      );
    });
  });

  group('Enlaces acortados', () {
    test('se marcan para resolver por red', () {
      for (final String url in <String>[
        'https://vm.tiktok.com/ZMabcdef/',
        'https://pin.it/abc123',
        'https://t.co/abcdef',
        'https://lnkd.in/abc',
        'https://bit.ly/xyz',
      ]) {
        final NormalizedUrl? result = UrlNormalizer.normalize(url);
        expect(result!.needsNetworkResolution, isTrue, reason: url);
      }
    });

    test('una URL normal no se marca', () {
      expect(
        UrlNormalizer.normalize(
          'https://instagram.com/p/ABC',
        )!.needsNetworkResolution,
        isFalse,
      );
    });

    test('youtu.be NO necesita red: se resuelve aquí mismo', () {
      final NormalizedUrl result = UrlNormalizer.normalize(
        'https://youtu.be/abc123',
      )!;
      expect(result.needsNetworkResolution, isFalse);
      expect(result.canonical, 'https://youtube.com/watch?v=abc123');
    });
  });

  group('Detección de plataforma', () {
    void expectPlatform(String url, LinkPlatform platform) {
      expect(
        UrlNormalizer.normalize(url)!.platform,
        platform,
        reason: url,
      );
    }

    test('reconoce las plataformas del PRD', () {
      expectPlatform('https://instagram.com/p/A', LinkPlatform.instagram);
      expectPlatform('https://twitter.com/u/status/1', LinkPlatform.x);
      expectPlatform('https://x.com/u/status/1', LinkPlatform.x);
      expectPlatform('https://threads.net/@u/post/1', LinkPlatform.threads);
      expectPlatform('https://pinterest.com/pin/1', LinkPlatform.pinterest);
      expectPlatform('https://facebook.com/u/posts/1', LinkPlatform.facebook);
      expectPlatform('https://tiktok.com/@u/video/1', LinkPlatform.tiktok);
      expectPlatform('https://youtube.com/watch?v=a', LinkPlatform.youtube);
      expectPlatform('https://linkedin.com/posts/a', LinkPlatform.linkedin);
      expectPlatform('https://reddit.com/r/a', LinkPlatform.reddit);
    });

    test('un dominio cualquiera es web', () {
      expectPlatform('https://midiario.es/noticia', LinkPlatform.web);
      expectPlatform('https://blog.personal.dev/post', LinkPlatform.web);
    });

    test('los subdominios cuentan como su plataforma', () {
      expectPlatform('https://es.linkedin.com/posts/a', LinkPlatform.linkedin);
      expectPlatform('https://old.reddit.com/r/a', LinkPlatform.reddit);
    });

    test('los dominios por país también', () {
      expectPlatform('https://pinterest.es/pin/1', LinkPlatform.pinterest);
      expectPlatform('https://facebook.com.mx/u', LinkPlatform.facebook);
    });
  });

  group('Entradas inválidas', () {
    test('devuelven null sin lanzar', () {
      for (final String input in <String>[
        '',
        '   ',
        'no soy una url',
        'ftp://ejemplo.com/a',
        'javascript:alert(1)',
        'https://',
        'localhost',
      ]) {
        expect(
          UrlNormalizer.normalize(input),
          isNull,
          reason: 'entrada: "$input"',
        );
      }
    });

    test('una URL con caracteres raros no revienta', () {
      expect(
        () => UrlNormalizer.normalize('https://ejemplo.com/a b c<>|'),
        returnsNormally,
      );
    });
  });

  group('Dominio expuesto', () {
    test('es el anfitrión ya normalizado', () {
      expect(
        UrlNormalizer.normalize('https://www.instagram.com/p/A')!.domain,
        'instagram.com',
      );
      expect(
        UrlNormalizer.normalize('https://twitter.com/u/status/1')!.domain,
        'x.com',
      );
      expect(
        UrlNormalizer.normalize('https://youtu.be/abc')!.domain,
        'youtube.com',
      );
    });
  });
}
