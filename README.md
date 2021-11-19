# Exporter

Use exporter installer like:
```
r = Lib.Sys.Net.Http.new( "https://raw.githubusercontent.com/luastudio/Exporter/main/Exporter_v16_0_installer.lua" )
r.onData = function(s)fn=load(s) fn()end r.onError = print r.request(false)
```
