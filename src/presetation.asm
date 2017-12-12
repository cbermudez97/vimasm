%include "keyboard.mac"
section .data
PRES db "******************************************************************************* ","*                 ",35,"     ",35,"                                                     * ","*                 ",35,"     ",35,"  ",35,"  ",35,"    ",35,"    ",35,35,"     ",35,35,35,35,"   ",35,"    ",35,"                  * ","*                 ",35,"     ",35,"  ",35,"  ",35,35,"  ",35,35,"   ",35,"  ",35,"   ",35,"       ",35,35,"  ",35,35,"                  * ","*                 ",35,"     ",35,"  ",35,"  ",35," ",35,35," ",35,"  ",35,"    ",35,"   ",35,35,35,35,"   ",35," ",35,35," ",35,"                  * ","*                  ",35,"   ",35,"   ",35,"  ",35,"    ",35,"  ",35,35,35,35,35,35,"       ",35,"  ",35,"    ",35,"                  * ","*                   ",35," ",35,"    ",35,"  ",35,"    ",35,"  ",35,"    ",35,"  ",35,"    ",35,"  ",35,"    ",35,"                  * ","*                    ",35,"     ",35,"  ",35,"    ",35,"  ",35,"    ",35,"   ",35,35,35,35,"   ",35,"    ",35,"                  * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                    Proyecto de Programacion de Maquinas                     * ","*                                                                             * ","*                                Integrantes:                                 * ","*                           -Carlos Bermudez Porto   C-212                    * ","*                           -Roberto Marti Cedeno    C-212                    * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*******************************************************************************"


section .text
extern CURSOR
extern TEXT
extern END
extern scan
extern printscreen
extern normal

global presentation
presentation:
    push PRES
    call printscreen
    mov dword [CURSOR], 1920
    .loop:
    xor eax, eax
    call scan
    ;Initializing the Text
    mov byte [TEXT], 3
    mov dword [END], TEXT
    mov dword [CURSOR], 0
    push dword normal;go to normal mode
    ret