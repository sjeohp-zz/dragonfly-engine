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
    collidable->translationalForce = GLKVector3Make(0, 0, 0);
    
    collidable->rotation = 0;
    collidable->rotationalVelocity = 0;
    collidable->rotationalForce = 0;
    
    collidable->restitution = 1;
    
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
    collidable->translationalForce = GLKVector3Make(0, 0, 0);
    
    collidable->rotation = 0;
    collidable->rotationalVelocity = 0;
    collidable->rotationalForce = 0;
    
    collidable->radius = radius;
    collidable->width = -1;
    collidable->height = -1;
    
    collidable->didCollide = NO;
    
    return collidable;
}

GLfloat sqrf(GLfloat x) { return x * x; }

GLfloat dist_sqrdf(GLKVector3 v, GLKVector3 w) { return sqrf(v.x - w.x) + sqrf(v.y - w.y); }

GLfloat distanceFromLineToPoint(DFLine line, GLKVector3 p, GLKVector3* closestPoint)
{
    GLfloat length_squared = dist_sqrdf(line.A, line.B);
    if (length_squared == 0) return dist_sqrdf(p, line.A);
    GLfloat t = ((p.x - line.A.x) * (line.B.x - line.A.x) + (p.y - line.A.y) * (line.B.y - line.A.y)) / length_squared;
    if (t < 0) {
        *closestPoint = line.A;
        return sqrtf(dist_sqrdf(p, line.A));
    }
    if (t > 1){
        *closestPoint = line.B;
        return sqrtf(dist_sqrdf(p, line.B));
    }
    *closestPoint = GLKVector3Make(line.A.x + t * (line.B.x - line.A.x),
                                   line.A.y + t * (line.B.y - line.A.y),
                                   0);
    return sqrtf(dist_sqrdf(p, *closestPoint));
}

GLuint DFCollidableDistanceFromRectToCirc(DFCollidableData* rect, DFCollidableData* circ, GLKVector3* closestPoint, GLuint* faceIndex)
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
        GLKVector3 c = GLKVector3Make(0, 0, 0);
        d = distanceFromLineToPoint(lines[i], circ->translation, &c);
        if (d < distance){
            distance = d;
            *closestPoint = c;
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

BOOL DFGeometryPolygonContainsPoint(GLushort numVertices, GLKVector3* polygonVertices, GLKVector3 point)
{
    GLfloat vertx[numVertices];
    GLfloat verty[numVertices];
    for (int i = 0; i < numVertices; i++){
        vertx[i] = polygonVertices[i].x;
        verty[i] = polygonVertices[i].y;
    }
    return pnpoly(numVertices, vertx, verty, point.x, point.y);
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

GLfloat DFGeometryPenetrationDistance(GLushort* faceIndex, GLKVector3* supportPoint, DFCollidableData* A, DFCollidableData* B)
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
            *supportPoint = s;
        }
    }
    *faceIndex = bestIndex;
    return bestDistance;
}

void resolvePolygonVsCircle(DFCollidableData* A, DFCollidableData* B, GLKVector3 supportPoint, GLuint faceIndex)
{
    GLKVector3 n = GLKVector3Normalize(GLKVector3Subtract(B->translation, supportPoint));
    
    //GLKVector3 pointVelocity = GLKVector3Add(B->translationalVelocity, GLKVector3MultiplyScalar(GLKVector3Subtract(B->translation, supportPoint), tanf(B->rotationalVelocity)));
    
    // Calculate relative velocity
    GLKVector3 rv = GLKVector3Subtract(B->translationalVelocity, A->translationalVelocity);
    
    // Calculate relative velocity in terms of the normal direction
    GLfloat velAlongNormal = GLKVector3DotProduct( rv, n );
    
    // Do not resolve if velocities are separating
    if(velAlongNormal > 0)
        return;
    
    // Calculate restitution
    GLfloat e = A->restitution * B->restitution;
    
    // Calculate impulse scalar
    GLfloat j = -(e + 1) * velAlongNormal;
    //j /= (1 / A->translationalInertia + 1 / B->translationalInertia);
    
    // Apply impulse
    GLKVector3 impulseB = GLKVector3MultiplyScalar(n, j * (A->translationalInertia / (A->translationalInertia + B->translationalInertia)));
    
    GLKVector3 impulseA = GLKVector3MultiplyScalar(GLKVector3Negate(n), j * (B->translationalInertia / (B->translationalInertia + A->translationalInertia)));
    GLKVector3 hA = GLKVector3Subtract(A->translation, supportPoint);
    
    GLKVector3 tIA = GLKVector3MultiplyScalar(impulseA, GLKVector3DotProduct(GLKVector3Normalize(hA), GLKVector3Normalize(impulseA)));
    GLfloat rIA = (-GLKVector3CrossProduct(GLKVector3Normalize(hA), GLKVector3Normalize(impulseA)).z) * GLKVector3Length(impulseA) / GLKVector3Length(hA);
    
    A->translationalVelocity = GLKVector3Add(A->translationalVelocity, GLKVector3MultiplyScalar(tIA, 1));// / A->translationalInertia));
    A->rotationalVelocity = A->rotationalVelocity + rIA ;/// A->rotationalInertia;
    
    GLKVector3 hB = GLKVector3Subtract(B->translation, supportPoint);
    
    GLKVector3 tIB = GLKVector3MultiplyScalar(impulseB, GLKVector3DotProduct(GLKVector3Normalize(hB), GLKVector3Normalize(impulseB)));
    GLfloat rIB = (-GLKVector3CrossProduct(GLKVector3Normalize(hB), GLKVector3Normalize(impulseB)).z) * GLKVector3Length(impulseB) / GLKVector3Length(hB);
    
    B->translationalVelocity = GLKVector3Add(B->translationalVelocity, GLKVector3MultiplyScalar(tIB, 1 ));
    B->rotationalVelocity = B->rotationalVelocity + rIB;
}

/*
 Rigid body physics between two oriented polygons.
 Needs tidying up.
 Needs to take rotational velocity at point of contact into account.
 Needs circle vs polygon.
 */
void resolvePolygonVsPolygon(DFCollidableData* A, DFCollidableData* B, GLushort faceIndex, GLfloat pD, GLKVector3 supportPoint)
{
    GLKVector3 n = A->normals[faceIndex];
    
    //GLKVector3 pointVelocity = GLKVector3Add(B->translationalVelocity, GLKVector3MultiplyScalar(GLKVector3Subtract(B->translation, supportPoint), tanf(B->rotationalVelocity)));
    
    // Calculate relative velocity
    GLKVector3 rv = GLKVector3Subtract(B->translationalVelocity, A->translationalVelocity);
    
    n = GLKVector3MultiplyScalar(GLKVector3Normalize(n), 1);//GLKVector3Length(rv));
    
    // Calculate relative velocity in terms of the normal direction
    GLfloat velAlongNormal = GLKVector3DotProduct( rv, n );
    
    // Do not resolve if velocities are separating
    if(velAlongNormal > 0)
        return;
    
    // Calculate restitution
    GLfloat e = A->restitution * B->restitution;
    
    // Calculate impulse scalar
    GLfloat j = -(e + 1) * velAlongNormal;
    //j /= (1 / A->translationalInertia + 1 / B->translationalInertia);
    
    // Apply impulse
    GLKVector3 impulse = GLKVector3MultiplyScalar(n, j * (A->translationalInertia / (A->translationalInertia + B->translationalInertia)));
    
    GLKVector3 impulseA = GLKVector3MultiplyScalar(GLKVector3Negate(n), j * (B->translationalInertia / (B->translationalInertia + A->translationalInertia)));
    GLKVector3 hA = GLKVector3Subtract(A->translation, supportPoint);
    
    GLKVector3 tIA = GLKVector3MultiplyScalar(impulseA, GLKVector3DotProduct(GLKVector3Normalize(hA), GLKVector3Normalize(impulseA)));
    GLfloat rIA = (-GLKVector3CrossProduct(GLKVector3Normalize(hA), GLKVector3Normalize(impulseA)).z) * GLKVector3Length(impulseA) / GLKVector3Length(hA);
    
    A->translationalVelocity = GLKVector3Add(A->translationalVelocity, GLKVector3MultiplyScalar(tIA, 1));// / A->translationalInertia));
    A->rotationalVelocity = A->rotationalVelocity + rIA ;/// A->rotationalInertia;
    
    GLKVector3 hB = GLKVector3Subtract(B->translation, supportPoint);
    
    GLKVector3 tIB = GLKVector3MultiplyScalar(impulse, GLKVector3DotProduct(GLKVector3Normalize(hB), GLKVector3Normalize(impulse)));
    GLfloat rIB = (-GLKVector3CrossProduct(GLKVector3Normalize(hB), GLKVector3Normalize(impulse)).z) * GLKVector3Length(impulse) / GLKVector3Length(hB);
    
    B->translationalVelocity = GLKVector3Add(B->translationalVelocity, GLKVector3MultiplyScalar(tIB, 1 ));
    B->rotationalVelocity = B->rotationalVelocity + rIB ;
}

BOOL DFCollidableCheckCollisionBetweenCircAndCirc(DFCollidableData* A, DFCollidableData* B)
{
    return DISTANCE_BETWEEN(A->translation.x, A->translation.y, B->translation.x, B->translation.y) < A->radius + B->radius;
}

BOOL DFCollidableCheckCollisionBetweenRectAndCirc(DFCollidableData* rect, DFCollidableData* circ)
{
    GLKVector3 contact;
    GLuint faceIndex;
    // DFGeometryPolygonContainsPoint(rect->numberOfVertices, rect->vertices, circ->translation) ||
    
    if (DFCollidableDistanceFromRectToCirc(rect, circ, &contact, &faceIndex) <= circ->radius){
        resolvePolygonVsCircle(rect, circ, contact, faceIndex);
        return YES;
    }
    return NO;
}

/*
 Needs to check object is physical before resolving.
 Collidables need function pointers for custom collision behaviour.
 */
BOOL DFCollidableCheckCollisionBetweenRectAndRect(DFCollidableData* A, DFCollidableData* B)
{
    GLushort fI1 = USHRT_MAX;
    GLushort fI2 = USHRT_MAX;
    GLKVector3 s1;
    GLKVector3 s2;
    //polyVSpoly(A, B);
    
    GLfloat d1 = DFGeometryPenetrationDistance(&fI1, &s1, A, B);
    GLfloat d2 = DFGeometryPenetrationDistance(&fI2, &s2, B, A);
    
    if (!(d1 > 0 || d2 > 0)){
        if (d1 > d2){
            A->didCollide = YES;
            B->didCollide = YES;
            resolvePolygonVsPolygon(A, B, fI1, d1, s1);
        } else {
            A->didCollide = YES;
            B->didCollide = YES;
            resolvePolygonVsPolygon(B, A, fI2, d2, s2);
        }
        return YES;
    }
    return NO;
    
}

void DFCollidableTransformVertices(DFCollidableData* collidable)
{
    if (collidable->radius != -1){
        return;
    }
    
    GLfloat r = collidable->rotation;
    GLfloat sinr = sinf(r);
    GLfloat cosr = cosf(r);
    GLfloat x = collidable->translation.x;
    GLfloat y = collidable->translation.y;
    GLfloat w = collidable->width/2.0;
    GLfloat h = collidable->height/2.0;
    
    collidable->vertices[0] = GLKVector3Make(cosr * (-w) -  sinr * (-h) + x,
                                             sinr * (-w) +  cosr * (-h) + y, 0);
    collidable->vertices[1] = GLKVector3Make(cosr * (w)  -  sinr * (-h) + x,
                                             sinr * (w)  +  cosr * (-h) + y, 0);
    collidable->vertices[2] = GLKVector3Make(cosr * (w)  -  sinr * (h) + x,
                                             sinr * (w)  +  cosr * (h) + y, 0);
    collidable->vertices[3] = GLKVector3Make(cosr * (-w) -  sinr * (h) + x,
                                             sinr * (-w) +  cosr * (h) + y, 0);
    
    collidable->normals[0] = DFGeometryNormal(collidable->vertices[0], collidable->vertices[1]);
    collidable->normals[1] = DFGeometryNormal(collidable->vertices[1], collidable->vertices[2]);
    collidable->normals[2] = DFGeometryNormal(collidable->vertices[2], collidable->vertices[3]);
    collidable->normals[3] = DFGeometryNormal(collidable->vertices[3], collidable->vertices[0]);
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