//
//  MBEOBJGroup.m
//  InstancedDrawing
//
//  Created by Warren Moore on 9/28/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#import "MBEOBJGroup.h"

@implementation MBEOBJGroup

- (instancetype)initWithName:(NSString *)name
{
    if ((self = [super init]))
    {
        _name = [name copy];
    }
    return self;
}

@end


