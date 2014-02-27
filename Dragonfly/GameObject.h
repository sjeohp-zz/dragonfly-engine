//
//  GameObject.h
//  Dragonfly
//
//  Created by Joseph on 24/02/14.
//  Copyright (c) 2014 Joseph Mark. All rights reserved.
//

#ifndef __Dragonfly__GameObject__
#define __Dragonfly__GameObject__

#include <vector>
#include <GLKit/GLKit.h>

#import "DFUtil.h"

class PhysicsBody
{
    friend class PhysicsComponent;
private:
    bool isCircle_;
    GLuint radius_;
    GLuint nvert_;
    GLfloat* vertx_;
    GLfloat* verty_;
    GLfloat* normx_;
    GLfloat* normy_;
    GLfloat restitution_;
    GLfloat inertia_;
protected:
    PhysicsBody()
    : isCircle_(false)
    {}
    
    PhysicsBody(GLuint radius)
    : radius_(radius), isCircle_(true)
    {}
    
    PhysicsBody(GLfloat* vertx, GLfloat* verty)
    : vertx_(vertx), verty_(verty), isCircle_(false)
    {}
    
    // Sets vertices and normals
    void setVertices(GLuint nvert, GLfloat* vertx, GLfloat* verty)
    {
        nvert_ = nvert;
        vertx_ = vertx;
        verty_ = verty;
        GLuint i = 0;
        while (i < nvert - 3){
            normx_[i] = verty[i+1] - verty[i];
            normy_[i] = -vertx[i+1] + vertx[i];
            normx_[i+1] = verty[i+2] - verty[i+1];
            normy_[i+1] = -vertx[i+2] + vertx[i+1];
            normx_[i+2] = verty[i+3] - verty[i+2];
            normy_[i+2] = -vertx[i+3] + vertx[i+2];
            i += 3;
        }
        while (i < nvert - 1){
            normx_[i] = verty[i+1] - verty[i];
            normy_[i] = -vertx[i+1] + vertx[i];
            ++i;
        }
        normx_[nvert-1] = verty[nvert-1] - verty[0];
        normy_[nvert-1] = -vertx[nvert-1] + vertx[0];
    }
    
    // Translates and rotates vertices and normals
    void transformVertices(GLKVector2 position, GLfloat angle)
    {
        if (isCircle()){ return; }
        GLfloat r = angle;
        GLfloat sinr = sinf(r);
        GLfloat cosr = cosf(r);
        GLfloat x = position.x;
        GLfloat y = position.y;
        GLfloat a;
        GLfloat vx[nvert_];
        GLfloat vy[nvert_];
        for (int i = 0; i < nvert_; ++i){
            a = GLKVector2Length(GLKVector2Subtract(GLKVector2Make(vertx_[i], verty_[i]), position));
            vx[i] = -cosr * a + x;
            vy[i] = -sinr * a + y;
        }
        setVertices(nvert_, vx, vy);
    }
public:
    bool isCircle() const { return isCircle_; }
    GLuint radius() const { return radius_; }
    GLuint nvert() const { return nvert_; }
    GLfloat* vertx() const { return vertx_; }
    GLfloat* verty() const { return verty_; }
    GLfloat* normx() const { return normx_; }
    GLfloat* normy() const { return normy_; }
    GLfloat restitution() const { return restitution_; }
    GLfloat inertia() const { return inertia_; }
};

class PhysicsComponent
{
private:
    GLKVector2 position_;
    GLKVector2 velocity_;
    GLfloat angle_;
    GLfloat angularVelocity_;
    PhysicsBody body_;
    GLKVector2 impulseVelocity_;
    GLfloat impulseAngVelocity_;
public:
    PhysicsComponent(GLKVector2 position, GLKVector2 velocity, GLfloat angle, GLuint radius)
    : position_(position), velocity_(velocity), angle_(angle), body_(radius), impulseVelocity_(GLKVector2Make(0, 0)), impulseAngVelocity_(0)
    {}
    
    PhysicsComponent(GLKVector2 position, GLKVector2 velocity, GLfloat angle, float* vertx, float* verty)
    : position_(position), velocity_(velocity), angle_(angle), body_(vertx, verty), impulseVelocity_(GLKVector2Make(0, 0)), impulseAngVelocity_(0)
    {}
    
    PhysicsComponent(GLKVector2 position, GLKVector2 velocity, GLfloat angle, GLuint width, GLuint height)
    : position_(position), velocity_(velocity), angle_(angle), body_(), impulseVelocity_(GLKVector2Make(0, 0)), impulseAngVelocity_(0)
    {
        float vertx[4], verty[4];
        vertx[0] = position.x - width/2.0;
        verty[0] = position.y - height/2.0;
        vertx[1] = position.x + width/2.0;
        verty[1] = position.y - height/2.0;
        vertx[2] = position.x + width/2.0;
        verty[2] = position.y + height/2.0;
        vertx[3] = position.x - width/2.0;
        verty[3] = position.y + height/2.0;
        body_.setVertices(4, vertx, verty);
    }
    
    GLKVector2 position() const { return position_; }
    GLKVector2 velocity() const { return velocity_; }
    GLfloat angle() const { return angle_; }
    GLfloat angularVelocity() const { return angularVelocity_; }
    PhysicsBody body() const { return body_; }
    
