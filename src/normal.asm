%include "keyboard.mac"
section .data
CONTROL_STATUS db 0


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
    bind KEY.UpArrow , UpArrow_Pressed
    bind KEY.DownArrow , DownArrow_Pressed
    bind KEY.LeftArrow , LeftArrow_Pressed
    bind KEY.RightArrow , RightArrow_Pressed
    bind KEY.Ctrl, Control_Pressed
    bind KEY.Ctrl+128, Control_Released  
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
    