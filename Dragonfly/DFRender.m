//
//  DFRender.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFRender.h"

void DFRenderGameObject(DFGameObject* obj, GLKBaseEffect* baseEffect)
{
    if (obj == NULL){
        return;
    }
    DFTextureData* texture = obj->textureData;
    while (texture != NULL){
        DFRenderTexture(texture, baseEffect);
        texture = texture->next;
    }
    DFRectangleData* rect = obj->rectangleData;
    while (rect != NULL){
        DFRenderRectangle(obj->rectangleData, baseEffect);
        rect = rect->next;
    }
    DFEllipseData* ellipse = obj->ellipseData;
    while (ellipse != NULL){
        DFRenderEllipse(obj->ellipseData, baseEffect);
    }
}

void DFRenderRectangle(DFRectangleData* rect, GLKBaseEffect* baseEffect)
{
    baseEffect.useConstantColor = NO;
    baseEffect.texture2d0.enabled = NO;
    
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(rect->position.x, rect->position.y, 0.0);
    GLKMatrix4 scale = GLKMatrix4MakeScale(rect->scale.x, rect->scale.y, rect->scale.z);
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(rect->rotation, 0.0, 0.0, 1.0);
    GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translation, GLKMatrix4Multiply(scale, GLKMatrix4Multiply(rotation, GLKMatrix4Identity)));
    baseEffect.transform.modelviewMatrix = modelMatrix;
    [baseEffect prepareToDraw];
    
    glBindVertexArrayOES(rect->arrayObject);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glDrawElements(GL_TRIANGLES, sizeof(RectIndices)/sizeof(RectIndices[0]), GL_UNSIGNED_SHORT, (void *)0);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glBindVertexArrayOES(0);
}

void DFRenderEllipse(DFEllipseData* ellipse, GLKBaseEffect* baseEffect)
{
    baseEffect.useConstantColor = NO;
    baseEffect.texture2d0.enabled = NO;
    
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(ellipse->position.x, ellipse->position.y, 0.0);
    GLKMatrix4 scale = GLKMatrix4MakeScale(ellipse->scale.x, ellipse->scale.y, ellipse->scale.z);
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(ellipse->rotation, 0.0, 0.0, 1.0);
    GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translation, GLKMatrix4Multiply(rotation, GLKMatrix4Multiply(scale, GLKMatrix4Identity)));
    baseEffect.transform.modelviewMatrix = modelMatrix;
    [baseEffect prepareToDraw];
    
    glBindVertexArrayOES(ellipse->arrayObject);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glDrawArrays(GL_TRIANGLE_FAN, 0, ELLIPSE_RESOLUTION);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glBindVertexArrayOES(0);
}

void DFRenderTexture(DFTextureData* texture, GLKBaseEffect* baseEffect)
{
    baseEffect.useConstantColor = YES;
    baseEffect.constantColor = texture->colour;
    baseEffect.texture2d0.enabled = YES;
    baseEffect.texture2d0.name = texture->name;
    
    GLKMatrix4 centre = GLKMatrix4MakeTranslation(-texture->centre.x, -texture->centre.y, -texture->centre.z);
    GLKMatrix4 scale = GLKMatrix4MakeScale(texture->scale.x, texture->scale.y, texture->scale.z);
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(texture->rotation, 0.0, 0.0, 1.0);
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(texture->position.x, texture->position.y, texture->position.z);
    GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translation, GLKMatrix4Multiply(rotation, GLKMatrix4Multiply(scale, GLKMatrix4Multiply(centre, GLKMatrix4Identity))));
    baseEffect.transform.modelviewMatrix = modelMatrix;
    [baseEffect prepareToDraw];
    
    glBindVertexArrayOES(texture->arrayObject);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glBindVertexArrayOES(0);
}