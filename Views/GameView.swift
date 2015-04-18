//
//  FirstViewController.swift
//  AiCubo
//
//  Created by Max Bilbow on 01/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit
import UIKit
import SceneKit

class GameView : RMSView, RMXView {
    
    var world: RMSWorld? {
        return self.interface?.world
    }
    var interface: RMXInterface?
    var gvc: RMXViewController?
    
    func initialize(gvc: RMXViewController, interface: RMXInterface){
        self.interface = interface
        self.gvc = gvc
    }
    
    var shapes: [RMSGeometry] = [ RMSGeometry.CUBE, RMSGeometry.PLANE, RMSGeometry.SPHERE ]
    var modelMatrix: GLKMatrix4!
    var viewMatrix: GLKMatrix4 {
        return self.camera.modelViewMatrix
    }
    @IBOutlet weak var pauseButton: UIButton!
    //    #if OPENGL_OSX
    //    var view: RMXView! = nil
    //    #endif
    var projectionMatrix: GLKMatrix4 {
        return self.camera.getProjectionMatrix(Float(self.bounds.size.width), height: Float(self.bounds.size.height))
    }
    var textureInfo: GLKTextureInfo! = nil
    var rotation: Float = 0
    var vertexArray: UnsafeMutablePointer<GLuint> = UnsafeMutablePointer<GLuint>.alloc(sizeof(GLuint))
    
    var effect: GLKBaseEffect! = nil
    var vertexBuffer: UnsafeMutablePointer<GLuint> = UnsafeMutablePointer<GLuint>.alloc(sizeof(GLuint64))
    var indexBuffer: UnsafeMutablePointer<GLuint> = UnsafeMutablePointer<GLuint>.alloc(sizeof(GLuint64))
    var initialized: Bool = false

    var lightPosition: GLKVector4 {
        if let sun =  self.world?.sun {
            return GLKVector4MakeWithVector3(SCNVector3ToGLKVector3(sun.position),1)
        } else {
            return GLKVector4Make(0, 0,-10,1.0)
        }
    }

    var lightColor: GLKVector4 {
        return GLKVector4Make(1, 1, 1, 1.0)
    }

    func setWorld(type: RMXWorldType){
        if self.world!.worldType != type {
            self.world!.setWorldType(worldType: type)
        }
    }
    var camera: RMXCamera {
        return self.world!.activeCamera
    }

    override required init(frame: CGRect) {
        super.init(frame: frame)//, context: EAGLContext(API:EAGLRenderingAPI.OpenGLES3))
        self.viewDidLoad()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewDidLoad()

    }
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        let test: AnyObject? = aDecoder.decodeObject()//.valueForKeyPath("test")
//        println("\n\n TEST: \(test) \n\n")
//        self.viewDidLoad()
//    }
    
    func viewDidLoad() {
        self.context = EAGLContext(API:EAGLRenderingAPI.OpenGLES3)
        self.drawableMultisample = GLKViewDrawableMultisample.Multisample4X
        self.drawableDepthFormat = GLKViewDrawableDepthFormat.Format24
       
        self.initEffect()
        self.setupGL()
    }
    
