%include "keyboard.mac"
section .data
CONTROL_STATUS db 0
global COPY_FROM
COPY_FROM db 0; 0-no copy 1-visual simple 2-visual line ...
NORMAL_CONSOLE db " --NORMAL--                                                                     "


section .text
extern RES_SIZE
extern CURSOR
extern COPY
extern SCREEN_START
extern TEXT
extern END
extern traslate
extern insertion
extern visual
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
    jmp .loop
    ret

get_input:
    push eax
    call scan
    push ax
    ;bindings here
    bind KEY.I, insertion
    bind KEY.UpArrow , UpArrow_Pressed
    bind KEY.DownArrow , DownArrow_Pressed
    bind KEY.LeftArrow , LeftArrow_Pressed
    bind KEY.RightArrow , RightArrow_Pressed
    bind KEY.Ctrl, Control_Pressed
    bind KEY.Ctrl+128, Control_Released
    bind KEY.V, visual
    bind KEY.P, Paste
    end_input:
    pop ax
    pop eax
    ret

Control_Pressed:
  cmp  byte [CONTROL_STATUS] , 1
  je .end
  mov byte [CONTROL_STATUS], 1
  .end:
  ret

Control_Released:
  cmp  byte [CONTROL_STATUS] , 0
  je .end
  mov byte [CONTROL_STATUS], 0
  .end:
  ret

Paste:
cmp byte [COPY_FROM], 0
je .none
cmp byte [COPY_FROM], 1
jne .line
.simple:
call paste_simple
jmp .none
.line:
;call paste_line
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
rep movsb
call newfix
popad
ret