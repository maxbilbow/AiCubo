//
//  RMXClock.swift
//  RattleGLES
//
//  Created by Max Bilbow on 25/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import CloudKit



typealias RMXTimedCallback = (frequency: NSTimeInterval? , call:()->())
//
//protocol RMXClock  {
//    var world: RMSWorld { get }
////    var systemTime: NSTimeInterval { get }
//    var timeSinceInitialization: NSTimeInterval { get }
//    var currentSessionTime: NSTimeInterval { get }
//    var callBacks: [ RMXTimedCallback? ] { get }
//    var speed: Float { get set }
//    var interface: RMXInterface { get  }
//    var increments: [String : Float] { get }
//    func getCounter(forKey key: String, plus: Float) -> Float
//}


class RMXClock {
    var world: RMSWorld

    var timeSinceLastUpdate: NSTimeInterval = 0
    var interface: RMXInterface
    
//    var world: RMSWorld
    
    var speed: Float = 1
    
    var increments: [String : Float] = ["i": 0]
    
    var allOfTime: NSTimeInterval {
        return NSTimeIntervalSince1970
    }
    
    var timeSinceInitialization: NSTimeInterval = 0
    
    var currentSessionTime: NSTimeInterval = 0
    
    var callBacks: [ RMXTimedCallback? ] = [ nil ]
    
    init(world: RMSWorld, interface: RMXInterface){
        self.interface = interface
        self.world = world
    }
    
    ///Probably not necessary to call, given its use... getCounter does the same.
    func setCounter(forKey key: String, value: Float = 0) -> Float?{
        return self.increments.updateValue(value, forKey: key)
    }
    
    
}