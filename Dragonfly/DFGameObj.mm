//
//  DFGameObj.cpp
//  Dragonfly
//
//  Created by Joseph on 20/12/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#include "DFGameObj.h"

#define ELLIPSE_RESOLUTION 64

typedef struct ColouredVertex
{
    GLfloat position[2];
    GLfloat colour[4];
}   ColouredVertex;

typedef struct TexturedVertex
{
    GLfloat geometryVertex[2];
    GLfloat textureVertex[2];
}   TexturedVertex;

const GLushort RectIndices[] = { 0, 1, 2, 2, 3, 0 };

class DFGameObj;
class DFRenderable;
class DFRenderableTexture;
class DFRenderableRect;
class DFRenderableEllipse;

class Located
{
private:
    GLKVector3 translation_;
public:
    Located() : translation_(GLKVector3Make(0, 0, 0)) {}
    GLKVector3 translation() const { return translation_; }
    void setTranslation(GLKVector3 translation) { translation_ = translation; }
};

class Oriented
{
private:
    GLfloat angle_;
public:
    Oriented() : angle_(0) {}
    GLfloat angle() const { return angle_; }
    void setAngle(GLfloat angle) { angle_ = angle; }
};

class Moving
{
private:
    GLKVector3 velocity_;
public:
    Moving() : velocity_(GLKVector3Make(0, 0, 0)) {}
    GLKVector3 velocity() const { return velocity_; }
    void setVelocity(GLKVector3 velocity) { velocity_ = velocity; }
};

class Spinning
{
private:
    GLfloat angularVelocity_;
public:
    Spinning() : angularVelocity_(0) {}
    GLfloat angularVelocity() const { return angularVelocity_; }
    void setAngularVelocity(GLfloat angularVelocity) { angularVelocity_ = angularVelocity; }
};

class Scaled
{
private:
    GLKVector3 scale_;
public:
    Scaled() : scale_(GLKVector3Make(1, 1, 1)) {}
    GLKVector3 scale() const { return scale_; }
    void setScale(GLKVector3 scale) { scale_ = scale; }
};

class Rendered : public virtual Located, public virtual Oriented, public virtual Scaled
{
private:
    GLuint renderID_;
    GLKVector4 colour_;
public:
    Rendered() : colour_(GLKVector4Make(1, 1, 1, 1)) {}
    GLKVector4 colour() const { return colour_; }
    void setColour(GLKVector4 colour) { colour_ = colour; }
    GLKMatrix4 modelview() const;
};

GLKMatrix4 Rendered::modelview() const
{
    GLKMatrix4 c = GLKMatrix4MakeTranslation(0, 0, 0);
    GLKMatrix4 s = GLKMatrix4MakeScale(scale().x, scale().y, scale().z);
    GLKMatrix4 r = GLKMatrix4MakeRotation(angle(), 0.0, 0.0, 1.0); // check if z can't be 0
    GLKMatrix4 t = GLKMatrix4MakeTranslation(translation().x, translation().y, 0.0);
    GLKMatrix4 matrix = GLKMatrix4Multiply(t, GLKMatrix4Multiply(s, GLKMatrix4Multiply(r, GLKMatrix4Multiply(c, GLKMatrix4Identity))));
    return matrix;
}

class RenderableTexture
{
private:
    GLuint name_;
    GLuint arrayObject_;
    GLuint vertexBuffer_;
public:
    RenderableTexture(NSString* fileName);
    TexturedVertex vertices[4];
    GLuint name() const { return name_; }
    GLuint arrayObject() const { return arrayObject_; }
};

RenderableTexture::RenderableTexture(NSString* fileName)
{
    NSString        *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSDictionary    *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
    NSError         *error;
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (textureInfo == nil) {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    }
    
    name_ = textureInfo.name;
    
    GLfloat width = textureInfo.width;
    GLfloat height = textureInfo.height;
    
    vertices[0].geometryVertex[0] = -width/2;
    vertices[0].geometryVertex[1] = -height/2;
    vertices[1].geometryVertex[0] = width/2;
    vertices[1].geometryVertex[1] = -height/2;
    vertices[2].geometryVertex[0] = -width/2;
    vertices[2].geometryVertex[1] = height/2;
    vertices[3].geometryVertex[0] = width/2;
    vertices[3].geometryVertex[1] = height/2;
    vertices[0].textureVertex[0] = 0;
    vertices[0].textureVertex[1] = 0;
    vertices[1].textureVertex[0] = 1;
    vertices[1].textureVertex[1] = 0;
    vertices[2].textureVertex[0] = 0;
    vertices[2].textureVertex[1] = 1;
    vertices[3].textureVertex[0] = 1;
    vertices[3].textureVertex[1] = 1;
    
    glGenVertexArraysOES(1, &arrayObject_);
    glBindVertexArrayOES(arrayObject_);
    glGenBuffers(1, &vertexBuffer_);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer_);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (const GLvoid *) offsetof(TexturedVertex, textureVertex));
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (const GLvoid *) offsetof(TexturedVertex, geometryVertex));
    glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

