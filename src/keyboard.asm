section .data

section .text
; scan()
; Get the hex code of the input if available otherwise zero
global scan
scan:
  ;Cleaning eax.
  xor eax, eax
  ;Cheking the status of input buffer.
  in  al, 0x64
  test al, 1
  je .zero ;Input buffer empty.
  test al, 32
  jne .zero
  ; Scan.
  in al, 0x60
  jmp .ret ;Return the hex code.
  ;Return zero.
  .zero:
    jmp scan
  .ret:
    ret
