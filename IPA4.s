
;CS 274
;
; IPA 4

;print string instructions
;MOV AH, 0x13            ; move BIOS interrupt number in AH
;MOV CX, 11              ; move length of string in cx
;MOV BX, 0               ; mov 0 to bx, so we can move it to es
;MOV ES, BX              ; move segment start of string to es, 0
;MOV BP, OFFSET hello    ; move start offset of string in bp
;MOV DL, 0               ; start writing from col 0
;int 0x10                ; BIOS inter

;set null spaces for input to be stored

;rng variables
db 0xAD      ;X0 (173)       ;Xk starts at (173), then Xk+1
db 0xAD
db 0x03       ;A value a, odd and ideally co-prime to (3)
db 0xFB       ;A large prime m that fits in a register of the required size (251)
db 0x00 ;     ;random num n, for card indexing

;game configs
num_decks: db 0x01      ;initial set at 1
num_cards: db 0x34      ;initial set at 52

;player variables
player_score: db 0x00 ; Will be used for player score
bet_amount: db 0x00     ;storing bet amount

;printable strings
deck: db "23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA"
db 0x00
money_question: db "How much would you like to bet? Must be a number between $10-$1000"

; adding questions for 3.4
bet_question: db "Which mode would you like to play against: Conservative, Normal, or Aggressive?"
risk_question: db "Determine the risk level you would like to play against for each action: Keep hand, Add card, Forfeit card. Must add to 100."
difficulty_question: db "Select difficulty mode: Easy, Normal, or Hard"

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

def calc_num_cards{
    mov ax,0    ;reset ax
   
    mov bp, offset num_cards    ;get index of num cards in memory
    
    
    mov ax, 0x34        ;move '52' into ax
    mul byte [5]        ;multipy 52 by num of decks
    mov byte [bp],al    ;update num cards in memory
    
    mov ax,0    ;reset ax
}

def rng{
    ;reset all registers
    mov ax,0
    mov bx,0
    mov cx,0
    mov dx,0
    
    mov al, byte [1]    ;X subscript k
    mov bl, byte [2]    ;coprime a
    mov cl, byte [3]    ;prime number m
    mov dx, 0
   
    
    ;obtain Xk+1 by Xk+1 = a * Xk mod m
    mul bx              ;multiply a by X subscript k
    div cx              ;then mod m = X subscript k+1
    mov ax,dx           ;this is Xk+1
    mov byte [1],al     ;store k+1 into mem[0]
  
    mov dx,0            ;reset dx 
    mov cl,byte[6]
    ;obtain index by n = Xk+1 mod num of cards
    div cx            ;Xk+1 mod num of cards
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
    cmp byte[4],0x0C    ;check if n is below 12
    jbe _print_h        ;if so,print hearts
    cmp byte[4],0x19    ;check if n is below 25
    jbe _print_c        ;if so,print clubs
    cmp byte[4],0x26    ;check if n is below 38
    jbe _print_s        ;if so, print spades
    cmp byte[4], 0x33   ;check if n is below 51
    jbe _print_d        ;if so,print diamnonds
    
    ret
}

def display_card {

    ; randomly displays value of card
    MOV bp, OFFSET deck
    mov al, byte [4]
    mov si, ax; rng card value
    add bp, si ; the index of the string we want to print
    mov ah, 0x02 ; BIOS function for printing char in ah, 
    mov dl, byte [bp]
    int 0x21    ;print card value
    
    ; Card value stored in dl
    
    
    ;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 2           ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET of   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    
    call check_suit
    
    ret
}

