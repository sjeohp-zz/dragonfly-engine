//
//  Rendering.h
//  Dragonfly
//
//  Created by Joseph on 28/02/14.
//  Copyright (c) 2014 Joseph Mark. All rights reserved.
//

#ifndef Dragonfly_Rendering_h
#define Dragonfly_Rendering_h

#include <GLKit/GLKit.h>

class RenderableComponent
{
    struct TexturedVertex
    {
        GLfloat geometryVertex[2];
        GLfloat textureVertex[2];
    };
private:
    GLKVector2 centre_;
    GLKVector2 scale_;
    GLKVector2 translation_;
    GLfloat angle_;
    GLKVector4 colour_;
    GLuint name_;
    GLuint width_;
    GLuint height_;
    GLuint arrayObject_;
    GLuint vertexBuffer_;
    TexturedVertex vertices_[4];
public:
    RenderableComponent(GLKVector2 scale,
                        GLKVector2 translation,
                        GLfloat angle,
                        GLKVector4 colour,
                        NSString* fileName)
    : scale_(scale), translation_(translation), angle_(angle), colour_(colour)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
        NSError *error;
        
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
        if (textureInfo == nil) {
            NSLog(@"Error loading file: %@", [error localizedDescription]);
        }
        
        name_ = textureInfo.name;
        width_ = textureInfo.width;
        height_ = textureInfo.height;
        centre_ = GLKVector2Make(width_/2.0, height_/2.0);
        vertices_[0].geometryVertex[0] = 0;
        vertices_[0].geometryVertex[1] = 0;
        vertices_[1].geometryVertex[0] = width_;
        vertices_[1].geometryVertex[1] = 0;
        vertices_[2].geometryVertex[0] = 0;
        vertices_[2].geometryVertex[1] = height_;
        vertices_[3].geometryVertex[0] = width_;
        vertices_[3].geometryVertex[1] = height_;
        vertices_[0].textureVertex[0] = 0;
        vertices_[0].textureVertex[1] = 0;
        vertices_[1].textureVertex[0] = 1;
        vertices_[1].textureVertex[1] = 0;
        vertices_[2].textureVertex[0] = 0;
        vertices_[2].textureVertex[1] = 1;
        vertices_[3].textureVertex[0] = 1;
        vertices_[3].textureVertex[1] = 1;
        
        glGenVertexArraysOES(1, &arrayObject_);
        glBindVertexArrayOES(arrayObject_);
        glGenBuffers(1, &vertexBuffer_);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer_);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices_), vertices_, GL_DYNAMIC_DRAW);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (const GLvoid *) offsetof(TexturedVertex, textureVertex));
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (const GLvoid *) offsetof(TexturedVertex, geometryVertex));
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
        glDisableVertexAttribArray(GLKVertexAttribPosition);
        glBindVertexArrayOES(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
    
    GLuint name() const { return name_; }
    GLKVector4 colour() const { return colour_; }
    GLuint arrayObject() const { return arrayObject_; }
    
    void addTranslation(GLKVector2 t) { translation_ = GLKVector2Add(translation_, t); }
    void addAngle(GLfloat a) { angle_ = angle_ + a; }
    
    GLKMatrix4 modelview() const {
        GLKMatrix4 c = GLKMatrix4MakeTranslation(-centre_.x, -centre_.y, 0);
        GLKMatrix4 s = GLKMatrix4MakeScale(scale_.x, scale_.y, 1);
        GLKMatrix4 r = GLKMatrix4MakeRotation(angle_, 0, 0, 1);
        GLKMatrix4 t = GLKMatrix4MakeTranslation(translation_.x, translation_.y, 0);
        return GLKMatrix4Multiply(t, GLKMatrix4Multiply(r, GLKMatrix4Multiply(s, GLKMatrix4Multiply(c, GLKMatrix4Identity))));
    }
};

void render(GLKBaseEffect* baseEffect, std::vector<RenderableComponent> v)
{
    baseEffect.useConstantColor = YES;
    baseEffect.texture2d0.enabled = YES;
    for (std::vector<RenderableComponent>::iterator it = v.begin(); it != v.end(); ++it){
        baseEffect.constantColor = it->colour();
        baseEffect.texture2d0.name = it->name();
        baseEffect.transform.modelviewMatrix = it->modelview();
        [baseEffect prepareToDraw];
        glBindVertexArrayOES(it->arrayObject());
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
        glDisableVertexAttribArray(GLKVertexAttribPosition);
        glBindVertexArrayOES(0);
    }
}

#endif
