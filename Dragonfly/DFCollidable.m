//
//  DFCollidable.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFCollidable.h"

GLKVector3 closestPoint;

DFCollidableData* DFCollidableMakeRect(GLfloat x, GLfloat y, GLfloat width, GLfloat height)
{
    DFCollidableData* collidable = (DFCollidableData*)malloc(sizeof(DFCollidableData));
    collidable->translation = GLKVector3Make(x, y, 0);
    collidable->translationalVelocity = GLKVector3Make(0, 0, 0);
    collidable->translationalAcceleration = GLKVector3Make(0, 0, 0);
    
    collidable->rotation = 0;
    collidable->rotationalVelocity = 0;
    collidable->rotationalAcceleration = 0;
    
    collidable->radius = -1;
    collidable->width = width;
    collidable->height = height;
    
    collidable->vertices = (GLKVector3*)malloc(sizeof(GLKVector3) * 4);
    collidable->vertices[0] = GLKVector3Make(x - width/2, y - height/2, 0);
    collidable->vertices[1] = GLKVector3Make(x + width/2, y - height/2, 0);
    collidable->vertices[2] = GLKVector3Make(x + width/2, y + height/2, 0);
    collidable->vertices[3] = GLKVector3Make(x - width/2, y + height/2, 0);
    
    collidable->normals = (GLKVector3*)malloc(sizeof(GLKVector3) * 4);
    collidable->normals[0] = DFGeometryNormal(collidable->vertices[0], collidable->vertices[1]);
    collidable->normals[1] = DFGeometryNormal(collidable->vertices[1], collidable->vertices[2]);
    collidable->normals[2] = DFGeometryNormal(collidable->vertices[2], collidable->vertices[3]);
    collidable->normals[3] = DFGeometryNormal(collidable->vertices[3], collidable->vertices[0]);
    
    collidable->numberOfVertices = 4;
    
    collidable->didCollide = NO;
    
    return collidable;
}

DFCollidableData* DFCollidableMakeCirc(GLfloat x, GLfloat y, GLfloat radius)
{
    DFCollidableData* collidable = (DFCollidableData*)malloc(sizeof(DFCollidableData));
    collidable->translation = GLKVector3Make(x, y, 0);
    collidable->translationalVelocity = GLKVector3Make(0, 0, 0);
    collidable->translationalAcceleration = GLKVector3Make(0, 0, 0);
    
    collidable->rotation = 0;
    collidable->rotationalVelocity = 0;
    collidable->rotationalAcceleration = 0;
    
    collidable->radius = radius;
    collidable->width = -1;
    collidable->height = -1;
    
    collidable->didCollide = NO;
    
    return collidable;
}

void DFCollidableAddPhysics(DFCollidableData* collidable, GLfloat mass, GLfloat elasticity)
{
    
}

BOOL rectContainsPoint(DFCollidableData* rect, GLKVector3 point)
{
    for (int i = 0; i < rect->numberOfVertices; i++){
        
    }
    return YES;
}

GLfloat sqrf(GLfloat x) { return x * x; }

GLfloat dist_sqrdf(GLKVector3 v, GLKVector3 w) { return sqrf(v.x - w.x) + sqrf(v.y - w.y); }

GLfloat distanceFromLineToPoint(DFLine line, GLKVector3 p)
{
    GLfloat length_squared = dist_sqrdf(line.A, line.B);
    if (length_squared == 0) return dist_sqrdf(p, line.A);
    GLfloat t = ((p.x - line.A.x) * (line.B.x - line.A.x) + (p.y - line.A.y) * (line.B.y - line.A.y)) / length_squared;
    if (t < 0) return dist_sqrdf(p, line.A);
    if (t > 1) return dist_sqrdf(p, line.B);
    closestPoint = GLKVector3Make(line.A.x + t * (line.B.x - line.A.x),
                                  line.A.y + t * (line.B.y - line.A.y),
                                  0);
    return sqrtf(dist_sqrdf(p, closestPoint));
}

