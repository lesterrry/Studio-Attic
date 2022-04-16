(*
Studio Attic v0.1.10
Cassette-recording tool
****************************************************************
COPYRIGHT LESTERRRY, 2021
*)

property gaplength : 3

display dialog "Welcome to Studio Attic!
Select tape length" default answer "" with title "Studio Attic" buttons {"60 min", "90 min", "From field"}

if the button returned of the result is "From field" and the text returned of the result is not "" then
	try
		set tapelength to the (text returned of the result as number) * 60
	on error
		display alert "Sorry, provided length is NaN"
		quit me
	end try
else if button returned of the result is "60 min" then
	set tapelength to 3600
else if button returned of the result is "90 min" then
	set tapelength to 5400
else
	quit me
end if

display dialog "Now select a Music playlist to record on your " & (round tapelength / 60) & " min cassette" default answer "" with title "Studio Attic" buttons {"Next"}
set plist to the (text returned of the result) as string
try
	tell application "Music" to reveal playlist plist
on error
	display alert "Sorry, '" & plist & "' does not seem to exist"
	quit me
end try

tell application "Music"
	set plistcount to number of tracks of playlist plist
	set plistlength to (round (duration of playlist plist as real)) + (plistcount * gaplength)
	set plistlengthsec to (round (plistlength / 60) - 1)
	set tapelengthsec to round (tapelength / 60)
	if plistlengthsec is greater than tapelengthsec then
		display alert "Sorry, this playlist is too long: " & (plistlengthsec as string) & " min vs " & (tapelengthsec as string) & " min"
		quit me
	end if
	repeat while true
		set a to 0
		set i to 0
		repeat with j in tracks of playlist plist
			try
				set b to a + gaplength + (duration of j)
			on error
				display alert "Sorry, problem with '" & name of j & "'"
				quit me
			end try
			if b < tapelength / 2 then
				set a to b
				set i to i + 1
			else
				set s to (round (a / 60)) as string
				set t to (round (plistlength - a) / 60) as string
				set o to (round plistlength / 60) as string
				set songscount_a to i
				set songscount_b to plistcount - i
				exit repeat
			end if
		end repeat
		tell me to display dialog ("Time including gaps: " & s & " min (" & (songscount_a as string) & " songs) will be recorded on side A, leaving " & t & " min (" & (songscount_b as string) & " songs) for B.
" & o & " min in total.") buttons {"Update", "Abort", "Next"} with title "Studio Attic" default button "Next"
		if the button returned of the result is "Abort" then
			quit me
		else if the button returned of the result is "Next" then
			exit repeat
		end if
	end repeat
	display dialog "You're all set to record '" & plist & "' on your " & (round tapelength / 60) & " min cassette. Don't forget to quit all disturbing apps to avoid unwanted sounds.
Shall we begin?" buttons {"Abort", "Advanced", "Launch"} default button "Launch" with title "Studio Attic"
	if the button returned of the result is "Abort" then
		quit me
	else
		set b to button returned of the result
		set shuffle enabled to false
		set song repeat to off
		set sound volume to 85
		set volume output volume 90
		set a to 0
		play playlist plist
		if b is "Advanced" then
			pause
			display dialog "Select a track to begin with" default answer "1" with title "Studio Attic" buttons {"Launch from side B", "Launch"} default button "Launch"
			if the button returned of the result is "Launch" then
				try
					set a to the (text returned of the result as number) - 1
				on error
					display alert "Sorry, provided track is NaN"
					quit me
				end try
			else
				set a to songscount_a
			end if
			repeat a times
				next track
			end repeat
			play
		end if
	end if
	set i to a
	set recb to false
	repeat while i is not equal to (songscount_a + songscount_b) - 1
		set i to i + 1
		repeat
			if player state is paused then
				quit me
			end if
			if player position is greater than (duration of the current track) - 2 then
				pause
				if i is equal to songscount_a and recb is false then
					set recb to true
					pause
					tell me to display dialog "Side A recording completed. Wait for the tape to end." buttons "Next" with title "Studio Attic"
					next track
					play
				else
					display notification (i as string) & " out of " & songscount_a + songscount_b & " recorded" with title plist & " – Studio Attic"
					delay gaplength
					next track
					play
				end if
				delay 4
				exit repeat
			end if
			delay 1
		end repeat
	end repeat
end tell
display dialog "Side B recording completed. Return soon to the Attic!" buttons "Exit" with title "Studio Attic"
