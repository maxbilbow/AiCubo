//
//  RMSKeys.swift
//  RattleGL
//
//  Created by Max Bilbow on 22/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import AppKit

class RMSKeys : RMXInterface, RMXControllerProtocol {
    
    lazy var mv: (on:RMFloat,off:RMFloat) = (self.moveSpeed, 0)
    lazy var keys: [ RMKey ] = [
        RMKey(self, action: "forward", characters: "w", speed: self.mv),
        RMKey(self, action: "back", characters: "s", speed: self.mv),
        RMKey(self, action: "left", characters: "a", speed: self.mv),
        RMKey(self, action: "right", characters: "d", speed: self.mv),
        RMKey(self, action: "up", characters: "e", speed: self.mv),
        RMKey(self, action: "down", characters: "q", speed: self.mv),
        RMKey(self, action: "jump", characters: " "),
        RMKey(self, action: "toggleGravity", characters: "g", isRepeating: false,speed: (0,1)),
        RMKey(self, action: "toggleAllGravity", characters: "G", isRepeating: false,speed: (0,1)),
        RMKey(self, action: "reset", characters: "R", isRepeating: false,speed: (0,1)),
        RMKey(self, action: "look", characters: "mouseMoved", isRepeating: false,speed: (0.01,0)),
        RMKey(self, action: "lockMouse", characters: "m"),//,
        RMKey(self, action: "grab", characters: "Mouse 1", isRepeating: false, speed: (0,1)),
        RMKey(self, action: "throw", characters: "Mouse 2", isRepeating: false,  speed: (0,20))
    ]
    
    override func viewDidLoad(coder: NSCoder! = nil) {
        super.viewDidLoad(coder: coder)
        self.lookSpeed *= 0.1
//        self.moveSpeed *= 0.1
    }
    func set(action a: String, characters k: String ) {
        let newKey = RMKey(self, action: a, characters: k)
        var exists = false
        for key in self.keys {
            if key.action == a {
                key.set(k)
                exists = true
                break
            }
            if !exists {
                self.keys.append(newKey)
            }
        }
    }
    
    func get(action: String?) -> RMKey? {
        for key in keys {
            if key.action == action {
                return key
            }
        }
        return nil
    }
    
    func get(forChar char: String?) -> RMKey? {
        for key in keys {
            if key.characters == char {
                return key
            }
        }
        return nil
    }
    
    func match(chr: String) -> NSMutableArray {
        let keys: NSMutableArray = NSMutableArray(capacity: chr.pathComponents.count)
        for key in self.keys {
            //RMXLog(key.description)
            for str in chr.pathComponents {
                if key.characters == str {
                    keys.addObject(key)
                }
            }
            
        }
        return keys
    }
    