    func initEffect() {
        #if OPENGL_ES
            self.effect = GLKBaseEffect()
            self.configureDefaultLight()
            self.initialized = true
            #elseif OPENGL_OSX
            
        #endif
        
    }
    func update(){
        
        self.effect.light0.enabled = GLboolean(1)
        self.effect.light0.ambientColor = lightColor
        self.effect.light0.diffuseColor = lightColor
        self.effect.light0.position = lightPosition
        //        self.projectionMatrix = self.camera.getProjectionMatrix(Float(self.view.bounds.size.width), height: Float(self.view.bounds.size.height))
        //        self.viewMatrix = self.interface.activeCamera.modelViewMatrix
        self.rotation += Float(self.world!.clock!.timeSinceLastUpdate * 0.5)
        //super.update()
        
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT));
        var matrixStack = GLKMatrixStackCreate(kCFAllocatorDefault).takeRetainedValue()
        self.drawChildren(self.world!, matrixStack: matrixStack)
        glBindVertexArrayOES(0)
    }


    func setupGL() {
        #if OPENGL_ES
            
            EAGLContext.setCurrentContext(self.context)
            
            //TODO
            // CGLGetCurrentContext(self.context)
            glEnable(GLenum(GL_DEPTH_TEST))
            glDepthFunc(GLenum(GL_LEQUAL))
            
            // Enable Transparency
            glEnable (GLenum(GL_BLEND))
            glBlendFunc (GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
            
            // Create Vertex Array Buffer For Vertex Array Objects
            
            glGenVertexArraysOES(1, self.vertexArray)
            glBindVertexArrayOES(self.vertexArray.memory)
            
            
            
            //        for shape in self.shapes {
            let shape = shapes[0].rawType
            
            // All of the following configuration for per vertex data is stored into the VAO
            
            // setup vertex buffer - what are my vertices?
            glGenBuffers(1, self.vertexBuffer)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer.memory);
            
            
            //            let shape = RMSGeometry.CUBE()//self.world.sun!)// o.geometry!
            glBufferData(GLenum(GL_ARRAY_BUFFER), RMSizeOfVertex(shape), RMVerticesPtr(shape), GLenum(GL_STATIC_DRAW))
            
            // setup index buffer - which vertices form a triangle?
            glGenBuffers(1, self.indexBuffer);
            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.indexBuffer.memory)
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLintptr(RMSizeOfIndices(shape)), RMIndicesPtr(shape), GLenum(GL_STATIC_DRAW))
            
            //Setup Vertex Atrributs
            glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
            //SYNTAX -,number of elements per vertex, datatype, FALSE, size of element, offset in datastructure
            glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), RMSizeOfVert(), RMOffsetVertPos())
            
            glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
            glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), RMSizeOfVert(), RMOffsetVertCol() )
            
            //Textures
            glEnableVertexAttribArray(GLuint(GLKVertexAttrib.TexCoord0.rawValue))
            glVertexAttribPointer(GLuint(GLKVertexAttrib.TexCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), RMSizeOfVert(), RMOffsetVertTex())
            
            //Normals
            glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Normal.rawValue))
            glVertexAttribPointer(GLuint(GLKVertexAttrib.Normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), RMSizeOfVert(), RMOffsetVertNorm());
            
            
            glActiveTexture(GLenum(GL_TEXTURE0))
            self.configureDefaultTexture()
            
            
            // were done so unbind the VAO
            
            glBindVertexArrayOES(0);
            
            
            //        }
        #endif
    }


    func configureDefaultLight() {
        //Lightning
        self.effect.light0.enabled = GLboolean(1)
        self.effect.light0.ambientColor = lightColor
        self.effect.light0.diffuseColor = lightColor
        self.effect.light0.position = lightPosition
    }

    func configureDefaultMaterial() {
        self.effect.texture2d0.enabled = GLboolean(0)
        self.effect.material.ambientColor = GLKVector4Make(0.3,0.3,0.3,1.0)
        self.effect.material.diffuseColor = GLKVector4Make(0.3,0.3,0.3,1.0)
        self.effect.material.emissiveColor = GLKVector4Make(0.0,0.0,0.0,1.0)
        self.effect.material.specularColor = GLKVector4Make(0.0,0.0,0.0,1.0)
        self.effect.material.shininess = 0.2
    }

    func configureDefaultTexture() {
        #if OPENGL_ES
            self.effect.texture2d0.enabled = GLboolean(1)
            
            var path = NSBundle.mainBundle().URLForResource("texture_poppy", withExtension:"png")?.path
            
            var error: NSErrorPointer = NSErrorPointer()
            let options: [NSObject : AnyObject] = NSDictionary(object: NSNumber(bool:true),forKey:GLKTextureLoaderOriginBottomLeft) as [NSObject : AnyObject]
            
            
            self.textureInfo = GLKTextureLoader.textureWithContentsOfFile(path, options: options, error: error)
            if self.textureInfo == nil {
            NSLog("Error loading texture: %@", error.debugDescription)
            }
            
            
            let tex = GLKEffectPropertyTexture()
            tex.enabled = GLboolean(1)
            tex.envMode = GLKTextureEnvMode.Decal
            tex.name = self.textureInfo.name
            
            self.effect.texture2d0.name = tex.name;
            #elseif OPENGL_OSX
            
        #endif
    }

 
    
    func updateView(view: UIView!, drawInRect rect: CGRect) {
        
    }

    func drawChildren(object: RMXSprite, var matrixStack: GLKMatrixStackRef) {
        if object.isDrawable {
            let r = object.radius; let pos = object.position
            let o = object.orientation; let q = GLKQuaternionMake(o.x, o.y, o.z, o.w)
            let scaleMatrix = GLKMatrix4MakeScale(r,r,r)
            let translateMatrix = GLKMatrix4MakeTranslation(pos.x,pos.y,pos.z)
            let rotationMatrix = GLKMatrix4MakeWithQuaternion(q)
                
            matrixStack = GLKMatrixStackCreate(kCFAllocatorDefault).takeRetainedValue()
            GLKMatrixStackMultiplyMatrix4(matrixStack, translateMatrix)
            GLKMatrixStackMultiplyMatrix4(matrixStack, rotationMatrix)
            GLKMatrixStackMultiplyMatrix4(matrixStack, scaleMatrix)
            
            GLKMatrixStackPush(matrixStack)
            self.modelMatrix = GLKMatrixStackGetMatrix4(matrixStack);
            
            glBindVertexArrayOES(self.vertexArray.memory)
            
            self.prepareEffectWithModelMatrix(self.modelMatrix, viewMatrix:self.viewMatrix, projectionMatrix: self.projectionMatrix)
            let shape = RMSGeometry.get(object.shapeType)
            glDrawElements(GLenum(GL_TRIANGLES), GLsizei(shape.sizeOfIndices) / GLsizei(shape.sizeOfIZero), GLenum(GL_UNSIGNED_BYTE), UnsafePointer<Void>())//nil or 0?
            
        }
        for child in object.children {
            self.drawChildren(child, matrixStack: matrixStack)
        }
    }


    func prepareEffectWithModelMatrix(modelMatrix: GLKMatrix4, viewMatrix:GLKMatrix4, projectionMatrix: GLKMatrix4) {
        self.effect.transform.modelviewMatrix =  GLKMatrix4Multiply(viewMatrix, modelMatrix)
        self.effect.transform.projectionMatrix = projectionMatrix;
        self.effect.prepareToDraw()
    }


    func tearDownGL() {
        #if OPENGL_ES
            EAGLContext.setCurrentContext(self.context)
            
            glDeleteBuffers(1, self.vertexBuffer)
            glDeleteBuffers(1, self.indexBuffer)
            
            glDeleteVertexArraysOES(1, self.vertexArray)
            
        #endif
        self.effect = nil
    }

    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return super.canPerformAction(action, withSender: sender)
    }
}