/**
 * Support file for GA-X99-Designare EX
 * 
 * Copyright (c) 2019 osy86
 */

#ifndef TBT_HOTPLUG_GPE
#define TBT_HOTPLUG_GPE _L01
#endif
#ifndef TBT_ROOT
#define TBT_ROOT \_SB.PCI0.BR3A.H000
#endif
#define TBT_HAS_COMPANION Zero
#define TBT_USB_PORT_1_COMPANION Zero
#define TBT_USB_PORT_2_COMPANION Zero

    External (TBT_ROOT, DeviceObj)
    External (\_GPE.XL01, MethodObj)
    External (\_SB.PCI0.BR3A.PMEP, FieldUnitObj)
    External (\_SB.PCI0.BR3A.PMEH, MethodObj)
    External (\_SB.PCI0.BR3A.HPEH, MethodObj)
    External (\_GPE.MMRP, MethodObj)
    External (\_GPE.MMTB, MethodObj)
    External (\PEMA, IntObj)
    External (\TBRP, IntObj)
    Scope (TBT_ROOT)
    {
        /**
         * Implement a call to the original HP handler
         * Then return One if this is a TB HP
         */
        Method (OHPE, 0, NotSerialized)
        {
            \_GPE.XL01 () // call original

            If ((\_SB.PCI0.BR3A.PMEP == 0x01))
            {
                Local0 = \_SB.PCI0.BR3A.PMEH (0x05)
            }
            Else
            {
                Local0 = \_SB.PCI0.BR3A.HPEH (0x05)
                If ((ToInteger (TBRP) == 0x28))
                {
                    Local0 = 0xFF
                }
            }

            DBG2 ("OHPE", Local0)
            If ((Local0 != 0xFF))
            {
                Return (One)
            }
            Else
            {
                Return (Zero)
            }
        }

        /**
         * Get PCI base address
         * Arg0 = bus, Arg1 = device, Arg2 = function
         */
        Method (MMIO, 3, NotSerialized)
        {
            Local0 = PEMA // base address
            Local0 += (Arg0 << 20)
            Local0 += (Arg1 << 15)
            Local0 += (Arg2 << 12)
            Return (Local0)
        }

        /**
         * Implement a call that returns the MMIO address
         * for the root port in Arg0
         */
        Method (MMRP, 1, Serialized)
        {
            Return (\_GPE.MMRP (Arg0))
        }

        /**
         * Implement a call that returns the MMIO address
         * for the upstream port in Arg0
         */
        Method (MMTB, 1, Serialized)
        {
            Return (\_GPE.MMTB (Arg0))
        }

        /**
         * This is passed to MMRP and MMTB as Arg0
         * Store the root controller for the TB here.
         */
        //Name (TBSE, 0)
        #define TBSE TBRP
    }
