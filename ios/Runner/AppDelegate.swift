import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // SECURE_CONFIG: Maps API Key should be managed via environment or secure CI/CD secrets.
    let mapsApiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"] ?? "YOUR_IOS_MAPS_API_KEY_HERE"
    GMSServices.provideAPIKey(mapsApiKey)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
