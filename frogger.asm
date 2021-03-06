; Frogger UEFI bootable
format pe64 dll efi
entry main

section '.text' code executable readable

; To use the uefi Input/Output functions
include 'uefi.inc'

main:

	; Initialize UEFI library
	InitializeLib

	; Equivalent to SystemTable->ConOut->OutputString(SystemTable->ConOut, "Message")
	uefi_call_wrapper ConOut, OutputString, ConOut, welcome_message
	uefi_call_wrapper ConOut, OutputString, ConOut, input_message

	jmp play

play:

	;	Equivalent to SystemTable->ConIn->Reset(SystemTable->ConIn, FALSE);
	; Clean the Input bufer
	uefi_call_wrapper ConIn, Reset, ConIn, 0

	call move_vehicles
	call show_board
	call get_user_input
	call identify_key
	jmp play

move_car:
	xor eax,eax

	; Store the current car position
	mov eax,[car_position]

	; Delete car and add an empty cell
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Move the car to the left
	sub eax,2

	call car_reach_end
	call check_car_colission

	; Draw the car "X"
	mov cl,byte[vehicle]
	mov byte[board+eax],cl

	; Update the postion
	mov [car_position],eax

	retn

move_truck:
	xor eax,eax

	; Store the current truck position
	mov eax,[truck_position]

	; Delete truck and add an empty cell
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Move the first "@" 2 positions to the right
	add eax,4

	call truck_reach_end
	call check_truck_colission

	; Draw the truck head "XX"
	mov cl,byte[van]
	mov byte[board+eax],cl

	; Set the truck default position to the first '@'
	sub eax,2

	; Update the position
	mov [truck_position],eax

	retn

move_bus:
	xor eax,eax

	; Store the current bus position
	mov eax,[bus_position]

	; Delete bus and add an empty cell
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Move the first "X" 3 positions to the right
	; "xXX" -> "XX" -> "XXx"
	add eax,6

	call bus_reach_end
	call check_bus_colission

	; Draw the bus head "XXX"
	mov cl,byte[bus]
	mov byte[board+eax],cl

	; Set the truck default position to the first 'X'
	sub eax,4

	; Update position
	mov [bus_position],eax
	retn
move_log:
	xor eax,eax

	; Store the current log position
	mov eax,[log_position]

	; Delete log and add an empty cell
	mov cl,byte[water]
	mov byte[board+eax],cl

	; Move the first "=" 3 positions to the right

	add eax,6

	call log_reach_end
	call check_log_colission

	; Draw the log head "==="
	mov cl,byte[log]
	mov byte[board+eax],cl

	; Set the log default position to the first '='
	sub eax,4

	; Update position
	mov [log_position],eax
	retn
move_log2:
	xor eax,eax

	; Store the current log position
	mov eax,[log2_position]

	; Delete log and add an empty cell
	mov cl,byte[water]
	mov byte[board+eax],cl

	; Move the first "=" 3 positions to the right

	add eax,6

	call log2_reach_end
	call check_log2_colission

	; Draw the log head "==="
	mov cl,byte[log]
	mov byte[board+eax],cl

	; Set the log default position to the first '='
	sub eax,4

	; Update position
	mov [log2_position],eax
	retn
move_log3:
	xor eax,eax

	; Store the current log position
	mov eax,[log3_position]

	; Delete log and add an empty cell
	mov cl,byte[water]
	mov byte[board+eax],cl

	; Move the first "=" 3 positions to the right

	add eax,6

	call log3_reach_end
	call check_log3_colission

	; Draw the log head "==="
	mov cl,byte[log]
	mov byte[board+eax],cl

	; Set the log default position to the first '='
	sub eax,4

	; Update position
	mov [log3_position],eax
	retn
move_log4:
	xor eax,eax

	; Store the current log position
	mov eax,[log4_position]

	; Delete log and add an empty cell
	mov cl,byte[water]
	mov byte[board+eax],cl

	; Move the first "=" 3 positions to the right

	add eax,6

	call log4_reach_end
	call check_log4_colission

	; Draw the log head "==="
	mov cl,byte[log]
	mov byte[board+eax],cl

	; Set the log default position to the first '='
	sub eax,4

	; Update position
	mov [log4_position],eax
	retn

; This subroutine checks if the car has reached the left limit
car_reach_end:
	add eax,2
	cmp eax,[left_limit_row6]
	je restart_car

	sub eax,2
	retn

