# calc_distance
; 27.09.2021 - Ferdinand Marx - GFMSoft - www.GFMSOFT.de
; This script converts MAIDENHEADLOCATOR to LATITUDE and LONGTITUDE and calculates the distance.
; Result is rounded
; It uses the haversine formula. - https://en.wikipedia.org/wiki/Haversine_formula

;~ .:Information:.

;~ 1. First you have to declare your own locator.
;~ 2. For this example our own locator is IO94GC - see $ownlocator
;~ 3. Leave $r and $mathpi as it is
;~ 4. Just call the function "Calcdistance" with a Maidenheadlocator-String !MUST HAVE 6 Characters!



;~ Example
MsgBox(64, "Info", "Distance to IO94GC is " & calcdistance("JN63EV") & " km !")
