//
//  RMSKeys.swift
//  RattleGL
//
//  Created by Max Bilbow on 22/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation


class RMSKeys : RMXInterface, RMXControllerProtocol {
 
    var keys: [ RMKey ]?
//    var specialKeys: [ RMKey ] = [ RMKey ]()
    override init(gvc: RMXViewController, world: RMSWorld){
        super.init(gvc: gvc, world: world)
        //self.set(action: "forward", key: "w")
        self.keys = [
            RMKey(action: "forward", key: "w"),
            RMKey(action: "back", key: "s"),
            RMKey(action: "left", key: "a"),
            RMKey(action: "right", key: "d"),
            RMKey(action: "up", key: "e"),
            RMKey(action: "down", key: "q"),
            RMKey(action: "jump", key: " "),
            RMKey(action: "toggleGravity", key: "g"),
            RMKey(action: "universalGravity", key: "G"),
            RMKey(action: "lockMouse", key: "m")//,
//            RMKey(action: "grab", key: "Mouse 1"),
//            RMKey(action: "throw", key: "Mouse 2")
        ]
    }

    
    func set(action a: String, key k: String ) {
        let newKey = RMKey(action: a, key: k)
        var exists = false
        for key in self.keys! {
            if key.action == a {
                key.set(k)
                exists = true
                break
            }
            if !exists {
                self.keys!.append(newKey)
            }
        }
    }
    
    func get(action: String) -> RMKey? {
        for key in keys! {
            if key.action == action {
                return key
            }
        }
        return nil
    }
    
    func match(chr: String) -> NSMutableArray {
        let keys: NSMutableArray = NSMutableArray(capacity: chr.pathComponents.count)
        for key in self.keys! {
            //RMXLog(key.description)
            for str in chr.pathComponents {
                if key.key == str {
                    keys.addObject(key)
                }
            }
            
        }
        return keys
    }
    
    func match(value: UInt16) -> RMKey? {
        for key in keys! {
            //RMXLog(key.description)
            if key.value == Int(value) {
                return key
            }
        }
        return nil
    }
}


 class RMKey {
//    private var _key: String?
    var pressed: Bool = false
    var action: String
    var key: String
    var isSpecial = false
    
    init(action: String, key: String) {
        self.action = action
        self.key = key
    }
    
    init(action: String, var specialKey key: String) {
        self.action = action
        self.isSpecial = true
        self.key = key
    }
    
    func set(key: String){
        self.key = key
    }
    
    init(name: String){
        fatalError("'\(name)' not recognised in \(__FILE__.lastPathComponent)")
    }
    var value: Int {
        return self.key.toInt() ?? -1
    }
    
    var description: String {
        return "\(self.action): \(self.key), \(self.value)"
    }
    
}

func ==(lhs: RMKey, rhs: Int) -> Bool{
    return lhs.value == rhs
}

func ==(lhs: RMKey, rhs: String) -> Bool{
    return lhs.action == rhs
}

func ==(lhs: RMKey, rhs: RMKey) -> Bool{
    return lhs.action == rhs.action
}

