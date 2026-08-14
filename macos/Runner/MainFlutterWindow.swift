import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Tamaño mínimo: por debajo de esto la interfaz de tres columnas deja de
    // tener sentido y la lista se vuelve ilegible.
    self.minSize = NSSize(width: 420, height: 560)

    // macOS recuerda por sí solo la posición y el tamaño de una ventana con
    // nombre de autoguardado. Se hace de forma nativa en lugar de con un
    // paquete: window_manager arrastra screen_retriever_macos, que declara
    // macOS 10.14 y rompe la compilación contra el mínimo 10.15 de Flutter.
    self.setFrameAutosaveName("SambaLinksMainWindow")

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
