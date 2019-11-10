//
//  kern_start.cpp
//  ThunderboltReset
//
//  Copyright © 2019 osy86. All rights reserved.
//

#include <Headers/plugin_start.hpp>
#include <Headers/kern_api.hpp>

#define MODULE_SHORT "tbr"

// Registers
#define REG_FW_STS            0x39944
#define REG_FW_STS_ICM_EN_INVERT    (1 << 1)
#define REG_FW_STS_ICM_EN        (1 << 0)

// Paths
static const char *pathThunderboltNHI[]        { "/System/Library/Extensions/AppleThunderboltNHI.kext/Contents/MacOS/AppleThunderboltNHI" };

static KernelPatcher::KextInfo kextThunderbolt[] {
    { "com.apple.driver.AppleThunderboltNHI", pathThunderboltNHI, 1, {true}, {}, KernelPatcher::KextInfo::Unloaded }
};

typedef void (*HALRegisterWrite32_t)(IOService *that, uint32_t offset, uint32_t data);
typedef uint32_t (*HALRegisterRead32_t)(IOService *that, uint32_t offset);
typedef int (*ResetNHI_t)(IOService *that);

static HALRegisterWrite32_t HALRegisterWrite32 = NULL;
static HALRegisterRead32_t HALRegisterRead32 = NULL;
static mach_vm_address_t OriginalResetNHI = 0;

static int PatchedResetHNI(IOService *that) {
    DBGLOG(MODULE_SHORT, "AppleThunderboltNHI::resetNHI called");
    
    IOService *hal = that->getProvider();
    uint32_t reg = HALRegisterRead32(hal, REG_FW_STS);
    DBGLOG(MODULE_SHORT, "AppleThunderboltNHI::resetNHI: REG_FW_STS = 0x%08X", reg);
    reg |= REG_FW_STS_ICM_EN_INVERT;
    HALRegisterWrite32(hal, REG_FW_STS, reg);
    IOSleep(1000);
    
    return reinterpret_cast<ResetNHI_t>(OriginalResetNHI)(that);
}

static void patchThunderboltNHI(KernelPatcher& patcher, size_t index, mach_vm_address_t address, size_t size) {
    HALRegisterWrite32 = reinterpret_cast<HALRegisterWrite32_t>(patcher.solveSymbol(index, "__ZN26AppleThunderboltGenericHAL15registerWrite32Ejj", address, size));
    if (!HALRegisterWrite32) {
        SYSLOG(MODULE_SHORT, "failed to find AppleThunderboltGenericHAL::registerWrite32");
        patcher.clearError();
        return;
    }
    
    HALRegisterRead32 = reinterpret_cast<HALRegisterRead32_t>(patcher.solveSymbol(index, "__ZN26AppleThunderboltGenericHAL14registerRead32Ej", address, size));
    if (!HALRegisterRead32) {
        SYSLOG(MODULE_SHORT, "failed to find AppleThunderboltGenericHAL::registerRead32");
        patcher.clearError();
        return;
    }
    
    KernelPatcher::RouteRequest requests[] {
        KernelPatcher::RouteRequest("__ZN19AppleThunderboltNHI8resetNHIEv", PatchedResetHNI, OriginalResetNHI),
    };
    patcher.routeMultiple(KernelPatcher::KernelID, requests);
    if (patcher.getError() != KernelPatcher::Error::NoError) {
        SYSLOG(MODULE_SHORT, "failed to patch AppleThunderboltNHI::resetNHI");
        patcher.clearError();
    }
}

// main function
static void pluginStart() {
    DBGLOG(MODULE_SHORT, "start");
    auto error = lilu.onKextLoad(kextThunderbolt, 1,
    [](void* user, KernelPatcher& patcher, size_t index, mach_vm_address_t address, size_t size) {
        DBGLOG(MODULE_SHORT, "found AppleThunderboltNHI");
        patchThunderboltNHI(patcher, index, address, size);
    }, nullptr);
    
    if (error != LiluAPI::Error::NoError)
    {
        SYSLOG(MODULE_SHORT, "failed to register onPatcherLoad method %d", error);
    }
}

// Boot args.
static const char *bootargOff[] {
    "-tbresetoff"
};
static const char *bootargDebug[] {
    "-tbresetdbg"
};
static const char *bootargBeta[] {
    "-tbresetbeta"
};

// Plugin configuration.
PluginConfiguration ADDPR(config) {
    xStringify(PRODUCT_NAME),
    parseModuleVersion(xStringify(MODULE_VERSION)),
    LiluAPI::AllowNormal,
    bootargOff,
    arrsize(bootargOff),
    bootargDebug,
    arrsize(bootargDebug),
    bootargBeta,
    arrsize(bootargBeta),
    KernelVersion::Mojave,
    KernelVersion::Catalina,
    pluginStart
};
