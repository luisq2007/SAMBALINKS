/// Extracción de URLs desde texto libre.
///
/// Instagram, X, Threads y TikTok no comparten una URL sola: comparten un
/// texto con la URL embebida ("Mira esta publicación https://…"). Sin esto,
/// el flujo principal del producto no funciona con las plataformas que más
/// importan.
///
/// La normalización y canonicalización viven en la Fase 4; aquí sólo se
/// localiza la URL dentro del texto.
library;

final RegExp _urlPattern = RegExp(
  r'https?://[^\s<>"'
  r"'"
  r']+',
  caseSensitive: false,
);

/// Puntuación que suele quedar pegada al final de una URL dentro de una frase.
const String _trailingJunk = '.,;:!?)]}\'"»';

/// Devuelve la primera URL http/https del texto, o `null` si no hay ninguna.
String? extractFirstUrl(String text) {
  final RegExpMatch? match = _urlPattern.firstMatch(text);
  if (match == null) {
    return null;
  }

  String url = match.group(0)!;
  while (url.isNotEmpty && _trailingJunk.contains(url[url.length - 1])) {
    url = url.substring(0, url.length - 1);
  }

  return url.isEmpty ? null : url;
}
