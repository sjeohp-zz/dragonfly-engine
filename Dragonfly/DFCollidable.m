//
//  DFCollidable.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFCollidable.h"

DFPoint closestPoint;

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

GLfloat sqrf(GLfloat x) { return x * x; }

GLfloat dist_sqrdf(DFPoint v, DFPoint w) { return sqrf(v.x - w.x) + sqrf(v.y - w.y); }

GLfloat distanceFromLineToPoint(DFLine line, DFPoint p)
{
    GLfloat length_squared = dist_sqrdf(line.A, line.B);
    if (length_squared == 0) return dist_sqrdf(line.A, p);
    GLfloat t = ((p.x - line.A.x) * (line.B.x - line.A.x) + (p.y - line.A.y) * (line.B.y - line.A.y)) / length_squared;
    if (t < 0) return dist_sqrdf(line.A, p);
    if (t > 1) return dist_sqrdf(line.B, p);
    closestPoint.x = line.A.x + t * (line.B.x - line.A.x);
    closestPoint.y = line.A.y + t * (line.B.y - line.A.y);
    return sqrtf(dist_sqrdf(closestPoint, p));
}

GLuint DFCollidableDistanceFromRectToCirc(DFCollidableData* rect, DFCollidableData* circ)
{
    DFPoint p = {
        circ->x,
        circ->y
    };
    GLuint x = rect->x;
    GLuint y = rect->y;
    GLuint w = rect->width/2;
    GLuint h = rect->height/2;
    DFLine lines[] = {
        {x - w, y - h},
        {x + w, y - h},
        {x + w, y + h},
        {x - w, y + h}
    };
    GLuint distance = -1;
    GLuint d;
    for (int i = 0; i < 4; i++){
        d = distanceFromLineToPoint(lines[i], p);
        if (d < distance){
            distance = d;
            rect->collisionPoint = closestPoint;
        }
    }
    return distance;
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

    for (int i = 0; i < 4; i++){
        for (int j = 0; j < 4; j++){
            if (((cornersB[j].x < cornersA[i].x && cornersB[j].x > A->x) ||
                 (cornersB[j].x > cornersA[i].x && cornersB[j].x < A->x)) &&
                ((cornersB[j].y < cornersA[i].y && cornersB[j].y > A->y) ||
                 (cornersB[j].y > cornersA[i].y && cornersB[j].y < A->y))) {
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