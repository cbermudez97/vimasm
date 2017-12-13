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
extern timer

global presentation
presentation:
    mov dword [timer], 0
    mov dword [timer+4], 0
    push PRES
    call printscreen
    xor eax, eax
    call scan
    ;Initializing the Text
    mov byte [TEXT], 3
    mov dword [END], TEXT
    mov dword [CURSOR], 0
    push dword normal;go to normal mode
    ret