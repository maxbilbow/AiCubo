//
//  RMXTerrainMesh.swift
//  AiCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit
#if iOS
    import UIKit
    #if METAL
    import Metal
    #endif
    #elseif OSX
    import GLUT
#endif

class RMXTerrainMesh : RMXMesh {

    var width: Float
    var depth: Float
    var height: Float

    #if METAL
    weak var device: MTLDevice
    #else
    weak var device: AnyObject?
    #endif
    var smoothness: Float
    var iterations: UInt16
    var stride: size_t // number of vertices per edge
    var vertexCount, indexCount: size_t
    var vertices: RMXVertex
    var indices: [UInt16]

/// Generates a square patch of terrain, using the diamond-square midpoint displacement algorithm.
/// Smoothness varies from 0 to 1, with 1 being the smoothest. `iterations` determines how many
/// times the recursive subdivision algorithm is applied; the total number of triangles is
/// 2 * (2 ^ (2 * iterations)). `width` determines both the width and depth of the patch. `height`
/// is the maximum possible distance from the lowest point to the highest point on the patch.
    init?(
        width: Float,
        height: Float,
        iterations: UInt16,
        smoothness: Float,
        device: AnyObject?
        ) {
            if iterations > 6
            {
                NSLog("Too many terrain mesh subdivisions requested. 16-bit indexing does not suffice.");
                return nil
            }
            
        
            self.width = width
            self.depth = width
            self.height = height
            self.smoothness = smoothness
            self.iterations = iterations
            self.device = device
            
            self.generateTerrain()
    }

    
  
    func dealloc() {
        free (self.vertices)
        //free(self.indices)
    }
    
    func generateTerrain() {
        self.stride = (1 << self.iterations) + 1 // number of vertices on one side of the terrain patch
        self.vertexCount = self.stride * self.stride;
        self.indexCount = (self.stride - 1) * (self.stride - 1) * 6;
        
        self.vertices = malloc(sizeof(MBEVertex) * self.vertexCount);
        self.indices = malloc(sizeof(uint16_t) * self.indexCount);
        
        var variance: Float = 1.0; // absolute maximum variance about mean height value
        let smoothingFactor: Float = powf(2, -self.smoothness); // factor by which to decrease variance each iteration
        
        // seed corners with 0.
        self.vertices[0].position.y = 0.0;
        self.vertices[self.stride].position.y = 0.0;
        self.vertices[(self.stride - 1) * self.stride].position.y = 0.0;
        self.vertices[(self.stride * self.stride) - 1].position.y = 0.0;
        
        for (var i: Int = 0; i < self.iterations; ++i)
        {
            let numSquares: Int = (1 << i); // squares per edge at the current subdivision level (1, 2, 4, 8)
        let squareSize: Int = (1 << (self.iterations - i)); // edge length of square at current subdivision (CHECK THIS)
        
            for (var y:Int = 0; y < numSquares; ++y) {
                for (var x:Int = 0; x < numSquares; ++x) {
                    let r = y * squareSize;
                    let c = x * squareSize;
                    self.performSquareStepWithRow(r, column:c, squareSize:squareSize, variance:variance)
                    self.performDiamondStepWithRow(r, column:c, squareSize:squareSize, variance:variance)
                }
            }
        
            variance *= smoothingFactor
        }
        
        self.computeMeshCoordinates()
        self.computeMeshNormals()
        self.generateMeshIndices()
        
        self.vertexBuffer = self.device.newBufferWithBytes(self.vertices,
            length:sizeof(MBEVertex) * self.vertexCount,
            options:MTLResourceOptionCPUCacheModeDefault)
        self.vertexBuffer.setLabel("Vertices (Terrain)")
        
        
        self.indexBuffer = self.device.newBufferWithBytes(self.indices,
            length:sizeof(uint16_t) * self.indexCount,
            options:MTLResourceOptionCPUCacheModeDefault)
        self.indexBuffer.setLabel("Indices (Terrain)")
    }
    
    func performSquareStepWithRow(row: Int, column:Int, squareSize:Int, variance:Float) {
        let r0:size_t = row
        let c0 = column
        let r1 = (r0 + squareSize) % self.stride
        let c1 = (c0 + squareSize) % self.stride
        let cmid = c0 + (squareSize / 2)
        let rmid = r0 + (squareSize / 2)
        let y00: Float = self.vertices[r0 * self.stride + c0].position.y
        let y01: Float = self.vertices[r0 * self.stride + c1].position.y
        let y11: Float = self.vertices[r1 * self.stride + c1].position.y
        let y10: Float = self.vertices[r1 * self.stride + c0].position.y
        let ymean: Float = (y00 + y01 + y11 + y10) * 0.25
        let error: Float = (((arc4random() / (float)(UINT32_MAX)) - 0.5) * 2) * variance
        let y: Float = ymean + error
        self.vertices[rmid * self.stride + cmid].position.y = y
    }
    
