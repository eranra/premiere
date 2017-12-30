;Random Transitions for Adobe Premiere 

#SingleInstance force
#IfWinActive ahk_exe Adobe Premiere Pro.exe

;; apply default transition to prev and next clip on the time line
apply_transition() {
	SetKeyDelay, 0
	MouseGetPos, xpos, ypos 			;----------------Prevents the user from interfering with the operation.
	BlockInput, on
	BlockInput, MouseMove 				

	;;MouseMove 0,0,0						;---------------- Move the mouse away, so it will not interfer in looking on the time line
	sleep 1
	Send ^+{A}							;---------------- Deselect all
	Send ^{Down}						;---------------- Select next clip
	Send {Left 5}						;---------------- Move back 5 frames
	
	count_error = 0
	loop {
		sleep 100							;---------------- look for the time line marker, either on yellow or red 
		ImageSearch, FoundX, FoundY, 800,660, 1920, 1080, C:\ToFind.png
		if ErrorLevel {
			ImageSearch, FoundX, FoundY, 800,660, 1920, 1080, C:\ToFindRed.png
			if ErrorLevel {
				count_error = count_error + 1
				sleep 1000
				if (count_error == 5) {
					MouseMove, %xpos%, %ypos%, 0		;------------- return mouse and control to user
					BlockInput, off
					BlockInput, MouseMoveOff
					MsgBox Can't find image , , 3
					return -1
				}
			}
			else
			{
				break
			}
		}
		else
		{
			break
		}
	}

	MouseMove, %FoundX%, %FoundY%, 0	;---------------- Set mouse location to time line

	Send, {Shift down}					;---------------- Add selection of previous clip (so now both pre, and next are selected)
	MouseClick, left, 0, 50 , , , , R
	Send, {Shift up}

	Send ^d								;---------------- Apply default transition bettwen the two clips
	Send {Right 5}						;---------------- cleanup
	Send ^+{A}

	MouseMove, %xpos%, %ypos%, 0		;------------- return mouse and control to user
	BlockInput, off
	BlockInput, MouseMoveOff 
	return 0
}

;; NOTE: create custom transition bin for the transition that you want to apply, make sure you flat them into the bin. Call the bin "Flat Video Transitions"

;; select a transition from the "Flat Video Transitions" bin, based on index of transition in the list
select_transition(transitioncount:=0) {
	SetKeyDelay, 0
	MouseGetPos, xpos, ypos 			;----------------Prevents the user from interfering with the operation.
	BlockInput, on
	BlockInput, MouseMove 				

	Send +{7} 							;---------- switch  effects panel
	Send +{F} 							;---------- switch to the find box
	ControlGetPos, X, Y, Width, Height, Edit7, ahk_class Premiere Pro

	Send Flat Video Transitions
	MouseMove, X+16, Y+150, 0			;---------- Move to first transition from the 'Flat Video Transitions' custom list
	MouseClick, Left
	sleep 10							;---------- scroll up (mouse) to make sure we are on the first transition
	Loop 40
		Click, WheelUp
	sleep 10
	Loop %transitioncount% 				;---------- scroll to desired transition
		Click, WheelDown
	sleep 10
	MouseClick, Left

	MouseClick, Right					;---------- set the transition as default 
	sleep 10
	MouseClick, Left , 5, 40, , , , R


	sleep 1 							;---------- switch back to timeline panel
	Send {tab}
	Send +{3}

	MouseMove, %xpos%, %ypos%, 0		;------------- return mouse and control to user
	BlockInput, off
	BlockInput, MouseMoveOff 
	return 0
}



;; Slect one of the 32 transitions from the "Flat Video Transitions" bin and apply to timeline
F10::
	Random, rand, 0, 32
	select_transition(rand)
	apply_transition()
	return

;; In loop, 10 times
F11::
	Loop, 10 {
		rand = 1
		Random, rand, 0, 32
		select_transition(rand)
		if (apply_transition() != 0) {
			return
		}
		sleep 1000
	}
	return

#IfWinActive

