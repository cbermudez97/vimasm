%include "utils.mac"

section .data
resto dd 0
return dd 0

section .text
extern TEXT
extern SCREEN_START
extern CURSOR
extern END
global traslate
global fix

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
    rellenar:
    cld
    xor eax, eax
    xor ecx, ecx
    xor edi, edi
    mov ecx, [ebp + 12]
    mov edi, [ebp + 16]
    ; no se incrementa p tambien se ha de eliminar
    rep stosb
    final:
    DEVOLVER_REGISTROS
    ret 12

;The fix method
;param1 = start, param2 = k ,param3 = end
fix:
  push ebp
  mov ebp, esp
  push ebx
  push ecx
  push edx
  mov edx, [ebp + 16];start
  loop:
    cmp edx, [ebp + 8];is the end
    je endfix
    cmp byte [edx], 10
    jne next
    ;endline found
    ;count ceros
    mov ebx, edx
    xor ecx, ecx
    .count:
      inc ebx
      cmp byte [ebx], 0
      jne .endcount
      inc ecx
      jmp .count
    .endcount:
    ;new zeros
    push ecx
    sub ecx, [ebp + 12]
    negative:
    cmp ecx, 0
    jge nonegative
    add ecx, 80
    jmp negative
    nonegative:
    greater:
    cmp ecx, 80
    jl nograter
    sub ecx, 80
    jmp greater
    nograter:
    sub ecx, [esp]
    add eax, ecx
    add esp, 4
    ;traslate to the correct position
    inc edx
    push edx
    push ecx
    push dword [ebp + 8]
    call traslate
    jmp fixagain
  next:
  inc edx
  jmp loop
  fixagain:
  ;recursion
  add ecx, [ebp + 12]
  push edx
  push ecx
  push dword [ebp + 8]
  call fix
  endfix:
  pop edx
  pop ecx
  pop ebx
  pop ebp
  ret 12

global newfix
newfix:
  pushad
  ;Calculating r from TEXT = 80*x + r
  xor edx, edx
  mov eax, TEXT
  mov ebx, 80
  div ebx
  mov [resto], edx
  ;Moving throug the text and fixing the enters
  mov ecx, TEXT
  add ecx, [SCREEN_START]
  add ecx, [CURSOR]
  checker:
  ;Checking if end line
  cmp byte [ecx], 10
  je endline
  jmp continue
  endline:
  ;end of line
  ;counting zeros
    mov ebx, ecx
    inc ebx
    zeros:
      cmp byte [ebx], 0
      jne nozeros
      inc ebx
      jmp zeros
    nozeros:
    ;store the result in ebx
    sub ebx, ecx
    dec ebx
    ;counting the real number of zeros rz = 80 - (text+screen_start+cursor % 80) + text%80
    mov eax, ecx
    sub eax, TEXT
    sub eax, [SCREEN_START]
    push ebx
    mov ebx, 80
    xor edx, edx
    div ebx
    sub ebx, edx
    ;calculating the correction c = rz - az
    sub ebx, [esp]
    add esp, 4
    inc ecx
    push ecx
    dec ecx
    dec ebx
    push ebx
    push dword [END]
    call traslate
    add [END], ebx
  continue:;not a end of line
  ;Checking if end of file
  cmp ecx, [END]
  je endchecker
  inc ecx
  jmp checker
  endchecker:
  popad
  ret