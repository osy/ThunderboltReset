/**
 * Support file for NUC Hades Canyon
 * 
 * Copyright (c) 2019 osy86
 */

#define TBT_HAS_COMPANION One
#define TBT_HOTPLUG_GPE _E20
#define TBT_ROOT \_SB.PCI0.RP05
#define XHC_ROOT \_SB.PCI0.XHC
#define TBT_USB_PORT_1_COMPANION 0x0C
#define TBT_USB_PORT_2_COMPANION 0x0D

    External (TBT_ROOT, DeviceObj)
    External (TBT_ROOT.PXSX, DeviceObj)
    External (XHC_ROOT, DeviceObj)
    Scope (TBT_ROOT)
    {
        External (MMRP, MethodObj)                        // Memory mapped root port
        External (MMTB, MethodObj)                        // Memory mapped TB port
        External (TBSE, FieldUnitObj)                     // TB root port number
        External (\_SB.PCI0.GPCB, MethodObj)              // get PCI MMIO base
        External (\_SB.PCI0.RP05.PXSX, DeviceObj)         // Replace the old device

        /**
         * Implement a call to the original HP handler
         * Then return One if this is a TB HP
         */
        Method (OHPE, 0, NotSerialized)
        {
            Return (One)
        }

        /**
         * Get PCI base address
         * Arg0 = bus, Arg1 = device, Arg2 = function
         */
        Method (MMIO, 3, NotSerialized)
        {
            Local0 = \_SB.PCI0.GPCB () // base address
            Local0 += (Arg0 << 20)
            Local0 += (Arg1 << 15)
            Local0 += (Arg2 << 12)
            Return (Local0)
        }

        /**
         * PXSX replaced by UPSB
         */
        Scope (PXSX)
        {
            Method (_STA, 0, NotSerialized)
            {
                Return (Zero) // hidden
            }
        }
    }
