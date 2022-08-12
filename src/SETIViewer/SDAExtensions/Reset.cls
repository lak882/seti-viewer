Class SETIViewer.SDAExtensions.Reset
{

/// Delete the charts in TrakCare & HealthShare we created.
ClassMethod ResetCharts()
{
    // Delete all the ids of the created charts.
    set id = $Order(^chartids(""))
    while (id '= "") {
        // clear all instances of this persistent
        do ##class(epr.Chart).%DeleteId(id)

        // find next node
        set id = $Order(^chartids(id))
    }

    kill ^chartids

    // reset chart list in chartbook
    // originally had 18 items 
    set chartbook = ##class(epr.ChartBook).%OpenId(47)
    set id = 18 // custom ids start at 18
    for { 
        // if no element was removed, then the output will be ""
        // then we've removed all the elements
        set s = chartbook.ChartList.RemoveAt(id)
        if (s = "") {
            Quit
        }
        set id  = id + 1
     }

    // Remove all the references in ChartBookItem. 
    set id = $Order(^chartBookItemIds(""))
    while (id '= "") {
        // clear all instances of this persistent
        do ##class(epr.ChartBookItem).%DeleteId(id)

        // find next node
        set id = $Order(^chartBookItemIds(id))
    }
    kill ^chartBookItemIds

    kill ^customProperties
}

/// Delete the CSP Pages we created.
ClassMethod ResetCSPPages()
{
    set filename = $Order(^CSPPages(""))
    while (filename '= "") {
        // clear all instances of this persistent
        do $system.CSP.DeletePage(filename, "ck")

        // find next node
        set filename = $Order(^CSPPages(filename))
    }

    kill ^CSPPages
}

/// Delete transformation that were stored in transformIDs.
ClassMethod ResetTransforms()
{
    set id = $Order(^transformIDs(""))

    while (id '= "") {
        // get result at key
        set cdef = ##class(websys.Transform).%DeleteId(id)
        // find next node
        set id = $Order(^transformIDs(id))
    }

    kill ^transformIDs
}

/// Reset the ClinicalViewer enviroment.
ClassMethod Reset()
{
    do ..ResetCharts()
    do ..ResetCSPPages()
    do ..ResetTransforms()
}

}
