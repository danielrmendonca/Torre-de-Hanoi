section .data
; OPERAÇÕES
; Quebra de linha = 0xA
; Print = 0x4 
; Leitura = 0x3
; Syscall = 0x80
; Finalizar execução / STDIN = 0x0
; Finalizar programa / STDOUT = 0x1

; REGISTRADORES DADOS
; eax
; ebx
; ecx
; edx

; REGISTRADORES MEMÓRIA
; esp (ponteiro da pilha)
; edp (ponteiro da base da pilha)
; esi
; edi

; Strings fixas
pergunta db "Digite a quantidade de discos (1 a 9):", 0xA, 0
pergunta_len equ $-pergunta

conclusao db "Concluído!", 0xA, 0
conclusao_len equ $-conclusao

erro db "Entrada inválida", 0xA, 0
erro_len equ $-erro

resposta db "Algoritmo de resolução da Torre de Hanoi para "
qtd_discos db " "
resposta2 db " disco(s)"
resposta_len equ $-resposta

; Mensagem output
output          db "Mova o disco "
num_disco       db  " "
                db " da Torre "
torre_fonte     db " "
                db " para a Torre "
torre_destino   db " ", 0xA
output_len      equ $-output

section .bss

entrada resb 2

digito_para_imprimir resb 1 ; Para debuggar

section .text
    global _start

_start:

; Pergunta ao usuário
mov eax, 0x4 ; Prepara para o print
mov ebx, 0x1 ; Saída padrão
mov ecx, pergunta
mov edx, pergunta_len
int 0x80

; Lê a entrada
mov eax, 0x3 ; Leitura
mov ebx, 0x0 ; Entrada padrão (teclado)
mov ecx, entrada
mov edx, 1 ; Apenas o número de discos na entrada
int 0x80

; Converter string
call string_para_int
; Quantidade de discos int em eax


; ----------DEBUGGER----------
;  add eax, '0' ; Converte para string novamente
;  mov [digito_para_imprimir], al
    
;  mov eax, 0x4
;  mov ebx, 0x1 
;  mov ecx, digito_para_imprimir
;  mov edx, 1
;  int 0x80
    
;  mov eax, 0x1 ; Finalizar programa
;  mov ebx, 0   ; Código de sucesso
;  int 0x80
; ------------------------------

string_para_int:
mov al, [entrada]
cmp al, '1' ; Compara o valor em al com 1
jl erro_conversao ; Jump if less
cmp al, '9' ; Compara o valor em al com 9
jg erro_conversao ; Jump if greater
; Entrada válida
sub al, '0' ; Converte para inteiro
movzx eax, al ; Carrega o valor em eax garantindo que seja sobreescrito
ret

erro_conversao:
; Exibir a mensagem de erro
mov eax, 0x4
mov ebx, 0x1
mov ecx, erro
mov edx, erro_len
int 0x80

; Finalizar o programa com erro
mov eax, 0x1 ; Finalizar programa
mov ebx, 1 ; Código de erro
int 0x80
