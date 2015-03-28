//
//  RMSGeometry.swift
//  RattleGL
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit


enum ShapeType: Int32 { case NULL = 0, CUBE = 1 , PLANE = 2, SPHERE = 3 }

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
            self.sizeOfVertex = RMSizeOfVertex(type.rawValue)
            self.sizeOfIndices = RMSizeOfIndices(type.rawValue)
            self.sizeOfIZero = RMSizeOfIZero(type.rawValue)
            //        geometry.verts = RMVertexWrapper.CUBE()
            self.vertices = RMVerticesPtr(type.rawValue)
            self.indices = RMIndicesPtr(type.rawValue)
//        }
        
    }
}



