//
//  DFEllipse.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFEllipse.h"

DFEllipseData* DFEllipseMake(GLfloat x, GLfloat y, GLfloat radius)
{
    DFEllipseData *ellipse = (DFEllipseData *)malloc(sizeof(DFEllipseData));
    
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
    
    ellipse->translation = GLKVector3Make(x, y, 0);
    ellipse->scale = GLKVector3Make(1, 1, 1);
    ellipse->rotation = 0.0;
    ellipse->next = NULL;
    
    return ellipse;
}

void DFEllipseFree(DFEllipseData* data)
{
    DFEllipseData* temp;
    DFEllipseData* curr = data;
    while (curr != NULL){
        temp = curr;
        curr = curr->next;
        free(temp);
    }
}