//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationMgr = CLLocationManager()
    
    let beaconIdentifiers = ["534ec0f7719f4a9c284fe7a6a16ab00b"]
    let beaconIdentifiers2 = ["ad2605e82e2416ed13046a3d7106da35"]
    let beaconIdentifiers3 = ["d515d0113e06c64d7cf49245074bec3f"]
    let beaconIdentifiers4 = ["0584bf7d65b3fce6b29b6f5c8b6fa816"]
    let cloudManager = CloudManager()
    let proximityManager = ProximityManager()
    let proximityManager2 = ProximityManager()
    let proximityManager3 = ProximityManager()
    let proximityManager4 = ProximityManager()
    var zoneViewByBeaconIdentifier = [String: UIView]()
    
    
    @IBOutlet weak var noBeaconsView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var BTManager = BTUtilities()
        self.getLocation()
        
        self.updateBeaconZoneViews(beaconIdentifiersInRange: [])
        
        // Step 1: Pre-fetch content related to your beacons
        self.cloudManager.fetchColors(beaconIdentifiers: self.beaconIdentifiers) { (result) in
            print("Resultado \(result)")
            switch result {
            case .error:
                self.presentFetchingColorsFailedAlert()
                return
                
            case .success(let colorByIdentifier):
                self.addBeaconZoneViews(colorByBeaconIdentifier: colorByIdentifier)
                
                // Step 2: Start monitoring proximity of your beacons
                self.proximityManager.delegate = self
                self.proximityManager.distance = 0.5
                self.proximityManager.startMonitoringProximity(identifiers: self.beaconIdentifiers)
                
                self.proximityManager2.delegate = self
                self.proximityManager2.distance = 0.5
                self.proximityManager2.startMonitoringProximity(identifiers: self.beaconIdentifiers2)
                
                self.proximityManager3.delegate = self
                self.proximityManager3.distance = 0.5
                self.proximityManager3.startMonitoringProximity(identifiers: self.beaconIdentifiers3)
                
                self.proximityManager4.delegate = self
                self.proximityManager4.distance = 0.5
                self.proximityManager4.startMonitoringProximity(identifiers: self.beaconIdentifiers4)
            }
        }
        //let detect = DetectBeacon.shared
        //let beacon = EstimoteExample.shared.getBeaconInfomation()
    }
    
    func getLocation() {
        // 1
        let status  = CLLocationManager.authorizationStatus()
        
        // 2
        if status == .notDetermined {
            locationMgr.requestWhenInUseAuthorization()
            return
        }
        
        // 3
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 4
        locationMgr.delegate = self
        locationMgr.startUpdatingLocation()
    }
    
    // 1
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        print("Current location: \(currentLocation)")
    }
    
    // 2
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
}

extension ViewController: ProximityManagerDelegate {
    
    func proximityManager(_ proximityManager: ProximityManager, didUpdateBeaconsInRange identifiers: Set<String>) {
        // Step 3: Update UI dependant on which beacons are in range
        self.updateBeaconZoneViews(beaconIdentifiersInRange: identifiers)
    }

    func proximityManager(_ proximityManager: ProximityManager, didFailWithError: Error) {
        self.presentMonitoringFailedAlert()
    }
}

