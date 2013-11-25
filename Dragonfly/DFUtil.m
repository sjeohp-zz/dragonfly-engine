//
//  DFUtil.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFUtil.h"

GLfloat sqrf(GLfloat x) { return x * x; }

GLfloat dist_sqrdf(DFPoint v, DFPoint w) { return sqrf(v.x - w.x) + sqrf(v.y - w.y); }

GLfloat dist_lineToPoint_sqrdf(DFLine line, DFPoint p)
{
    GLfloat length_squared = dist_sqrdf(line.A, line.B);
    if (length_squared == 0) return dist_sqrdf(line.A, p);
    GLfloat t = ((p.x - line.A.x) * (line.B.x - line.A.x) + (p.y - line.A.y) * (line.B.y - line.A.y)) / length_squared;
    if (t < 0) return dist_sqrdf(line.A, p);
    if (t > 1) return dist_sqrdf(line.B, p);
    DFPoint closestPoint = {
        line.A.x + t * (line.B.x - line.A.x),
        line.A.y + t * (line.B.y - line.A.y)
    };
    return dist_sqrdf(closestPoint, p);
}

GLfloat DFDistanceFromLineToPoint(DFLine line, DFPoint p)
{
    return sqrtf(dist_lineToPoint_sqrdf(line, p));
}

DFVector3   DFVector3Make(GLfloat x, GLfloat y, GLfloat z)
{
    DFVector3 vector = {x, y, z};
    return vector;
}

DFVector4   DFVector4Make(GLfloat x, GLfloat y, GLfloat z, GLfloat a)
{
    DFVector4 vector = {x, y, z, a};
    return vector;
}