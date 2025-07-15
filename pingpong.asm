section .data
    rows        equ 20
    cols        equ 40
    screen_width equ 60
    paddle_size equ 4
    welcome_msg db 'PINGPONG START', 10
    welcome_msg_len equ $-welcome_msg
    hello_msg db 'Controls: W/S to move, Q to quit', 10
    hello_msg_len equ $-hello_msg
    newline db 10
    screen db 1200 dup(' ')
    esc_clear db 27, '[2J', 27, '[H'
    esc_clear_len equ $-esc_clear
    score_msg db 'Player: '
    score_msg_len equ $-score_msg
    ai_msg db 'AI: '
    ai_msg_len equ $-ai_msg

section .bss
    lpaddle_pos resb 1
    rpaddle_pos resb 1
    ball_x      resb 1
    ball_y      resb 1
    ball_dx     resb 1
    ball_dy     resb 1
    key         resb 1
    player_score resb 1
    ai_score    resb 1
    ai_counter  resb 1

section .text
    global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, welcome_msg
    mov rdx, welcome_msg_len
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, hello_msg
    mov rdx, hello_msg_len
    syscall

    mov byte [lpaddle_pos], 8
    mov byte [rpaddle_pos], 8
    mov byte [ball_x], 20
    mov byte [ball_y], 10
    mov byte [ball_dx], 1
    mov byte [ball_dy], 1
    mov byte [player_score], 0
    mov byte [ai_score], 0
    mov byte [ai_counter], 0

main_loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, esc_clear
    mov rdx, esc_clear_len
    syscall

    lea rdi, [rel screen]
    mov rcx, rows*screen_width
    mov al, ' '
.clear_loop:
    mov [rdi], al
    inc rdi
    loop .clear_loop

    lea rsi, [rel screen]
    mov rcx, cols
.draw_top_border:
    mov byte [rsi], '-'
    inc rsi
    loop .draw_top_border

    lea rsi, [rel screen]
    mov rax, rows-1
    imul rax, screen_width
    add rsi, rax
    mov rcx, cols
.draw_bottom_border:
    mov byte [rsi], '-'
    inc rsi
    loop .draw_bottom_border

    movzx rbx, byte [lpaddle_pos]
    mov rcx, paddle_size
.draw_lpaddle:
    lea rsi, [rel screen]
    mov rax, rbx
    imul rax, screen_width
    add rsi, rax
    mov byte [rsi], '|'
    inc rbx
    loop .draw_lpaddle

    movzx rbx, byte [rpaddle_pos]
    mov rcx, paddle_size
.draw_rpaddle:
    lea rsi, [rel screen]
    mov rax, rbx
    imul rax, screen_width
    add rax, cols-1
    add rsi, rax
    mov byte [rsi], '|'
    inc rbx
    loop .draw_rpaddle

    movzx rbx, byte [ball_y]
    movzx rdx, byte [ball_x]
    lea rsi, [rel screen]
    mov rax, rbx
    imul rax, screen_width
    add rax, rdx
    add rsi, rax
    mov byte [rsi], 'O'

    lea rsi, [rel screen]
    mov rax, 3
    imul rax, screen_width
    add rax, 45
    add rsi, rax
    mov rcx, score_msg_len
    lea rdi, [rel score_msg]
.draw_player_label:
    mov al, [rdi]
    mov [rsi], al
    inc rsi
    inc rdi
    loop .draw_player_label
    movzx rax, byte [player_score]
    add al, '0'
    mov [rsi], al

    lea rsi, [rel screen]
    mov rax, 5
    imul rax, screen_width
    add rax, 45
    add rsi, rax
    mov rcx, ai_msg_len
    lea rdi, [rel ai_msg]
.draw_ai_label:
    mov al, [rdi]
    mov [rsi], al
    inc rsi
    inc rdi
    loop .draw_ai_label
    movzx rax, byte [ai_score]
    add al, '0'
    mov [rsi], al

    xor r8, r8
.print_rows:
    cmp r8, rows
    jge .done_printing
    
    lea rsi, [rel screen]
    mov rax, r8
    imul rax, screen_width
    add rsi, rax
    mov rax, 1
    mov rdi, 1
    mov rdx, screen_width
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    inc r8
    jmp .print_rows
