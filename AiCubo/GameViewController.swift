//
//  GameViewController.swift
//  RattleGLES
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//
import Foundation
import GLKit
#if OPENGL_ES
    import UIKit
    #elseif OPENGL_OSX
    import OpenGL
    import GLUT
#endif

class GameViewController : GLKViewController {
    
    var shapes: [RMSGeometry] = [ RMSGeometry(type: .CUBE), RMSGeometry(type: .PLANE) ]
    var modelMatrix: GLKMatrix4!
    var viewMatrix: GLKMatrix4 {
        return self.camera.modelViewMatrix
    }
    
    var projectionMatrix: GLKMatrix4 {
        return self.camera.getProjectionMatrix(Float(self.view.bounds.size.width), height: Float(self.view.bounds.size.height))
    }
    var textureInfo: GLKTextureInfo! = nil
    var rotation: Float = 0
    var vertexArray: UnsafeMutablePointer<GLuint> = UnsafeMutablePointer<GLuint>.alloc(sizeof(GLuint))
    var context: RMXContext?
    var effect: GLKBaseEffect! = nil
    var vertexBuffer: UnsafeMutablePointer<GLuint> = UnsafeMutablePointer<GLuint>.alloc(sizeof(GLuint64))
    var indexBuffer: UnsafeMutablePointer<GLuint> = UnsafeMutablePointer<GLuint>.alloc(sizeof(GLuint64))
    var initialized: Bool = false
    
    var lightPosition: GLKVector4 {
        return world.sun != nil ? GLKVector4MakeWithVector3(world.sun!.position, 1.0) : GLKVector4Make(0, 0,-10,1.0)
    }
    
    var lightColor: GLKVector4 {
        return world.sun != nil ? world.sun!.shape!.color : GLKVector4Make(1, 1, 1, 1.0)
    }
    
    lazy var interface: RMXController = RMXController(gvc: self, world: RMX.buildScene())
    var world: RMSWorld {
        return interface.world
    }
    
    var objects: Array<RMSParticle> {
        return self.interface.world.drawables
    }
    
    var camera: RMXCamera {
        return self.interface.activeCamera
    }
    
    override func viewDidLoad() {
        //        self.viewMatrix = self.interface.activeCamera.modelViewMatrix
        #if OPENGL_ES
            self.context = EAGLContext(API: EAGLRenderingAPI.OpenGLES3)
            #elseif OPENGL_OSX
            self.context = CGLGetCurrentContext()
        #endif
        
        #if OPENGL_ES
            
            #elseif OPENGL_OSX
            
        #endif
        if (self.context == nil) {
            NSLog("Failed to create ES context")
        }
        
        #if OPENGL_ES
            let view = self.view as! RMXView
            view.context = self.context
            view.drawableMultisample = GLKViewDrawableMultisample.Multisample4X
            view.drawableDepthFormat = GLKViewDrawableDepthFormat.Format24
            #elseif OPENGL_OSX
            //TODO
        #endif
        
        
        self.initEffect()
        self.setupGL()
        
        super.viewDidLoad()
        
    }
    
