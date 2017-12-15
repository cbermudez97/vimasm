%include "keyboard.mac"

section .data
global RES_START
global RES_END
global RES_SIZE
RES_SIZE dd 0
RES_START dd 0;initial position
RES_END dd 0;end position
;the text to copy
global COPY
COPY times 10000000 db 0
VISUAL_CONSOLE db " --VISUAL--                                                                     "
ENDING db 0

section .text
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
extern setcursor

%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  jmp end_input
  %%next:
%endmacro

global visual
visual:
    mov byte [ENDING], 0
    mov eax, TEXT
    add eax, [SCREEN_START]
    add eax, [CURSOR]
    mov [RES_START], eax
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
      push VISUAL_CONSOLE
      call printconsole
      ;Get the input
      call get_input
      mov eax, TEXT
      add eax, [SCREEN_START]
      add eax, [CURSOR]
      mov dword [RES_END], eax
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
  mov byte [COPY_FROM], 1
  mov edi, COPY
  mov eax, [RES_START]
  cmp eax, [RES_END]
  jb .lesser
  .greater:
  mov ecx, [RES_START]
  sub ecx, [RES_END]
  inc ecx
  mov esi, [RES_END]
  jmp .endcmp
  .lesser:
  mov ecx, [RES_END]
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

fixcopied:
  pushad
  mov edi, COPY
  add edi, [RES_SIZE]
  dec edi
  cmp byte [edi], 3
  jne .continue
  dec dword [RES_SIZE]
  .continue:
  popad
  ret