.done_printing:

    mov rax, 0
    mov rdi, 0
    mov rsi, key
    mov rdx, 1
    syscall

    cmp byte [key], 'q'
    je quit

    cmp byte [key], 'w'
    jne .not_w
    movzx rax, byte [lpaddle_pos]
    cmp rax, 1
    jbe .not_w
    dec byte [lpaddle_pos]
.not_w:
    cmp byte [key], 's'
    jne .not_s
    movzx rax, byte [lpaddle_pos]
    add rax, paddle_size
    cmp rax, rows-1
    jae .not_s
    inc byte [lpaddle_pos]
.not_s:

    inc byte [ai_counter]
    movzx rax, byte [ai_counter]
    and rax, 15
    
    cmp rax, 15
    je .ai_done
    cmp rax, 14
    je .ai_wrong_direction
    
    movzx rax, byte [ball_y]
    movzx rbx, byte [rpaddle_pos]
    add rbx, paddle_size/2
    cmp rax, rbx
    jbe .ai_up
    movzx rcx, byte [rpaddle_pos]
    add rcx, paddle_size
    cmp rcx, rows-1
    jae .ai_done
    inc byte [rpaddle_pos]
    jmp .ai_done
.ai_up:
    movzx rcx, byte [rpaddle_pos]
    cmp rcx, 1
    jbe .ai_done
    dec byte [rpaddle_pos]
    jmp .ai_done

.ai_wrong_direction:
    movzx rax, byte [ball_y]
    movzx rbx, byte [rpaddle_pos]
    add rbx, paddle_size/2
    cmp rax, rbx
    jbe .ai_wrong_down
    movzx rcx, byte [rpaddle_pos]
    cmp rcx, 1
    jbe .ai_done
    dec byte [rpaddle_pos]
    jmp .ai_done
.ai_wrong_down:
    movzx rcx, byte [rpaddle_pos]
    add rcx, paddle_size
    cmp rcx, rows-1
    jae .ai_done
    inc byte [rpaddle_pos]
.ai_done:

    movzx rax, byte [ball_x]
    movsx rbx, byte [ball_dx]
    add rax, rbx
    mov [ball_x], al
    movzx rax, byte [ball_y]
    movsx rbx, byte [ball_dy]
    add rax, rbx
    mov [ball_y], al

    movzx rax, byte [ball_y]
    cmp rax, 1
    jne .not_top
    neg byte [ball_dy]
.not_top:
    cmp rax, rows-2
    jne .not_bottom
    neg byte [ball_dy]
.not_bottom:

    movzx rax, byte [ball_x]
    cmp rax, 1
    jne .not_left_paddle
    movzx rbx, byte [ball_y]
    movzx rcx, byte [lpaddle_pos]
    cmp rbx, rcx
    jb .not_left_paddle
    add rcx, paddle_size
    cmp rbx, rcx
    jae .not_left_paddle
    neg byte [ball_dx]
.not_left_paddle:

    movzx rax, byte [ball_x]
    cmp rax, cols-2
    jne .not_right_paddle
    movzx rbx, byte [ball_y]
    movzx rcx, byte [rpaddle_pos]
    cmp rbx, rcx
    jb .not_right_paddle
    add rcx, paddle_size
    cmp rbx, rcx
    jae .not_right_paddle
    neg byte [ball_dx]
.not_right_paddle:

    movzx rax, byte [ball_x]
    test rax, rax
    jnz .not_reset_left
    inc byte [ai_score]
    mov byte [ball_x], 20
    mov byte [ball_y], 10
    mov byte [ball_dx], 1
.not_reset_left:
    cmp rax, cols-1
    jne .not_reset_right
    inc byte [player_score]
    mov byte [ball_x], 20
    mov byte [ball_y], 10
    mov byte [ball_dx], -1
.not_reset_right:

    mov rcx, 20000000
.delay_loop:
    loop .delay_loop

    jmp main_loop

quit:
    mov rax, 60
    xor rdi, rdi
    syscall 