    func initEffect() {
        self.effect = GLKBaseEffect()
        self.configureDefaultLight()
        self.initialized = true
        
    }
    func update(){
        self.interface.update()
        self.effect.light0.enabled = GLboolean(1)
        self.effect.light0.ambientColor = lightColor
        self.effect.light0.diffuseColor = lightColor
        self.effect.light0.position = lightPosition
        //        self.projectionMatrix = self.camera.getProjectionMatrix(Float(self.view.bounds.size.width), height: Float(self.view.bounds.size.height))
        //        self.viewMatrix = self.interface.activeCamera.modelViewMatrix
        self.rotation += Float(self.world.clock!.timeSinceLastUpdate * 0.5)
        //super.update()
    }
    
    
    func setupGL() {
        
        #if OPENGL_ES
            EAGLContext.setCurrentContext(self.context)
            #elseif OPENGL_OSX
            //TODO
            // CGLGetCurrentContext(self.context)
        #endif
        #if OPENGL_ES
            glEnable(GLenum(GL_DEPTH_TEST))
            glDepthFunc(GLenum(GL_LEQUAL))
            
            // Enable Transparency
            glEnable (GLenum(GL_BLEND))
            glBlendFunc (GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
            
        #endif
        // Create Vertex Array Buffer For Vertex Array Objects
        #if OPENGL_ES
            glGenVertexArraysOES(1, self.vertexArray)
            glBindVertexArrayOES(self.vertexArray.memory)
            #elseif OPENGL_OSX
            glGenVertexArrays(1, self.vertexArray)
            glBindVertexArray(self.vertexArray.memory)
        #endif
        
        
        for shape in self.shapes {
            let shape = shape.type.rawValue
            
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
            #if OPENGL_ES
                glBindVertexArrayOES(0);
                #elseif OPENGL_OSX
                glBindVertexArray(0);
            #endif
            
        }
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
        self.effect.material.shininess = 0
    }
    
    func configureDefaultTexture() {
        self.effect.texture2d0.enabled = GLboolean(1)
        
        var path = NSBundle.mainBundle().URLForResource("texture_numbers", withExtension:"png")?.path
        
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
        
    }
    
    #if OPENGL_ES
    override func glkView(view: RMXView!, drawInRect: CGRect){
        self.updateView(view, drawInRect: drawInRect)
    }
    #elseif OPENGL_OSX
    override func drawLayer(layer: CALayer!, inContext ctx: CGContext!) {
    super.drawLayer(layer,inContext: ctx)
    self.updateView(self.view as! NSOpenGLView,drawInRect: CGContextGetPathBoundingBox(ctx))
    }
    #endif
    func updateView(view: RMXView!, drawInRect rect: CGRect) {
        autoreleasepool({
            glClearColor(1.0, 1.0, 1.0, 1.0);
            glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT));
            
            for o in self.objects {
                if o.geometry != .NULL {
                    let sprite = o.shape!
                    let scaleMatrix = sprite.scaleMatrix
                    let translateMatrix = sprite.translationMatrix
                    let rotationMatrix = sprite.rotationMatrix
                    
                    
                    var matrixStack = GLKMatrixStackCreate(kCFAllocatorDefault).takeRetainedValue()
                    
                    GLKMatrixStackMultiplyMatrix4(matrixStack, translateMatrix)
                    GLKMatrixStackMultiplyMatrix4(matrixStack, rotationMatrix)
                    GLKMatrixStackMultiplyMatrix4(matrixStack, scaleMatrix)
                    
                    GLKMatrixStackPush(matrixStack)
                    self.modelMatrix = GLKMatrixStackGetMatrix4(matrixStack);
                    #if OPENGL_ES
                        glBindVertexArrayOES(self.vertexArray.memory)
                        #elseif OPENGL_OSX
                        glBindVertexArray(self.vertexArray.memory)
                    #endif
                    self.prepareEffectWithModelMatrix(self.modelMatrix, viewMatrix:self.viewMatrix, projectionMatrix: self.projectionMatrix)
                    let shape = RMSGeometry.CUBE()
                    glDrawElements(GLenum(GL_TRIANGLES), GLsizei(shape.sizeOfIndices) / GLsizei(shape.sizeOfIZero), GLenum(GL_UNSIGNED_BYTE), UnsafePointer<Void>())//nil or 0?
                    #if OPENGL_ES
                        glBindVertexArrayOES(0)
                        #elseif OPENGL_OSX
                        glBindVertexArray(0)
                    #endif
                    
                }
            }
        })
    }
    
    func prepareEffectWithModelMatrix(modelMatrix: GLKMatrix4, viewMatrix:GLKMatrix4, projectionMatrix: GLKMatrix4) {
        self.effect.transform.modelviewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix)
        self.effect.transform.projectionMatrix = projectionMatrix;
        self.effect.prepareToDraw()
    }
    let _farMin: Float = 249
    
    #if iOS
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    //        NSLog("Received Memory Waning")
    if self.camera.far > _farMin {
    self.camera.far *= 0.9
    if self.camera.far < _farMin {
    self.camera.far = _farMin
    }
    }
    
    NSLog("\(self.camera.far)")
    }
    #endif
    
    func tearDownGL() {
        #if OPENGL_ES
            EAGLContext.setCurrentContext(self.context)
            #elseif OPENGL_OSX
            // CGContextRef.setCurrentContext(self.context)
        #endif
        glDeleteBuffers(1, self.vertexBuffer)
        glDeleteBuffers(1, self.indexBuffer)
        #if OPENGL_ES
            glDeleteVertexArraysOES(1, self.vertexArray)
            #elseif OPENGL_OSX
            glDeleteVertexArrays(1, self.vertexArray)
        #endif
        self.effect = nil
    }
    
}