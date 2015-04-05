//
//  MBEOBJGroup.h
//  InstancedDrawing
//
//  Created by Warren Moore on 9/28/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBEOBJGroup : NSObject

- (instancetype)initWithName:(NSString *)name;

@property (copy) NSString *name;
@property (copy) NSData *vertexData;
@property (copy) NSData *indexData;

@end
