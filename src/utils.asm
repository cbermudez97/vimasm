%include "utils.mac"

section .text
global traslate
traslate:
    SALVAR_REGISTROS
    ; guardando la cantidad de veces a mover 
    mov eax, [ebp + 12]; guardando el numero de iteraciones
    mov ecx, eax
    cmp eax, 0
    jge positivo
    xor ecx, ecx
    mov ebx, -1
    imul ebx ; multiplicando para eliminar el signo
    mov edx, [ebp + 12]
    mov ecx, eax
    ;-----negativo-----------------
    negativo:
    cld
    mov edi, [ebp + 16]
    mov esi, edi
    sub esi, [ebp + 12]
    mov edx, [ebp + 8]
    inc edx
    .loop1:
    cmp esi, edx
    je .endloop1
    movsb
    jmp .loop1
    .endloop1:
    xor eax, eax
    .loop2:
    cmp edi, edx
    je .endloop2
    stosb
    jmp .loop2
    .endloop2:
    jmp final
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
    cld
    xor eax, eax
    mov ecx, [ebp + 12]
    mov edi, [ebp + 16]
    ; no se incrementa p tambien se ha de eliminar
    rep stosb
    final:
    DEVOLVER_REGISTROS
    ret 12