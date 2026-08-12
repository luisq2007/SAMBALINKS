import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../core/utils/url_extractor.dart';
import '../domain/incoming_share.dart';

/// Puente con la hoja de compartir del sistema.
///
/// El plugin expone dos rutas distintas y ambas son obligatorias:
/// `getInitialMedia()` para cuando el sistema abre la app desde cero, y
/// `getMediaStream()` para cuando ya estaba en segundo plano. Atender sólo una
/// deja la mitad de los casos reales sin funcionar.
class ShareReceiver {
  ShareReceiver({ReceiveSharingIntent? intent})
    : _intent = intent ?? ReceiveSharingIntent.instance;

  final ReceiveSharingIntent _intent;

  /// Contenido con el que se abrió la app, si la abrió un "compartir".
  ///
  /// Llama a `reset()` después de leerlo: sin eso el sistema devuelve el mismo
  /// contenido en el siguiente arranque y se duplica el enlace.
  Future<List<IncomingShare>> initialShares() async {
    final List<SharedMediaFile> media = await _intent.getInitialMedia();
    final List<IncomingShare> shares = _toShares(media, ShareArrival.cold);
    await _intent.reset();
    return shares;
  }

  /// Contenido que llega mientras la app está viva.
  Stream<List<IncomingShare>> shareStream() {
    return _intent.getMediaStream().map(
      (List<SharedMediaFile> media) => _toShares(media, ShareArrival.warm),
    );
  }

  List<IncomingShare> _toShares(
    List<SharedMediaFile> media,
    ShareArrival arrival,
  ) {
    final DateTime now = DateTime.now();

    return media
        .where(
          (SharedMediaFile m) =>
              m.type == SharedMediaType.text || m.type == SharedMediaType.url,
        )
        .map((SharedMediaFile m) {
          // En un compartido de texto el plugin deja el contenido en `path`.
          final String raw = m.path;
          return IncomingShare(
            rawText: raw,
            url: extractFirstUrl(raw),
            arrival: arrival,
            receivedAt: now,
          );
        })
        .toList();
  }
}
