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
    collidable->position.x = x;
    collidable->position.y = y;
    collidable->width = width;
    collidable->height = height;
    collidable->radius = -1;
    collidable->physics = NO;
    return collidable;
}

DFCollidableData*   DFCollidableMakeCirc(GLfloat x, GLfloat y, GLfloat radius)
{
    DFCollidableData* collidable = (DFCollidableData*)malloc(sizeof(DFCollidableData));
    collidable->position.x = x;
    collidable->position.y = y;
    collidable->width = -1;
    collidable->height = -1;
    collidable->radius = radius;
    collidable->physics = NO;
    return collidable;
}

void DFCollidableAddPhysics(DFCollidableData* collidable, GLfloat mass, GLfloat elasticity)
{
    collidable->physics = YES;
    collidable->mass = mass;
    collidable->elasticity = elasticity;
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
        circ->position.x,
        circ->position.y
    };
    GLuint x = rect->position.x;
    GLuint y = rect->position.y;
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
            if (rect->physics){
                rect->collisionPoint = closestPoint;
            }
        }
    }
    return distance;
}

BOOL DFCollidableCheckCollisionBetweenCircAndCirc(DFCollidableData* A, DFCollidableData* B)
{
    return DISTANCE_BETWEEN(A->position.x, A->position.y, B->position.x, B->position.y) < A->radius + B->radius;
}

BOOL DFCollidableCheckCollisionBetweenRectAndCirc(DFCollidableData* rect, DFCollidableData* circ)
{
    return DISTANCE_BETWEEN(rect->position.x, rect->position.y, circ->position.x, circ->position.y) < DFCollidableDistanceFromRectToCirc(rect, circ);
}

BOOL DFCollidableCheckCollisionBetweenRectAndRect(DFCollidableData* A, DFCollidableData* B)
{
    DFPoint cornersA[] = {
        {A->position.x - A->width/2, A->position.y - A->height/2},
        {A->position.x + A->width/2, A->position.y - A->height/2},
        {A->position.x + A->width/2, A->position.y + A->height/2},
        {A->position.x - A->width/2, A->position.y + A->height/2}
    };
    
    DFPoint cornersB[] = {
        {B->position.x - B->width/2, B->position.y - B->height/2},
        {B->position.x + B->width/2, B->position.y - B->height/2},
        {B->position.x + B->width/2, B->position.y + B->height/2},
        {B->position.x - B->width/2, B->position.y + B->height/2}
    };

    for (int i = 0; i < 4; i++){
        for (int j = 0; j < 4; j++){
            if (((cornersB[j].x < cornersA[i].x && cornersB[j].x > A->position.x) ||
                 (cornersB[j].x > cornersA[i].x && cornersB[j].x < A->position.x)) &&
                ((cornersB[j].y < cornersA[i].y && cornersB[j].y > A->position.y) ||
                 (cornersB[j].y > cornersA[i].y && cornersB[j].y < A->position.y))) {
                    return YES;
                }
        }
    }
    return NO;
}

void DFCollidablePhysics(DFCollidableData* objectA, DFCollidableData* objectB)
{
    if (objectA->radius != -1){
        if (objectB->radius != -1){
            GLKVector3 difference = GLKVector3Subtract(objectB->position, objectA->position);
            
            GLKVector3 Vi1 = GLKVector3Project(objectA->velocity, difference);
            GLKVector3 Vi2 = GLKVector3Project(objectB->velocity, difference);
            
            GLfloat M1 = objectA->mass;
            GLfloat M2 = objectB->mass;
            
            GLfloat mcalc1 = (M1 - M2)/(M1 + M2);
            GLKVector3 Vi1mult = GLKVector3MultiplyScalar(Vi1, mcalc1);
            GLfloat mcalc2 = (2 * M2)/(M1 + M2);
            GLKVector3 Vi2mult = GLKVector3MultiplyScalar(Vi2, mcalc2);
            GLKVector3 Vf1 = GLKVector3Add(Vi1mult, Vi2mult);
            GLKVector3 dV = GLKVector3Subtract(Vf1, Vi1);
            
            GLfloat e1 = objectA->elasticity;
            GLfloat e2 = objectB->elasticity;
            GLfloat calc = e1 * e2;
            GLKVector3 cV = GLKVector3MultiplyScalar(dV, calc);
            
            GLKVector3 currcV = objectA->velocity;
            GLKVector3 newcV = GLKVector3Add(currcV, cV);
            
            objectA->velocity = newcV;
            
            objectA->didCollide = YES;
        } else {
            
            //circle vs rectangle
        }
    } else {
        if (objectB->radius != -1){
            
            //rectangle vs circle
        } else {
            
            //rectangle vs rectangle
        }
    }
}

void DFCollidableCollisionBetween(DFCollidableData* objA, DFCollidableData* objB)
{
    if (objA->physics && objB->physics){
        DFCollidablePhysics(objA, objB);
    }
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