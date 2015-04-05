//
//  MBEOBJMesh.h
//  InstancedDrawing
//
//  Created by Warren Moore on 12/4/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

@import Foundation;
@import Metal;
#import "MBEMesh.h"

@class MBEOBJGroup;

@interface MBEOBJMesh : MBEMesh

- (instancetype)initWithGroup:(MBEOBJGroup *)group device:(id<MTLDevice>)device;

@end
