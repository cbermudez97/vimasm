%include "keyboard.mac"
section .data

section .text
extern CURSOR
extern SCREEN_START
extern TEXT
extern insertion
extern printscreen
extern scan
extern UpArrow_Pressed
extern DownArrow_Pressed
extern RightArrow_Pressed
extern LeftArrow_Pressed

%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  jmp end_input
  %%next:
%endmacro

global normal
normal:
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
      ;Print in the Console
      call get_input
    jmp .loop
    ret

get_input:
    push eax
    call scan
    push ax
    ;bindings here
    bind KEY.I, to_insertion
    end_input:
    pop ax
    pop eax
    ret

    to_insertion:
    add esp,4;the return dir
    pop ax;get input ax
    pop eax;get input eax
    add esp,4;the get input return dir
    push dword insertion
    ret