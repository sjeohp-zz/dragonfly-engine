//
//  DFUtil.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFUtil.h"

DFVector3   DFVector3Make(GLfloat x, GLfloat y, GLfloat z)
{
    DFVector3 vector = {x, y, z};
    return vector;
}

DFVector4   DFVector4Make(GLfloat x, GLfloat y, GLfloat z, GLfloat a)
{
    DFVector4 vector = {x, y, z, a};
    return vector;
}

GLKVector3 DFGeometryNormal(GLKVector3 vertexA, GLKVector3 vertexB)
{
    GLKVector3 n = GLKVector3Make((vertexB.y - vertexA.y),
                                  -(vertexB.x - vertexA.x),
                                  0);
    return n;
}

