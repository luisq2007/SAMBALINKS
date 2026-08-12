import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/utils/url_extractor.dart';

void main() {
  group('extractFirstUrl', () {
    test('devuelve la URL cuando el texto es sólo la URL', () {
      expect(
        extractFirstUrl('https://instagram.com/p/ABC123/'),
        'https://instagram.com/p/ABC123/',
      );
    });

    test('extrae la URL embebida en texto — el caso real de Instagram y X', () {
      expect(
        extractFirstUrl('Mira esta publicación https://instagram.com/p/ABC123/'),
        'https://instagram.com/p/ABC123/',
      );
    });

    test('extrae la URL cuando va seguida de más texto', () {
      expect(
        extractFirstUrl('Antes https://ejemplo.com/post después'),
        'https://ejemplo.com/post',
      );
    });

    test('descarta la puntuación final de la frase', () {
      expect(extractFirstUrl('Genial: https://ejemplo.com.'), 'https://ejemplo.com');
      expect(extractFirstUrl('(ver https://ejemplo.com/a)'), 'https://ejemplo.com/a');
      expect(extractFirstUrl('¿viste https://ejemplo.com?'), 'https://ejemplo.com');
    });

    test('conserva los parámetros de consulta', () {
      expect(
        extractFirstUrl('https://youtube.com/watch?v=abc&t=30'),
        'https://youtube.com/watch?v=abc&t=30',
      );
    });

    test('acepta http además de https', () {
      expect(extractFirstUrl('http://ejemplo.com'), 'http://ejemplo.com');
    });

    test('devuelve la primera cuando hay varias URLs', () {
      expect(
        extractFirstUrl('https://uno.com y también https://dos.com'),
        'https://uno.com',
      );
    });

    test('sobrevive a emoji y saltos de línea', () {
      expect(
        extractFirstUrl('🔥 imperdible\nhttps://tiktok.com/@user/video/123\n'),
        'https://tiktok.com/@user/video/123',
      );
    });

    test('devuelve null cuando no hay URL', () {
      expect(extractFirstUrl('un texto cualquiera sin enlaces'), isNull);
      expect(extractFirstUrl(''), isNull);
    });

    test('ignora dominios sin esquema — la Fase 4 decidirá qué hacer con ellos', () {
      expect(extractFirstUrl('visita ejemplo.com'), isNull);
    });
  });
}
