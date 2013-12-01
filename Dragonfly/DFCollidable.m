//
//  DFCollidable.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFCollidable.h"

DFCollidableData*   DFCollidableMakeRect(GLfloat x, GLfloat y, GLfloat width, GLfloat height)
{
    DFCollidableData* collidable = (DFCollidableData*)malloc(sizeof(DFCollidableData));
    collidable->x = x;
    collidable->y = y;
    collidable->width = width;
    collidable->height = height;
    collidable->radius = -1;
    return collidable;
}

DFCollidableData*   DFCollidableMakeCirc(GLfloat x, GLfloat y, GLfloat radius)
{
    DFCollidableData* collidable = (DFCollidableData*)malloc(sizeof(DFCollidableData));
    collidable->x = x;
    collidable->y = y;
    collidable->width = -1;
    collidable->height = -1;
    collidable->radius = radius;
    return collidable;
}

BOOL DFCollidableCheckCollisionBetweenCircAndCirc(DFCollidableData* A, DFCollidableData* B)
{
    return DISTANCE_BETWEEN(A->x, A->y, B->x, B->y) < A->radius + B->radius;
}

BOOL DFCollidableCheckCollisionBetweenRectAndCirc(DFCollidableData* rect, DFCollidableData* circ)
{
    return DISTANCE_BETWEEN(rect->x, rect->y, circ->x, circ->y) < DFCollidableDistanceFromRectToCirc(rect, circ);
}

BOOL DFCollidableCheckCollisionBetweenRectAndRect(DFCollidableData* A, DFCollidableData* B)
{
    DFPoint cornersA[] = {
        {A->x - A->width/2, A->y - A->height/2},
        {A->x + A->width/2, A->y - A->height/2},
        {A->x + A->width/2, A->y + A->height/2},
        {A->x - A->width/2, A->y + A->height/2}
    };
    
    DFPoint cornersB[] = {
        {B->x - B->width/2, B->y - B->height/2},
        {B->x + B->width/2, B->y - B->height/2},
        {B->x + B->width/2, B->y + B->height/2},
        {B->x - B->width/2, B->y + B->height/2}
    };
    
    DFPoint curr;
    
    for (int i = 0; i < 4; i++){
        curr = cornersA[i];
        for (int i = 0; i < 2; i++){
            if (((cornersB[i].x < curr.x && cornersB[(i + 2) % 4].x > curr.x) ||
                 (cornersB[i].x < curr.x && cornersB[(i + 2) % 4].x > curr.x)) &&
                ((cornersB[i].y < curr.y && cornersB[(i + 2) % 4].y > curr.y) ||
                 (cornersB[i].y > curr.y && cornersB[(i + 2) % 4].y < curr.y))) {
                    return YES;
                }
        }
    }
    return NO;
}

void DFCollidableCollisionBetween(DFCollidableData* objA, DFCollidableData* objB)
{
    
}

void DFCollidableFree(DFCollidableData* data)
{
    DFCollidableData* temp;
    DFCollidableData* curr = data;
    while (curr != NULL){
        temp = curr;
        curr = curr->next;
        free(temp);
    }
}