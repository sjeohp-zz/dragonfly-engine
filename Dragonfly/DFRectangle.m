//
//  DFRectangle.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFRectangle.h"


DFRectangleData* DFRectangleMake(GLfloat x, GLfloat y, GLfloat width, GLfloat height)
{
    DFRectangleData *rect = (DFRectangleData *)malloc(sizeof(DFRectangleData));
    
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
    
    rect->translation = GLKVector3Make(x, y, 0);
    rect->centre = GLKVector3Make(width/2, height/2, 0);
    rect->scale = GLKVector3Make(1, 1, 1);
    rect->rotation = 0;
    
    rect->next = NULL;
    
    return rect;
}

void DFRectangleFree(DFRectangleData* data)
{
    DFRectangleData* temp;
    DFRectangleData* curr = data;
    while (curr != NULL){
        temp = curr;
        curr = curr->next;
        free(temp);
    }
}