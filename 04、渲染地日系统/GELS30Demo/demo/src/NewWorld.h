//
//  NewWorld.h
//  demo
//
//  Created by 刘靖煌 on 2024/5/15.
//

#import <Foundation/Foundation.h>

#import <stdio.h>
#import <iostream>

#include "Engine.h"

#include <vector>
#include <memory>

NS_ASSUME_NONNULL_BEGIN

class NewWorld : Object3D {
    
private:
    shared_ptr<Object3D> sunObj;
    shared_ptr<Object3D> earthObj;
    shared_ptr<Object3D> moonObj;
    shared_ptr<Object3D> cubeObj;
    
    float cycleAccumulator = 0.0f;
    
    int width;
    int height;
    
public:
    void Begin();
    
    void LoopOnce(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent);
    
    void End();
    
    
    GLubyte* loadImage(NSString *fileName);
};


NS_ASSUME_NONNULL_END
