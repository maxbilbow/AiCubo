//
//  RMSGeometry.swift
//  RattleGL
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit



//public struct RMSVertex {
//    var Position: [Float]
//    var Color: [Float]
//    var TexCoord: [Float]
//    var Normal: [Float]
//}
//
//public struct RMSPosition {
//    var x, y, z: Int
//}

class RMSGeometry  {
    
    var type: ShapeType

    var rawType: Int32 {
        return Int32(self.type.rawValue)
    }
    var vertices: UnsafePointer<Void>
    var indices: UnsafePointer<Void>
    var sizeOfVertex: GLsizeiptr// {
    //        return GLintptr(self.verts.sizeV)
    //    }
    var sizeOfIndices: GLintptr
    var sizeOfIZero: GLsizei! = nil

    
    static let CUBE = RMSGeometry(type: .CUBE)
    static let SPHERE = RMSGeometry(type: .SPHERE)
    static let PLANE = RMSGeometry(type: .PLANE)
    
    init(type: ShapeType = .NULL){
        self.type = type
//        switch(type) {
//        case .CUBE:
        let typeInt = Int32(type.rawValue)
            self.sizeOfVertex = RMSizeOfVertex(typeInt)
            self.sizeOfIndices = RMSizeOfIndices(typeInt)
            self.sizeOfIZero = RMSizeOfIZero(typeInt)
            //        geometry.verts = RMVertexWrapper.CUBE()
            self.vertices = RMVerticesPtr(typeInt)
            self.indices = RMIndicesPtr(typeInt)
//        }
        
    }
    
    static func get(type: ShapeType) -> RMSGeometry{
        switch (type) {
        case .CUBE:
            return self.CUBE
        default:
            return self.CUBE
        }
    }
}



