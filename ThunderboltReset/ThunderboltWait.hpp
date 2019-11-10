//
//  ThunderboltWait.hpp
//  ThunderboltReset
//
//  Copyright © 2019 osy86. All rights reserved.
//

#ifndef ThunderboltWait_hpp
#define ThunderboltWait_hpp

#include <IOKit/IOService.h>

class ThunderboltWait : public IOService {
    OSDeclareDefaultStructors(ThunderboltWait);
public:
    virtual IOService *probe(IOService *provider, SInt32 *score) override;
};

#endif /* ThunderboltWait_hpp */
