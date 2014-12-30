@echo off
set /p changes="Changes: "
"../../../bin/gmad.exe" create -out "D:\Daten\Workshop\bhud.gma" -folder "D:\Daten\Server\Valve Server\steamapps\common\GarrysModDS\garrysmod\addons\bHUD"
"../../../bin/gmpublish" update -addon "D:\Daten\Workshop\bhud.gma" -id "175630527" -changes "%changes%"
PAUSE