class RenderableRect
{
private:
    GLuint indexBuffer_;
    GLuint arrayObject_;
    GLuint vertexBuffer_;
public:
    RenderableRect(GLfloat width, GLfloat height);
    ColouredVertex vertices[4];
    GLuint arrayObject() const { return arrayObject_; }
};

RenderableRect::RenderableRect(GLfloat width, GLfloat height)
{
    vertices[0].position[0] = -width/2;
    vertices[0].position[1] = -height/2;
    vertices[1].position[0] = width/2;
    vertices[1].position[1] = -height/2;
    vertices[2].position[0] = width/2;
    vertices[2].position[1] = height/2;
    vertices[3].position[0] = -width/2;
    vertices[3].position[1] = height/2;
    
    vertices[0].colour[0] = 0;
    vertices[0].colour[1] = 0;
    vertices[0].colour[2] = 0;
    vertices[0].colour[3] = 1;
    vertices[1].colour[0] = 0;
    vertices[1].colour[1] = 0;
    vertices[1].colour[2] = 0;
    vertices[1].colour[3] = 1;
    vertices[2].colour[0] = 0;
    vertices[2].colour[1] = 0;
    vertices[2].colour[2] = 0;
    vertices[2].colour[3] = 1;
    vertices[3].colour[0] = 0;
    vertices[3].colour[1] = 0;
    vertices[3].colour[2] = 0;
    vertices[3].colour[3] = 1;
    
    glGenVertexArraysOES(1, &arrayObject_);
    glBindVertexArrayOES(arrayObject_);
    
    glGenBuffers(1, &vertexBuffer_);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer_);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
    glGenBuffers(1, &indexBuffer_);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer_);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(RectIndices), RectIndices, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(ColouredVertex), (const GLvoid *) offsetof(ColouredVertex, colour));
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(ColouredVertex), (const GLvoid *) offsetof(ColouredVertex, position));
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

class RenderableEllipse
{
private:
    GLuint arrayObject_;
    GLuint vertexBuffer_;
public:
    RenderableEllipse(GLfloat radius);
    ColouredVertex  vertices[ELLIPSE_RESOLUTION];
    GLuint arrayObject() const { return arrayObject_; }
};

RenderableEllipse::RenderableEllipse(GLfloat radius)
{
    for (int i = 0; i < ELLIPSE_RESOLUTION; i++){
        float theta = ((float)i) / ELLIPSE_RESOLUTION * 2 * M_PI;
        vertices[i].position[0] = sin(theta) * radius;
        vertices[i].position[1] = cos(theta) * radius;
        vertices[i].colour[0] = 0;
        vertices[i].colour[1] = 0;
        vertices[i].colour[2] = 0;
        vertices[i].colour[3] = 1;
    }
    
    glGenVertexArraysOES(1, &arrayObject_);
    glBindVertexArrayOES(arrayObject_);
    glGenBuffers(1, &vertexBuffer_);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer_);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(ColouredVertex), (const GLvoid *) offsetof(ColouredVertex, position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(ColouredVertex), (const GLvoid *) offsetof(ColouredVertex, colour));
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

class RenderEngine
{
    
};

void DFRender(const RenderableTexture& texture, GLKBaseEffect* baseEffect)
{
    baseEffect.useConstantColor = YES;
    baseEffect.constantColor = texture.colour();
    baseEffect.texture2d0.enabled = YES;
    baseEffect.texture2d0.name = texture.name();
    
    baseEffect.transform.modelviewMatrix = texture.modelview();
    [baseEffect prepareToDraw];
    
    glBindVertexArrayOES(texture.arrayObject());
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glBindVertexArrayOES(0);
}

void DFRender(const RenderableRect& rect, GLKBaseEffect* baseEffect)
{
    baseEffect.useConstantColor = NO;
    baseEffect.texture2d0.enabled = NO;
    
    baseEffect.transform.modelviewMatrix = rect.modelview();
    [baseEffect prepareToDraw];
    
    glBindVertexArrayOES(rect.arrayObject);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glDrawElements(GL_TRIANGLES, sizeof(RectIndices)/sizeof(RectIndices[0]), GL_UNSIGNED_SHORT, (void *)0);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glBindVertexArrayOES(0);
}

void DFRender(const RenderableEllipse& ellipse, GLKBaseEffect* baseEffect)
{
    baseEffect.useConstantColor = NO;
    baseEffect.texture2d0.enabled = NO;

    baseEffect.transform.modelviewMatrix = ellipse.modelview();
    [baseEffect prepareToDraw];
    
    glBindVertexArrayOES(ellipse.arrayObject);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glDrawArrays(GL_TRIANGLE_FAN, 0, ELLIPSE_RESOLUTION);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glBindVertexArrayOES(0);
}