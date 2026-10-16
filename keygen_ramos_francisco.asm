; ====================================================================
; Proyecto Módulo 2 - Keygen Básico (x86-64 Assembly)
; Nombre: Francisco Ramos Vazquez
;
; Compilación y Enlace:
;   uasm64 -win64 keygen_ramos_francisco.asm
;   GoLink.exe keygen_ramos_francisco.obj kernel32.dll /fo keygen_ramos_francisco.exe /console /entry main
; ====================================================================

extrn GetStdHandle: proc
extrn WriteConsoleA: proc
extrn ReadConsoleA: proc
extrn ExitProcess: proc

.data
    prompt          db "Ingresa tu nombre de usuario: ", 0
    prompt_len      dq $ - prompt - 1

    mensaje_llave   db "Tu llave es: ", 0
    mensaje_len     dq $ - mensaje_llave - 1

    newline         db 13, 10, 0
    newline_len     dq $ - newline - 1

    error_vacio     db "Error: nombre no valido.", 13, 10, 0
    error_len       dq $ - error_vacio - 1

    hex_chars       db "0123456789ABCDEF"

    buffer          db 64 DUP (0)
    buffer_len      dq 64
    leidos          dq 0
    escritos        dq 0

    suma            dq 0
    hex_buffer      db 17 DUP (0)   ; 16 dígitos hex + NULL

    hStdout         dq 0
    hStdin          dq 0

.code

main proc
    sub rsp, 28h                    ; Reservar Shadow Space (32 bytes + alineación)

    ; 1. Obtener handle de STDOUT
    mov rcx, -11                    ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov [hStdout], rax

    ; 2. Obtener handle de STDIN
    mov rcx, -10                    ; STD_INPUT_HANDLE
    call GetStdHandle
    mov [hStdin], rax

    ; 3. Mostrar Prompt
    mov rcx, [hStdout]
    lea rdx, prompt
    mov r8, [prompt_len]
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    ; 4. Leer nombre del usuario
    mov rcx, [hStdin]
    lea rdx, buffer
    mov r8, [buffer_len]
    lea r9, leidos
    mov qword ptr [rsp + 20h], 0
    call ReadConsoleA

    ; 5. Verificar si el nombre está vacío (Enter son <= 2 bytes: \r\n)
    mov rax, [leidos]
    cmp rax, 2
    jle error_nombre_vacio

    ; 6. Bucle de suma ASCII
    lea rsi, buffer
    mov rcx, [leidos]
    sub rcx, 2                      ; Descontar \r\n
    xor rax, rax

bucle_suma:
    movzx rdx, byte ptr [rsi]
    add rax, rdx
    inc rsi
    loop bucle_suma

    ; Transformación adicional (XOR con constante 0ABCDh)
    xor rax, 0ABCDh
    mov [suma], rax

    ; 7. Conversión a Hexadecimal (16 dígitos)
    mov rax, [suma]
    lea rdi, hex_buffer
    add rdi, 15
    mov rcx, 16
    lea rbx, hex_chars

bucle_hex:
    mov rdx, rax
    and rdx, 0Fh
    mov dl, [rbx + rdx]
    mov [rdi], dl
    dec rdi
    shr rax, 4
    loop bucle_hex

    mov byte ptr [hex_buffer + 16], 0

    ; 8. Mostrar "Tu llave es: "
    mov rcx, [hStdout]
    lea rdx, mensaje_llave
    mov r8, [mensaje_len]
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    ; 9. Mostrar la llave generada (hex_buffer)
    mov rcx, [hStdout]
    lea rdx, hex_buffer
    mov r8, 16
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    ; 10. Mostrar salto de línea final
    mov rcx, [hStdout]
    lea rdx, newline
    mov r8, [newline_len]
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    jmp fin

error_nombre_vacio:
    mov rcx, [hStdout]
    lea rdx, error_vacio
    mov r8, [error_len]
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

fin:
    add rsp, 28h                    ; Restaurar la pila
    xor ecx, ecx
    call ExitProcess
main endp

end