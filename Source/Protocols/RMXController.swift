//
//  RMXController.swift
//  RattleGL
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

protocol RMXControllerProtocol {
    var world: RMSWorld? { get }
    var activeSprite: RMXSprite? { get }
    var activeCamera: RMXCamera? { get }
}