def string_to_num { ;could be a method instead MAYBE

    MOV bp, OFFSET deck
    ;mov al, byte [4] ;rand number n (index of deck)
    mov al, byte [4]
    mov ah, 0
    mov si, ax 
    add bp, si ; the index of the string we want to print
    mov dl, byte [bp] ; stores character in

    ; add number to player byte[5] which is the 6th index
    ; which is the player score
    ;mov ax, 0 ; move zero into ax
    
    cmp dl, 0x41           ; Compare with ASCII value of 'A'
    je  convert_A            ; Jump if equal to 'A'
    cmp dl, 0x32           ; Compare with ASCII value of '2'
    je  convert_2            ; Jump if equal to '2'
    cmp dl, 0x33           ; Compare with ASCII value of '3'
    je  convert_3            ; Jump if equal to '3'
    cmp dl, 0x34           ; Compare with ASCII value of '4'
    je  convert_4            ; Jump if equal to '4'
    cmp dl, 0x35           ; Compare with ASCII value of '5'
    je  convert_5            ; Jump if equal to '5'
    cmp dl, 0x36           ; Compare with ASCII value of '6'
    je  convert_6            ; Jump if equal to '6'
    cmp dl, 0x37           ; Compare with ASCII value of '7'
    je  convert_7            ; Jump if equal to '7'
    cmp dl, 0x38           ; Compare with ASCII value of '8'
    je  convert_8            ; Jump if equal to '8'
    cmp dl, 0x39           ; Compare with ASCII value of '9'
    je  convert_9            ; Jump if equal to '9'
    cmp dl, 0x54           ; Compare with ASCII value of 'T'
    je  convert_T            ; Jump if equal to 'T'
    cmp dl, 0x4A           ; Compare with ASCII value of 'J'
    je  convert_J            ; Jump if equal to 'J'
    cmp dl, 0x51           ; Compare with ASCII value of 'Q'
    je  convert_Q            ; Jump if equal to 'Q'
    cmp dl, 0x4B           ; Compare with ASCII value of 'K'
    je  convert_K            ; Jump if equal to 'K'

    ret
}
; 3.4 logic for game modes
; computer betting mode
def comp_bet_mode{

    MOV ah, 0x13            ; BIOS interrupt for printing string
    MOV CX, 46              ; Length of string for bet question
    MOV BX, 0               ; Set BX to 0 for segment start of string
    MOV ES, BX              ; Move segment start of string to ES
    MOV BP, OFFSET bet_question   ; Start offset of bet question string
    MOV DL, 0               ; Start writing from column 0
    int 0x10                ; Invoke BIOS interrupt
    
    ; Load user input (mode)
    call input_check   
    
    ; Determine bet amount based on the mode
    cmp al, 'C'             ; Check if mode is Conservative
    je conservative_mode     ; Jump if mode is Conservative
    cmp al, 'N'             ; Check if mode is Normal
    je normal_mode           ; Jump if mode is Normal
    cmp al, 'A'             ; Check if mode is Aggressive
    je aggressive_mode       ; Jump if mode is Aggressive
    
    ; If none of the modes match, default to Normal mode
    normal_mode:
        mov al, [bet_amount]   ; Load bet amount
        jmp bet_done           ; Jump to the end of the betting logic
    conservative_mode:
        ; Under-bet human by 20%
        mov al, [bet_amount]   ; Load bet amount
        sub al, 20             ; Subtract 20%
        jmp bet_done           ; Jump to the end of the betting logic
    aggressive_mode:
        ; Outmatch human bet by 30%
        mov al, [bet_amount]   ; Load bet amount
        add al, 30             ; Add 30%
    bet_done:
        mov [comp_bet_amount], al  ; Store the computed bet amount
    ret
    
}

