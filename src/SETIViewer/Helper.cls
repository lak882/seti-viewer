Class SETIViewer.Helper
{

/// Get the infotype from a streamlet class.
ClassMethod getInfotype(streamletClassName As %String) As %String
{
    set streamlet = ##class(%Dictionary.ClassDefinition).%OpenId(streamletClassName)
    set arr = streamlet.Parameters
    set key = ""
    for {
        set key = arr.Next(key)
        set parameter = arr.GetAt(key)
        if (parameter.Name = "INFOTYPE") {
            return parameter.Default
        }
    }
    // no infotype found, return default
    return "PRC"
}

/// Returns a CSP page that is in the hsviewer folder.
ClassMethod GetViewerCSP(name As %String) As %File
{
    set dir = ##class(%File).ManagerDirectory()
    set dir = ##class(%File).ParentDirectoryName(dir)
    set dir = ##class(%File).SubDirectoryName(dir, "csp")
    set dir = ##class(%File).SubDirectoryName(dir, "healthshare")
    set dir = ##class(%File).SubDirectoryName(dir, "hsviewer")

    set filename = dir _ "\" _ name _ ".csp"
    set filename = ##class(%File).NormalizeFilename(filename)

    set cspname = "/csp/healthshare/hsviewer/" _ name _ ".csp"

    // delete file if it already exists
    try { do $system.CSP.DeletePage(cspname, "ck") } catch {}

    set file = ##class(%File).%New(filename)

    set ^CSPPages(cspname) = ""

    return file
}

/// Compiles a page in the hsviewer folder.
/// Try/catch block, since it'll throw an error if the page is already loaded.
ClassMethod CompileViewerCSP(name As %String)
{
    do $system.OBJ.Load("/csp/healthshare/hsviewer/" _ name _ ".csp", "ck")
}

}
