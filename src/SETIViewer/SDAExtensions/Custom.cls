Class SETIViewer.SDAExtensions.Custom
{

/// Creates a new chart with custom SDA from scratch.
/// 
/// 1. Create a class that gets SDA data from the custom SDA.
/// 2. Create a CSP page that displays SDA data using the class from 1.
/// 3. Create a class that calls the CSP page from 2.
/// 4. Create a new chart in Clinical Viewer that uses the class from 3.
/// as its Custom Chart Expression.
ClassMethod CreateViewerTab(custom As %String, customPlural As %String)
{
    do ..CreateDataClass(custom)
    do ..CreateCSPPage(custom)
    do ..CreateCSPCaller(custom)
    do ..ChartTrackCare(custom, customPlural)
}

/// Do not need to create chart again when adding properties to custom SDA.
ClassMethod UpdateViewerTab(custom As %String)
{
    do ..CreateDataClass(custom)
    do ..CreateCSPPage(custom)
    do ..CreateCSPCaller(custom)
}

/// Create a data class that forwards that data to the CSP page.
ClassMethod CreateDataClass(custom As %String)
{
    // 0. Get name of the infotype.
    set streamletClassName = "HS.Local.User.Streamlet.Z" _ custom
    set infotype = ##class(SETIViewer.Helper).getInfotype(streamletClassName)

    // 1. Create a class method that extracts the destired data.
    set className = "HS.Local.User.Z" _ custom _ "ToViewer"
    // does a class not exist yet

    // try to create a new class
    // open it, if it already exists
    set cdef = ##class(%Dictionary.ClassDefinition).%New(className) 
    set s = cdef.%Save()
    if (s '= 1) {
        set cdef = ##class(%Dictionary.ClassDefinition).%OpenId(className)
        do cdef.Methods.Clear()
    } else {
        set cdef.Super = "%RegisteredObject"
    }

    // create the new class
    Set getExtension = ##class(%Dictionary.MethodDefinition).%New("")
    Set getExtension.Name = "Get" _ custom
    set getExtension.FormalSpec = "id"
    Set getExtension.ReturnType = "%String"
    Set getExtension.ClassMethod = 1
    Set str = ##class(%Stream.TmpCharacter).%New()

    // add lines of code
    do str.WriteLine("    set aggKey = ##class(web.SDA3.Loader).GetAgKey(id)")
    do str.WriteLine("    set sql = ""SELECT * FROM HS_SDA3_Streamlet.Abstract where AggregationKey = ? AND InfoType = '" _ infotype _ "'"" ")
    do str.WriteLine("    set statement = ##class(%SQL.Statement).%New()")
    do str.WriteLine("    set sc = statement.%Prepare(sql)")
    do str.WriteLine("    if $$$ISERR(sc){return sc}")
    do str.WriteLine("    set result = statement.%Execute(aggKey)")

    do str.WriteLine("    set output = """" ")
    do str.WriteLine("    while (result.%Next() '= 0){")
    do str.WriteLine("        set streamletID = result.%Get(""ID"")")
    do str.WriteLine("        set tSC = ##class(HS.SDA3.Container).LoadSDAObject(streamletID,.sda)")

    // if it already had properties
    if ($DATA(^customProperties(custom))) {
        // add the row properties for every property
        set propList = ^customProperties(custom)

        // get every property from the SDA
        for i = 1:1:$LISTLENGTH(propList) {
            set prop = $LIST(propList, i)
            do str.WriteLine("        set " _ prop _ " = sda." _ prop)
        }

        // write the output string for the tables
        do str.Write("        set output = output _ ""<tr>")
        for i = 1:1:$LISTLENGTH(propList) {
            set prop = $LIST(propList, i)
            do str.Write("<td>""_" _ prop _ "_""</td>")
        }
        do str.WriteLine("</tr>""")

    // no properties yet -> empty output
    } else {
        do str.WriteLine("        set output = """" ")
    }

    do str.WriteLine("    }")
    do str.WriteLine("    return output")

    Set getExtension.Implementation = str

    do cdef.Methods.Insert(getExtension)
    do cdef.%Save()

    do $system.OBJ.Compile(className)
}

/// Create CSP page. 
ClassMethod CreateCSPPage(custom As %String)
{
    set file = ##class(SETIViewer.Helper).GetViewerCSP(custom)
    do file.Open("WSN")
    do file.WriteLine("<html>")
    do file.WriteLine("<head>")
    do file.WriteLine("<title>	Consumer Data </title>")
    do file.WriteLine("</head>")
    do file.WriteLine("<body>")
    do file.WriteLine("<table style=""table-layout: fixed; WIDTH: 100%;font-family:  arial;background-color: #e5e5e5;border-color: bfe4e3;border-top: 2px;"">")
    do file.WriteLine("    <tbody style=""border-spacing: 0;border-collapse: collapse;"">")
    do file.WriteLine("    <tr style=""background-color: #d3d2d2;"">")

    // add headers for every property
    if ($DATA(^customProperties(custom)))
    {
        set propList = ^customProperties(custom)
        for i = 1:1:$LISTLENGTH(propList) {
            set prop = $LIST(propList, i)
            do file.WriteLine("        <th>" _ prop _ "</th>")
        }
    }

    // no properties yet -> no headers

    do file.WriteLine("    </tr>")
    do file.WriteLine("   	#(##class(HS.Local.User.Z" _ custom _ "ToViewer).Get" _ custom _ "($g(%session.Data(""PatientID""))))#")
    do file.WriteLine("</tbody>")
    do file.WriteLine("</table>")
    do file.WriteLine("</body>")
    do file.WriteLine("</html>")
    do file.Close() // important, because otherwise it'll be seen as already loaded

    do ##class(SETIViewer.Helper).CompileViewerCSP(custom)
}

/// Create a method that calls CSP page.
ClassMethod CreateCSPCaller(custom As %String)
{
    // 0. Get name of the infotype.
    set streamletClassName = "HS.Local.User.Streamlet.Z" _ custom
    set infotype = ##class(SETIViewer.Helper).getInfotype(streamletClassName)

    // 1. Create a class method that extracts the destired data.
    set className = "HS.Local.User.Z" _ custom _ "ToViewer"
    // does a class not exist yet

    // try to create a new class
    // open it, if it already exists
    set cdef = ##class(%Dictionary.ClassDefinition).%New(className) 
    set s = cdef.%Save()
    if (s '= 1) {
        set cdef = ##class(%Dictionary.ClassDefinition).%OpenId(className)
    } else {
        set cdef.Super = "%RegisteredObject"
    }

    // create the new class
    set getExtension = ##class(%Dictionary.MethodDefinition).%New("")
    set getExtension.Name = "Get" _ custom _ "URL"
    set getExtension.FormalSpec = "id"
    set getExtension.ReturnType = "%String"
    set getExtension.ClassMethod = 1
    set str = ##class(%Stream.TmpCharacter).%New()
    
    // add lines of code
    do str.WriteLine("   	Quit ""../../" _ custom _ ".csp"" ")
    set getExtension.Implementation = str

    do cdef.Methods.Insert(getExtension)
    do cdef.%Save()
    do $system.OBJ.Compile(className)
}

/// Creates a chart in TrackCare and adds it to the HS-Doctor chartbook.
ClassMethod ChartTrackCare(custom As %String, customPlural As %String)
{
    set chartid = ..CreateChart(custom, customPlural)
    do ..AddToChartbook(chartid)
}

// Creates a new chart in TrackCare.

ClassMethod CreateChart(custom As %String, customPlural As %String = "") As %Numeric
{
    set chart = ##class(epr.Chart).%New(custom)

    set chart.ChartType = "N"
    set chart.DisplayConsultBanner = 0
    set chart.HideHeaderIfSingleChartItem = 0

    // add chart name depending on custom plural
    if (customPlural = "") {
        set chart.Name = custom _ "s"
        set chart.Caption = custom _ "s"
    } else {
        set chart.Name = customPlural
        set chart.Caption = customPlural
    }

    set chart.Owner = "SITE"
    set chart.ShowNavTabs = 0
    set chart.CustomURLExpression = "##class(HS.Local.User.Z" _ custom _ "ToViewer).Get" _ custom _ "URL()"
    set chart.TimeChanged = $HOROLOG

    set s = chart.%Save()
    w $system.Status.DisplayError(s)

    if ( '$DATA(^chartids(chart.%Id())) ) {
        set ^chartids(chart.%Id()) = ""
    }
    return chart.%Id()
}

/// Adds chartbook to HS-Doctor
ClassMethod AddToChartbook(id As %Numeric)
{
    // open HS-Doctor at id 47
    set chart = ##class(epr.Chart).%OpenId(id)
    set chartbook = ##class(epr.ChartBook).%OpenId(47)

    // update chart list
    set list = chartbook.ChartList
    set idString = "" _ id
    // inset into the list
    set s =  list.InsertObjectId(idString)
    w $system.Status.DisplayError(s)

    // add to chart book item
    set chartbookitem = ##class(epr.ChartBookItem).%New()
    set chartbookitem.ChartBookDR = chartbook 
    set chartbookitem.ChartDR = chart 
    set chartbookitem.ChartPosition = "M"
    set chartbookitem.EPRPrintHideNoData = 0
    set chartbookitem.ChartSequence = 1

    set s = chartbookitem.%Save()
    w $system.Status.DisplayError(s)

    set ^chartBookItemIds(chartbookitem.%Id()) = ""
}

}
