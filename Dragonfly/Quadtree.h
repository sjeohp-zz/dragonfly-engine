//
//  Quadtree.h
//  Dragonfly
//
//  Created by Joseph on 25/02/14.
//  Copyright (c) 2014 Joseph Mark. All rights reserved.
//

#ifndef Dragonfly_Quadtree_h
#define Dragonfly_Quadtree_h

#include <vector>

#include "Physics.h"
#include "Util.h"

typedef std::shared_ptr<PhysicsComponent> cmpt_ptr;

class Quadtree
{
private:
    
    std::vector<Quadtree> quads_;
    float* vertx_;
    float* verty_;
    std::vector<cmpt_ptr> items_;
    
public:
    
    Quadtree() {}
    
    Quadtree(float* vertx,
             float* verty,
             int depth)
    : vertx_(vertx), verty_(verty)
    {
        std::vector<const Quadtree> quads(4);
        if (depth > 0){
            float vx0[4], vy0[4];
            vx0[0] = vertx[0];
            vy0[0] = verty[0];
            vx0[1] = vx0[0];
            vy0[1] = (verty[1] - verty[0]) / 2.0;
            vx0[2] = (vertx[3] - vertx[2]) / 2.0;
            vy0[2] = vy0[1];
            vx0[3] = vx0[2];
            vy0[3] = vy0[0];
            quads_[0] = Quadtree(vx0, vy0, depth-1);
            float vx1[4], vy1[4];
            vx1[0] = vx0[1];
            vy1[0] = vy0[1];
            vx1[1] = vx1[0];
            vy1[1] = verty[1];
            vx1[2] = vx0[2];
            vy1[2] = verty[2];
            vx1[3] = vx0[2];
            vy1[3] = vy1[0];
            quads_[1] = Quadtree(vx1, vy1, depth-1);
            float vx2[4], vy2[4];
            vx2[0] = vx1[3];
            vy2[0] = vy1[3];
            vx2[1] = vx1[2];
            vy2[1] = vy1[2];
            vx2[2] = vertx[2];
            vy2[2] = vy2[1];
            vx2[3] = vx2[2];
            vy2[3] = vy2[0];
            quads_[2] = Quadtree(vx2, vy2, depth-1);
            float vx3[4], vy3[4];
            vx3[0] = vx0[3];
            vy3[0] = vy0[3];
            vx3[1] = vx0[2];
            vy3[1] = vy0[2];
            vx3[2] = vx2[3];
            vy3[2] = vy2[3];
            vx3[3] = vertx[3];
            vy3[3] = verty[3];
            quads_[3] = Quadtree(vx3, vy3, depth-1);
        }
    }
    
    float* vertx() const
    {
        return vertx_;
    }
    
    float* verty() const
    {
        return verty_;
    }
    
    std::vector<cmpt_ptr> items() const
    {
        return items_;
    }
    
    std::vector<Quadtree> quads() const
    {
        return quads_;
    }
    
    void insert(cmpt_ptr item)
    {
        if (quads_.empty()){
            items_.push_back(item);
            return;
        }
        PhysicsBody body = item->body();
        if (body.isCircle()){
            for (int i = 0; i < 4; ++i){
                if (poly_contains_pnt(4, quads_[i].vertx(), quads_[i].verty(), item->position().x, item->position().y)
                    &&
                    dist_poly_circ(4, quads_[i].vertx(), quads_[i].verty(), item->position().x, item->position().y) < body.radius())
                {
                    quads_[i].insert(item);
                    return;
                }
            }
            items_.push_back(item);
            return;
        }
        for (int i = 0; i < 4; ++i){
            if (poly_contains_poly(4, quads_[i].vertx(), quads_[i].verty(), body.nvert(), body.vertx(), body.verty())){
                quads_[i].insert(item);
                return;
            }
        }
        items_.push_back(item);
    }
    
    std::vector<cmpt_ptr> checkCollisions() const
    {
        std::vector<cmpt_ptr> itms;
        if (!quads_.empty()){
            std::vector<cmpt_ptr> quadItms;
            quadItms = quads_[0].checkCollisions();
            for (std::vector<cmpt_ptr>::iterator it = quadItms.begin(); it != quadItms.end(); ++it){
                itms.push_back(*it);
                for (std::vector<cmpt_ptr>::iterator ita = items().begin(); ita != items().end(); ++ita){
                    possibleCollision(*ita, *it);
                }
            }
            quadItms = quads_[1].checkCollisions();
            for (std::vector<cmpt_ptr>::iterator it = quadItms.begin(); it != quadItms.end(); ++it){
                itms.push_back(*it);
                for (std::vector<cmpt_ptr>::iterator ita = items().begin(); ita != items().end(); ++ita){
                    possibleCollision(*ita, *it);
                }
            }
            quadItms = quads_[2].checkCollisions();
            for (std::vector<cmpt_ptr>::iterator it = quadItms.begin(); it != quadItms.end(); ++it){
                itms.push_back(*it);
                for (std::vector<cmpt_ptr>::iterator ita = items().begin(); ita != items().end(); ++ita){
                    possibleCollision(*ita, *it);
                }
            }
            quadItms = quads_[3].checkCollisions();
            for (std::vector<cmpt_ptr>::iterator it = quadItms.begin(); it != quadItms.end(); ++it){
                itms.push_back(*it);
                for (std::vector<cmpt_ptr>::iterator ita = items().begin(); ita != items().end(); ++ita){
                    possibleCollision(*ita, *it);
                }
            }
        }
        u_long s = items_.size();
        for (int i = 0; i < s; ++i){
            for (int j = i; j < s; ++j){
                possibleCollision(items_[i], items_[j]);
                itms.push_back(items_[i]);
                itms.push_back(items_[j]);
            }
        }
        return itms;
    }
};

#endif
