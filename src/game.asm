%include "video.mac"
%include "keyboard.mac"
section .data
ASCII_CODE_S db  0,27,49,50,51,52,53,54,55,56,57,48,45,61,8,9,113,119,101,114,116,121,117,105,111,112,91 ,93 ,13,0,97,115,100,102,103,104,106,107,108,59,39,96 ,0,92 ,122,120,99,118,98,110,109,44,46,47,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,45,0,0,0,43,0,0,0,0,0
ASCII_CODE_NS db 0,27,33,64,35,36,37,94,38,42,40,41,95,43,8,9,81 ,87 ,69 ,82 ,84 ,89 ,85 ,73 ,79 ,80 ,123,125,13,0,65,83 ,68 ,70 ,71 ,72 ,74 ,75 ,76 ,58,34,126,0,124,90 ,88 ,67,86 ,66,78 ,77 ,60,62,63,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,45,0,0,0,43,0,0,0,0,0
ASCII_CODE_LEN dd 83


section .text
extern clear
extern scan
extern calibrate

;parametro 2 registro donde guardar, parametro 1 codigo hex de la tecla 
%macro GET_ASCII 2.nolist
mov %2, [ASCII_CODE + %1]
%endmacro


; Bind a key to a procedure
%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  %%next:
%endmacro

; Fill the screen with the given background color
%macro FILL_SCREEN 1
  push word %1
  call clear
  add esp, 2
%endmacro

global game
game:
  ; Initialize game

  FILL_SCREEN BG.BLACK

  ; Calibrate the timing
  call calibrate

  ; Snakasm main loop
  game.loop:
    .input:
      call get_input

    ; Main loop.

    ; Here is where you will place your game logic.
    ; Develop procedures like paint_map and update_content,
    ; declare it extern and use here.

    jmp game.loop


draw.red:
  FILL_SCREEN BG.RED
  ret


draw.green:
  FILL_SCREEN BG.GREEN
  ret


get_input:
    call scan
    push ax
    ; The value of the input is on 'word [esp]'
    
    ; Your bindings here
    cmp al, KEY.UP
    jne not_up
    call draw.red
    not_up:
    cmp al, KEY.DOWN
    jne not_down
    call draw.green
    not_down:

    add esp, 2 ; free the stack
    ret
