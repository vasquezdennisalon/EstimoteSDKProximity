//
//  ProximityManager.swift
//  aupar
//
//  Created by Denis Vásquez on 8/14/18.
//  Copyright © 2018 aritec-la. All rights reserved.
//

import UIKit
import Foundation

protocol ProximityManagerDelegate: class {
    func proximityManager(_ proximityManager: ProximityManager, didUpdateBeaconsInRange identifiers: Set<String>)
    func proximityManager(_ proximityManager: ProximityManager, didFailWithError: Error)
}

extension ProximityManager {
    struct Parameters {
        /// Desired distance from a beacon from which enter/exit events should be triggered, in meters.
        var desiredDistance:Double?
    }
}

/// Monitors proximity of beacons using Estimote Monitoring to inform which beacons are currently in range.
class ProximityManager: NSObject {
    
    weak var delegate: ProximityManagerDelegate?
    var distance:Double?
    fileprivate lazy var monitoringManager: ESTMonitoringV2Manager = ESTMonitoringV2Manager(desiredMeanTriggerDistance: Parameters.init(desiredDistance: distance!).desiredDistance!, delegate: self)
    
    func startMonitoringProximity(identifiers: [String]) {
        print("Distancia \(Parameters.init(desiredDistance: distance!).desiredDistance!)")
        self.monitoringManager.startMonitoring(forIdentifiers: identifiers)
    }
    
    fileprivate func updateBeaconsInRange() {
        let beaconIdentifiersInRange = self.monitoringManager.monitoredIdentifiers.filter { [weak self] (identifier) -> Bool in
            return self?.monitoringManager.stateForBeacon(withIdentifier: identifier) == .insideZone
        }
        
        self.delegate?.proximityManager(self, didUpdateBeaconsInRange: beaconIdentifiersInRange)
    }
    
    fileprivate func name(_ state: ESTMonitoringState) -> String {
        switch state {
        case .unknown: return "Unknown"
        case .insideZone: return "Inside"
        case .outsideZone: return "Outside"
        }
    }
}

extension ProximityManager: ESTMonitoringV2ManagerDelegate {
    
    func monitoringManagerDidStart(_ manager: ESTMonitoringV2Manager) {
        print("Monitoring started successfully.")
    }
    
    func monitoringManager(_ manager: ESTMonitoringV2Manager, didFailWithError error: Error) {
        print("Monitoring failed: \(error.localizedDescription)")
        self.delegate?.proximityManager(self, didFailWithError: error)
    }
    
    func monitoringManager(_ manager: ESTMonitoringV2Manager, didDetermineInitialState state: ESTMonitoringState, forBeaconWithIdentifier identifier: String) {
        print("Determined initial state for \(identifier) - \(self.name(state)).")
        self.updateBeaconsInRange()
    }
    
    func monitoringManager(_ manager: ESTMonitoringV2Manager, didEnterDesiredRangeOfBeaconWithIdentifier identifier: String) {
        print("Entered range of \(identifier).")
        self.updateBeaconsInRange()
    }
    
    func monitoringManager(_ manager: ESTMonitoringV2Manager, didExitDesiredRangeOfBeaconWithIdentifier identifier: String) {
        print("Exited range of \(identifier).")
        self.updateBeaconsInRange()
    }
}
