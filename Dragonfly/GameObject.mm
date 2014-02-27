//
//  GameObject.m
//  Dragonfly
//
//  Created by Joseph on 24/02/14.
//  Copyright (c) 2014 Joseph Mark. All rights reserved.
//

#import "GameObject.h"
#import "DFUtil.h"

typedef std::shared_ptr<PhysicsComponent> cmpt_ptr;

#pragma mark Physics

// Resolves any collision involving a polygon
// cmptA must be a polygon
void resolve(cmpt_ptr cmptA, cmpt_ptr cmptB, GLushort faceIndex, GLKVector2 supportPoint)
{
    PhysicsBody bodyA = cmptA->body();
    PhysicsBody bodyB = cmptB->body();
    
    // Calculate relative velocity
    GLKVector2 relativeVelocity = GLKVector2Subtract(cmptB->velocity(), cmptA->velocity());
    
    // Get normcmptAl
    GLKVector2 normal = GLKVector2Normalize(GLKVector2Make(cmptA->body().normx()[faceIndex], cmptA->body().normy()[faceIndex]));
    
    // Calculate relative velocity in terms of the normal direction
    GLfloat velAlongNormal = GLKVector2DotProduct(relativeVelocity, normal);
    
    // Do not resolve if velocities are separating
    if(velAlongNormal > 0){ return; }
    
    // Calculate restitution
    GLfloat e = bodyA.restitution() * bodyB.restitution();
    
    // Calculate impulse scalar
    GLfloat j = -(e + 1) * velAlongNormal;
    
    // Calculate total impulse
    GLKVector2 impulseA = GLKVector2MultiplyScalar(GLKVector2Negate(normal), j * (bodyB.inertia() / (bodyB.inertia() + bodyA.inertia())));
    
    // Calculate impulse towards centre of mass
    GLKVector2 hypotA = GLKVector2Subtract(cmptA->position(), supportPoint);
    GLKVector2 translationalImpulseA = GLKVector2MultiplyScalar(impulseA, GLKVector2DotProduct(GLKVector2Normalize(hypotA), GLKVector2Normalize(impulseA)));
    
    // Calculate angular impulse
    GLKVector3 hA = GLKVector3Normalize(GLKVector3Make(hypotA.x, hypotA.y, 0));
    GLKVector3 imA = GLKVector3Normalize(GLKVector3Make(impulseA.x, impulseA.y, 0));
    GLfloat angularImpulseA = -(GLKVector3CrossProduct(hA, imA)).z / GLKVector2Length(impulseA) / GLKVector2Length(hypotA);
    
    // Apply impulse to A
    cmptA->addImpulse(translationalImpulseA);
    cmptA->addAngImpulse(angularImpulseA);
    
    // Calculate total impulse
    GLKVector2 impulseB = GLKVector2MultiplyScalar(normal, j * (bodyA.inertia() / (bodyA.inertia() + bodyB.inertia())));
    
    // Calculate impulse towards centre of mass
    GLKVector2 hypotB = GLKVector2Subtract(cmptB->position(), supportPoint);
    GLKVector2 translationalImpulseB = GLKVector2MultiplyScalar(impulseB, GLKVector2DotProduct(GLKVector2Normalize(hypotB), GLKVector2Normalize(impulseB)));
    
    // Calculate angular impulse
    GLKVector3 hB = GLKVector3Normalize(GLKVector3Make(hypotB.x, hypotB.y, 0));
    GLKVector3 imB = GLKVector3Normalize(GLKVector3Make(impulseB.x, impulseB.y, 0));
    GLfloat angularImpulseB = -(GLKVector3CrossProduct(hB, imB)).z / GLKVector2Length(impulseB) / GLKVector2Length(hypotB);
    
    // Apply impulse to B
    cmptB->addImpulse(translationalImpulseB);
    cmptB->addAngImpulse(angularImpulseB);
}

void resolveCircles(cmpt_ptr a, cmpt_ptr b)
{
    
}

