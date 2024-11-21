        DEVICE ZXSPECTRUM48
        SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
        org $8000              ; Program is located from memory address $8000 = 32768

begin:  di              ; Disable Interrupts
        ld sp,0         ; Set stack pointer to top of ram (RAMTOP)

;-------------------------------------------------------------------------------------------------
; Student Code
        ld ix, $5800    ; Top left of screen attribute memory
        ld iy, $5AFF    ; Bottom right of screen attribute memory
        ld d, 8         ; Initial color (BLUE) for the line

mainLoop:
        call linSup     ; Paint upper line at the right speed
        call linInf     ; Paint lower line at the right speed
        jp mainLoop

endofcode:      jr endofcode    ; Infinite loop

T1: DW T1RESET       ; Timer for upper line
T2: DW T2RESET       ; Timer for lower Line
T3: DW T3RESET       ; Timer for keyboard input

T1RESET: EQU 250     ; Timer values for upper line
T2RESET: EQU 3000    ; Timer values for lower line
T3RESET: EQU 3000    ; Timer values for keyboard input
;-------------------------------------------------------------------------------------------------
; linSup : Paints a fixed-color dot at MEM[IX] at timer intervals. Increments IX
; Receives:    IX pointing to screen memory.
; Returns:     IX gets incremented

linSup: 
        push de
        ld d, 8         ; Blue color for the line
        ld hl, T1
        push hl
        call timer
        jr nz, exitLinSup
        ld (ix), d         
        inc ix         
        ld bc, T1RESET
        ld (hl), bc      

exitLinSup: 
        pop hl
        pop de
        ret

; linInf : Paints dot at MEM[IY] in color D at timer intervals. Decrements IY
; Receives:    IY pointing to screen memory. D as color to paint
; Returns:     IY gets decremented

linInf: 
        push de
        ld hl, T2
        push hl
        call timer
        jr nz, exitLinInf
        call keyboard           ; Check if "Space" is pressed to update color
        ld (iy), d              ; Paint with updated color
        dec iy                  
        ld bc, T2RESET
        ld (hl), bc    

exitLinInf:
        pop hl
        pop de
        ret

; Keyboard : Reads keyboard (Space) and increments D to change color
; Receives:  D=D+1 if Space is pressed (bit 0 of $7FFE).
;            Resets keyboard timer if Space is pressed.

keyboard:
        push hl
        ld hl, T3
        call timer
        jr nz, noKey         ; If timer hasn't expired, don't check keyboard

        ld bc, $7FFE  
        in a, (c)       
        bit 0, a             ; Check bit 0 for "Space" key
        jr nz, noKey         ; If "Space" is not pressed, skip
        inc d                ; Increment D to change color
        ld bc, T3RESET
        ld (hl), bc          ; Reset keyboard timer

noKey: 
        pop hl
        ret

; Timer : Decrements a 16-bit variable until it reaches zero
; Receives: HL pointing to 16-bit variable.
;           Var=Var-1 if Var>0
; Returns:  Z flag if reached 0. NZ otherwise

timer: 
        push bc
        ld bc, (hl)
        ld a,b 
        or c 
        jr z, exitTimer
        dec bc
        ld (hl),bc
exitTimer: 
        pop bc
        ret