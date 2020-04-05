section .data
global timer
timer dd 0,0
section .text
extern interval
extern blinkcursor
extern setcursor
extern CURSOR
; scan()
; Get the hex code of the input if available otherwise zero
global scan
scan:
  ;Cleaning eax.
  xor eax, eax
  ;Updating the Cursor
  cmp dword [timer], 0
  jne yes
  cmp dword [timer+4], 0
  jne yes
  jmp continue
  yes:
  push dword 500
  push dword timer
  call interval
  cmp al, 0
  je continue
  call blinkcursor
  push dword [CURSOR]
  call setcursor
  continue:
  ;Cheking the status of input buffer.
  in  al, 0x64
  test al, 1
  je .zero ;Input buffer empty.
  test al, 32
  jne .zero;Input data is from the mouse.
  ; Scan.
  in al, 0x60
  jmp .ret ;Return the hex code.
  ;Return zero.
  .zero:
    jmp scan
  .ret:
    ret
