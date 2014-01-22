//
//  DFRender.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFRender.h"

DFRenderableTexture* DFRenderableMakeTexture(NSString *fileName)
{
    NSString        *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSDictionary    *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
    NSError         *error;
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (textureInfo == nil) {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    }
    
    DFRenderableTexture *texture = (DFRenderableTexture *)malloc(sizeof(DFRenderableTexture));
    
    texture->name = textureInfo.name;
    texture->width = textureInfo.width;
    texture->height = textureInfo.height;
    texture->vertices[0].geometryVertex[0] = 0;
    texture->vertices[0].geometryVertex[1] = 0;
    texture->vertices[1].geometryVertex[0] = texture->width;
    texture->vertices[1].geometryVertex[1] = 0;
    texture->vertices[2].geometryVertex[0] = 0;
    texture->vertices[2].geometryVertex[1] = texture->height;
    texture->vertices[3].geometryVertex[0] = texture->width;
    texture->vertices[3].geometryVertex[1] = texture->height;
    texture->vertices[0].textureVertex[0] = 0;
    texture->vertices[0].textureVertex[1] = 0;
    texture->vertices[1].textureVertex[0] = 1;
    texture->vertices[1].textureVertex[1] = 0;
    texture->vertices[2].textureVertex[0] = 0;
    texture->vertices[2].textureVertex[1] = 1;
    texture->vertices[3].textureVertex[0] = 1;
    texture->vertices[3].textureVertex[1] = 1;
    
    glGenVertexArraysOES(1, &texture->arrayObject);
    glBindVertexArrayOES(texture->arrayObject);
    glGenBuffers(1, &texture->vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, texture->vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(texture->vertices), texture->vertices, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (const GLvoid *) offsetof(TexturedVertex, textureVertex));
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (const GLvoid *) offsetof(TexturedVertex, geometryVertex));
    glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    texture->relativeTranslation = GLKVector3Make(0, 0, 0);
    texture->translation = GLKVector3Make(0, 0, 0);
    texture->centre = GLKVector3Make(texture->width/2, texture->height/2, 0);
    texture->scale = GLKVector3Make(1, 1, 1);
    texture->colour = GLKVector4Make(1, 1, 1, 1);
    texture->relativeRotation = 0;
    texture->rotation = 0;
    
    texture->next = NULL;
    
    return texture;
}

void DFRenderableAddTexture(DFRenderableData* data, DFRenderableTexture* texture)
{
    if (data == NULL){
        return;
    }
    DFRenderableTexture* curr = data->texture;
    if (curr == NULL){
        data->texture = texture;
    } else {
        while (curr->next != NULL){
            curr = curr->next;
        }
        curr->next = texture;
    }
}

void DFRenderableAddTextureFromFile(DFRenderableData* data, NSString* fileName)
{
    DFRenderableAddTexture(data, DFRenderableMakeTexture(fileName));
}

void DFRenderableFreeTexture(DFRenderableTexture* data)
{
    DFRenderableTexture* temp;
    DFRenderableTexture* curr = data;
    while (curr != NULL){
        temp = curr;
        curr = curr->next;
        free(temp);
    }
}

DFRenderableRect* DFRenderableMakeRect(GLfloat x, GLfloat y, GLfloat width, GLfloat height)
{
    DFRenderableRect *rect = (DFRenderableRect *)malloc(sizeof(DFRenderableRect));
    
    rect->vertices[0].position[0] = 0;
    rect->vertices[0].position[1] = 0;
    rect->vertices[1].position[0] = width;
    rect->vertices[1].position[1] = 0;
    rect->vertices[2].position[0] = width;
    rect->vertices[2].position[1] = height;
    rect->vertices[3].position[0] = 0;
    rect->vertices[3].position[1] = height;
    
    rect->vertices[0].colour[0] = 0;
    rect->vertices[0].colour[1] = 0;
    rect->vertices[0].colour[2] = 0;
    rect->vertices[0].colour[3] = 1;
    rect->vertices[1].colour[0] = 0;
    rect->vertices[1].colour[1] = 0;
    rect->vertices[1].colour[2] = 0;
    rect->vertices[1].colour[3] = 1;
    rect->vertices[2].colour[0] = 0;
    rect->vertices[2].colour[1] = 0;
    rect->vertices[2].colour[2] = 0;
    rect->vertices[2].colour[3] = 1;
    rect->vertices[3].colour[0] = 0;
    rect->vertices[3].colour[1] = 0;
    rect->vertices[3].colour[2] = 0;
    rect->vertices[3].colour[3] = 1;
    
    glGenVertexArraysOES(1, &rect->arrayObject);
    glBindVertexArrayOES(rect->arrayObject);
    
    glGenBuffers(1, &rect->vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, rect->vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(rect->vertices), rect->vertices, GL_STATIC_DRAW);
    glGenBuffers(1, &rect->indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, rect->indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(RectIndices), RectIndices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(ColouredVertex), (const GLvoid *) offsetof(ColouredVertex, colour));
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(ColouredVertex), (const GLvoid *) offsetof(ColouredVertex, position));
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    rect->relativeTranslation = GLKVector3Make(0, 0, 0);
    rect->translation = GLKVector3Make(x, y, 0);
    rect->centre = GLKVector3Make(width/2, height/2, 0);
    rect->scale = GLKVector3Make(1, 1, 1);
    rect->relativeRotation = 0;
    rect->rotation = 0;
    
    rect->next = NULL;
    
    return rect;
}

void DFRenderableAddRect(DFRenderableData* data, DFRenderableRect* rect)
{
    if (data == NULL){
        return;
    }
    DFRenderableRect* curr = data->rect;
    if (curr == NULL){
        data->rect = rect;
    } else {
        while (curr->next != NULL){
            curr = curr->next;
        }
        curr->next = rect;
    }
}

void DFRenderableFreeRect(DFRenderableRect* data)
{
    DFRenderableRect* temp;
    DFRenderableRect* curr = data;
    while (curr != NULL){
        temp = curr;
        curr = curr->next;
        free(temp);
    }
}

