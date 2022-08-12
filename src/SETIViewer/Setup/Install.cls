Class SETIViewer.Setup.Install
{

ClassMethod Install()
{
    do ..Mappings()
    do ..Compile()
    do ..DispatchViewer()
}

// Create mappings for SETIViewer package and extension global.
ClassMethod Mappings()
{
    try {
        zn "%SYS"
        s hscustom("Database") = "HSCUSTOM"
        // map SETI viewer
        do ##class(Config.MapPackages).Create("HSVIEWER", "SETIViewer", .hscustom)
        // map extension
        
        s hsviewer("Database") = "HSVIEWER"
        do ##class(Config.MapGlobals).Create("HSCUSTOM", "extension", .hsviewer)
        zn "HSCUSTOM"
    } catch {
        w !, "Mappings: Switching to %SYS failed."
    }
}

// Re-compile mapped packages.
ClassMethod Compile()
{
    try {
        zn "HSVIEWER"
        do $system.OBJ.CompilePackage("SETIViewer")
        zn "HSCUSTOM"
    } catch {
        w !, "Compile: Switching to HSVIEWER failed."
    }
}

// Setup DispatchViewer REST Api.
ClassMethod DispatchViewer()
{
    try {
        zn "%SYS"
        set dispatch = ##class(Security.Applications).%New("")
        set dispatch.Name = "/dispatchviewer"
        set dispatch.NameSpace = "HSVIEWER"
        set dispatch.DispatchClass = "SETIViewer.DispatchViewer"
        do dispatch.MatchRoles.Insert(":%All")
        set dispatch.UseCookies = 2
        do dispatch.%Save()
        zn "HSCUSTOM"
    } catch {
        w !, "DispatchViewer: Switching to %SYS failed."
    }
}

}
