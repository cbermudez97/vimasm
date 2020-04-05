%include "video.mac"
section .data
global blink
blink db 1


; Frame buffer location
%define FBUFFER 0xB8000

; swap ecx para interacambiar foregraund con backgraund color
%macro SWAP 1 .nolist
push eax
push ebx
xor eax,eax
xor ebx,ebx
mov eax, [%1]
mov bh,al
mov bl,ah
mov [%1], bx 
pop ebx
pop eax
%endmacro 

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
%macro SETCURSOR 1.nolist
    push dx
    cmp byte [blink], 1
    jne .no
    .yes:
    mov dx, %1
    or dx, CURSOR.ON|BG.GRAY
    or dx, FG.BLACK
    mov %1, dx
    jmp .end
    .no:
    mov dx, %1
    or dx, FG.BRIGHT|FG.GRAY
    or dx, BG.BLACK
    mov %1, dx
    jmp .end 
    .end:
    pop dx
%endmacro




section .text

global blinkcursor
blinkcursor:
xor byte [blink], 1
ret

global setcursor
setcursor:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    mov eax, [ebp + 8]
    mov ebx, 2
    mul ebx
    mov dx, [FBUFFER + eax]
    xor dh, dh
    cmp byte [blink], 1
    jne .no
    .yes:
    or dx, CURSOR.ON|BG.GRAY
    or dx, FG.BLACK
    jmp .end
    .no:
    or dx, FG.BRIGHT|FG.GRAY
    or dx, BG.BLACK
    .end:
    mov [FBUFFER + eax ], dx
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret 4

; clear(byte char, byte attrs)
; Clear the screen by filling it with char and attributes.
global clear
clear:
  push ebp
  mov ebp, esp
  push eax
  push ecx
  push edi
  xor eax, eax
  mov ax, [ebp + 8] ; char, attrs
  mov edi, FBUFFER
  mov ecx, COLS * ROWS
  cld
  rep stosw
  pop edi
  pop ecx
  pop eax
  pop ebp
  ret 2


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
global printscreen
printscreen:
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
inc ebx
cld
mov edi, VSCREEN_START ; inicio de la direccion de video
mov esi, edx ; mov el inicio del array de caracteres
mov ecx, 1920 ; cantidad de veces que se ejectua el ciclo
.imprimir:
xor eax,eax
lodsb
;cmp esi, ebx ; comparar si esta el cursor en esa direccion
;jnz .nocursor
;SETCURSOR ax ; prender el cursor
cmp al , 0 ; compara el caracter en al si es cero (no jode lo de arriba)
jz .rellenar
cmp al , 10; es un salto de linea
jz .rellenar
cmp al , 3 ;es un fin de archivo
jz .rellenar
; drawing char
or ax, FG.BRIGHT
or ax, FG.GRAY
or ax, BG.BLACK
.impress:
stosw
jmp .cont
; filling the cell
.rellenar:
and al, 0
stosw
.cont:
dec ecx
cmp ecx, 0
jnz .imprimir
pop edi
pop esi
pop edx
pop ecx
pop ebx
pop eax
pop ebp
ret 8

;param text to print(dir)
global printconsole
printconsole:
push ebp
mov ebp, esp
push esi
push edi
push ecx
push eax
cld
mov esi, [ebp + 8]
mov edi, 1920
shl edi, 1
add edi, FBUFFER
mov ecx, 80
.loop:
xor eax, eax
lodsb
or ax, BG.BLACK|FG.GRAY|FG.BRIGHT
stosw
dec ecx
cmp ecx, 0
je .endloop
jmp .loop
.endloop:
pop eax
pop ecx
pop edi
pop esi
pop ebp
ret 4

;requiere que se le pase como parametro la pos inicial y la final para intercambiar fgraund con backgraund color
global interchange
interchange:
push ebp
mov ebp,esp
push eax
push ebx
push ecx
xor eax, eax
xor ebx, ebx
xor ecx, ecx
; cuantos me voy a mover
mov eax, [ebp + 8]
mov ecx, [ebp + 12]
sub ecx, eax
inc ecx

; el tamaño de la pantalla es de word no de byte
shl eax , 1
; donde empiezo a resaltar
mov edi, 0xB8000
add edi, eax

xor eax,eax

.ciclo:
mov ax, [edi]
cmp al, 0
je .continue
cmp al, 3
je .continue
cmp al, 10
je .continue
ror ah,4
mov [edi], ax
.continue:
add edi,2
dec ecx
cmp ecx, 0
jnz .ciclo
pop ecx
pop ebx
pop eax
pop ebp
ret 8