    // To be called per collision that needs resolving
    void addImpulse(GLKVector2 v) { impulseVelocity_ = GLKVector2Add(impulseVelocity_, v); }
    void addAngImpulse(GLfloat a) { impulseAngVelocity_ += a; }
    
    // To be called before applying velocity
    void applyImpulse()
    {
        velocity_ = GLKVector2Add(velocity_, impulseVelocity_);
        angularVelocity_ += impulseAngVelocity_;
    }
    
    // Updates position and orientation
    void applyVelocity(GLfloat dT)
    {
        position_ = GLKVector2Add(position_, GLKVector2MultiplyScalar(velocity_, dT));
        angle_ += angularVelocity_ * dT;
        body_.transformVertices(position_, angle_);
    }
};

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

class RenderableComponent
{
    struct TexturedVertex
    {
        GLfloat geometryVertex[2];
        GLfloat textureVertex[2];
    };
private:
    GLKVector2 centre_;
    GLKVector2 scale_;
    GLKVector2 translation_;
    GLfloat angle_;
    GLKVector4 colour_;
    GLuint name_;
    GLuint width_;
    GLuint height_;
    GLuint arrayObject_;
    GLuint vertexBuffer_;
    TexturedVertex vertices_[4];
public:
    RenderableComponent(GLKVector2 scale,
                        GLKVector2 translation,
                        GLfloat angle,
                        GLKVector4 colour,
                        NSString* fileName)
    : scale_(scale), translation_(translation), angle_(angle), colour_(colour)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
        NSError *error;
        
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
        if (textureInfo == nil) {
            NSLog(@"Error loading file: %@", [error localizedDescription]);
        }
        
        name_ = textureInfo.name;
        width_ = textureInfo.width;
        height_ = textureInfo.height;
        centre_ = GLKVector2Make(width_/2.0, height_/2.0);
        vertices_[0].geometryVertex[0] = 0;
        vertices_[0].geometryVertex[1] = 0;
        vertices_[1].geometryVertex[0] = width_;
        vertices_[1].geometryVertex[1] = 0;
        vertices_[2].geometryVertex[0] = 0;
        vertices_[2].geometryVertex[1] = height_;
        vertices_[3].geometryVertex[0] = width_;
        vertices_[3].geometryVertex[1] = height_;
        vertices_[0].textureVertex[0] = 0;
        vertices_[0].textureVertex[1] = 0;
        vertices_[1].textureVertex[0] = 1;
        vertices_[1].textureVertex[1] = 0;
        vertices_[2].textureVertex[0] = 0;
        vertices_[2].textureVertex[1] = 1;
        vertices_[3].textureVertex[0] = 1;
        vertices_[3].textureVertex[1] = 1;
        
        glGenVertexArraysOES(1, &arrayObject_);
        glBindVertexArrayOES(arrayObject_);
        glGenBuffers(1, &vertexBuffer_);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer_);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices_), vertices_, GL_DYNAMIC_DRAW);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (const GLvoid *) offsetof(TexturedVertex, textureVertex));
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (const GLvoid *) offsetof(TexturedVertex, geometryVertex));
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
        glDisableVertexAttribArray(GLKVertexAttribPosition);
        glBindVertexArrayOES(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
    
    GLuint name() const { return name_; }
    GLKVector4 colour() const { return colour_; }
    GLuint arrayObject() const { return arrayObject_; }
    
    void addTranslation(GLKVector2 t) { translation_ = GLKVector2Add(translation_, t); }
    void addAngle(GLfloat a) { angle_ = angle_ + a; }
    
    GLKMatrix4 modelview() const {
        GLKMatrix4 c = GLKMatrix4MakeTranslation(-centre_.x, -centre_.y, 0);
        GLKMatrix4 s = GLKMatrix4MakeScale(scale_.x, scale_.y, 1);
        GLKMatrix4 r = GLKMatrix4MakeRotation(angle_, 0, 0, 1);
        GLKMatrix4 t = GLKMatrix4MakeTranslation(translation_.x, translation_.y, 0);
        return GLKMatrix4Multiply(t, GLKMatrix4Multiply(r, GLKMatrix4Multiply(s, GLKMatrix4Multiply(c, GLKMatrix4Identity))));
    }
};

void render(GLKBaseEffect* baseEffect, std::vector<RenderableComponent> v)
{
    baseEffect.useConstantColor = YES;
    baseEffect.texture2d0.enabled = YES;
    for (std::vector<RenderableComponent>::iterator it = v.begin(); it != v.end(); ++it){
        baseEffect.constantColor = it->colour();
        baseEffect.texture2d0.name = it->name();
        baseEffect.transform.modelviewMatrix = it->modelview();
        [baseEffect prepareToDraw];
        glBindVertexArrayOES(it->arrayObject());
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
        glDisableVertexAttribArray(GLKVertexAttribPosition);
        glBindVertexArrayOES(0);
    }
}

class GameObj
{
private:
    PhysicsComponent* physCmpt;
    RenderableComponent* rendCmpt;
public:
    
};

#endif /* defined(__Dragonfly__GameObject__) */