; This subroutine checks if the car has reached the right limit
truck_reach_end:
	sub eax,2
	cmp eax,[right_limit_row5]
	je restart_truck

	add eax,2
	retn

; This subroutine checks if the car has reached the right limit
bus_reach_end:
	sub eax,2
	cmp eax,[right_limit_row4]
	je restart_bus

	add eax,2
	retn

log_reach_end:
	sub eax,2
	cmp eax,[right_limit_row2]
	je restart_log

	add eax,2
	retn
log2_reach_end:
	sub eax,2
	cmp eax,[right_limit_row2]
	je restart_log2

	add eax,2
	retn
log3_reach_end:
	sub eax,2
	cmp eax,[right_limit_row3]
	je restart_log3

	add eax,2
	retn
log4_reach_end:
	sub eax,2
	cmp eax,[right_limit_row3]
	je restart_log4

	add eax,2
	retn
	

; This subroutine restart the car position to the first right position
restart_car:
	; Delete car position
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Get the start position of the row
	sub eax,2
	add eax,[board_cols]

	; Draw the "-" at the end of the row
	xor ecx,ecx
	mov cl,byte[vehicle]
	mov byte[board+eax],cl

	; Update car position
	mov [car_position],eax

	jmp play

; This subroutine restart the truck position to the first left position
restart_truck:
	; Delete the 2 van '@@'
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	; Get the start position of the row
	add eax,4
	sub eax,[board_cols]

	; Draw the '@@' at the begining of the row
	xor ecx,ecx
	mov cl,byte[van]
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl

	; Set the truck default position to the first '@'
	sub eax,2

	; Update truck postion
	mov [truck_position],eax

	jmp play

; This subroutine restart the bus position to the first left position
restart_bus:
	; Delete the 3 bus 'XXX'
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	; Get the start position of the row
	add eax,6
	sub eax,[board_cols]

	; Draw the ']]]' at the begining of the row
	xor ecx,ecx
	mov cl,byte[bus]
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl

	; Set the bus default position to the first ']'
	sub eax,4

	; Update the bus position
	mov [bus_position],eax

	jmp play

restart_log:
	; Delete the 3 log '==='
	mov cl,byte[water]
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	; Get the start position of the row
	add eax,6
	sub eax,[board_cols]

	; Draw the '===' at the begining of the row
	xor ecx,ecx
	mov cl,byte[log]
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl

	; Set the log default position to the first '='
	sub eax,4

	; Update the bus position
	mov [log_position],eax

	jmp play
restart_log2:
	; Delete the 3 log '==='
	mov cl,byte[water]
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	; Get the start position of the row
	add eax,6
	sub eax,[board_cols]

	; Draw the '===' at the begining of the row
	xor ecx,ecx
	mov cl,byte[log]
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl

	; Set the log default position to the first '='
	sub eax,4

	; Update the bus position
	mov [log2_position],eax

	jmp play
restart_log3:
	; Delete the 3 log '==='
	mov cl,byte[water]
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	; Get the start position of the row
	add eax,6
	sub eax,[board_cols]

	; Draw the '===' at the begining of the row
	xor ecx,ecx
	mov cl,byte[log]
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl

	; Set the log default position to the first '='
	sub eax,4

	; Update the bus position
	mov [log3_position],eax

	jmp play

restart_log4:
	; Delete the 3 log '==='
	mov cl,byte[water]
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	; Get the start position of the row
	add eax,6
	sub eax,[board_cols]

	; Draw the '===' at the begining of the row
	xor ecx,ecx
	mov cl,byte[log]
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl

	; Set the log default position to the first '='
	sub eax,4

	; Update the bus position
	mov [log4_position],eax

	jmp play
; This subroutine checks if the vehicle has colissioned the Frog
check_car_colission:

	xor ecx,ecx
	mov cl,byte[frog]

	cmp byte[board+eax],cl
	je game_over

	retn

; This subroutine checks if the vehicle has colissioned the Frog
check_truck_colission:

	xor ecx,ecx
	mov cl,byte[frog]

	cmp byte[board+eax],cl
	je game_over

	retn


; This subroutine checks if the vehicle has colissioned the Frog
check_bus_colission:

	xor ecx,ecx
	mov cl,byte[frog]

	cmp byte[board+eax],cl
	je game_over

	retn
; This subroutine checks if the vehicle has colissioned the Frog
check_log_colission:

	xor ecx,ecx
	mov cl,byte[frog]

	cmp byte[board+eax],cl
	je play
	retn
