%include "keyboard.mac"
section .data
PRES db "*******************************************************************************
*                 #     #                                                     *
*                 #     #  #  #    #    ##     ####   #    #                  *
*                 #     #  #  ##  ##   #  #   #       ##  ##                  *
*                 #     #  #  # ## #  #    #   ####   # ## #                  *
*                  #   #   #  #    #  ######       #  #    #                  *
*                   # #    #  #    #  #    #  #    #  #    #                  *
*                    #     #  #    #  #    #   ####   #    #                  *
*                                                                             *
*                                                                             *
*                                                                             *
*                                                                             *
*                                                                             *
*                                                                             *
*                                                                             *
*                    Proyecto de Programación de Maquinas                     *
*                                                                             *
*                                Integrantes:                                 *
*                           -Carlos Bermudez Porto   C-212                    *
*                           -Roberto Marti Cedeño    C-212                    *
*                                                                             *
*                                                                             *
*                                                                             *
*******************************************************************************"


section .text
extern printscreen

global presentation
presentation:
    push PRES
    call printscreen
    ret