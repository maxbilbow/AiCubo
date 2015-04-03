//
//  GameView.swift
//  AiCubo
//
//  Created by Max Bilbow on 03/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import UIKit

class GameView : UIView, RMXView {
    var world: RMSWorld = RMSWorld()
    override required init(frame: CGRect) {
        super.init(frame: frame)//, context: EAGLContext(API:EAGLRenderingAPI.OpenGLES3))
        self.viewDidLoad()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)//, context: EAGLContext(API:EAGLRenderingAPI.OpenGLES3))
        self.viewDidLoad()
    }
    
    func viewDidLoad() {
        
    }
}