rm -R build
mkdir build
zip build/cryptolich.love * -x todo.md build.sh cryptolich.ico *~ build/
cd build

unzip ~/Software/love/love-11.4-win32.zip
cd love-11.4-win32
cat love.exe ../cryptolich.love > cryptolich.exe
wine ~/Software/resourcehacker/ResourceHacker.exe -open cryptolich.exe -save cryptolich.exe -action addoverwrite -res ../../cryptolich.ico -mask ICONGROUP,MAINICON,
rm game.ico
rm love.ico
rm love.exe
rm lovec.exe
rm changes.txt
rm readme.txt
cd ..

~/Software/love/love-11.4-x86_64.AppImage --appimage-extract
cd squashfs-root
cat bin/love ../cryptolich.love > bin/cryptolich
chmod +x bin/cryptolich
echo "#!/bin/bash
bin/cryptolich" > cryptolich.sh
chmod +x cryptolich.sh
rm bin/love
rm AppRun
rm bzip2installed.txt
rm love.desktop
rm love.svg
cd ..

echo "butler push love-11.4-win32 dbisdorf/tower-of-the-cryptolich:win32 --userversion x.x.x"
echo "butler push squashfs-root dbisdorf/tower-of-the-cryptolich:linux --userversion x.x.x"

