//
//  RMXDebugger.swift
//  RattleGL
//
//  Created by Max Bilbow on 15/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

public class RMXDebugger  {
    

}
extension RMX {
    static var isDebugging: Bool { return true }
}

public func RMXLog(_ message: AnyObject? = "", sender: AnyObject = __FUNCTION__, file: AnyObject = __FILE__){
    if RMX.isDebugging{
        let msg: AnyObject? = message ?? ""
        println("\(file.lastPathComponent)::\(sender): \(msg)")
    }
}

