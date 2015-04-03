//
//  RMXViewController.swift
//  RattleGLES
//
//  Created by Max Bilbow on 26/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit

    
extension RMX {
#if iOS
    /* static func Controller(view: GameView, world: RMSWorld) -> RMXDPad {
        return RMXDPad(view: view, world: world)
    } */
    static func Controller(gvc: RMXViewController) -> RMXDPad {
        return RMXDPad(gvc: gvc)
    }
    #elseif OSX
    static func Controller(gvc: RMXViewController) -> RMSKeys {
        return RMSKeys(gvc: gvc)
    }
#endif
}

protocol RMXView {
    var world: RMSWorld { get set }
    init(frame: CGRect)
    func viewDidLoad()
}

protocol RMXViewController {
    
    var gameView: GameView! { get }
    
    #if iOS
        var view: UIView! { get set }
//        #elseif OPENGL_OSX
//        var view: NSOpenGLView! { get set }
    #endif

    var interface: RMXInterface { get }


}

