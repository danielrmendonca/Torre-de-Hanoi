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

; Torres para chamada
TORRE_A equ 1
TORRE_B equ 2
TORRE_C equ 3

section .bss

entrada resb 2

digito_para_imprimir resb 1 ; Para debuggar

section .text
    global _start

_start:

; Pergunta ao usuário
mov eax, 0x4        ; Prepara para o print
mov ebx, 0x1        ; Saída padrão
mov ecx, pergunta
mov edx, pergunta_len
int 0x80

; Lê a entrada
mov eax, 0x3        ; Leitura
mov ebx, 0x0        ; Entrada padrão (teclado)
mov ecx, entrada
mov edx, 1          ; Apenas o número de discos na entrada
int 0x80

; Converter string
call string_para_int
; Quantidade de discos int em eax

; Torres em ordem e quantidade de discos na pilha
push dword TORRE_B      ; Torre Auxiliar - 4 bytes
push dword TORRE_C      ; Torre Destino - 4 bytes
push dword TORRE_A      ; Torre Origem - 4 bytes
push eax                ; Número de discos inserido pelo usuário - 4 bytes
 
call torre_de_hanoi     ; 4 bytes

; Exibir a mensagem de finalização do algoritmo
mov eax, 0x4
mov ebx, 0x1
mov ecx, conclusao
mov edx, conclusao_len
int 0x80
call 0x1

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

torre_de_hanoi:
; Parâmetros: (n, origem, auxiliar, destino)
push ebp                      ; Ponto de referência na pilha (Base pointer)
mov ebp, esp                  ; Colocar o ponto de referência no topo da pilha
; REFERÊNCIA
; [ebp+8] número de discos restantes na Torre de origem (eax)
; [ebp+12] = TORRE_A
; [ebp+16] = TORRE_B
; [ebp+20] = TORRE_C

; Início da função
mov eax, [ebp+8]             ; Número de discos em eax
cmp eax, 0                   ; Verifica se ainda há discos
je saida                     ; Finaliza se 0, continua para o caso base e demais casos

; Primeira chamada recursiva (Isolar o maior disco)
push dword [ebp+16]           ; Empurra a torre auxiliar (TORRE_B)
push dword [ebp+20]           ; Empurra a torre destino (TORRE_C)
push dword [ebp+12]           ; Empurra a torre origem (TORRE_A)
dec eax                       ; Tira o primeiro disco
push dword eax                ; Número de discos restantes

call torre_de_hanoi           ; Chegar no caso base (Volta para aqui quando for 1)

; Printando os movimentos a partir do caso base (Por o maior disco do destino)
push dword [ebp+16]           ; Empilha o torre de Saida
push dword [ebp+12]           ; Empilha o torre de Ida
push dword [ebp+8]            ; Empilha o disco
call print_mov                ; Mover o disco que foi isolado

; Segunda chamada recursiva (Montar a torre n-1 na torre destino)
push dword [ebp+12]           ; Torre origem
push dword [ebp+16]           ; Torre auxiliar
push dword [ebp+20]           ; Torre destino

mov eax, [ebp+8]              ; Discos restantes
dec eax
push dword eax

call torre_de_hanoi

saida: 
mov esp, ebp
pop ebp
ret                 ; Volta para depois da ultima chamada

print_mov:
push ebp                     ; Salva a referência
mov ebp, esp                 ; Coloca o ponto de referência no topo

mov eax, [ebp+8]             ; Disco isolado atual
add al, '0'                  ; Converte para string de volta
mov [num_disco], al          ; Coloca o valor em num_disco

mov eax, [ebp+12]            ; Torre origem
add al, '@'                  ; Converte para string
mov [torre_fonte], al        ; Coloca o valor em torre_fonte

mov eax, [ebp+16]            ; Torre destino
add al, '@'
mov [torre_destino], al

mov eax, 0x4                ; Print
mov ebx, 0x1                ; Saída padrão (Tela)
mov ecx, output             ; Mensagem
mov edx, output_len         ; Tamanho
int 0x80                    ; Sistema

call saida

string_para_int:
mov al, [entrada]
cmp al, '1'             ; Compara o valor em al com 1
jl erro_conversao       ; Jump if less
cmp al, '9'             ; Compara o valor em al com 9
jg erro_conversao       ; Jump if greater
; Entrada válida
sub al, '0'             ; Converte para inteiro
movzx eax, al           ; Carrega o valor em eax garantindo que seja sobreescrito
ret

erro_conversao:
; Exibir a mensagem de erro
mov eax, 0x4
mov ebx, 0x1
mov ecx, erro
mov edx, erro_len
int 0x80

; Finalizar o programa com erro
mov eax, 0x1    ; Finalizar programa
mov ebx, 1      ; Código de erro
int 0x80