DFRenderableEllipse* DFRenderableMakeEllipse(GLfloat x, GLfloat y, GLfloat radius)
{
    DFRenderableEllipse *ellipse = (DFRenderableEllipse *)malloc(sizeof(DFRenderableEllipse));
    
    for (int i = 0; i < ELLIPSE_RESOLUTION; i++){
        float theta = ((float)i) / ELLIPSE_RESOLUTION * 2 * M_PI;
        ellipse->vertices[i].position[0] = sin(theta) * radius;
        ellipse->vertices[i].position[1] = cos(theta) * radius;
        ellipse->vertices[i].colour[0] = 0;
        ellipse->vertices[i].colour[1] = 0;
        ellipse->vertices[i].colour[2] = 0;
        ellipse->vertices[i].colour[3] = 1;
    }
    
    glGenVertexArraysOES(1, &ellipse->arrayObject);
    glBindVertexArrayOES(ellipse->arrayObject);
    glGenBuffers(1, &ellipse->vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, ellipse->vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(ellipse->vertices), ellipse->vertices, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(ColouredVertex), (const GLvoid *) offsetof(ColouredVertex, position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(ColouredVertex), (const GLvoid *) offsetof(ColouredVertex, colour));
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    ellipse->relativeTranslation = GLKVector3Make(0, 0, 0);
    ellipse->translation = GLKVector3Make(x, y, 0);
    ellipse->scale = GLKVector3Make(1, 1, 1);
    ellipse->relativeRotation = 0;
    ellipse->rotation = 0.0;
    
    ellipse->next = NULL;
    
    return ellipse;
}

void DFRenderableAddEllipse(DFRenderableData* data, DFRenderableEllipse* ellipse)
{
    if (data == NULL){
        return;
    }
    DFRenderableEllipse* curr = data->ellipse;
    if (curr == NULL){
        data->ellipse = ellipse;
    } else {
        while (curr->next != NULL){
            curr = curr->next;
        }
        curr->next = ellipse;
    }
}

void DFRenderableFreeEllipse(DFRenderableEllipse* data)
{
    DFRenderableEllipse* temp;
    DFRenderableEllipse* curr = data;
    while (curr != NULL){
        temp = curr;
        curr = curr->next;
        free(temp);
    }
}

void DFRenderTexture(DFRenderableTexture* texture, GLKBaseEffect* baseEffect)
{
    baseEffect.useConstantColor = YES;
    baseEffect.constantColor = texture->colour;
    baseEffect.texture2d0.enabled = YES;
    baseEffect.texture2d0.name = texture->name;
    
    GLKMatrix4 centre = GLKMatrix4MakeTranslation(-texture->centre.x, -texture->centre.y, -texture->centre.z);
    GLKMatrix4 scale = GLKMatrix4MakeScale(texture->scale.x, texture->scale.y, texture->scale.z);
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(texture->rotation, 0.0, 0.0, 1.0);
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(texture->translation.x, texture->translation.y, texture->translation.z);
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

void DFRenderRect(DFRenderableRect* rect, GLKBaseEffect* baseEffect)
{
    baseEffect.useConstantColor = NO;
    baseEffect.texture2d0.enabled = NO;
    
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(rect->translation.x, rect->translation.y, 0.0);
    GLKMatrix4 scale = GLKMatrix4MakeScale(rect->scale.x, rect->scale.y, rect->scale.z);
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(rect->rotation, 0.0, 0.0, 1.0);
    GLKMatrix4 centre = GLKMatrix4MakeTranslation(-rect->centre.x, -rect->centre.y, -rect->centre.z);
    GLKMatrix4 modelMatrix = GLKMatrix4Multiply(translation, GLKMatrix4Multiply(scale, GLKMatrix4Multiply(rotation, GLKMatrix4Multiply(centre, GLKMatrix4Identity))));
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

void DFRenderEllipse(DFRenderableEllipse* ellipse, GLKBaseEffect* baseEffect)
{
    baseEffect.useConstantColor = NO;
    baseEffect.texture2d0.enabled = NO;
    
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(ellipse->translation.x, ellipse->translation.y, 0.0);
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

void DFRender(DFRenderableData* data, GLKBaseEffect* baseEffect)
{
    if (data == NULL){
        return;
    }
    GLfloat sinr = sinf(data->rotation);
    GLfloat cosr = cosf(data->rotation);
    GLfloat x = data->translation.x;
    GLfloat y = data->translation.y;
    GLfloat rx;
    GLfloat ry;
    DFRenderableTexture* texture = data->texture;
    while (texture != NULL){
        rx = texture->relativeTranslation.x;
        ry = texture->relativeTranslation.y;
        texture->translation = GLKVector3Make(cosr * (rx) - sinr * (ry) + x, sinr * (rx) + cosr * (ry) + y, 0);
        texture->rotation = data->rotation + texture->relativeRotation;
        DFRenderTexture(texture, baseEffect);
        texture = texture->next;
    }
    DFRenderableRect* rect = data->rect;
    while (rect != NULL){
        rx = rect->relativeTranslation.x;
        ry = rect->relativeTranslation.y;
        rect->translation = GLKVector3Make(cosr * (rx) - sinr * (ry) + x, sinr * (rx) + cosr * (ry) + y, 0);
        rect->rotation = data->rotation + rect->relativeRotation;
        DFRenderRect(rect, baseEffect);
        rect = rect->next;
    }
    DFRenderableEllipse* ellipse = data->ellipse;
    while (ellipse != NULL){
        rx = ellipse->relativeTranslation.x;
        ry = ellipse->relativeTranslation.y;
        ellipse->translation = GLKVector3Make(cosr * (rx) - sinr * (ry) + x, sinr * (rx) + cosr * (ry) + y, 0);
        ellipse->rotation = data->rotation + ellipse->relativeRotation;
        DFRenderEllipse(ellipse, baseEffect);
        ellipse = ellipse->next;
    }
}