; computer risk level 
def comp_risk_level{
MOV ah, 0x13            ; BIOS interrupt for printing string
    mov cx, 68              ; Length of string for risk question
    mov bx, 0               ; Set BX to 0 for segment start of string
    mov es, bx              ; Move segment start of string to ES
    mov bp, OFFSET risk_question   ; Start offset of risk question string
    mov dl, 0               ; Start writing from column 0
    int 0x10                ; Invoke BIOS interrupt
    
    ; Read user input for risk level
    mov ah, 0x0A            ; BIOS function for buffered input
    lea dx, buffer          ; Load the buffer address
    int 0x21                ; Invoke BIOS interrupt to read input
    
    ; Convert the ASCII input to binary (assuming it's a single digit)
    movzx ax, byte offset buffer ; Load the ASCII input
    sub ax, '0'             ; Convert ASCII character to integer
    
    ; Store the risk level in mem
    mov [risk_level], ax    ; Store the risk level for further processing
    
    ; Generate a random number to determine the action
    call rng                ; Assuming rng function generates a random number
    
    mov ax, [random_number] ; Assuming random number is stored in memory
    cmp ax, 33              ; Check if random number is less than 33 (33%)
    jb keep_hand            ; Jump if random number is less than 33%
    cmp ax, 66              ; Check if random number is less than 66 (66%)
    jb add_card             ; Jump if random number is less than 66%
    jmp forfeit_hand        ; If not keeping or adding, forfeit the hand
    
keep_hand:
    ; Keep current hand
    mov [comp_action], 'K' ; Store action as Keep
    ret

add_card:
    ; Add another card
    mov [comp_action], 'A' ; Store action as Add
    ret

forfeit_hand:
    ; Forfeit current hand
    mov [comp_action], 'F' ; Store action as Forfeit
    
    ret
}

; difficulty mode
def difficulty{

    MOV ah, 0x13            ; BIOS interrupt for printing string
    MOV CX, 41              ; Length of string for difficulty question
    MOV BX, 0               ; Set BX to 0 for segment start of string
    MOV ES, BX              ; Move segment start of string to ES
    MOV BP, OFFSET difficulty_question  ; Start offset of difficulty question string
    MOV DL, 0               ; Start writing from column 0
    int 0x10                ; Invoke BIOS interrupt
    
    ; Load user input (difficulty level)
    MOV al, [user_difficulty_input]  
    
    cmp al, 'E'             ; Check if difficulty level is Easy
    je easy_level           ; Jump if difficulty level is Easy
    cmp al, 'N'             ; Check if difficulty level is Normal
    je normal_level         ; Jump if difficulty level is Normal
    cmp al, 'H'             ; Check if difficulty level is Hard
    je hard_level           ; Jump if difficulty level is Hard
    
    ; If none of the levels match, default to Normal level
    normal_level:
        ; Default parameters for Normal difficulty
        jmp difficulty_done   ; Jump to the end of difficulty level setting
    easy_level:
        ; Decrease initial money for computer opponent (50% of human's initial amount)
        jmp difficulty_done   ; Jump to the end of difficulty level setting
    hard_level:
        ; Increase initial money for computer opponent (50% extra money than the human)
    difficulty_done:
    
    ret
}

convert_A:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0xB             ; Add the integer value for 'A' (e.g., 11 for Ace)
    mov byte [7], al        ; Store the result back into byte[7]

convert_2:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x2             ; Add the integer value for '2'
    mov byte [7], al        ; Store the result back into byte[7]
    

convert_3:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x3             ; Add the integer value for '3'
    mov byte [7], al        ; Store the result back into byte[7]
    

convert_4:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x4             ; Add the integer value for '4'
    mov byte [7], al        ; Store the result back into byte[7]
   

convert_5:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x5             ; Add the integer value for '5'
    mov byte [7], al        ; Store the result back into byte[7]
   

convert_6:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x6             ; Add the integer value for '6'
    mov byte [7], al        ; Store the result back into byte[7]
   

convert_7:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x7             ; Add the integer value for '7'
    mov byte [7], al        ; Store the result back into byte[7]
  

convert_8:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x8             ; Add the integer value for '8'
    mov byte [7], al        ; Store the result back into byte[7]
  

convert_9:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x9             ; Add the integer value for '9'
    mov byte [7], al        ; Store the result back into byte[7]
    

convert_T:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0xA             ; Add the integer value for 'T' (e.g., 10 for Ten)
    mov byte [7], al        ; Store the result back into byte[7]
    

convert_J:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0xB             ; Add the integer value for 'J' (e.g., 11 for Jack)
    mov byte [7], al        ; Store the result back into byte[7]
   

convert_Q:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0xC             ; Add the integer value for 'Q' (e.g., 12 for Queen)
    mov byte [7], al        ; Store the result back into byte[7]
   

convert_K:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0xD             ; Add the integer value for 'K' (e.g., 13 for King)
    mov byte [7], al        ; Store the result back into byte[7]
    


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
    jmp _game_loop
 

_print_c:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 5             ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET c   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    jmp _game_loop
    
_print_s:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 5             ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET s   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    jmp _game_loop
    
_print_d:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX,  8           ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET d   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    jmp _game_loop

_player_turn:

_cpu_turn:

_game_loop:
    
    call rng            ;test random number generator
    call string_to_num
    ;call display_card   ;test display function
    ;call win            ;test win print function
    ;call lose           ;test cpu win print function   


    

_end_game:
