%include "keyboard.mac"
section .data
global CONTROL_STATUS
CONTROL_STATUS db 0
global COPY_FROM
COPY_FROM db 0; 0-no copy 1-visual simple 2-visual line ...
NORMAL_CONSOLE db " --NORMAL--                                                                     "
ENDING db 0

section .text
extern REPLACE
extern RES_SIZE
extern CURSOR
extern COPY
extern SCREEN_START
extern TEXT
extern END
extern traslate
extern insertion
extern visual_simple
extern visual_line
extern printscreen
extern scan
extern UpArrow_Pressed
extern DownArrow_Pressed
extern RightArrow_Pressed
extern LeftArrow_Pressed
extern timer
extern RES_START
extern RES_END
extern newfix
extern printconsole
extern setcursor
extern Shift_Pressed
extern Shift_Released
extern SHIFT_STATUS

%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  jmp end_input
  %%next:
%endmacro

global normal
normal:
    rdtsc
    mov [timer], eax
    mov [timer+4], edx
    mov byte [ENDING], 0
    .loop:
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
      ;Print Cursor
      push dword [CURSOR]
      call setcursor 
      ;Print in the Console
      push NORMAL_CONSOLE
      call printconsole
      ;Get the input
      call get_input
      cmp byte [ENDING], 1
      je .end
    jmp .loop
    .end:
    ret

get_input:
    push eax
    call scan
    push ax
    ;bindings here
    ;Binds whit control pressed
    bind KEY.I, to_insertion
    bind KEY.UpArrow , UpArrow_Pressed
    bind KEY.DownArrow , DownArrow_Pressed
    bind KEY.LeftArrow , LeftArrow_Pressed
    bind KEY.RightArrow , RightArrow_Pressed
    bind KEY.Ctrl, Control_Pressed
    bind KEY.Ctrl+128, Control_Released
    bind KEY.R, to_replace
    bind KEY.V, to_visuals
    bind KEY.P, Paste
    bind KEY.L_SH , Shift_Pressed
    bind KEY.L_SH+128 , Shift_Released
    bind KEY.R_SH , Shift_Pressed
    bind KEY.R_SH+128 , Shift_Released
    bind KEY.C, to_presentation
    end_input:
    pop ax
    pop eax
    ret

global Control_Pressed
Control_Pressed:
  cmp  byte [CONTROL_STATUS] , 1
  je .end
  mov byte [CONTROL_STATUS], 1
  .end:
  ret

global Control_Released
Control_Released:
  cmp  byte [CONTROL_STATUS] , 0
  je .end
  mov byte [CONTROL_STATUS], 0
  .end:
  ret

global Paste
Paste:
cmp byte [COPY_FROM], 0
je .none
cmp byte [COPY_FROM], 1
jne .line
.simple:
call paste_simple
jmp .none
.line:
call paste_line
.none:
ret

paste_simple:
pushad
cld
mov edi, TEXT
add edi, [SCREEN_START]
add edi, [CURSOR]
mov esi, COPY
mov eax, [RES_START]
mov ecx, [RES_SIZE]
;Traslating the text ecx (size of the new text)
push edi
push ecx
push dword [END]
call traslate
add dword [END], ecx
;Copying
rep movsb
call newfix
popad
ret

paste_line:
pushad
cld
;Getting the starting position
.loop:
mov edi, TEXT
add edi, [SCREEN_START]
add edi, [CURSOR]
cmp byte [edi], 10
je .endloopeof
cmp byte [edi], 3
je .endloop
call RightArrow_Pressed
jmp .loop
.endloop:
;inserting an end of line
push edi
push dword 1
push dword [END]
call traslate
mov byte [edi], 10
inc dword [END]
call newfix
.endloopeof:
;set the cursor on the next end of line or end of file
call RightArrow_Pressed
mov edi, TEXT
add edi, [SCREEN_START]
add edi, [CURSOR]
;Insert the text
mov esi, COPY
mov ecx, [RES_SIZE]
push edi
push ecx
push dword [END]
call traslate
add dword [END], ecx
rep movsb
call newfix
popad
ret

to_visuals:
cmp byte [SHIFT_STATUS], 1;visual line shift + v
jne .next1
call visual_line
jmp .end
.next1:
;cmp byte [CONTROL_STATUS], 1;visual block control + v
;jne .next2
;.next2:
;visual simple
call visual_simple
.end:
ret

to_insertion:
  mov byte [REPLACE], 0
  call insertion
  ret

to_replace:
  cmp byte [SHIFT_STATUS], 1
  jne .no
  mov byte [REPLACE], 1
  call insertion
  .no:
  ret

to_presentation:
  cmp byte [CONTROL_STATUS], 1
  jne .no
  mov byte [ENDING], 1
  .no:
  ret