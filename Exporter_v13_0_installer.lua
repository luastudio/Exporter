-- Exporter v13_0 installer
-- https://scormpool.com/luastudio/download/Exporter_v13_0.luastudio

host = "scormpool.com"
path = "/luastudio/download/"
fileName = "Exporter_v13_0.luastudio"

request = string.format([[GET %s%s HTTP/1.1
Host: %s
Connection: close
Content-Type: application/x-www-form-urlencoded

]], path, fileName, host)

processThread = Lib.Sys.VM.Thread.create([[
init = Lib.Sys.VM.Thread.readMessage(true)
request = init.request
host = init.host
fileName = init.fileName

function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

socket = Lib.Sys.SSL.Socket.new()
Lib.Sys.trace("Connecting")
socket.connect( Lib.Sys.Net.Host.new( host ), 443 )
Lib.Sys.trace("Connected")
Lib.Sys.trace("Writing header")
socket.write(request)

-- SKIP the HTTP header (until \r\n\r\n)
k = 4
s = Lib.Sys.IO.Bytes.alloc( k )
socket.setTimeout(10)
while( true )do
  local p = socket.input.readBytes(s,0,k)
  while( p ~= k )do
    p = p + socket.input.readBytes(s,p,k - p)
  end 

  if( k == 1 )then

    local c = s.get(0)
    if( c == 10 )then break end
	if( c == 13 )then k = 3 else k = 4 end

  elseif( k == 2 )then

    local c = s.get(1)
    if( c == 10 )then
      if( s.get(0) == 13 )then break end
      k = 4
    elseif( c == 13 )then k = 3 else k = 4 end

  elseif( k == 3 )then

    local c = s.get(2)
    if( c == 10 )then
      if( s.get(1) ~= 13 )then k = 4
      elseif( s.get(0) ~= 10 )then k = 2 else break end
    elseif( c == 13 )then
      if( s.get(1) ~= 10 or s.get(0) ~= 13 )then k = 1 else k = 3 end
    else k = 4 end

  elseif( k == 4 )then

    local c = s.get(3)
    if( c == 10 )then
      if( s.get(2) ~= 13 )then goto continue
	  elseif(s.get(1) ~= 10 or s.get(0) ~= 13 )then k = 2 else break end
    elseif( c == 13 )then
      if( s.get(2) ~= 10 or s.get(1) ~= 13 )then k = 3 else k = 1 end
    end

  end

  ::continue::
end

local fOut = Lib.Sys.IO.File.write(Lib.Media.FileSystem.File.documentsDirectory.nativePath.."/"..fileName, true)
bufSize = 1024 * 10
buf = Lib.Sys.IO.Bytes.alloc( bufSize )
pos = 0
len = -1
eof = false
local mbComplete = 0
while true do
    --len = socket.input.readBytes( buf, 0, bufSize ) need safe call for capturing Eof
    status, result = pcall(socket.input.readBytes, buf, 0, bufSize)
    if not status then
        eof = (result == "Eof")
        if not eof then print(err) break end   
    else
        len = result
    end

    if eof or len <= 0 then 
      if eof and pos == 0 then Lib.Sys.trace("empty file or incorrect url") end 
      break
    else
      fOut.writeBytes(buf, 0, len) 
      pos = pos + len 
      --Lib.Sys.trace(pos) 

      local doneMb = round(pos / (1024 * 1024))
      if(doneMb > mbComplete) then
         Lib.Sys.trace("Loaded " .. doneMb .. " Mb")
         mbComplete = doneMb
      end
	end
end
fOut.close()
socket.close()
Lib.Sys.trace("DONE")]])

processThread.sendMessage({request = request, host = host, fileName = fileName})