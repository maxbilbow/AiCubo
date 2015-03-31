//
//  RMSCollisionBody.swift
//  AiCubo
//
//  Created by Max Bilbow on 31/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation

enum RMXCollisionBodyType { case DEFAULT, SPHERE, CUBE }
class RMSCollisionBody : RMSChildNode {
    
    var type: RMXCollisionBodyType
    
    init(_ parent: RMSParticle, type: RMXCollisionBodyType = .DEFAULT) {
        self.type = type
        super.init(parent)
    }
}