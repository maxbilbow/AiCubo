//
//  RMXViewController.swift
//  RattleGLES
//
//  Created by Max Bilbow on 26/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit

    


protocol RMXViewController  {
    var shapes: [RMSGeometry] { get set }
    var modelMatrix: GLKMatrix4! { get set }
    var viewMatrix: GLKMatrix4 { get }
    
    var projectionMatrix: GLKMatrix4 { get }
    var textureInfo: GLKTextureInfo! { get set }
    var rotation: Float { get set }
    var vertexArray: UnsafeMutablePointer<GLuint> { get set }
    var effect: GLKBaseEffect! { get set }
    var vertexBuffer: UnsafeMutablePointer<GLuint> { get set }
    var indexBuffer: UnsafeMutablePointer<GLuint> { get set }
    var initialized: Bool { get set }
    

    var context: RMXContext! { get set }
    var view: RMXView! { get set }
    
    var lightPosition: GLKVector4 { get }
    
    var lightColor: GLKVector4 { get }
    
    var interface: RMXController { get }
    var world: RMSWorld { get }
    var objects: Array<RMSParticle> { get }
    
    var camera: RMXCamera { get }
    
    func viewDidLoad()
    
    func initEffect()
    
    func update()
    
    func setupGL()

    func configureDefaultLight()
    
    func configureDefaultMaterial()
    
    func configureDefaultTexture()
    
    func prepareEffectWithModelMatrix(modelMatrix: GLKMatrix4, viewMatrix:GLKMatrix4, projectionMatrix: GLKMatrix4)
    
    func didReceiveMemoryWarning()
    
    func tearDownGL()
}