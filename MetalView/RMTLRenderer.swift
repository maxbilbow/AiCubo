//
//  RMTLRenderer.swift
//  AiCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import Quartscore
import Metal
class MBERenderer : NSObject {
    
    static let MBECowCount:size_t = 80;
    static let MBECowSpeed:Float = 0.75;
    static let MBECowTurnDamping:Float = 0.95;
    
    static let MBETerrainSize:Float = 40;
    static let MBETerrainHeight:Float = 1.5;
    static let MBETerrainSmoothness:Float = 0.95;
    
    static let MBECameraHeight:Float = 1;
    
    static let Y:GLKVector3 = GLKVector3Make( 0, 1, 0 )
    
    class func random_unit_float()->Float {
        return arc4random() / Double(UINT32_MAX)
    }

    
    var layer:CAMetalLayer
    // Long-lived Metal objects
    var device: MTLDevice
    var commandQueue:MTLCommandQueue
    var renderPipeline:MTLRenderPipelineState
    var depthState:MTLDepthStencilState
    var depthTexture:MTLTexture
    var sampler:MTLSamplerState
    // Resources
    var terrainMesh:RMXTerrainMesh
    var terrainTexture: MTLTexture
    var cowMesh: RMXMesh
    var cowTexture: MTLTexture
    var sharedUniformBuffer, terrainUniformBuffer, cowUniformBuffer: MTLBuffer
    // Parameters
    var cameraPosition: GLKVector3
    var cameraHeading, cameraPitch: Float
    var cows: [NSArray]
    var frameCount: size_t
    var angularVelocity, velocity, frameDuration: Float

    init(layer:CAMetalLayer) {
        if self = super.init() {
            self.frameDuration = 1 / 60.0;
            self.layer = layer;
            self.buildMetal()
            self.buildPipelines()
            self.buildCows()
            self.buildResources()
        }
        return self;
    }
    
    private func buildMetal()    {
        self.device = MTLCreateSystemDefaultDevice()
        self.layer.device =self.device
        self.layer.pixelFormat = MTLPixelFormatBGRA8Unorm
    }
    
    private func buildPipelines()
    {
        self.commandQueue = self.device.newCommandQueue()
        
        let library:MTLLibrary = self.device.newDefaultLibrary()
        
        let vertexDescriptor:MTLVertexDescriptor = MTLVertexDescriptor.new()
        vertexDescriptor.attributes[0].format = MTLVertexFormatFloat4;
        vertexDescriptor.attributes[0].offset = 0;
        vertexDescriptor.attributes[0].bufferIndex = 0;
        vertexDescriptor.attributes[1].format = MTLVertexFormatFloat4;
        vertexDescriptor.attributes[1].offset = sizeof(vector_float4);
        vertexDescriptor.attributes[1].bufferIndex = 0;
        vertexDescriptor.attributes[2].format = MTLVertexFormatFloat2;
        vertexDescriptor.attributes[2].offset = sizeof(vector_float4) * 2;
        vertexDescriptor.attributes[2].bufferIndex = 0;
        vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
        vertexDescriptor.layouts[0].stride = sizeof(MBEVertex);
        
        let pipelineDescriptor:MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor.new()
        pipelineDescriptor.vertexFunction = library.newFunctionWithName("vertex_project")
        pipelineDescriptor.fragmentFunction = library.newFunctionWithName("fragment_texture")
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.BGRA8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
        
        let error:NSError! = nil
        self.renderPipeline = self.device.newRenderPipelineStateWithDescriptor(pipelineDescriptor,error:&error)
        if self.renderPipeline == nil {
            NSLog("Failed to create render pipeline state: \(error)")
        }
        
        let depthDescriptor:MTLDepthStencilDescriptor = MTLDepthStencilDescriptor.new()
        depthDescriptor.depthWriteEnabled = true
        depthDescriptor.depthCompareFunction = MTLCompareFunctionLess;
        self.depthState = self.device.newDepthStencilStateWithDescriptor(depthDescriptor)
        
        let samplerDescriptor:MTLSamplerDescriptor = MTLSamplerDescriptor.new()
        samplerDescriptor.minFilter = MTLSamplerMinMagFilterNearest;
        samplerDescriptor.magFilter = MTLSamplerMinMagFilterLinear;
        samplerDescriptor.sAddressMode = MTLSamplerAddressModeRepeat;
        samplerDescriptor.tAddressMode = MTLSamplerAddressModeRepeat;
        self.sampler = self.device.newSamplerStateWithDescriptor(samplerDescriptor)
    }
    
