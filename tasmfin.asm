; ---------------------------------------
; NAME: Mustafa Mohamed Mustafa Mohamed Shehata , SECTION(8)
; NAME: Mustafa Mahmoud Mohamed Taha Al'mam ,     SECTION(8)
; Third Team (Year 3)
; CS Team
; ---------------------------------------
.MODEL SMALL
.STACK 100h

.DATA

line_top    db '--- LITTLE PROFESSOR GAME ---$',0
txt_solve   db 'Solve: $'
txt_eq      db ' = $'
msg_wrong   db 0Dh,0Ah,'Wrong! Try again.$'
msg_correct db 0Dh,0Ah,'Correct! Well done.$'
msg_again   db 0Dh,0Ah,'Again? (Y/N): $'
nl          db 0Dh,0Ah,'$'

answer_buffer db 4          ; max input
              db 0          ; number of chars typed
              db 4 dup(0)   ; input itself

; ---------------------------------------
; CODE SEGMENT
; ---------------------------------------
.CODE

print_str PROC NEAR
    mov ah, 09h
    int 21h
    ret
print_str ENDP

newline PROC NEAR
    mov dx, offset nl
    mov ah, 09h
    int 21h
    ret
newline ENDP

get_line PROC NEAR
    mov ah, 0Ah
    lea dx, answer_buffer
    int 21h
    ret
get_line ENDP

print_digit PROC NEAR
    add dl, '0'
    mov ah, 02h
    int 21h
    ret
print_digit ENDP

; ---------------------------------------
; Small delay to desync RNG calls
; ---------------------------------------
delay_small PROC NEAR
    mov cx, 500
delay_lp:
    loop delay_lp
    ret
delay_small ENDP

; ---------------------------------------
; Random digit 0-9 with mixed entropy
; ---------------------------------------
rand_digit PROC NEAR
    mov ah, 2Ch
    int 21h          ; AL,CL,DL,DH = time

    xor al, dh       ; mix hours
    add al, dl       ; mix centiseconds

    and al, 0Fh      ; keep 0..15
    cmp al, 9
    jle rd_ok
    sub al, 6        ; convert 10..15 to 4..9
rd_ok:
    ret
rand_digit ENDP

; ---------------------------------------
; MAIN PROGRAM
; ---------------------------------------
start:

    mov ax, @data
    mov ds, ax

    mov dx, offset line_top
    call print_str
    call newline

generate_problem:

    call newline

    ; first random digit
    call rand_digit
    mov bl, al

    ; delay so next random isn?t same
    call delay_small

    ; second random digit
    call rand_digit
    mov bh, al

    mov dx, offset txt_solve
    call print_str

    mov dl, bl
    call print_digit

    mov dl, '+'
    mov ah, 02h
    int 21h

    mov dl, bh
    call print_digit

    mov dx, offset txt_eq
    call print_str

    call get_line

    ; no input?
    cmp byte ptr answer_buffer+1, 0
    je wrong_answer

    ; convert input to number in CL
    mov al, answer_buffer+1   ; length
    cmp al, 1
    je single_digit

    ; two-digit number
    mov al, answer_buffer+2
    sub al, '0'
    mov cl, al

    mov al, answer_buffer+3
    sub al, '0'
    mov ch, al

    mov al, cl
    mov cl, 10
    mul cl
    add al, ch
    mov cl, al
    jmp check_answer

single_digit:
    mov al, answer_buffer+2
    sub al, '0'
    mov cl, al

check_answer:
    mov al, bl
    add al, bh
    cmp cl, al
    je correct_answer

wrong_answer:
    mov dx, offset msg_wrong
    call print_str
    jmp generate_problem

correct_answer:
    mov dx, offset msg_correct
    call print_str

; ---------------------------------------
; Ask Y/N with safe validation
; ---------------------------------------
ask_again:
    mov dx, offset msg_again
    call print_str

    mov ah, 01h
    int 21h       ; AL = key

    cmp al, 'Y'
    jne chk_y_low
    jmp generate_problem

chk_y_low:
    cmp al, 'y'
    jne chk_N
    jmp generate_problem

chk_N:
    cmp al, 'N'
    jne chk_n_low
    jmp exit_program

chk_n_low:
    cmp al, 'n'
    jne ask_again
    jmp exit_program

exit_program:
    mov ax, 4C00h
    int 21h

END start