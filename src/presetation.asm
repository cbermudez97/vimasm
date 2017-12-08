%include "keyboard.mac"
section .data
PRES db "******************************************************************************* ","*                 ",35,"     ",35,"                                                     * ","*                 ",35,"     ",35,"  ",35,"  ",35,"    ",35,"    ",35,35,"     ",35,35,35,35,"   ",35,"    ",35,"                  * ","*                 ",35,"     ",35,"  ",35,"  ",35,35,"  ",35,35,"   ",35,"  ",35,"   ",35,"       ",35,35,"  ",35,35,"                  * ","*                 ",35,"     ",35,"  ",35,"  ",35," ",35,35," ",35,"  ",35,"    ",35,"   ",35,35,35,35,"   ",35," ",35,35," ",35,"                  * ","*                  ",35,"   ",35,"   ",35,"  ",35,"    ",35,"  ",35,35,35,35,35,35,"       ",35,"  ",35,"    ",35,"                  * ","*                   ",35," ",35,"    ",35,"  ",35,"    ",35,"  ",35,"    ",35,"  ",35,"    ",35,"  ",35,"    ",35,"                  * ","*                    ",35,"     ",35,"  ",35,"    ",35,"  ",35,"    ",35,"   ",35,35,35,35,"   ",35,"    ",35,"                  * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*                    Proyecto de Programacion de Maquinas                     * ","*                                                                             * ","*                                Integrantes:                                 * ","*                           -Carlos Bermudez Porto   C-212                    * ","*                           -Roberto Marti Cedeno    C-212                    * ","*                                                                             * ","*                                                                             * ","*                                                                             * ","*******************************************************************************"


section .text
extern CURSOR
extern scan
extern printscreen
extern insertion
;extern normal

global presentation
presentation:
    push PRES
    call printscreen
    mov dword [CURSOR], 1920
    .loop:
    xor eax, eax
    call scan
    mov dword [CURSOR], 0
    ;jmp normal
    jmp insertion
    jmp .loop
    ret