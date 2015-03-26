//
//  RMXObject.swift
//  RattleGL3-0
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//


public class RMXObject {
    private static var COUNT: Int = 0
    var rmxID: Int
    var isAnimated: Bool = true
    private var _name: String
    var parent: RMXObject?
    var world: RMSWorld?
    var body: RMSPhysicsBody! = nil
    var resets: [() -> () ]
    var behaviours: [() -> ()]
    
    var isAlwaysActive = true
    var isActive = true
    var variables: [ String: Variable] = [ "isBouncing" : Variable(i: 1) ]
    var name: String {
        return "\(_name): \(self.rmxID)"
    }
    init(parent: RMXObject? = nil, world: RMSWorld? = nil, name: String = "RMXObject"){
        self.parent = parent
        self.world = world
        self.rmxID = RMXObject.COUNT
        _name = name
        RMXObject.COUNT++
        self.resets = Array<() -> ()>()
        self.behaviours = Array<() -> ()>()
        var timePassed = 1000
        func restIf()->Bool{
            if timePassed == 0 {
                timePassed = 1000
                return true
            } else {
                timePassed -= 1
                return false
            }
        }
        self.prepareToRest = restIf
        self.resets.append({ println("INIT: \(name), \(self.rmxID)")})
        
        
        
    }
    func getName() -> String {
        return _name
    }
    func setName(name: String){
        _name = name
    }
    func addInitCall(reset: () -> ()){
        self.resets.append(reset)
        self.resets.last?()
    }
    
    
   
    func reset(){
        for re in resets {
            re()
        }
    }
   
    func plusAngle(x: Float,y:Float,z:Float = 0) {
        if self.body != nil {
            self.body.plusAngle(x, y: y, z: z)
        }
    }
    
    func debug() {}
    
    var position: RMXVector3 {
        return self.body.position ?? RMXVector3Zero
    }
    var isAlert = true
    var wasJustWoken = false
    var wantsToSleep = false
    var shouldAnimate: Bool {
        if self.isAlwaysActive {
            return true
        } else if self.wasJustWoken {
            self.wasJustWoken == false
            return true
        } else if self.wantsToSleep {
            return self.prepareToRest()
        } else {
            return false
        }
    }
    
    var prepareToRest: (() -> Bool)
    
    func setRestCondition(restIf: () -> Bool) {
        self.prepareToRest = restIf
    }
    

    ///Useful for global counters across many files

    func getBool(forKey key: String) -> Variable {
        if let b = self.variables[key] {
            return b
        } else {
            let v = Variable(bool: false)
            self.variables.updateValue(v, forKey: key)
            return v
        }
    }
    
    class Variable {
        var i: Float = 0
        var isActive: Bool = false
        let bools: [String:Bool] = [ "isTrue" : false ]
        init(i: Float = 0){
            self.i = i
        }
        
        init(bool: Bool){
            self.isActive = bool
        }
    }

}
