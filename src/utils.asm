%include "utils.mac"

section .text
global traslate
traslate:
SALVAR_REGISTROS
    ; guardando la cantidad de veces a mover 
    mov eax, [ebp + 12]; guardando la el numero de iteraciones
    mov ecx, eax
    cmp eax, 0
    jge positivo
    xor ecx,ecx
    mov ebx, -1
    imul ebx ; multiplicando para eliminar el signo
    mov edx,[ebp + 12]
    mov ecx,ebx
    ;-----negativo-----------------
    ;negativo:
    cld
    mov esi, [ebp + 16]; inicio
    mov edi, [ebp + 16]; inicio
    add esi, ebx
    mov ecx, [ebp + 8] ; 
    sub ecx, [ebp + 16]
    add ecx, [ebp + 12] ; inico del movimiento
    inc ecx          ; ecx = fin - pos - i + 1
    rep movsb ; copiar [byte esi] a [byte edi]
    ;------rellenar con ceros -------
    mov ecx, ebx ; volviendo a guardar la cantidad de iteraciones
    ; el edi esta en el final del nuevo array (char de fin de archivo)
    inc edi
    xor eax,eax
    rep stosb
    jmp final!!!
    positivo:
    std 
    mov esi, [ebp + 8]
    mov edi, [ebp + 8]
    add edi, [ebp + 12]
    mov ecx, [ebp + 8]
    sub ecx, [ebp + 16]
    inc ecx ; f - p + 1
    rep movsb ;mismo que el negatico (ver)
    ;rellenar con ceros -------
    xor eax, eax
    mov ecx, [ebp + 12]
    mov edi, esi
    ; no se incrementa p tambien se ha de eliminar
    rep stosb
    final!!!:
    DEVOLVER_REGISTROS
    ret