    private func buildCows()
    {
        let cows = NSMutableArray.arrayWithCapacity(MBECowCount)
        
        for (var i:Int = 0; i < MBECowCount; ++i) {
            let cow: RMTLCow = RMTLCow()
        
            // Situate the cow somewhere in the internal 80% part of the terrain patch
            let x: Float = (random_unit_float() - 0.5) * MBETerrainSize * 0.8
            let z: Float = (random_unit_float() - 0.5) * MBETerrainSize * 0.8
            let y: Float = self.terrainMesh.heightAtPositionX(x, z:z)
        
            cow.position = GLKVector3Make( x, y, z )
            cow.heading = 2 * M_PI * self.random_unit_float()
            cow.targetHeading = cow.heading;
            
            cows.addObject(cow)
        }
        
        self.cows = cows.copy()
    }
    
    private func loadMeshes()
    {
        self.terrainMesh = RMXTerrainMesh(
            RMXTerrainSize,
            height:RMXTerrainHeight,
            iterations:4,
            smoothness:MBETerrainSmoothness,
            device:self.device
            )
        
        let modelURL:NSURL = NSBundle.mainBundle.URLForResource:("spot", withExtension:"obj")
        MBEOBJModel *cowModel = [[MBEOBJModel alloc] initWithContentsOfURL:modelURL generateNormals:YES];
        MBEOBJGroup *spotGroup = [cowModel groupForName:@"spot"];
        self.cowMesh = [[MBEOBJMesh alloc] initWithGroup:spotGroup device:_device];
    }
    
    private func loadTextures()
    {
        self.terrainTexture = [MBETextureLoader texture2DWithImageNamed:@"grass" device:_device];
        self.terrainTexture setLabel:@"Terrain Texture"];
        
