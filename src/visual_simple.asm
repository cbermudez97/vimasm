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
VISUAL_CONSOLE db " --VISUAL SIMPLE--                                                                     "
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
extern interchange
extern setcursor
extern Control_Pressed
extern Control_Released
extern Shift_Pressed
extern Shift_Released
extern mov_cursor
extern CONTROL_STATUS

%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  jmp end_input
  %%next:
%endmacro

global visual_simple
visual_simple:
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
      ;Calculate
      mov eax, TEXT
      add eax, [SCREEN_START]
      add eax, [CURSOR]
      mov dword [RES_END], eax
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
    ; Binds that need control
    cmp byte [CONTROL_STATUS], 1
    jne nocontrol
    bind KEY.H, reschar
    bind KEY.W, resword
    bind KEY.U, resline
    jmp end_input
    nocontrol:
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
  push eax
  push ebx
  call interchange
  jmp .endcmp
  .lesser:
  push ebx
  push eax
  call interchange
  .endcmp:
  popad
  ret

;Highlighting with movement operators
global resword
resword:
pushad

xor eax,eax
xor ecx,ecx
xor edx,edx
xor ebx,ebx

mov eax, TEXT
add eax, [SCREEN_START]
add eax, [CURSOR]

cmp eax, TEXT
je .end

mov edi, eax
dec edi
.ciclo:
cmp byte [edi], 0
jnz .noescero
inc edi
jmp .seacaba
.noescero:
cmp byte [edi], 10
jnz .noesfindelinea
inc edi
jmp .seacaba
.noesfindelinea:
cmp byte [edi], 32
jnz .noesespacio
inc edi
jmp .seacaba
.noesespacio:
cmp edi, TEXT 
jnz .noesinicio
inc ecx
jmp .seacaba
.noesinicio:
inc ecx
dec edi
jmp .ciclo

.seacaba:
not ecx
inc ecx
push ecx
call mov_cursor
.end:
popad
ret 


global reschar
reschar:
call LeftArrow_Pressed
ret

global resline
resline:
pushad

xor eax,eax
xor ecx,ecx
xor edx,edx
xor ebx,ebx

mov eax, TEXT
add eax, [SCREEN_START]
add eax, [CURSOR]

cmp eax, TEXT
je .end

mov edi,eax
dec edi
.ciclo:
cmp byte [edi], 0
jnz .noescero
inc edi
jmp .seacaba
.noescero:
cmp byte [edi], 10
jnz .noesfindelinea
inc edi
jmp .seacaba
.noesfindelinea:
cmp edi, TEXT 
jnz .noesinicio
inc ecx
jmp .seacaba
.noesinicio:
inc ecx
dec edi
jmp .ciclo

.seacaba:
not ecx
inc ecx
cmp ecx, 0
je .end
push ecx
call mov_cursor
.end:
popad
ret