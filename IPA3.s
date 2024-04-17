
;CS 274
;
; IPA 3: 3.1

;print string instructions
;MOV AH, 0x13            ; move BIOS interrupt number in AH
;MOV CX, 11              ; move length of string in cx
;MOV BX, 0               ; mov 0 to bx, so we can move it to es
;MOV ES, BX              ; move segment start of string to es, 0
;MOV BP, OFFSET hello    ; move start offset of string in bp
;MOV DL, 0               ; start writing from col 0
;int 0x10                ; BIOS inter

;set null spaces for input to be stored


db 0xAD       ;X0 (173)
db 0xAD       ;Xk starts at (173), then Xk+1
db 0x03       ;A value a, odd and ideally co-prime to (3)
db 0xFB       ;A large prime m that fits in a register of the required size (251)

db 0x00 ; To prevent overriding
db 0x00 ; Will be used for player score

  
deck1: db "23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA"
db 0x00
money_question: db "How much would you like to bet? Must be a number between $10-$1000" 
db 0x00
of: db "of"
db 0x00
c: db "Clubs"
db 0x00
d: db "Diamonds"
db 0x00
s: db "Spades"
db 0x00
h: db "Hearts"
db 0x00
player_wins: db "You win!"
db 0x00
cpu_wins: db "CPU wins!"
db 0x00
base:
    db 0x00
; To make a buffer users will write to
; INT 0x10h need an initial 'guess' of how
; many characters will appear
;N:  db 0x0a
buffer:    ; Maximum value to read
    
    db 0x05    ; Actual value read after INT
    db 0x05
    db [0xff, 0x05] ; Buffer of the right size  
                    ; First value: filler
                    ; Second value: number of bytes
    db 0xff

def rng{
    
    mov al, byte [1]    ;X subscript k
    mov bl, byte [2]    ;coprime a
    mov cl, byte [3]    ;prime number m
    mov dx, 0
   
    
    ;obtain Xk+1 by Xk+1 = a * Xk mod m
    mul bx              ;multiply a by X subscript k
    div cx              ;then mod m = X subscript k+1
    mov ax,dx           ;this is Xk+1
    mov byte [1],al     ;store k+1 into mem[0]
   
    mov cx, 0x34        ;move '52' into cx
    mov dx,0            ;reset dx 
    
    ;obtain index by n = Xk+1 mod 52
    div cx              ;Xk+1 mod 52
    mov byte [4], dl    ;store n into mem[4]
    
    ;reset all registers
    mov ax,0
    mov bx,0
    mov cx,0
    mov dx,0
    
    ret
}


def win{
    ;print player wins statement
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 9              ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET player_wins   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter

    ret
}

def lose{
    ;print cpu win statement
MOV AH, 0x13            ; move BIOS interrupt number in AH
MOV CX, 10              ; move length of string in cx
MOV BX, 0               ; mov 0 to bx, so we can move it to es
MOV ES, BX              ; move segment start of string to es, 0
MOV BP, OFFSET cpu_wins    ; move start offset of string in bp
MOV DL, 0               ; start writing from col 0
int 0x10                ; BIOS inter

    ret
}

def input_check{ ; input of bet placed


    ;check if valid bet is placed
    cmp byte [si,1], 1 ;check if bet size has less than 2 integers
    jl start         ;jump back to start if so
    cmp byte [si,1],3  ;check if bet size has greater than 4 integers
    jg start         ;jump back to start if so
    jl _game_loop    ;bet is between 10-1000, jump to game loop
    cmp byte [si,5], 0x30  ;check if last number is between 1000-1999,i.e greater than 1000
    jg start         ;jump to start if so
    jmp _game_loop  ;bet is between 10-1000, jump to game loop
    
    ret
}



def check_suit{ ; checks what suit the card picked is
    ; 4th byte (5th index)
    cmp byte[4],0x0C
    jbe _print_c
    cmp byte[4],0x19
    jbe _print_d
    cmp byte[4],0x26
    jbe _print_s
    cmp byte[4], 0x33
    jbe _print_h
    
    ret
}

def display_card {

    ; randomly displays value of card
    MOV bp, OFFSET deck1
    mov al, byte [4]
    mov si, ax; rng card value
    add bp, si ; the index of the string we want to print
    mov ah, 0x02 ; BIOS function for printing char in ah, 
    mov dl, byte [bp]
    int 0x21    ;print card value
    
    ; Card value stored in dl
    
    
    ;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 1            ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET of   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    
    call check_suit
    
    ret
}

def string_to_num {
    ; converts the a string "A" or "1" or "9"
    ; to an int value

    ; get stored value and cmp to ascii values
    ; if they are equal, then add that to player score
    
    MOV bp, OFFSET deck1
    mov al, byte [4]
    mov si, ax; rng card value
    add bp, si ; the index of the string we want to print
    mov dl, byte [bp] ; stores character in
    
    ;cmp , byte [bp] 
    
    ; add number to player byte[5] which is the 6th index
    ; which is the player score
    
    ; comparing char stored which is a card value
    ; to each ascii value from A,2 to J,Q, K
    
    
    
    ret
}

def player_choice{
    ;ask user if they would like 
    ;to hit or not
    ret
}

def player_hit{
    ;give user another card
    ;change current value
    ;if ace is hit, add when then call ace_was_hit
    ret
}

def ace_was_hit{
    ;ask user if they want to keep as 1 or make 11
    ;add current value plus 10
    ret
    
}


; rand num in byte[4]


start:
    ; Initialize relevant variable
    ; Use interrupt here to read user input
     
    MOV ah, 0x13            ; move BIOS interrupt number in AH
    MOV cx, 66          ; move length of string in cx
    MOV bx, 0               ; mov 0 to bx, so we can move it to es
    MOV es, bx             ; move segment start of string to es, 0
    MOV bp, OFFSET money_question   ; move start offset of string in bp
    MOV dl, 0              ; start writing from col 0
    int 0x10                ; BIOS inter
    
    mov ah, 0x0A
    lea dx, word buffer
    mov si, dx ;index i, start at 53
    int 0x21
    
    call input_check    ;test input check function, will be changed later
    
_print_h:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 6             ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET h   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    
 

_print_d:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX,  8           ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET d   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    
_print_c:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 5             ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET c   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    
_print_s:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 5             ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET s   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    
    
_game_loop:
    call rng            ;test random number generator
    call display_card   ;test display function
    
    ;call win            ;test win print function
    ;call lose           ;test cpu win print function   

    

_end_game: