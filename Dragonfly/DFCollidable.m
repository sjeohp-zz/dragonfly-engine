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

void DFCollidableAddPhysics(DFCollidableData* collidable, GLfloat mass, GLfloat elasticity)
{
    
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

BOOL DFCollidableCheckCollisionBetweenCircAndCirc(DFCollidableData* A, DFCollidableData* B)
{
    return DISTANCE_BETWEEN(A->translation.x, A->translation.y, B->translation.x, B->translation.y) < A->radius + B->radius;
}

BOOL DFCollidableCheckCollisionBetweenRectAndCirc(DFCollidableData* rect, DFCollidableData* circ)
{
    GLushort fI;
    return DFGeometryPolygonContainsPoint(rect->numberOfVertices, rect->vertices, circ->translation) || DFCollidableDistanceFromRectToCirc(&fI, rect, circ) <= circ->radius;
}

void resolveCollision(DFCollidableData* A, DFCollidableData* B, GLushort faceIndex, GLfloat pD, GLKVector3 supportPoint)
{
    
    GLKVector3 n = A->normals[faceIndex];
    
    
    // Calculate relative velocity
    GLKVector3 rv = GLKVector3Subtract(B->translationalVelocity, A->translationalVelocity);
    
    n = GLKVector3MultiplyScalar(GLKVector3Normalize(n), GLKVector3Length(rv));
    
    // Calculate relative velocity in terms of the normal direction
    GLfloat velAlongNormal = GLKVector3DotProduct( rv, n );
    
    // Do not resolve if velocities are separating
    if(velAlongNormal > 0)
        return;
    
    // Calculate restitution
    GLfloat e = A->restitution * B->restitution;
    
    // Calculate impulse scalar
    GLfloat j = -e * velAlongNormal;
    j /= 1 / A->translationalInertia + 1 / B->translationalInertia;
    
    // Apply impulse
    GLKVector3 impulse = GLKVector3MultiplyScalar(n, j);
    
    GLKVector3 impulseA = GLKVector3Negate(impulse);
    GLKVector3 hA = GLKVector3Subtract(A->translation, supportPoint);
    
    GLKVector3 tIA = GLKVector3MultiplyScalar(GLKVector3Normalize(impulseA), GLKVector3DotProduct(hA, impulseA));
    GLfloat rIA = -GLKVector3CrossProduct(hA, impulseA).z;
    
    A->translationalVelocity = GLKVector3Add(A->translationalVelocity, GLKVector3MultiplyScalar(tIA, 1 / A->translationalInertia));
    A->rotationalVelocity = A->rotationalVelocity + rIA / A->rotationalInertia;
    
    GLKVector3 hB = GLKVector3Subtract(B->translation, supportPoint);
    
    GLKVector3 tIB = GLKVector3MultiplyScalar(GLKVector3Normalize(impulse), GLKVector3DotProduct(hB, impulse));
    GLfloat rIB = -GLKVector3CrossProduct(hB, impulse).z;
    
    B->translationalVelocity = GLKVector3Add(B->translationalVelocity, GLKVector3MultiplyScalar(tIB, 1 / B->translationalInertia));
    B->rotationalVelocity = B->rotationalVelocity + rIB / B->rotationalInertia;
    
    
    //GLKVector3 difference = GLKVector3Subtract(objectB->position, objectA->position);
    
    /*
    GLKVector3 Vi2 = GLKVector3Project(A->translationalVelocity, GLKVector3Negate(n));
    GLKVector3 Vi1 = GLKVector3Project(B->translationalVelocity, GLKVector3Negate(n));
    
    GLfloat M1 = B->translationalInertia;
    GLfloat M2 = A->translationalInertia;
    
    GLfloat mcalc1 = (M1 - M2)/(M1 + M2);
    GLKVector3 Vi1mult = GLKVector3MultiplyScalar(Vi1, mcalc1);
    GLfloat mcalc2 = (2 * M2)/(M1 + M2);
    GLKVector3 Vi2mult = GLKVector3MultiplyScalar(Vi2, mcalc2);
    GLKVector3 Vf1 = GLKVector3Add(Vi1mult, Vi2mult);
    GLKVector3 dV = GLKVector3Subtract(Vf1, Vi1);
    
    GLfloat e1 = A->restitution;
    GLfloat e2 = B->restitution;
    GLfloat calc = e1 * e2;
    GLKVector3 cV = GLKVector3MultiplyScalar(dV, calc);
    
    GLKVector3 currcV = A->translationalVelocity;
    GLKVector3 newcV = GLKVector3Add(currcV, cV);
    
    //B->translationalVelocity = GLKVector3MultiplyScalar(GLKVector3Normalize(n), pD);
    //B->translationalForce = cV;
    
    GLfloat vi1 = GLKVector3DotProduct(B->translationalVelocity, GLKVector3MultiplyScalar( GLKVector3Normalize(n), GLKVector3Length((B->translationalVelocity)) ));
    GLfloat vi2 = GLKVector3DotProduct(A->translationalVelocity, GLKVector3MultiplyScalar( GLKVector3Normalize(n), GLKVector3Length((A->translationalVelocity)) ));
    GLfloat m1 = B->translationalInertia;
    GLfloat m2 = A->translationalInertia;
    GLfloat mc1 = (m1 - m2)/(m1 + m2);
    GLfloat mc2 = (2 * m2)/(m1 + m2);
    GLfloat vi1m = vi1 * mc1;
    GLfloat vi2m = vi2 * mc2;
    GLfloat vf1 = vi1m + vi2m;
    GLfloat vf2 = vi2m + vi1m;
    GLfloat dv1 = vf1 - vi1;
    GLfloat dv2 = vf2 - vi2;
    dv1 *= calc;
    dv2 *= calc;
    
    
    GLKVector3 nv1 = GLKVector3MultiplyScalar(GLKVector3Normalize(n), dv1);
    GLKVector3 nv2 = GLKVector3MultiplyScalar(GLKVector3Normalize(n), dv2);
    
    if (!DFGeometryPolygonContainsPoint(A->numberOfVertices, A->vertices, DFGeometrySupportPoint(B, GLKVector3Negate(n)))){
        
        
        //return;
    }
    
    B->translationalForce = nv1;
    A->translationalForce = GLKVector3Negate(nv1);
    //A->translationalForce = nv2;
     */
}


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
            resolveCollision(A, B, fI1, d1, s1);
        } else {
            A->didCollide = YES;
            B->didCollide = YES;
            resolveCollision(B, A, fI2, d2, s2);
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