        self.cowTexture = [MBETextureLoader texture2DWithImageNamed:@"spot" device:_device];
        self.cowTexture setLabel:@"Cow Texture"];
    }
    
    private func buildUniformBuffers()
    {
        self.sharedUniformBuffer = self.device newBufferWithLength:sizeof(Uniforms)
        options:MTLResourceOptionCPUCacheModeDefault];
        self.sharedUniformBuffer setLabel:@"Shared Uniforms"];
        
        self.terrainUniformBuffer = self.device newBufferWithLength:sizeof(PerInstanceUniforms)
        options:MTLResourceOptionCPUCacheModeDefault];
        self.terrainUniformBuffer setLabel:@"Terrain Uniforms"];
        
        self.cowUniformBuffer = self.device newBufferWithLength:sizeof(PerInstanceUniforms) * MBECowCount
        options:MTLResourceOptionCPUCacheModeDefault];
        self.cowUniformBuffer setLabel:@"Cow Uniforms"];
    }
    
    private func buildResources()
    {
        self.loadMeshes];
        self.loadTextures];
        self.buildUniformBuffers];
    }
    
    private func buildDepthTexture()
    {
        CGSize drawableSize = self.layer.drawableSize;
        MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
        width:drawableSize.width
        height:drawableSize.height
        mipmapped:NO];
        self.depthTexture = [self.device newTextureWithDescriptor:descriptor];
        [self.depthTexture setLabel:@"Depth Texture"];
    }
    
    private func positionConstrainedToTerrainForPosition(position:GLKVector3) -> GLKVector3
    {
        vector_float3 newPosition = position;
        
        // limit x and z extent to terrain patch boundaries
        const float halfWidth = self.terrainMesh.width * 0.5;
        const float halfDepth = self.terrainMesh.depth * 0.5;
        
        if (newPosition.x < -halfWidth)
        newPosition.x = -halfWidth;
        else if (newPosition.x > halfWidth)
        newPosition.x = halfWidth;
        
        if (newPosition.z < -halfDepth)
        newPosition.z = -halfDepth;
        else if (newPosition.z > halfDepth)
        newPosition.z = halfDepth;
        
        newPosition.y = [self.terrainMesh heightAtPositionX:newPosition.x z:newPosition.z];
        
        return newPosition;
    }
    
    private func updateTerrain()
    {
        PerInstanceUniforms terrainUniforms;
        terrainUniforms.modelMatrix = matrix_identity();
        terrainUniforms.normalMatrix = matrix_upper_left3x3(terrainUniforms.modelMatrix);
        memcpy([self.terrainUniformBuffer contents], &terrainUniforms, sizeof(PerInstanceUniforms));
    }
    
    private func updateCamera()
    {
        vector_float3 cameraPosition = self.cameraPosition;
        
        self.cameraHeading += self.angularVelocity * self.frameDuration;
        
        // update camera location based on current heading
        cameraPosition.x += -sin(self.cameraHeading) * self.velocity * self.frameDuration;
        cameraPosition.z += -cos(self.cameraHeading) * self.velocity * self.frameDuration;
        cameraPosition = self.positionConstrainedToTerrainForPosition:cameraPosition];
        cameraPosition.y += MBECameraHeight;
        
        self.cameraPosition = cameraPosition;
    }
    
    private func updateCows()
    {
        for (size_t i = 0; i < MBECowCount; ++i)
        {
        MBECow *cow = self.cows[i];
        
        // all cows select a new heading every ~4 seconds
        if (self.frameCount % 240 == 0)
        cow.targetHeading = 2 * M_PI * random_unit_float();
        
        // smooth between the current and intended direction
        cow.heading = (MBECowTurnDamping * cow.heading) + ((1 - MBECowTurnDamping) * cow.targetHeading);
        
        // update cow position based on its orientation, constraining to terrain
        vector_float3 position = cow.position;
        position.x += sin(cow.heading) * MBECowSpeed * self.frameDuration;
        position.z += cos(cow.heading) * MBECowSpeed * self.frameDuration;
        position = self.positionConstrainedToTerrainForPosition:position];
        cow.position = position;
        
        // build model matrix for cow
        matrix_float4x4 rotation = matrix_rotation(Y, -cow.heading);
        matrix_float4x4 translation = matrix_translation(cow.position);
        
        // copy matrices into uniform buffers
        PerInstanceUniforms uniforms;
        uniforms.modelMatrix = matrix_multiply(translation, rotation);
        uniforms.normalMatrix = matrix_upper_left3x3(uniforms.modelMatrix);
        memcpy([self.cowUniformBuffer contents] + sizeof(PerInstanceUniforms) * i, &uniforms, sizeof(PerInstanceUniforms));
        }
    }
    
    private func updateSharedUniforms()
    {
        matrix_float4x4 viewMatrix = matrix_multiply(matrix_rotation(Y, self.cameraHeading),
        matrix_translation(-self.cameraPosition));
        
        float aspect = self.layer.drawableSize.width / self.layer.drawableSize.height;
        float fov = (aspect > 1) ? (M_PI / 4) : (M_PI / 3);
        matrix_float4x4 projectionMatrix = matrix_perspective_projection(aspect, fov, 0.1, 100);
        
        Uniforms uniforms;
        uniforms.viewProjectionMatrix = matrix_multiply(projectionMatrix, viewMatrix);
        memcpy([self.sharedUniformBuffer contents], &uniforms, sizeof(Uniforms));
    }
    
    private func updateUniforms()
    {
        self.updateTerrain];
        self.updateCows];
        self.updateCamera];
        self.updateSharedUniforms];
    }
    
    private func createRenderPassWithColorAttachmentTexture(texture:MTLTexture) -> MTLRenderPassDescriptor
    {
        MTLRenderPassDescriptor *renderPass = [MTLRenderPassDescriptor new];
        renderPass.colorAttachments[0].texture = texture;
        renderPass.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderPass.colorAttachments[0].storeAction = MTLStoreActionStore;
        renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0.2, 0.5, 0.95, 1.0);
        
        renderPass.depthAttachment.texture = self.depthTexture;
        renderPass.depthAttachment.loadAction = MTLLoadActionClear;
        renderPass.depthAttachment.storeAction = MTLStoreActionStore;
        renderPass.depthAttachment.clearDepth = 1.0;
        
        return renderPass;
    }
    
    private func drawTerrainWithCommandEncoder(commandEncoder:MTLRenderCommandEncoder)    {
        [commandEncoder setVertexBuffer:self.terrainMesh.vertexBuffer offset:0 atIndex:0];
        [commandEncoder setVertexBuffer:self.sharedUniformBuffer offset:0 atIndex:1];
        [commandEncoder setVertexBuffer:self.terrainUniformBuffer offset:0 atIndex:2];
        [commandEncoder setFragmentTexture:self.terrainTexture atIndex:0];
        [commandEncoder setFragmentSamplerState:self.sampler atIndex:0];
        
        [commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
        indexCount:[self.terrainMesh.indexBuffer length] / sizeof(MBEIndexType)
        indexType:MTLIndexTypeUInt16
        indexBuffer:self.terrainMesh.indexBuffer
        indexBufferOffset:0];
    }

    
    private func drawCowsWithCommandEncoder(commandEncoder:MTLRenderCommandEncoder)  {
        [commandEncoder setVertexBuffer:self.cowMesh.vertexBuffer offset:0 atIndex:0)
        [commandEncoder setVertexBuffer:self.sharedUniformBuffer offset:0 atIndex:1)
        [commandEncoder setVertexBuffer:self.cowUniformBuffer offset:0 atIndex:2)
        [commandEncoder setFragmentTexture:self.cowTexture atIndex:0)
        [commandEncoder setFragmentSamplerState:self.sampler atIndex:0)
        
        [commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
        indexCount:[self.cowMesh.indexBuffer length] / sizeof(MBEIndexType)
        indexType:MTLIndexTypeUInt16
        indexBuffer:self.cowMesh.indexBuffer
        indexBufferOffset:0
        instanceCount:MBECowCount)
    }

    
    func draw() {
        self.updateUniforms)
        
        id<CAMetalDrawable> drawable = [self.layer nextDrawable)
        
        if (drawable)
        {
            if ([self.depthTexture width] != self.layer.drawableSize.width ||
                [self.depthTexture height] != self.layer.drawableSize.height)
            {
                self.buildDepthTexture)
            }
            
            MTLRenderPassDescriptor *renderPass = self.createRenderPassWithColorAttachmentTexture:[drawable texture])
            
            id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer)
            
            id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPass)
            [commandEncoder setRenderPipelineState:self.renderPipeline)
            [commandEncoder setDepthStencilState:self.depthState)
            [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise()
            [commandEncoder setCullMode:MTLCullModeBack()
            
            self.drawTerrainWithCommandEncoder:commandEncoder()
            self.drawCowsWithCommandEncoder:commandEncoder()
            
            [commandEncoder endEncoding()
            
            [commandBuffer presentDrawable:drawable()
            [commandBuffer commit()
            
            ++self.frameCount;
        }

    }

}
