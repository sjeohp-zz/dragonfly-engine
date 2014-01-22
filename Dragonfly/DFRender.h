//
//  DFRender.h
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "DFUtil.h"

#define ELLIPSE_RESOLUTION  64

typedef struct TexturedVertex {
    GLfloat geometryVertex[2];
    GLfloat textureVertex[2];
}   TexturedVertex;

typedef struct DFRenderableTexture {
    TexturedVertex              vertices[4];
    GLuint                      arrayObject;
    GLuint                      vertexBuffer;
    GLuint                      width;
    GLuint                      height;
    GLuint                      name;
    GLKVector3                  relativeTranslation;
    GLKVector3                  translation;
    GLKVector3                  centre;
    GLKVector3                  scale;
    GLKVector4                  colour;
    GLfloat                     relativeRotation;
    GLfloat                     rotation;
    struct DFRenderableTexture* next;
}   DFRenderableTexture;

const GLushort RectIndices[] = {
    0, 1, 2,
    2, 3, 0
};

typedef struct DFRenderableRect {
    ColouredVertex              vertices[4];
    GLuint                      vertexBuffer;
    GLuint                      indexBuffer;
    GLuint                      arrayObject;
    GLKVector3                  relativeTranslation;
    GLKVector3                  translation;
    GLKVector3                  centre;
    GLKVector3                  scale;
    GLfloat                     relativeRotation;
    GLfloat                     rotation;
    struct DFRenderableRect*    next;
}   DFRenderableRect;

typedef struct DFRenderableEllipse {
    ColouredVertex              vertices[ELLIPSE_RESOLUTION];
    GLuint                      arrayObject;
    GLuint                      vertexBuffer;
    GLKVector3                  relativeTranslation;
    GLKVector3                  translation;
    GLKVector3                  scale;
    GLfloat                     relativeRotation;
    GLfloat                     rotation;
    struct DFRenderableEllipse* next;
}   DFRenderableEllipse;

typedef struct DFRenderableData {
    DFRenderableTexture*    texture;
    DFRenderableRect*       rect;
    DFRenderableEllipse*    ellipse;
    GLKVector3              translation;
    GLfloat                 rotation;
}   DFRenderableData;

DFRenderableTexture*    DFRenderableMakeTexture(NSString* fileName);
void                    DFRenderableAddTexture(DFRenderableData* data, DFRenderableTexture* texture);
void                    DFRenderableAddTextureFromFile(DFRenderableData* data, NSString* fileName);
void                    DFRenderableFreeTexture(DFRenderableTexture* texture);

DFRenderableRect*       DFRenderableMakeRect(GLfloat x, GLfloat y, GLfloat width, GLfloat height);
void                    DFRenderableAddRect(DFRenderableData* data, DFRenderableRect* rect);
void                    DFRenderableFreeRect(DFRenderableRect* rect);

DFRenderableEllipse*    DFRenderableMakeEllipse(GLfloat x, GLfloat y, GLfloat radius);
void                    DFRenderableAddEllipse(DFRenderableData* data, DFRenderableEllipse* ellipse);
void                    DFRenderableFreeEllipse(DFRenderableEllipse* data);

void                    DFRender(DFRenderableData* data, GLKBaseEffect* baseEffect);