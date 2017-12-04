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
END dd 0

;Shift Status
SHIFT_STATUS db 0

section .text
extern clear
extern scan
extern calibrate
extern printscreen
extern putc
extern traslate

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
  jmp end_input
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
  mov byte [TEXT], 3
  mov dword [END], TEXT
  ; Insertion mode main loop
  game.loop:
    .input:
      ;Cleaning registries.
      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx
      ;Printing the screen.
      mov eax, TEXT
      add eax, [SCREEN_START]
      add eax, [CURSOR]
      push eax
      sub eax, [CURSOR]
      push eax
      call printscreen
      ;End printing the screen.
      call get_input;Get the Input.
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
    bind KEY.L_SH , Shift_Pressed
    bind KEY.L_SH+128 , Shift_Released
    bind KEY.UpArrow , UpArrow_Pressed
    bind KEY.DownArrow , DownArrow_Pressed
    bind KEY.LeftArrow , LeftArrow_Pressed
    bind KEY.RightArrow , RightArrow_Pressed
    bind KEY.BKSP , Backspace_Pressed
    bind KEY.Enter , Enter_Pressed

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
      ;Insert a new char
      push edx
      push dword 1
      push dword [END]
      call traslate
      inc dword [END]
      ;Write char in al to the Text
      mov [edx], bl
      ;Move cursor one position
      push dword 1
      call mov_cursor

    ;End get_input
    end_input:
    pop ax
    pop eax
    pop edx
    pop ebx
    pop ecx
    ret

;New method
mov_cursor:
  push ebp
  mov ebp, esp
  push ecx

  mov ecx, [ebp + 8]
  add dword [CURSOR], ecx
  cmp dword [CURSOR], 0
  jge .not_negative
    sub dword [SCREEN_START], 80
    cmp dword [SCREEN_START], 0
    jge .not_negative_screen
    add dword [SCREEN_START], 80
    sub dword [CURSOR], ecx
    jmp .end 
    .not_negative_screen:
    push dword 80
    call mov_cursor
    jmp .end
  .not_negative:

  cmp dword [CURSOR], 1920
  jl .end
    add dword [SCREEN_START], 80
    cmp dword [SCREEN_START], 10000000
    jle .not_end_text
    sub dword [SCREEN_START], 80
    sub dword [CURSOR], ecx
    jmp .end 
    .not_end_text:
    push dword -80
    call mov_cursor
  .end:
  pop ecx
  pop ebp
  ret 4


;Bindings Methods
Shift_Pressed:
  mov byte [SHIFT_STATUS], 1
  ret

Shift_Released:
  mov byte [SHIFT_STATUS], 0
  ret

UpArrow_Pressed:
  push eax
  push dword -80
  call mov_cursor
  .loop:
  mov eax, TEXT
  add eax, [SCREEN_START]
  add eax, [CURSOR]
  cmp byte [eax], 0
  jne .end
  push dword -1
  call mov_cursor
  jmp .loop
  .end:
  pop eax
  ret

DownArrow_Pressed:
  push eax
  push dword 80
  call mov_cursor
  .loop:
  mov eax, TEXT
  add eax, [SCREEN_START]
  add eax, [CURSOR]
  cmp byte [eax], 0
  jne .end
  push dword -1
  call mov_cursor
  jmp .loop
  .end:
  pop eax
  ret
  
LeftArrow_Pressed:
  push eax
  push dword -1
  call mov_cursor
  .loop:
  mov eax, TEXT
  add eax, [SCREEN_START]
  add eax, [CURSOR]
  cmp byte [eax], 0
  jne .end
  push dword -1
  call mov_cursor
  jmp .loop
  .end:
  pop eax
  ret
  
RightArrow_Pressed:
  push eax
  push dword 1
  call mov_cursor
  .loop:
  mov eax, TEXT
  add eax, [SCREEN_START]
  add eax, [CURSOR]
  cmp eax, [END]
  ja .endtext
  cmp byte [eax], 0
  jne .end
  push dword 1
  call mov_cursor
  mov eax, TEXT
  add eax, [SCREEN_START]
  add eax, [CURSOR]
  jmp .loop
  .endtext:
  call LeftArrow_Pressed
  .end:
  pop eax
  ret

Backspace_Pressed:
  push eax
  mov eax, TEXT
  add eax, [SCREEN_START]
  add eax, [CURSOR]
  cmp eax, TEXT
  je .end
  call LeftArrow_Pressed
  mov eax, TEXT
  add eax, [SCREEN_START]
  add eax, [CURSOR]
  push eax
  push dword -1
  push dword [END]
  call traslate
  dec dword [END]
  .end:
  pop eax
  ret

Enter_Pressed:
  push eax
  push edx
  push ebx
  xor edx, edx
  xor eax, eax
  xor ebx, ebx
  ;Calculating spaces to traslate later
  mov eax, [CURSOR]
  mov ebx, 80
  div ebx
  sub ebx, edx
  ;Writing the enter char
  ;Set edx on the cursor correct place.
  xor edx, edx
  mov edx, TEXT
  add edx, [SCREEN_START]
  add edx, [CURSOR]
  ;Putting the blank spaces
  push edx
  push ebx
  push dword [END]
  call traslate
  ;Write char in al to the Text
  mov byte [edx], 10
  add dword [END], ebx
  push ebx
  call mov_cursor
  pop ebx
  pop edx
  pop eax
  ret