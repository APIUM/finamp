import CarPlay
import Flutter

@available(iOS 12.0, *)
@objc(CarPlaySceneDelegate)
class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {

    var interfaceController: CPInterfaceController?

    override init() {
        super.init()
        NSLog("CarPlay: CarPlaySceneDelegate initialized")
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didConnect interfaceController: CPInterfaceController) {
        NSLog("CarPlay: Scene delegate didConnect called")
        self.interfaceController = interfaceController

        // Create root template
        let rootTemplate = createRootTemplate()
        NSLog("CarPlay: Setting root template with \(rootTemplate.templates.count) tabs")
        interfaceController.setRootTemplate(rootTemplate, animated: true, completion: { success, error in
            if let error = error {
                NSLog("CarPlay: Error setting root template: \(error)")
            } else {
                NSLog("CarPlay: Root template set successfully")
            }
        })

        // Notify Flutter about CarPlay connection
        notifyFlutter(event: "carplay_connected")
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        NSLog("CarPlay: Scene delegate didDisconnect called")
        self.interfaceController = nil

        // Notify Flutter about CarPlay disconnection
        notifyFlutter(event: "carplay_disconnected")
    }
    
    private func createRootTemplate() -> CPTabBarTemplate {
        // Browse tab
        let browseTemplate = CPListTemplate(title: "Browse", sections: [])
        browseTemplate.tabImage = UIImage(systemName: "music.note.list")
        
        // Now Playing tab
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        nowPlayingTemplate.tabImage = UIImage(systemName: "play.circle")
        
        // Search tab
        let searchTemplate = CPListTemplate(title: "Search", sections: [])
        searchTemplate.tabImage = UIImage(systemName: "magnifyingglass")
        
        return CPTabBarTemplate(templates: [browseTemplate, nowPlayingTemplate, searchTemplate])
    }
    
    private func notifyFlutter(event: String) {
        guard let flutterViewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController else {
            return
        }
        
        let channel = FlutterMethodChannel(name: "finamp/carplay", binaryMessenger: flutterViewController.binaryMessenger)
        channel.invokeMethod(event, arguments: nil)
    }
}