check_log2_colission:

	xor ecx,ecx
	mov cl,byte[frog]
	cmp byte[board+eax],cl
	je play
	retn
check_log3_colission:

	xor ecx,ecx
	mov cl,byte[frog]
	cmp byte[board+eax],cl
	je play
	retn
check_log4_colission:

	xor ecx,ecx
	mov cl,byte[frog]
	cmp byte[board+eax],cl
	je play
	retn

move_vehicles:
	call move_car
	call move_truck
	call move_bus
	call move_log
	call move_log2
	call move_log3
	call move_log4
	retn

show_board:
	uefi_call_wrapper ConOut, OutputString, ConOut, board
	retn

; This subroutine waits until the user press any key
get_user_input:
	uefi_call_wrapper ConIn, ReadKeyStroke, ConIn, INPUT_KEY
	cmp byte[INPUT_KEY.UnicodeChar], 0
	jz get_user_input
	retn

; If the user press any other key just the vehicles move
identify_key:
	call clear_screen
	cmp byte[INPUT_KEY+2], "w"
	je move_up
	cmp byte[INPUT_KEY+2], "a"
	je move_left
	cmp byte[INPUT_KEY+2], "s"
	je move_down
	cmp byte[INPUT_KEY+2], "d"
	je move_right

	retn

clear_screen:
	; call uefi function to clear the screen
	uefi_call_wrapper ConOut, ClearScreen, ConOut
	retn

move_down:

	uefi_call_wrapper ConOut, OutputString, ConOut, down_message

	xor eax,eax

	; Store the frog poistion
	mov eax,[frog_position]

	call check_first_row

	; Delete frog adn add an empty cell
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Move the frog one row up
	add eax,72

	call check_game_over

	; Draw 'R' in new position
	mov cl,byte[frog]
 	mov byte[board+eax],cl

	; Update frog position
	mov [frog_position],eax

	retn

move_up:

	uefi_call_wrapper ConOut, OutputString, ConOut, up_message

	xor eax,eax

	; Store the frog poistion
	mov eax,[frog_position]

	; Delete frog and add an empty cell
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Move the frog one row down
	sub eax,72

	call check_game_over
	call check_win_game

	; Draw the 'R' in new position
	mov cl,byte[frog]
 	mov byte[board+eax],cl

	; Update frog position
	mov [frog_position],eax

	retn

move_right:

	uefi_call_wrapper ConOut, OutputString, ConOut, right_message

	xor eax,eax

	; Store the for poistion
	mov eax,[frog_position]

	; Delete the frog and add an empty cell
 	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Move frog to the next right position
	add eax,2

	call check_game_over
	call right_limit_reached

	; Draw the 'R' in new position
	mov cl,byte[frog]
	mov byte[board+eax],cl

	; Update frog position
	mov [frog_position],eax

	retn

move_left:

	uefi_call_wrapper ConOut, OutputString, ConOut, left_message

	xor eax,eax

	; Store the frog position
	mov eax,[frog_position]

	; Delete frog position and add an empty cell
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Move frgo to the next left position
	sub eax,2

	call check_game_over
	call left_limit_reached

	; Draw the 'R' in the next position
	mov cl,byte[frog]
	mov byte[board+eax],cl

	; Update frog position
	mov [frog_position],eax

	retn

check_game_over:
	; Check if frog crashed
	; Check next position
	cmp byte[board+eax], '-'
	je game_over
	cmp byte[board+eax], '@'
	je game_over
	cmp byte[board+eax], ']'
	je game_over
	cmp byte[board+eax], 's'
	je game_over
	retn

; Check if the frog is in the 5th row (where starts)
check_first_row:
	add eax,72
	cmp eax, [right_limit_row7]
	jg play

	sub eax,72
	retn

check_win_game:
	cmp eax,[board_cols]
	jl win_game
	retn

; Check if frog_position has reached a left limit
right_limit_reached:
	sub eax,2
	cmp eax,[right_limit_row7]
	je restart_frog_to_left
	cmp eax,[right_limit_row6]
	je restart_frog_to_left
	cmp eax,[right_limit_row5]
	je restart_frog_to_left
	cmp eax,[right_limit_row4]
	je restart_frog_to_left
	cmp eax,[right_limit_row3]
	je restart_frog_to_left_water
	cmp eax,[right_limit_row2]
	je restart_frog_to_left_water

	; Restablish again frog position
	add eax,2

	retn

