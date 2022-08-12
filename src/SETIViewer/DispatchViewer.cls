Class SETIViewer.DispatchViewer Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/extend" Method="POST" Call="Extend" Cors="true"/>
<Route Url="/custom" Method="POST" Call="Custom" Cors="true"/>
<Route Url="/reset" Method="POST" Call="Reset" Cors="true"/>
<Route Url="/customAddProperty" Method="POST" Call="CustomAddProperty" Cors="true"/>
</Routes>
}

ClassMethod Extend() As %Status
{
    set proxyObj = {}.%FromJSON(%request.Content)
    set ^extension = proxyObj.extension
    set ^extension("sda") = proxyObj.sda
    do ##class(SETIViewer.SDAExtensions.Extension).CreateTransformTrakCare(^extension, ^extension("sda"))
    try {
        zn "HSCUSTOM"
        do ##class(SETIViewer.SDAExtensions.Extension).CreateTransformClass(^extension, ^extension("sda"))
        zn "HSVIEWER"

    } catch {
        zn "HSVIEWER"
        w !, "Extend: Switching to HSCUSTOM failed"
    }
    Quit $$$OK
}

ClassMethod Custom() As %Status
{
    set proxyObj = {}.%FromJSON(%request.Content)
    set sda = proxyObj.sda
    set customPlural = proxyObj.customPlural
    do ##class(SETIViewer.SDAExtensions.Custom).CreateViewerTab(sda, customPlural)
    Quit $$$OK
}

ClassMethod CustomAddProperty() As %Status
{
    set proxyObj = {}.%FromJSON(%request.Content)
    set sda = proxyObj.sda 
    set propertyName = proxyObj.propertyName 
    set propertyType = proxyObj.propertyType 

    if ($DATA(^customProperties(sda))) {
        set $LIST(^customProperties(sda), *+1) = propertyName 
    } else {
        set ^customProperties(sda) = $lb(propertyName)
    }

    do ##class(SETIViewer.SDAExtensions.Custom).UpdateViewerTab(sda)
}

ClassMethod Reset() As %Status
{
    do ##class(SETIViewer.SDAExtensions.Reset).Reset()
    Quit $$$OK
}

}