GLKVector2 support_point(cmpt_ptr cmpt, GLKVector2 dir)
{
    GLfloat bestProjection = -FLT_MAX;
    GLKVector2 bestVertex;
    
    for (int i = 0; i < cmpt->body().nvert(); ++i)
    {
        GLKVector2 v = GLKVector2Make(cmpt->body().vertx()[i], cmpt->body().verty()[i]);
        GLfloat projection = GLKVector2DotProduct(v, dir);

        if(projection > bestProjection)
        {
            bestVertex = v;
            bestProjection = projection;
        }
    }
    return bestVertex;
}

GLfloat penetration(cmpt_ptr cmptA, cmpt_ptr cmptB, GLushort* faceIndex, GLKVector2* supportPoint)
{
    GLfloat bestDistance = -FLT_MAX;
    GLushort bestIndex;
    GLKVector2 bestPoint;
    for (int i = 0; i < cmptA->body().nvert(); ++i)
    {
        // Retrieve a face normal from A
        GLKVector2 n = GLKVector2Make(cmptA->body().normx()[i], cmptA->body().normy()[i]);
        
        // Retrieve support point from B along -n
        GLKVector2 s = support_point(cmptB, GLKVector2Negate(n));
        
        // Retrieve vertex on face from A, transform into
        // B's model space
        GLKVector2 v = GLKVector2Make(cmptA->body().vertx()[i], cmptA->body().verty()[i]);
        
        // Compute penetration distance (in B's model space)
        GLfloat d = GLKVector2DotProduct(n, GLKVector2Subtract(s, v));
        
        // Store greatest distance
        if (d > bestDistance)
        {
            bestDistance = d;
            bestIndex = i;
            bestPoint = s;
        }
    }
    *faceIndex = bestIndex;
    *supportPoint = bestPoint;
    return bestDistance;
}

void possibleCollision(cmpt_ptr cmptA, cmpt_ptr cmptB)
{
    PhysicsBody bodyA = cmptA->body();
    PhysicsBody bodyB = cmptB->body();
    
    if (bodyA.isCircle() && bodyB.isCircle()){
        if (DISTANCE_BETWEEN(cmptA->position().x, cmptA->position().y, cmptB->position().x, cmptB->position().y) < bodyA.radius() + bodyB.radius()){
            resolveCircles(cmptA, cmptB);
        }
    } else if (bodyA.isCircle()){
        GLKVector2 supportPoint;
        GLuint faceIndex;
        if (dist_poly_circ(bodyB.nvert(), bodyB.vertx(), bodyB.verty(), cmptA->position().x, cmptA->position().y, &supportPoint, &faceIndex) <= cmptA->body().radius()){
            resolve(cmptB, cmptA, faceIndex, supportPoint);
        }
    } else if (bodyB.isCircle()){
        GLKVector2 supportPoint;
        GLuint faceIndex;
        if (dist_poly_circ(bodyA.nvert(), bodyA.vertx(), bodyA.verty(), cmptB->position().x, cmptB->position().y, &supportPoint, &faceIndex) <= cmptB->body().radius()){
            resolve(cmptA, cmptB, faceIndex, supportPoint);
        }
    } else {
        GLushort faceIndexA = USHRT_MAX;
        GLushort faceIndexB = USHRT_MAX;
        GLKVector2 supportPointA;
        GLKVector2 supportPointB;
        GLfloat d1 = penetration(cmptA, cmptB, &faceIndexA, &supportPointA);
        GLfloat d2 = penetration(cmptB, cmptA, &faceIndexB, &supportPointB);
        
        if (!(d1 > 0 || d2 > 0)){
            if (d1 > d2){
                resolve(cmptA, cmptB, faceIndexA, supportPointA);
            } else {
                resolve(cmptB, cmptA, faceIndexB, supportPointA);
            }
        }
    }
}

#pragma mark Rendering



#pragma mark GameObj

