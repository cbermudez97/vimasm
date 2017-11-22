%include "video.mac"

; Frame buffer location
%define FBUFFER 0xB8000

; FBOFFSET(byte row, byte column)
%macro FBOFFSET 2.nolist
    xor eax, eax
    mov al, COLS
    mul byte %1
    add al, %2
    adc ah, 0
    shl ax, 1
%endmacro

; SETCURSOR(word cursor position,CURSOR.ON to activate the cursor or CURSOR.OFF to remove the cursor)
%macro SETCURSOR 2.nolist
    push dx
    mov dx, %1
    or dx, %2
    mov %1, dx
    pop dx
%endmacro




section .text

; clear(byte char, byte attrs)
; Clear the screen by filling it with char and attributes.
global clear
clear:
  push ebp
  mov ebp, esp
  push eax
  push ecx
  push edi
  mov ax, [esp + 8] ; char, attrs
  mov edi, FBUFFER
  mov ecx, COLS * ROWS
  cld
  rep stosw
  pop edi
  pop ecx
  pop eax
  ret 4


; putc(char chr, byte color, byte r, byte c)
;      4         5           6       7
global putc
putc:
    push ebp
    mov ebp, esp
    push ebx
    push eax
    xor eax, eax
    xor ebx, ebx
    ; calc famebuffer offset 2 * (r * COLS + c)
    FBOFFSET [ebp + 11], [ebp + 10]

    mov bx, [ebp + 8]
    mov [FBUFFER + eax], bx
    pop eax
    pop ebx
    pop ebp
    ret 4

;(dword text + screenstart, dword cursor)
;draw the entire screen
;-------------We need to be sure about the paraghap does not go away from the screen-----------------
global PrintScreen
PrintScreen:
push ebp
mov ebp, esp
push eax
push ebx
push ecx
push edx
push esi
push edi
xor eax,eax
xor ebx,ebx
xor ecx,ecx
xor edx,edx
mov edx, [ebp + 8] ; inicio del array
mov ebx, [ebp + 12] ; posicion del cursor
mov eax, 0
cld
mov edi, VSCREEN_START ; inicio de la direccion de video
mov esi, edx ; mov el inicio del array de caracteres
mov ecx, 1920 ; cantidad de veces que se ejectua el ciclo
.imprimir:
xor eax,eax
mov al, [esi]
cmp esi,ebx ; comparar si esta el cursor en esa direccion
jnz .nocursor
SETCURSOR ax, CURSOR.ON ; prender el cursor
.nocursor: ; continuar
cmp al , 0 ; compara el caracter en al si es cero (no jode lo de arriba)
jz .rellenar
; drawing char
or ax, FG.BRIGHT
or ax, FG.GRAY
or ax, BG.BLACK
stosw
jmp .cont
; filling the cell
.rellenar:
and ax,word 0
stosw
.cont:
dec ecx
cmp ecx,0
jnz .imprimir
pop edi
pop esi
pop edx
pop ecx
pop ebx
pop eax
pop ebp
ret 8