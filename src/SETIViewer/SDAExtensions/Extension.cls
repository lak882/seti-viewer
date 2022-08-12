Class SETIViewer.SDAExtensions.Extension
{

/// Create a transform in TrakCare.
ClassMethod CreateTransformTrakCare(extension As %String, sda As %String)
{
        set transform = ##class(websys.Transform).%New()
        set transform.Code = sda _ extension _ "Transform"   
        set ^transformIDs("0||" _ transform.Code) = ""
        set transform.Name = "Display " _ extension _ " Extension"
        set transform.Description = "Display the " _ extension _ " extension in the viewer."
        // expression is the function that will be called in HSCUSTOM
        set transform.Expression = "set val=##class(HS.Local.User.ExtensionToViewer).Get" _ sda _ extension _ "($g(rs.Data(""RowID"")))"
        do transform.%Save()
}

/// Pushes the changes to the Clinical Viewer.
/// 
/// extension: name of the extension
/// ExtendSDA: Extension.Sneeziness
/// 
/// infotype: streamlet connecting it
/// default: PRC
/// 
/// 0. Get name of the infotype.
/// 1. Create a class method that extracts the desired data.
/// 2. Create a transform.
/// 3. Apply the transform.
ClassMethod CreateTransformClass(extension As %String, sda As %String)
{
        // 0. Get name of the infotype.
        set streamletClassName = "HS.SDA3.Streamlet." _ sda
        set infotype = ##class(SETIViewer.Helper).getInfotype(streamletClassName)

        // 1. Create a class method that extracts the destired data.
        set className = "HS.Local.User.ExtensionToViewer"
        // does a class not exist yet

        // try to create a new class
        // open it, if it already exists
        set cdef = ##class(%Dictionary.ClassDefinition).%New(className) 
        set s = cdef.%Save()
        if (s '= 1) {
            set cdef = ##class(%Dictionary.ClassDefinition).%OpenId(className)
        }

        // create the new class
        Set getExtension = ##class(%Dictionary.MethodDefinition).%New("")
        Set getExtension.Name = "Get" _ sda _ extension
        set getExtension.FormalSpec = "id"
        Set getExtension.ReturnType = "%String"
        Set getExtension.ClassMethod = 1
        Set str = ##class(%Stream.TmpCharacter).%New()

        // add lines of code
        Do str.WriteLine("  set patientid = %request.Data(""PatientID"",1)")
        Do str.WriteLine("  set streamletID = ##class(web.SDA3.Loader).GetStreamletId(,patientid,""" _ infotype _ """,id)")
        Do str.WriteLine("  set tSC = ##class(HS.SDA3.Container).LoadSDAObject(streamletID,.sda)")
        Do str.WriteLine("  set extension = sda.Extension." _ extension )
        Do str.WriteLine("  quit extension")
        Set getExtension.Implementation = str

        do cdef.Methods.Insert(getExtension)
        do cdef.%Save()

        do $system.OBJ.Compile(className)
}

}
