//
//  DFTexture.h
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "DFUtil.h"

typedef struct TexturedVertex {
    GLfloat geometryVertex[2];
    GLfloat textureVertex[2];
}   TexturedVertex;

typedef struct DFTextureData {
    TexturedVertex          vertices[4];
    GLuint                  arrayObject;
    GLuint                  vertexBuffer;
    GLuint                  width;
    GLuint                  height;
    GLuint                  name;
    GLKVector3              position;
    GLKVector3              centre;
    GLKVector3              scale;
    GLKVector4              colour;
    GLfloat                 rotation;
    struct DFTextureData*   next;
}   DFTextureData;

DFTextureData*      DFTextureLoad(NSString* fileName);
