//
//  DFUtil.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFUtil.h"


bool poly_contains_pnt(int nvert, float *vertx, float *verty, float pntx, float pnty)
{
    int i, j, c = false;
    for (i = 0, j = nvert-1; i < nvert; j = i++) {
        if ( ((verty[i]>pnty) != (verty[j]>pnty)) &&
            (pntx < (vertx[j]-vertx[i]) * (pnty-verty[i]) / (verty[j]-verty[i]) + vertx[i]) ){
            c = !c;
        }
    }
    return c;
}

bool poly_contains_poly(int nverta, float* ax, float* ay, int nvertb, float* bx, float* by)
{
    bool c = true;
    for (int i = 0; i < nvertb; ++i){
        if (!poly_contains_pnt(nverta, ax, ay, bx[i], by[i])){
            c = false;
        }
    }
    return c;
}

float sqrf(float x) { return x * x; }

float dist_sqrdf(float vx, float vy, float wx, float wy)
{
    return sqrf(vx - wx) + sqrf(vy - wy);
}

float dist_line_point(LineSegment line, float px, float py)
{
    float length_squared = dist_sqrdf(line.ax, line.ay, line.bx, line.by);
    if (length_squared == 0) return dist_sqrdf(px, py, line.ax, line.ay);
    float t = ((px - line.ax) * (line.bx - line.ax) + (py - line.ay) * (line.by - line.ay)) / length_squared;
    if (t < 0) {
        return sqrtf(dist_sqrdf(px, py, line.ax, line.ay));
    }
    if (t > 1){
        return sqrtf(dist_sqrdf(px, py, line.bx, line.by));
    }
    float cx = line.ax + t * (line.bx - line.ax);
    float cy = line.ay + t * (line.by - line.ay);
    return sqrtf(dist_sqrdf(px, py, cx, cy));
}

float dist_line_point(LineSegment line, float px, float py, GLKVector2* closestPnt)
{
    float length_squared = dist_sqrdf(line.ax, line.ay, line.bx, line.by);
    if (length_squared == 0) return dist_sqrdf(px, py, line.ax, line.ay);
    float t = ((px - line.ax) * (line.bx - line.ax) + (py - line.ay) * (line.by - line.ay)) / length_squared;
    if (t < 0) {
        *closestPnt = GLKVector2Make(line.ax, line.ay);
        return sqrtf(dist_sqrdf(px, py, line.ax, line.ay));
    }
    if (t > 1){
        *closestPnt = GLKVector2Make(line.bx, line.by);
        return sqrtf(dist_sqrdf(px, py, line.bx, line.by));
    }
    float cx = line.ax + t * (line.bx - line.ax);
    float cy = line.ay + t * (line.by - line.ay);
    *closestPnt = GLKVector2Make(cx, cy);
    return sqrtf(dist_sqrdf(px, py, cx, cy));
}

GLuint dist_poly_circ(int nvert, float* vertx, float* verty, float circx, float circy)
{
    GLuint distance = -1;
    GLuint temp;
    for (int i = 0; i < nvert - 1; ++i){
        temp = dist_line_point(LineSegment(vertx[i], verty[i], vertx[i+1], verty[i+1]), circx, circy);
        if (temp < distance){
            distance = temp;
        }
    }
    temp = dist_line_point(LineSegment(vertx[nvert-1], verty[nvert-1], vertx[0], verty[0]), circx, circy);
    if (temp < distance){
        distance = temp;
    }
    return distance;
}

GLuint dist_poly_circ(int nvert, float* vertx, float* verty, float circx, float circy, GLKVector2* closestPnt, GLuint* faceIndex)
{
    GLuint distance = -1;
    GLuint temp;
    for (int i = 0; i < nvert - 1; ++i){
        GLKVector2 c = GLKVector2Make(0, 0);
        temp = dist_line_point(LineSegment(vertx[i], verty[i], vertx[i+1], verty[i+1]), circx, circy, &c);
        if (temp < distance){
            distance = temp;
            *closestPnt = c;
            *faceIndex = i;
        }
    }
    GLKVector2 c = GLKVector2Make(0, 0);
    temp = dist_line_point(LineSegment(vertx[nvert-1], verty[nvert-1], vertx[0], verty[0]), circx, circy, &c);
    if (temp < distance){
        distance = temp;
        *closestPnt = c;
        *faceIndex = nvert-1;
    }
    return distance;
}