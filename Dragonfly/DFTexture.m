//
//  DFTexture.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFTexture.h"

DFTextureData* DFTextureLoad(NSString *fileName)
{
    NSString        *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSDictionary    *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
    NSError         *error;
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (textureInfo == nil) {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    }
    
    DFTextureData *texture = (DFTextureData *)malloc(sizeof(DFTextureData));
    
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
    
    texture->position = GLKVector3Make(0, 0, 0);
    texture->centre = GLKVector3Make(texture->width/2, texture->height/2, 0);
    texture->scale = GLKVector3Make(1, 1, 1);
    texture->colour = GLKVector4Make(1, 1, 1, 1);
    texture->rotation = 0;
    
    texture->next = NULL;
    
    return texture;
}