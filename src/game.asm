%include "video.mac"
%include "keyboard.mac"
section .data
;Data related to the hex-ascii translate.
ASCII_CODE_NS db  0,27,49,50,51,52,53,54,55,56,57,48,45,61,8,9,113,119,101,114,116,121,117,105,111,112,91 ,93 ,13,0,97,115,100,102,103,104,106,107,108,59,39,96 ,0,92 ,122,120,99,118,98,110,109,44,46,47,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,45,0,0,0,43,0,0,0,0,0
ASCII_CODE_S  db  0,27,33,64,35,36,37,94,38,42,40,41,95,43,8,9,81 ,87 ,69 ,82 ,84 ,89 ,85 ,73 ,79 ,80 ,123,125,13,0,65,83 ,68 ,70 ,71 ,72 ,74 ,75 ,76 ,58,34,126,0,124,90 ,88 ,67,86 ,66,78 ,77 ,60,62,63,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,45,0,0,0,43,0,0,0,0,0
ASCII_CODE_LEN dd 83

;Data related to the text and cursor.
TEXT times 10000000 db 0
SCREEN_START dd 0
CURSOR dd 0

;Shift Status
SHIFT_STATUS db 0


section .text
extern clear
extern scan
extern calibrate
extern PrintScreen
extern putc

;Put in parameter 2 (registry) the ascii code of the key whit hex code parameter 1. No Shift
%macro GET_ASCII_NS 2
mov %2, [ASCII_CODE_NS + %1]
%endmacro
;Put in parameter 2 (registry) the ascii code of the key whit hex code parameter 1. Shift
%macro GET_ASCII_S 2
mov %2, [ASCII_CODE_S + %1]
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
      ;Cleaning registries.
      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx
      call get_input;Get the Input.
      ;Printing the screen.
      mov eax, TEXT
      add eax, [SCREEN_START]
      add eax, [CURSOR]
      cmp eax, TEXT
      je .input
      ;mov bl, [eax-1]
      ;or bx, FG.GRAY
      ;push word 0x0000
      ;push bx
      ;call putc
      push eax
      sub eax, [CURSOR]
      push eax
      call PrintScreen
      ;End printing the screen.
    ; Main loop.
    jmp game.loop
    ret

get_input:
    ;Saving registries
    push ecx
    push ebx
    push edx
    push eax

    call scan; Hex code in eax(al)
    push ax
    ; Check if value is valid
    cmp al, 0
    je end_input
    
    ; Check for bindings.(enter,backspace...)
    bind KEY.L_SH , Shift_Pressed;Shift Pressed?
    bind KEY.L_SH+128 , Shift_Released;Shift Released?

    
    ;Update the the text if char.        
      xor ebx, ebx
      cmp eax, [ASCII_CODE_LEN]
      ja end_input
      mov dl, [SHIFT_STATUS]
      cmp dl, 1
      jne .noShift
      .shift:
      GET_ASCII_S eax, bl
      jmp .continue
      .noShift:
      GET_ASCII_NS eax, bl
      .continue:
      cmp bl, 0
      je end_input

      .update:
      ;Set edx on the cursor correct place.
      mov edx, TEXT
      add edx, [SCREEN_START]
      add edx, [CURSOR]
      ;Write char in al to the Text
      mov [edx], bl
      ;Move cursor one position
      mov ecx, 1
      push ecx
      call adv_cursor

    ;End get_input
    end_input:
    pop ax
    pop eax
    pop edx
    pop ebx
    pop ecx
    ret

;Move CURSOR forward(need correction with the limits in case of bad assumptions!!!)
adv_cursor:
  push ebp
  mov ebp, esp
  push eax
  push ebx
  push ecx
  ;Get parameter
  mov ecx, [ebp + 8]
  ;Get CURSOR
  mov eax, [CURSOR]
  ;Advance CURSOR
  .loop1:
    inc eax
    loop .loop1
  ;While CURSOR is out of screen, advance SCREEN_START
  .loop2:
    mov ebx, SCREEN_START  
    cmp eax, 1920
    jbe .end2;If CURSOR is on screen, end.
    ;Else advance SCREEN_START and adjust CURSOR.
    add ebx, 80
    sub eax, 80
    jmp .loop2
    .end2:
  ;Update CURSOR and SCREEN_START
  mov [SCREEN_START], ebx
  mov [CURSOR], eax
  ;Epilog
  pop ecx
  pop ebx
  pop eax
  pop ebp
  ret 4


  ;Bindings Methods
  Shift_Pressed:
    mov byte [SHIFT_STATUS], 1
    ret
  Shift_Released:
    mov byte [SHIFT_STATUS], 0
    ret