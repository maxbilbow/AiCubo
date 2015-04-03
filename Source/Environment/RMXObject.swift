//
//  RMXObject.swift
//  RattleGL3-0
//
//  Created by Max Bilbow on 10/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//
import GLKit

class RMXObject  {
    static var COUNT: Int = 0
    var rmxID: Int
    var isUnique: Bool = false
    var position: GLKVector3
    var isAnimated: Bool = true
    private var _name: String
    var parent: RMSParticle?
    lazy var world: RMSWorld = self as! RMSWorld
    var body: RMSPhysicsBody! = nil
    var collisionBody: RMSCollisionBody! = nil
    var resets: [() -> () ]
    var behaviours: [(Bool) -> ()]
    var children: [Int : RMSParticle]
    var hasChildren: Bool {
        return !children.isEmpty
    }
    var isAlwaysActive = true
    var isActive = true
    var variables: [ String: Variable] = [ "isBouncing" : Variable(i: 1) ]
    var name: String {
        return "\(_name): \(self.rmxID)"
    }
    
    
    init(parent: RMSParticle? = nil, name: String = "RMXObject"){
        
        self.children = Dictionary<Int,RMSParticle>()
        self.parent = parent
        
        self.rmxID = RMXObject.COUNT
        self.position = GLKVector3Make(0,0,0)
        _name = name
        RMXObject.COUNT++
        self.resets = Array<() -> ()>()
        self.behaviours = Array<(Bool) -> ()>()
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
        
//        self.resets.append({ println("INIT: \(name), \(RMXObject.COUNT)")})
        self.objectDidInitialize()
        
    }
    
    func objectDidInitialize(){
        if self.parent != nil {
            self.world = self.parent!.world
        }
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
        for child in children {
            child.1.reset()
        }
    }
   
   
    
    func debug() {}
    


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
    var hasBehaviour = true
    func animate(){
        for behaviour in self.behaviours {
            behaviour(self.hasBehaviour)
        }
        for child in children {
            child.1.animate()
        }
    }
    
    func insertChildNode(child: RMSParticle){
        self.children[child.rmxID] = child
    }
    
    func insertChildNode(children: [Int:RMSParticle]){
        for child in children {
            self.children[child.0] = child.1
        }
    }
    
    
    
    func expellChild(rmxID: Int){
        self.children.removeValueForKey(rmxID)
    }
    
    func expellChild(child: RMSParticle){
        self.children.removeValueForKey(child.rmxID)
    }
    
    func removeBehaviours(){
        self.behaviours.removeAll()
    }
    
    func setBehaviours(areOn: Bool){
        self.hasBehaviour = areOn
        for child in children{
            child.1.hasBehaviour = areOn
        }
    }
}
