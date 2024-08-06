import Flutter
import UIKit
import CoreLocation

public class SwiftBackgroundLocationPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    static var locationManager: CLLocationManager?
    static var channel: FlutterMethodChannel?
    var running = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftBackgroundLocationPlugin()
        
        SwiftBackgroundLocationPlugin.channel = FlutterMethodChannel(name: "com.almoullim.background_location/methods", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: SwiftBackgroundLocationPlugin.channel!)
        SwiftBackgroundLocationPlugin.channel?.setMethodCallHandler(instance.handle)
        instance.running = false
    }

    private func initLocationManager() {
        if (SwiftBackgroundLocationPlugin.locationManager == nil) {
            SwiftBackgroundLocationPlugin.locationManager = CLLocationManager()
            SwiftBackgroundLocationPlugin.locationManager?.delegate = self
            SwiftBackgroundLocationPlugin.locationManager?.requestAlwaysAuthorization()
            SwiftBackgroundLocationPlugin.locationManager?.startMonitoringSignificantLocationChanges()

            SwiftBackgroundLocationPlugin.locationManager?.allowsBackgroundLocationUpdates = true
            if #available(iOS 11.0, *) {
                SwiftBackgroundLocationPlugin.locationManager?.showsBackgroundLocationIndicator = false;
            }
            SwiftBackgroundLocationPlugin.locationManager?.pausesLocationUpdatesAutomatically = false
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        SwiftBackgroundLocationPlugin.channel?.invokeMethod("location", arguments: "method")

        if (call.method == "start_location_service") {
            initLocationManager()
            SwiftBackgroundLocationPlugin.channel?.invokeMethod("location", arguments: "start_location_service")      
            
            let args = call.arguments as? Dictionary<String, Any>
            
            SwiftBackgroundLocationPlugin.locationManager?.distanceFilter = kCLDistanceFilterNone
        
            // SwiftBackgroundLocationPlugin.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            SwiftBackgroundLocationPlugin.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            // SwiftBackgroundLocationPlugin.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
            // SwiftBackgroundLocationPlugin.locationManager?.desiredAccuracy = kCLLocationAccuracyReduced
            }

            SwiftBackgroundLocationPlugin.locationManager?.startUpdatingLocation()
            running = true
            result(true)
        } else if (call.method == "is_service_running") {
            result(running)
        } else if (call.method == "stop_location_service") {
            initLocationManager()
            running = false
            SwiftBackgroundLocationPlugin.channel?.invokeMethod("location", arguments: "stop_location_service")
            SwiftBackgroundLocationPlugin.locationManager?.stopUpdatingLocation()
            result(true)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
           
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = [
            "speed": locations.last!.speed,
            "altitude": locations.last!.altitude,
            "latitude": locations.last!.coordinate.latitude,
            "longitude": locations.last!.coordinate.longitude,
            "accuracy": locations.last!.horizontalAccuracy,
            "bearing": locations.last!.course,
            "time": locations.last!.timestamp.timeIntervalSince1970 * 1000,
            "is_mock": false
        ] as [String : Any]
        SwiftBackgroundLocationPlugin.channel?.invokeMethod("location", arguments: location)    
    }
}