restart_frog_to_left:
	; Delete frog position
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Get the last position of the row
	add eax,2
	sub eax,[board_cols]

	mov cl,byte[frog]
	mov byte[board+eax],cl

	; Update frog position
	mov [frog_position],eax

	jmp play

restart_frog_to_left_water:
	; Delete frog position
	mov cl,byte[water]
	mov byte[board+eax],cl

	; Get the last position of the row
	add eax,2
	sub eax,[board_cols]

	mov cl,byte[frog]
	mov byte[board+eax],cl

	; Update frog position
	mov [frog_position],eax

	jmp play

; Check if frog_position has reached a left limit
left_limit_reached:
	; Because must check the left limit position
	add eax,2
	cmp eax,[left_limit_row7]
	je restart_frog_to_right
	cmp eax,[left_limit_row6]
	je restart_frog_to_right
	cmp eax,[left_limit_row5]
	je restart_frog_to_right
	cmp eax,[left_limit_row4]
	je restart_frog_to_right
	cmp eax,[left_limit_row3]
	je restart_frog_to_right_water
	cmp eax,[left_limit_row2]
	je restart_frog_to_right_water

	; Restablish again frog position
	sub eax,2

	retn

restart_frog_to_right:
	; Delete frog position
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Get the start position of the row
	sub eax,2
	add eax,[board_cols]

	mov cl,byte[frog]
	mov byte[board+eax],cl

	; Update frog position
	mov [frog_position],eax

	jmp play
restart_frog_to_right_water:
	; Delete frog position
	mov cl,byte[water]
	mov byte[board+eax],cl

	; Get the start position of the row
	sub eax,2
	add eax,[board_cols]

	mov cl,byte[frog]
	mov byte[board+eax],cl

	; Update frog position
	mov [frog_position],eax

	jmp play

game_over:
	call clear_screen
	uefi_call_wrapper ConOut, OutputString, ConOut, lose_message
	jmp finish

win_game:
	call clear_screen
	uefi_call_wrapper ConOut, OutputString, ConOut, win_message
	jmp finish

finish:
	mov eax, EFI_SUCCESS
	uefi_call_wrapper BootServices, Exit, BootServices

section '.data' data readable writeable

	; Game Logic Data
	right_limit_row1	dd		68
	right_limit_row2	dd		142
	right_limit_row3	dd		214
	right_limit_row4	dd		286
	right_limit_row5	dd		358
	right_limit_row6	dd		430
	right_limit_row7	dd		502

	left_limit_row1	dd		8
	left_limit_row2	dd		76
	left_limit_row3	dd		148
	left_limit_row4	dd		220
	left_limit_row5	dd		292
	left_limit_row6	dd		364
	left_limit_row7	dd		436

	frog_position		dd		470
	bus_position		dd		224
	log_position        dd      80
	log2_position        dd      100
	log3_position        dd      172
	log4_position        dd      192
	truck_position	dd		326
	car_position		dd		386
	board_rows			dd		7
	board_cols			dd		68
	len_board				dd		504

	board								du		13,10,'__________________________________',\
												13,10,'sss===sssssss===ssssssssssssssssss',\
												13,10,'sssssssssssss===sssssss===ssssssss',\
												13,10,'___]]]____________________________',\
												13,10,'___________________@@_____________',\
								 				13,10,'___________-______________________',\
								 				13,10,'_________________R________________',13,10,0

	frog						du		'R'
 	empty_cell			du		'_'
	water				du  	's'
	vehicle					du		'-'
	van					du		'@'
	bus					du		']'
	log					du		'='
	INPUT_KEY				EFI_INPUT_KEY
	MinCod   EQU 4Bh
	; Output Messages
	input_message 	du 		'To move your Frog use (W - A - S - D)...',13,10,0
	lose_message  	du 		'You have lost! Thanks for playing!',13,10,\
												':(',13,0
	win_message	  	du 		'You have won! Thanks for playing!',13,10,\
												':D',13,0
	left_message 		du		'Move left',13,10,0
	right_message 	du		'Move right',13,10,0
	up_message 			du		'Move up',13,10,0
	down_message 		du		'Move down',13,10,0
	welcome_message du		13,10,'Welcome!',13,10,'This is the Frogger Game V0.1',13,10,\
												'If you are watching this is because the Operating System is not working anymore',\
												' so we thought that this would be a very joyful and funny Panic Mode.',13,10,10,\
												'Enjoy it, greetings.',13,10,10,10,0

section '.reloc' fixups data discardable