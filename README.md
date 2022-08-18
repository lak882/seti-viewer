[![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/SETI)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fintersystems-iris-dev-template&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fseti)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)

<h1 align="center">
  <br>
  <a href=""><img src="logo/Logo_h256.png" height="100"></a>
</h1>

# SDA Extension Tool (SETI) Viewer

Add-on to unlock the Clinical Viewer feature of SDA Extension Tool.

## Installation

1. You must have installed [SDA Extension Tool](https://openexchange.intersystems.com/package/SETI) for this to work.

2. For Clinical Viewer open a Terminal in the HSCUSTOM namespace.

3. Use [ObjectScript Package Manager](https://openexchange.intersystems.com/package/ObjectScript-Package-Manager) to install SETI Viewer.
```
HSCUSTOM> zpm "install seti-viewer"
```

### Requirements

* [SDA Extension Tool](https://openexchange.intersystems.com/package/SETI) installed 
* [ObjectScript Package Manager](https://openexchange.intersystems.com/package/ObjectScript-Package-Manager) installed 
* HealthShare with appropriate license
* SETI Viewer uses HSVIEWER as its Viewer Access Gateway namespace (see [Setup Overview](https://openexchange.intersystems.com/package/SETI#setup-overview))


