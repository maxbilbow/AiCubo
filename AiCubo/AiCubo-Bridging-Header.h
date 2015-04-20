//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//



#import "Vertices.h"
int RMSizeOfVert();
const void * RMOffsetVertCol();
const void * RMOffsetVertTex();
const void * RMOffsetVertNorm();
const void * RMOffsetVertPos();


long RMSizeOfVertexCube();
long RMSizeOfIndicesCube();
int RMSizeOfIZeroCube();
const void * RMVerticesCubePtr();
const void * RMIndicesCubePtr();


long RMSizeOfVertexPlane();
long RMSizeOfIndicesPlane();
int RMSizeOfIZeroPlane();
const void * RMVerticesPlanePtr();
const void * RMIndicesPlanePtr();






long RMSizeOfVertex(int type);
long RMSizeOfIndices(int type);
int RMSizeOfIZero(int type);
//
const void * RMVerticesPtr(int type);
const void * RMIndicesPtr(int type);

#if OPENGL_OSX
#define RMX_DEPRECATED(from, to, msg) __OSX_AVAILABLE_BUT_DEPRECATED_MSG(__MAC_##from, __MAC_##to, __IPHONE_NA, __IPHONE_NA, "" #msg "")


#import "RMOpenGL.h"
#import "RFOpenGLView.h"

#endif

