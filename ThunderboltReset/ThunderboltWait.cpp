//
//  ThunderboltWait.cpp
//  ThunderboltReset
//
//  Copyright © 2019 osy86. All rights reserved.
//

#include "ThunderboltWait.hpp"
#include <IOKit/IOLib.h>

OSDefineMetaClassAndStructors(ThunderboltWait, IOService);

extern volatile bool gIsReady;

IOService *ThunderboltWait::probe(IOService *provider, SInt32 *score) {
    while (!gIsReady) {
        IOLog("ThunderboltWait: patch not ready yet, delaying thread\n");
        IODelay(1000000);
    }
    IOLog("ThunderboltWait: patch completed, returning\n");
    return NULL;
}