    func match(value: UInt16) -> RMKey? {
        for key in keys {
            //RMXLog(key.description)
            if key.charToInt == Int(value) {
                return key
            }
        }
        return nil
    }
    var mousePos: NSPoint = NSPoint(x: NSEvent.mouseLocation().x, y: NSEvent.mouseLocation().y)
    var mouseDelta: NSPoint {
        let newPos = NSEvent.mouseLocation()
        let delta = NSPoint(
            x: newPos.x - self.mousePos.x,
            y: newPos.y - self.mousePos.y
        )
        self.mousePos = newPos
        return delta
    }
    override func update() {
        for key in self.keys {
            key.update()
        }
        super.update()
        let delta = self.mouseDelta
        //self.get(forChar: "mouseMoved")?.actionWithValues([RMFloat(self.mouseDelta.x), RMFloat(self.mouseDelta.y)])
        self.action(action: "look", speed: self.lookSpeed, point: [RMFloat(delta.x), RMFloat(delta.y)])
//        RMXLog("\(self.mouseDelta.x), \(self.mouseDelta.y)")
    }
}


 class RMKey {
//    private var _key: String?
    var isPressed: Bool = false
    var action: String
    var characters: String
    var isSpecial = false
    var speed:(on:RMFloat,off:RMFloat)
    var isRepeating: Bool = true
    var values: [RMFloat] = []
    private var keys: RMSKeys
    
    init(_ keys: RMSKeys, action: String, characters: String, isRepeating: Bool = true, speed: (on:RMFloat,off:RMFloat) = (1,0), values: [RMFloat]? = nil) {
        self.keys = keys
        self.action = action
        self.isSpecial = true
        self.characters = characters
        self.speed = speed
        self.isRepeating = isRepeating
        if values != nil {
            self.values = values!
        }
    }
    
    func set(characters: String){
        self.characters = characters
    }
    
    ///Returns true if key was not already pressed, and sets isPressed = true
    func press() -> Bool{
        if self.isRepeating {
            if self.isPressed {
                return false
            } else {
                self.isPressed = true
                return true
            }
        } else  {
            self.isPressed = true
            self.keys.action(action: self.action, speed: self.speed.on, point: self.values)
            return true
        }
    }
    
    func actionWithValues(values: [RMFloat]){
        self.keys.action(action: self.action, speed: self.speed.on, point: values)
    }
    
    ///Returns true if key was already pressed, and sets isPressed = false
    func release() -> Bool{
        if self.isPressed {
            self.isPressed = false
            self.keys.action(action: self.action, speed: self.speed.off, point: self.values)
            return true
        } else {
            return false
        }
    }
    
    init(name: String){
        fatalError("'\(name)' not recognised in \(__FILE__.lastPathComponent)")
    }
    var charToInt: Int {
        return self.characters.toInt() ?? -1
    }
    
    var description: String {
        return "\(self.action): \(self.characters), speed: \(self.speed), pressed: \(self.isPressed)"
    }
    
    func update(){
        if self.isRepeating && self.isPressed {
            self.keys.action(action: self.action, speed: self.speed.on, point: self.values)
        }
    }
}

func ==(lhs: RMKey, rhs: Int) -> Bool{
    return lhs.charToInt == rhs
}

func ==(lhs: RMKey, rhs: String) -> Bool{
    return lhs.action == rhs
}

func ==(lhs: RMKey, rhs: RMKey) -> Bool{
    return lhs.action == rhs.action
}


extension GameView {
    
    var keys: RMSKeys {
        return self.interface as! RMSKeys
    }
    
    override func keyDown(theEvent: NSEvent) {
        if let key = self.keys.get(forChar: theEvent.characters) {
            if key.press() {
                //RMXLog(key.description)
                
            }
        } else {
            super.keyDown(theEvent)
        }
        
    }
    
    override func keyUp(theEvent: NSEvent) {
        if let key = self.keys.get(forChar: theEvent.characters) {
            if key.release() {
                //RMXLog(key.description)
            }
        } else {
            super.keyUp(theEvent)
        }
    }
    
    override func rightMouseUp(theEvent: NSEvent) {
        self.keys.get(forChar: "Mouse 2")?.release()
    }
    
    override func rightMouseDown(theEvent: NSEvent) {
        self.keys.get(forChar: "Mouse 2")?.press()
    }
    
    /*
    override func mouseMoved(theEvent: NSEvent) {
        keys.get(forChar: "mouseMoved")?.actionWithValues([RMFloat(theEvent.deltaX), RMFloat(theEvent.deltaY)])
        RMXLog("\(theEvent.deltaX), \(theEvent.deltaY)")
    }
    
    override func cursorUpdate(event: NSEvent) {
        RMXLog("\(event.deltaX), \(event.deltaY)")
        keys.get(forChar: "mouseMoved")?.actionWithValues([RMFloat(event.deltaX), RMFloat(event.deltaY)])
        super.cursorUpdate(event)
    }
    
    override func mouseDragged(theEvent: NSEvent) {
       // keys.get(forChar: "mouseMoved")?.actionWithValues([RMFloat(theEvent.deltaX), RMFloat(theEvent.deltaY)])
        //RMXLog("\(theEvent.deltaX), \(theEvent.deltaY)")
        super.mouseDragged(theEvent)
    }
*/
}
