%include "keyboard.mac"

section .data
VISUAL_CONSOLE db " --VISUAL LINE--                                                                     "
ENDING db 0

section .text
extern RES_START
extern RES_END
extern RES_SIZE
extern COPY
extern CURSOR
extern SCREEN_START
extern TEXT
extern END
extern normal
extern printscreen
extern scan
extern UpArrow_Pressed
extern DownArrow_Pressed
extern RightArrow_Pressed
extern LeftArrow_Pressed
extern COPY_FROM
extern printconsole
extern interchange
extern setcursor
extern Control_Pressed
extern Control_Released
extern Shift_Pressed
extern Shift_Released

%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  jmp end_input
  %%next:
%endmacro

global visual_line
visual_line:
    mov byte [ENDING], 0
    ;Calculate the Start of the Line
    mov eax, [CURSOR]
    xor edx, edx
    mov ebx, 80
    div ebx
    xor edx, edx
    mul ebx
    add eax, TEXT
    add eax, [SCREEN_START]
    mov [RES_START], eax
    .loop:
      ;Cleaning registries.
      xor eax, eax
      xor ebx, ebx
      xor ecx, ecx
      xor edx, edx
      ;Calculate
      mov eax, [CURSOR]
      xor edx, edx
      mov ebx, 80
      div ebx
      xor edx, edx
      mul ebx
      add eax, TEXT
      add eax, [SCREEN_START]
      mov [RES_END], eax
      ;Printing the screen.
      mov eax, TEXT
      add eax, [SCREEN_START]
      add eax, [CURSOR]
      push eax
      sub eax, [CURSOR]
      push eax
      call printscreen
      ;Highlight text
      call highlight
      ;Print Cursor
      push dword [CURSOR]
      call setcursor
      ;Print in the Console
      push VISUAL_CONSOLE
      call printconsole
      ;Get the input
      call get_input
    cmp byte [ENDING], 1
    je .return
    jmp .loop
    .return:
    ret

get_input:
    push eax
    call scan
    push ax
    ;bindings here
    bind KEY.ESC, to_normal
    bind KEY.UpArrow , UpArrow_Pressed
    bind KEY.DownArrow , DownArrow_Pressed
    bind KEY.LeftArrow , LeftArrow_Pressed
    bind KEY.RightArrow , RightArrow_Pressed
    bind KEY.Y, copyselected
    bind KEY.Ctrl, Control_Pressed
    bind KEY.Ctrl+128, Control_Released
    bind KEY.L_SH , Shift_Pressed
    bind KEY.L_SH+128 , Shift_Released
    bind KEY.R_SH , Shift_Pressed
    bind KEY.R_SH+128 , Shift_Released
    end_input:
    pop ax
    pop eax
    ret

to_normal:
   mov byte [ENDING], 1
   ret

copyselected:
  pushad
  .notatstart:
  cld
  mov byte [COPY_FROM], 2
  mov edi, COPY
  mov eax, [RES_START]
  cmp eax, [RES_END]
  jb .lesser
  .greater:
  mov ecx, [RES_START]
  add ecx, 79
  sub ecx, [RES_END]
  inc ecx
  mov esi, [RES_END]
  jmp .endcmp
  .lesser:
  mov ecx, [RES_END]
  add ecx, 79
  sub ecx, eax
  inc ecx
  mov esi, [RES_START]
  .endcmp:
  mov [RES_SIZE], ecx
  rep movsb
  popad
  ;exiting to normal mode
  mov byte [ENDING], 1
  call fixcopied
  ret

fixcopied:;fix needed
  pushad
  mov edi, COPY
  mov esi, COPY
  add esi, RES_SIZE
  dec esi
  .loop:
  cmp byte [edi], 3
  jne .noend
  sub edi, COPY
  mov [RES_SIZE], edi
  jmp .endloop
  .noend:
  cmp edi, esi
  je .endloop
  inc edi
  jmp .loop
  .endloop:
  popad
  ret

highlight:
  pushad
  mov eax, [RES_START]
  mov ebx, [RES_END]
  sub eax, TEXT
  sub eax, [SCREEN_START]
  sub ebx, TEXT
  sub ebx, [SCREEN_START]
  cmp eax, 0
  jge .next
  mov eax, 0
  .next:
  cmp eax, 1920
  jle .next1
  mov eax, 1920
  .next1:
  cmp ebx, 0
  jge .next2
  mov ebx, 0
  .next2:
  cmp ebx, 1920
  jle .next3
  mov ebx, 1920
  .next3:
  cmp eax, ebx
  jb .lesser
  .greater:
  add eax, 79
  push eax
  push ebx
  call interchange
  jmp .endcmp
  .lesser:
  add ebx, 79
  push ebx
  push eax
  call interchange
  .endcmp:
  popad
  ret