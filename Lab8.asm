; CS 274 Spring 24 - Lab 8
; Author: Mia, Elijah, Julian
; Sketch of code structure for CP2 in terms of procdeures, BlackJack

; proc rand_number
; generate random number from valid range within deck(s)

; proc rand_suit
; will use logic from rand_number to obtain suit

; Note: may combine both rand_number and rand_suit into one proc, rand_gen
; for ease of display

; proc win
; display win-statement when either player wins the current game
; a) player1 reaches 21 before player2
; b) player2 goes over 21

; proc lose
; display lose-statement when a player loses by:
; a) going over 21
; b) player1 reaches 21 first

; proc input_check
; verifies that a player inputs a bet amount
; checks if bet is valid according to remaining balance

; proc check_suit
; identifies generated suit and displays it

; proc display_card
; print the card value obtained by random generation of both suit and number

; proc string_to_num
; converts A as in Ace to the value 1, or 11
; same logic applies to jack, queen, king

; proc player_choice
; ask user to hit or stand

; proc player_hit
; jump here if player chooses to hit on current turn
; give user another card and update values
; if given an ace, call proc ace_hit

; proc ace_hit
; ask user if they want to use ace as '11' or '1'
; update sum of card values