GLuint DFCollidableDistanceFromRectToCirc(GLushort* faceIndex, DFCollidableData* rect, DFCollidableData* circ)
{
    DFLine lines[] = {
        { rect->vertices[0], rect->vertices[1] },
        { rect->vertices[1], rect->vertices[2] },
        { rect->vertices[2], rect->vertices[3] },
        { rect->vertices[3], rect->vertices[0] }
    };
    GLuint distance = -1;
    GLuint d;
    for (int i = 0; i < 4; i++){
        d = distanceFromLineToPoint(lines[i], circ->translation);
        if (d < distance){
            distance = d;
            *faceIndex = i;
        }
    }
    return distance;
}

int pnpoly(int nvert, float *vertx, float *verty, float testx, float testy)
{
    int i, j, c = 0;
    for (i = 0, j = nvert-1; i < nvert; j = i++) {
        if ( ((verty[i]>testy) != (verty[j]>testy)) &&
            (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
            c = !c;
    }
    return c;
}

BOOL rectVsCircle(DFCollidableData* rect, DFCollidableData* circ)
{
    GLushort nvert = rect->numberOfVertices;
    GLfloat vertx[nvert];
    GLfloat verty[nvert];
    for (int i = 0; i < nvert; i++){
        vertx[i] = rect->vertices[i].x;
        verty[i] = rect->vertices[i].y;
    }
    return pnpoly(nvert, vertx, verty, circ->translation.x, circ->translation.y);
}

GLKVector3 DFGeometrySupportPoint(DFCollidableData* collidable, GLKVector3 dir)
{
    GLfloat bestProjection = -FLT_MAX;
    GLKVector3 bestVertex;
    for (int i = 0; i < collidable->numberOfVertices; i++)
    {
        GLKVector3 v = collidable->vertices[i];
        GLfloat projection = GLKVector3DotProduct(v, dir);
        
        if(projection > bestProjection)
        {
            bestVertex = v;
            bestProjection = projection;
        }
    }
    return bestVertex;
}

GLfloat DFGeometryPenetrationDistance(GLushort* faceIndex, DFCollidableData* A, DFCollidableData* B )
{
    GLfloat bestDistance = -FLT_MAX;
    GLushort bestIndex;
    
    for (int i = 0; i < A->numberOfVertices; i++)
    {
        // Retrieve a face normal from A
        GLKVector3 n = A->normals[i];
        
        // Retrieve support point from B along -n
        GLKVector3 s = DFGeometrySupportPoint(B, GLKVector3Negate(n));
        
        // Retrieve vertex on face from A, transform into
        // B's model space
        GLKVector3 v = A->vertices[i];
        
        // Compute penetration distance (in B's model space)
        GLfloat d = GLKVector3DotProduct(n, GLKVector3Subtract(s, v));
        
        // Store greatest distance
        if (d > bestDistance)
        {
            bestDistance = d;
            bestIndex = i;
        }
    }

    *faceIndex = bestIndex;
    return bestDistance;
}

BOOL DFCollidableCheckCollisionBetweenCircAndCirc(DFCollidableData* A, DFCollidableData* B)
{
    return DISTANCE_BETWEEN(A->translation.x, A->translation.y, B->translation.x, B->translation.y) < A->radius + B->radius;
}

BOOL DFCollidableCheckCollisionBetweenRectAndCirc(DFCollidableData* rect, DFCollidableData* circ)
{
    GLushort fI;
    return rectVsCircle(rect, circ) || DFCollidableDistanceFromRectToCirc(&fI, rect, circ) <= circ->radius;
}

BOOL DFCollidableCheckCollisionBetweenRectAndRect(DFCollidableData* A, DFCollidableData* B)
{
    GLushort fI;
    return DFGeometryPenetrationDistance(&fI, A, B) <= 0;
}

/*
void phys()
{
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
}
 */

void DFCollidablePhysics(DFCollidableData* objectA, DFCollidableData* objectB)
{
    if (objectA->radius != -1){
        if (objectB->radius != -1){
            
            //circle vs circle
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
    objA->didCollide = YES;
    objB->didCollide = YES;
}

void DFCollidableFree(DFCollidableData* data)
{
    free(data);
}