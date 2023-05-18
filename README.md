# Exporter

Use exporter installer like:
```
r = Lib.Sys.Net.Http.new( "https://raw.githubusercontent.com/luastudio/Exporter/main/Exporter_installer.lua" )
r.onData = function(s)fn=load(s) fn("23.0")end r.onError = print r.request(false)
```
Replase "23.0" to version you want to install