//
//  BTUtilities.swift
//  aupar
//
//  Created by Javier Cifuentes on 2/5/18.
//  Copyright © 2018 aritec-la. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BTStatus{
    case on
    case off
    case unauthorized
    case unsupported
}

class BTUtilities: NSObject,CBCentralManagerDelegate{
    var manager:CBCentralManager!
    var status:BTStatus = .off
    var loaded:Bool = false
    
    override init(){
        super.init()
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.loaded = true
        if central.state == CBManagerState.poweredOn {
            print("Bluetooth is ON")
            self.status = .on
        } else if central.state == CBManagerState.poweredOff {
            print("Bluetooth is OFF")
            self.status = .off
        } else if central.state == CBManagerState.unsupported {
            print("Bluetooth is UNSUPPORTED")
            self.status = .unsupported
        } else if central.state == CBManagerState.unauthorized {
            print("Bluetooth is UNAUTHORIZED")
            self.status  = .unauthorized
        }
    }
    func check()->BTStatus{
        if(self.manager.state == CBManagerState.poweredOff){
            self.status = .off
        }else if (self.manager.state == CBManagerState.poweredOn){
            self.status = .on
        }else if (self.manager.state == CBManagerState.unauthorized){
            self.status = .unauthorized
        }else if (self.manager.state == CBManagerState.unsupported){
            self.status = .unsupported
        }
        return self.status
    }
   
   
    
}