    func performDiamondStepWithRow(row: Int, column:Int, squareSize:Int, variance:Float) {
        let r0 = row;
        let c0 = column;
        let r1 = (r0 + squareSize) % self.stride;
        let c1 = (c0 + squareSize) % self.stride;
        let cmid = c0 + (squareSize / 2);
        let rmid = r0 + (squareSize / 2);
        let y00: Float = self.vertices[r0 * self.stride + c0].position.y;
        let y01: Float = self.vertices[r0 * self.stride + c1].position.y;
        let y11: Float = self.vertices[r1 * self.stride + c1].position.y;
        let y10: Float = self.vertices[r1 * self.stride + c0].position.y;
        var error: Float = 0
        error = (((arc4random() / (float)(UINT32_MAX)) - 0.5) * 2) * variance;
        self.vertices[r0 * self.stride + cmid].position.y = (y00 + y01) * 0.5 + error;
        error = (((arc4random() / (float)(UINT32_MAX)) - 0.5) * 2) * variance;
        self.vertices[rmid * self.stride + c0].position.y = (y00 + y10) * 0.5 + error;
        error = (((arc4random() / (float)(UINT32_MAX)) - 0.5) * 2) * variance;
        self.vertices[rmid * self.stride + c1].position.y = (y01 + y11) * 0.5 + error;
        error = (((arc4random() / (float)(UINT32_MAX)) - 0.5) * 2) * variance;
        self.vertices[r1 * self.stride + cmid].position.y = (y01 + y11) * 0.5 + error;
    }
    
    func computeMeshCoordinates() {
        for (var r = 0; r < self.stride; ++r) {
            for (var c = 0; c < self.stride; ++c) {
                let x = (Float(c) / (self.stride - 1) - 0.5) * self.width;
                let y = self.vertices[r * self.stride + c].position.y * self.height;
                let z = (Float(r) / (self.stride - 1) - 0.5) * self.depth;
                self.vertices[r * self.stride + c].position = vector_float4( x, y, z, 1 )
        
                let s = Float(c) / (self.stride - 1) * 5;
                let t = Float(r) / (self.stride - 1) * 5;
                self.vertices[r * self.stride + c].texCoords = GLKVector2Make(s, t)
            }
        }
    }
    
    func computeMeshNormals() {
        let yScale:Float = 4
        for (var r = 0; r < self.stride; ++r) {
            for (var c = 0; c < self.stride; ++c) {
                if (r > 0 && c > 0 && r < self.stride - 1 && c < self.stride - 1) {
                    let L:GLKVector4 = self.vertices[r * self.stride + (c - 1)].position;
                    let R:GLKVector4 = self.vertices[r * self.stride + (c + 1)].position;
                    let U:GLKVector4 = self.vertices[(r - 1) * self.stride + c].position;
                    let D:GLKVector4 = self.vertices[(r + 1) * self.stride + c].position;
                    let T:GLKVector3 = GLKVector3Make( R.x - L.x, (R.y - L.y) * yScale, 0 )
                    let B:GLKVector3 = GLKVector3Make( 0, (D.y - U.y) * yScale, D.z - U.z )
                    let N:GLKVector3 = vector_cross(B, T);
                    var normal:GLKVector4 = GLKVector4Make( N.x, N.y, N.z, 0 )
                    normal = vector_normalize(normal);
                    self.vertices[r * self.stride + c].normal = normal;
                } else {
                    let N: GLKVector4 = GLKVector4Make( 0, 1, 0, 0 )
                    self.vertices[r * self.stride + c].normal = N;
                }
            }
        }
    }
    
    func generateMeshIndices()    {
        var i:uint16_t = 0;
        for (var r = 0; r < self.stride - 1; ++r) {
            for (var c = 0; c < self.stride - 1; ++c) {
                self.indices[i++] = r * self.stride + c;
                self.indices[i++] = (r + 1) * self.stride + c;
                self.indices[i++] = (r + 1) * self.stride + (c + 1);
                self.indices[i++] = (r + 1) * self.stride + (c + 1);
                self.indices[i++] = r * self.stride + (c + 1);
                self.indices[i++] = r * self.stride + c;
            }
        }
    }
    
    func heightAtPositionX(x: Float, z:Float) -> Float {
        let halfSize:Float = self.width / 2;
        
        if (x < -halfSize || x > halfSize || z < -halfSize || z > halfSize) {
            return 0.0
        }
        
        // Normalize x and z between 0 and 1
        let nx: Float = (x / self.width) + 0.5;
        let nz: Float = (z / self.depth) + 0.5;
        
        // Compute fractional indices of nearest vertices
        let fx: Float = nx * (self.stride - 1);
        let fz: Float = nz * (self.stride - 1);
        
        // Compute index of nearest vertices that are "up" and to the left
        var ix:Int = floorf(fx);
        var iz:Int = floorf(fz);
        
        // Compute fractional offsets in the direction of next nearest vertices
        let dx: Float = fx - ix;
        let dz: Float = fz - iz;
        
        // Get heights of nearest vertices
        let y00: Float = self.vertices[iz * self.stride + ix].position.y;
        let y01: Float = self.vertices[iz * self.stride + (ix + 1)].position.y;
        let y10: Float = self.vertices[(iz + 1) * self.stride + ix].position.y;
        let y11: Float = self.vertices[(iz + 1) * self.stride + (ix + 1)].position.y;
        
        // Perform bilinear interpolation to get approximate height at point
        let ytop: Float = ((1 - dx) * y00) + (dx * y01);
        let ybot: Float = ((1 - dx) * y10) + (dx * y11);
        let y: Float = ((1 - dz) * ytop) + (dz * ybot);
        
        return y;
    }


}
