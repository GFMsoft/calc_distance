; 27.09.2021 - Ferdinand Marx - GFMSoft - www.GFMSOFT.de
; This script converts MAIDENHEADLOCATOR to LATITUDE and LONGTITUDE and calculates the distance.
; Result is rounded
; It uses the haversine formula. - https://en.wikipedia.org/wiki/Haversine_formula

;~ .:Information:.

;~ 1. First you have to declare your own locator.
;~ 2. For this example our own locator is IO94GC - see $ownlocator
;~ 3. Leave $r and $mathpi as it is
;~ 4. Just call the function "Calcdistance" with a Maidenheadlocator-String !MUST HAVE 6 Characters!



;Vars
Global $qthdistance, $ownlocator, $mathpi, $r
$r = 6371000 ; Radius of earth - usually i had this in the func - defined at every call - but this is obviously a const so it goes to global
$mathpi = 3.14159 ; Thats PI - Used for some Math later

; PLEASE INSERT YOUR MAIDENHEAD-LOCATOR HERE
$ownlocator = "IO94GC"

;~ Example
MsgBox(64, "Info", "Distance to IO94GC is " & calcdistance("JN63EV") & " km !")



;This function converts Maidenheadlocator to LAT LON coords
Func convertlocator($locator)

	Local $latitude, $longtitude, $array, $workarray, $asciiarray, $worklocator
	Local $lat_step1, $lat_step2, $lat_step3
	Local $lon_step1, $lon_step2, $lon_step3, $lon_step4

	If StringLen($locator) <> 6 Then
		ConsoleWrite("Targetlocator corrupt - cant calculate!" & @CRLF)
		Return 0
	EndIf

	$worklocator = StringTrimLeft($locator, 4)
	$worklocator = StringLower($worklocator)
	$locator = StringTrimRight($locator, 2)
	$locator = $locator & $worklocator
	$asciiarray = StringToASCIIArray($locator)
	$workarray = StringSplit($locator, "")


	If IsArray($workarray) = False Then
		ConsoleWrite("ERROR - WORKARRAY - FALSE" & @CRLF)
		Return 0
	EndIf
	If $workarray[0] <> 6 Then
		ConsoleWrite("ERROR - WORKARRAY <> 6" & @CRLF)
		Return 0
	EndIf


	;step 1 - find ascii char for 2th char in locator code
	$lat_step1 = $asciiarray[1]

	$lat_step1 = $lat_step1 - 65
	$lat_step1 = $lat_step1 * 10

	;step2 - get number of position 4
	$lat_step2 = $workarray[4]

	;step 3 - find ascii char for 6th char of locator
	$lat_step3 = $asciiarray[5]
	$lat_step3 = $lat_step3 - 97
	$lat_step3 = $lat_step3 / 24
	$lat_step3 = $lat_step3 + (1 / 48)
	$lat_step3 = $lat_step3 - 90

	;step 4 - all together STEP1 + STEP2 + STEP3
	$latitude = $lat_step1 + $lat_step2 + $lat_step3

;~ ___________
;~ LONGTITUDE

	;step1 - Find the ASCII charachter code for the 1st character of the locator code
	$lon_step1 = $asciiarray[0]

	$lon_step1 = $lon_step1 - 65
	$lon_step1 = $lon_step1 * 20

	;step2 - Get number from position 3
	$lon_step2 = $workarray[3]
	$lon_step2 = $lon_step2 * 2

	;step3 - Find the ASCII charachter code for the 5th character of the locator code
	$lon_step3 = $asciiarray[4]
	$lon_step3 = $lon_step3 - 97
	$lon_step3 = $lon_step3 / 12
	$lon_step3 = $lon_step3 + (1 / 24)

	;step4 - Add results A, B and C then deduct 180
	$longtitude = ($lon_step1 + $lon_step2 + $lon_step3) - 180

	Return Round($latitude, 3) & "," & Round($longtitude, 3)

EndFunc   ;==>convertlocator

;This function calculates the distance of two qth's
Func calcdistance($qthdistance)

	;checking for inputerrors
	If StringLen($qthdistance) <> 6 Or $qthdistance = "" Then
		Return 0
	EndIf

	;this is for users trying to crash your application
	If $qthdistance = "      " Then
		Return 0
	EndIf

	;Define local vars
	Local $lat1, $lat2, $lon1, $lon2, $point1, $point2
	Local $phi1, $phi2, $a, $c, $d

	; delta = Δφ
	Local $delta

	; spectral = Δλ
	Local $spectral

	;LAT and LON of Point 1
	;This is always your position
	$point1 = convertlocator($ownlocator)
	$point1 = StringSplit($point1, ",")

	;Check for errors
	If IsArray($point1) = False Then
		Return 0
	EndIf

	$lat1 = $point1[1]
	$lon1 = $point1[2]

	;LAT and LON of Point 2
	$point2 = convertlocator($qthdistance)
	$point2 = StringSplit($point2, ",")

	;Check for errors
	If IsArray($point2) = False Then
		Return 0
	EndIf

	$lat2 = $point2[1]
	$lon2 = $point2[2]

	$phi1 = $lat1 * $mathpi / 180
	$phi2 = $lat2 * $mathpi / 180
	$delta = ($lat2 - $lat1) * $mathpi / 180
	$spectral = ($lon2 - $lon1) * $mathpi / 180
	$a = Sin($delta / 2) * Sin($delta / 2) + Cos($phi1) * Cos($phi2) * Sin($spectral / 2) * Sin($spectral / 2)
	$c = 2 * _atan2(Sqrt($a), Sqrt(1 - $a))
	$d = $r * $c

	Return Round($d / 1000, 0)

EndFunc   ;==>calcdistance

;This function is needed for the distance calculation of two qth's
Func _atan2($y, $x)
	If $x > 0 Then
		Return ATan($y / $x)
	ElseIf $x < 0 And $y >= 0 Then
		Return ATan($y / $x) + ACos(-1)
	ElseIf $x < 0 And $y < 0 Then
		Return ATan($y / $x) - ACos(-1)
	ElseIf $x = 0 And $y > 0 Then
		Return ACos(-1) / 2
	ElseIf $x = 0 And $y < 0 Then
		Return -ACos(-1) / 2
	Else
		Return 0
	EndIf
EndFunc   ;==>_atan2
