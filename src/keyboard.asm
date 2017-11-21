section .data

; Previous scancode.
key db 0 

section .text
; scan()
; Get the hex code of the input if available otherwise zero
global scan
scan:
  ;Cleaning eax.
  xor eax, eax
  ;Cheking the status of input buffer.
  in eax, 0x64
  and eax, 2
  je .zero ;Input buffer empty.
  ; Scan.
  in al, 0x60
  jmp .ret ;Return the hex code.
  ;Return zero.
  .zero:
    xor eax, eax
  .ret:
    ret
