/**
 * Template. Replace this with your own candidates.
 */
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "HPLog", 0x00001000)
{
    External (\_GPE.XL69, MethodObj)
    External (\_GPE.XL61, MethodObj)
    External (\_GPE.XL62, MethodObj)
    External (\_GPE.XL66, MethodObj)
    External (\_GPE.XL12, MethodObj)
    External (\_GPE.XL6F, MethodObj)
    External (\RMDT.P1, MethodObj)

    Scope (_GPE)
    {
        Method (_L69, 0, Serialized)  // _Lxx: Level-Triggered GPE
        {
            \RMDT.P1 ("_L69")
            XL69 ()
        }

        Method (_L61, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            \RMDT.P1 ("_L61")
            XL61 ()
        }

        Method (_L62, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            \RMDT.P1 ("_L62")
            XL62 ()
        }

        Method (_L66, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            \RMDT.P1 ("_L66")
            XL66 ()
        }

        Method (_L12, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            \RMDT.P1 ("_L12")
            XL12 ()
        }

        Method (_L6F, 0, NotSerialized)  // _Lxx: Level-Triggered GPE
        {
            \RMDT.P1 ("_L6F")
            XL6F ()
        }
    }
}