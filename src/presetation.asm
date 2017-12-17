%include "keyboard.mac"
section .data
PRES db "******************************************************************************* ","*                 ",35,"     ",35,"                                                     * ","*                 ",35,"     ",35,"  ",35,"  ",35,"    ",35,"    ",35,35,"     ",35,35,35,35,"   ",35,"    ",35,"                  * ","*                 ",35,"     ",35,"  ",35,"  ",35,35,"  ",35,35,"   ",35,"  ",35,"   ",35,"       ",35,35,"  ",35,35,"                  * ","*                 ",35,"     ",35,"  ",35,"  ",35," ",35,35," ",35,"  ",35,"    ",35,"   ",35,35,35,35,"   ",35," ",35,35," ",35,"                  * ","*                  ",35,"   ",35,"   ",35,"  ",35,"    ",35,"  ",35,35,35,35,35,35,"       ",35,"  ",35,"    ",35,"                  * ","*                   ",35," ",35,"    ",35,"  ",35,"    ",35,"  ",35,"    ",35,"  ",35,"    ",35,"  ",35,"    ",35,"                  * ","*                    ",35,"     ",35,"  ",35,"    ",35,"  ",35,"    ",35,"   ",35,35,35,35,"   ",35,"    ",35,"                  * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                    Proyecto de Programacion de Maquinas                     * ","*                                                                             * ","*                                Integrantes:                                 * ","*                           -Carlos Bermudez Porto   C-212                    * ","*                           -Roberto Marti Cedeno    C-212                    * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*******************************************************************************"
CONSOLE_TEXT db "                          <PRESS ENTER TO CONTINUE>                             "

section .text
extern CURSOR
extern SCREEN_START
extern TEXT
extern END
extern scan
extern printscreen
extern normal
extern timer
extern CONTROL_STATUS
extern SHIFT_STATUS
extern COPY_FROM
extern traslate
extern printconsole
extern Control_Pressed
extern Control_Released
extern Shift_Pressed
extern Shift_Released

%macro bind 2
  cmp byte [esp], %1
  jne %%next
  call %2
  %%next:
%endmacro

global presentation
presentation:
    mov dword [timer], 0
    mov dword [timer+4], 0
    push PRES
    call printscreen
    push CONSOLE_TEXT
    call printconsole
    xor eax, eax
    again:
    call scan
    push ax
    cmp eax, KEY.Enter
    je start
    bind KEY.Ctrl, Control_Pressed
    bind KEY.Ctrl+128, Control_Released
    bind KEY.L_SH , Shift_Pressed
    bind KEY.L_SH+128 , Shift_Released
    bind KEY.R_SH , Shift_Pressed
    bind KEY.R_SH+128 , Shift_Released
    pop ax
    jmp again
    start:
    ;Initializing the Text
    mov byte [TEXT], 3
    mov dword [END], TEXT
    mov dword [SCREEN_START], 0
    mov dword [CURSOR], 0
    mov byte [COPY_FROM], 0
    done:
    call normal
    ;Cleaning TEXT
    mov eax, TEXT
    sub eax, [END]
    push dword TEXT
    push eax
    push dword [END]
    call traslate
    jmp presentation
    ret