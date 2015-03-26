//
//  CWrappers.m
//  RattleGLES
//
//  Created by Max Bilbow on 24/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//


#import "Vertices.h"

const void * RMOffsetVertCol() {
    return (const void * ) __builtin_offsetof(Vertex, Color);
}

const void * RMOffsetVertTex(){
    return (const void *) __builtin_offsetof(Vertex, TexCoord);
}

const void * RMOffsetVertNorm(){
    return (const void *) __builtin_offsetof(Vertex, Normal);
}

const void * RMOffsetVertPos() {
    return (const void *) __builtin_offsetof(Vertex, Position);
}
int RMSizeOfVert(){
    return sizeof(Vertex);
}


long RMSizeOfVertexCube(){
    return sizeof(VerticesCube);
}

long RMSizeOfIndicesCube(){
    return sizeof(IndicesTrianglesCube);
}

int RMSizeOfIZeroCube(){
    return sizeof(IndicesTrianglesCube[0]);
}

const void * RMVerticesCubePtr(){
    return VerticesCube;
}

const void * RMIndicesCubePtr() {
    return IndicesTrianglesCube;
}


const int RMX_NULL = 0, RMX_CUBE = 1, RMX_PLANE = 2,  RMX_SPHERE = 3;

long RMSizeOfVertex(int type){
    switch (type){
        case RMX_PLANE:
            return sizeof(VerticesPlane);
        case RMX_SPHERE:
            return sizeof(VerticesSphere);
        case RMX_CUBE:
        default:
            return sizeof(VerticesCube);
    }
}

long RMSizeOfIndices(int type){
    switch (type){
        case RMX_PLANE:
            return sizeof(IndicesTrianglesPlane);
        case RMX_SPHERE:
            return sizeof(IndicesTrianglesSphere);
        case RMX_CUBE:
        default:
            return sizeof(IndicesTrianglesCube);
    }
    
    
    
}
int RMSizeOfIZero(int type){
    switch (type){
        case RMX_PLANE:
            return sizeof(IndicesTrianglesPlane[0]);
        case RMX_SPHERE:
            return IndicesTrianglesSphere[0];
        case RMX_CUBE:
        default:
            return sizeof(IndicesTrianglesCube[0]);
    }
}

const void * RMVerticesPtr(int type){
    switch (type){
        case RMX_PLANE:
            return VerticesPlane;
        case RMX_SPHERE:
            return VerticesSphere;
        case RMX_CUBE:
        default:
            return VerticesCube;
    }
    
    
}

const void * RMIndicesPtr(int type){
    switch (type){
        case RMX_PLANE:
            return IndicesTrianglesPlane;
        case RMX_SPHERE:
            return IndicesTrianglesSphere;
        case RMX_CUBE:
        default:
            return IndicesTrianglesCube;
    }
    
}
