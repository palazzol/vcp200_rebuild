;
; VCP200 circuit
;
; PB0 - 8 - GO/NO-ON 
; PB1 - 9 - TURN RIGHT/YES-OFF
; PB2 - 10 - REVERSE/NOT SURE
; PB3 - 11 - SLOW
; PB4 - 12 - STOP
; PB5 - 13 - TAXI or RESET
; PB6 - 14 - LEFT TURN
; PB7 - 15 - BUCKETS or LIGHTS
; TIMER - 7 - DATA IN 
; PA7 - 19 - MODE - high = Yes/No/On/Off mode
; PA6 - 18 - grounded; do middle part of special mode
; PA5 - 17 - Vcc
; PA4 - 16 - Vcc
; ~IRQ - 2 - Hardwired to + (unused)
; 10 Mhz Xtal
;

; MC6804P2 Data Space Defines

PORTA   .equ    0x00
PORTB   .equ    0x01
DDRA    .equ    0x04
DDRB    .equ    0x05

TSTATUS .equ    0x09

ROM5D   .equ    0x5D
ROM5E   .equ    0x5E
ROM5F   .equ    0x5F

X       .equ    0x80
Y       .equ    0x81
V       .equ    0x82
W       .equ    0x83
RAM84   .equ    0x84

FCNT    .equ    0x85
VCNT    .equ    0x86
SCNT    .equ    0x87

RAM88   .equ    0x88        ; N?
RAM89   .equ    0x89
RAM8A   .equ    0x8A
RAM8B   .equ    0x8B
RAM8C   .equ    0x8C
RAM8D   .equ    0x8D
RAM8E   .equ    0x8E
RAM8F   .equ    0x8F
RAM90   .equ    0x90
RAM91   .equ    0x91
RAM92   .equ    0x92

RAM9E   .equ    0x9E
RAM9F   .equ    0x9F

PRESCALE    .equ    0xFD
TCOUNT  .equ    0xFE
A       .equ    0xFF

        ; VCP200 - Program ROM

        .area   CODE1   (ABS)

        ; Self-test ROM area start
        .org    0x0ae0

L0AE0:
        BCS     L0AE6
        JSR     L0AE6
        ADD     #0x00
        RTS

L0AE6:
        STA     RAM9E
        COMA 
        AND     ,Y
        COMA 
        STA     RAM9F
        LDA     ,Y
        COMA 
        AND     RAM9E
        COMA 
        AND     RAM9F
        COMA 
        RTS

; SELF-TEST START

SELFTST:

        MVI     W,#0x04	        ; 0x04 -> W register
L0AF9:
        BEQ     L0AF9           ; ???
L0AFA:
        BCS     L0AFA           ; ???
        LDA     #0x00           ; A = 0
        STA     PORTA           ; Clear PORTA
        BSET    #7,DDRA         ; Set PA7 As OUTPUT

; Stack Test

; JSR 4 times
        STA     V               ; Clear V Register
L0B02:
        BRSET   #2,V,L0B08      ; exit if V == 4
        INC     V               ; V = V + 1
        JSR     L0B02           ; add a stack level

; RTS 5 times
L0B08:
        BRSET   #7,V,L0B0D      ; Exit if V == -1
        DEC     V               ; V = V - 1
        RTS
L0B0D:
        JSR     L0BFF           ; A=0, Clear interrupt mask?
L0B0F:
        BRSET   #1,0x09,L0B0F   ; wait for timer?

        BCS     L0B1B
        LDA     #0x06           ; DDRC into X
        STA     X
        SUB     #0x04           ; DDRA into Y
        STA     Y
L0B19:
        LDA     #0x0F
L0B1B:
        STA     RAM84           ; 0x0F into $84
        LDA     V               ; Put V into DDRA (should be 0xff)
        STA     ,Y              ; Select PORTA as all outputs
        AND     RAM84           ; A = 0x0F
        STA     ,X              ; Select PC0-PC3 as all outputs
        LDA     V
L0B23:
        STA     ,Y              ; Select PORTA as all outputs, again
        CMP     0xFF            ; All outputs?
L0B26:
        BCS     L0B26           ; 
        BSET    #3,PORTB        ; Set PB3 HIGH - nIRQ
        BSET    #6,PORTA        ; Set PA6 as Output - turn on LED
        BCLR    #2,0x02         ; Set PC2 LOW - no effect
        CMP     ,Y              ; DDRA all outputs?
        COMA                    ; A = 0xff
        BEQ     L0B23
        LDA     ,X
        COMA 
        BRSET   #7,0xFF,L0B1B
        AND     #0x00
        STA     ,X
        DEC     X
        DEC     Y
        BRCLR   #5,Y,L0B19

        LDA     #0x0F
        STA     DDRB            ; PB0-PB3 as outputs
        SUB     0x0A
        SUB     #0xEE
L0B45:
        BNE     L0B45
        LDA     0x0B
        CMP     #0x1B
L0B4A:
        BNE     L0B4A

        INC     PORTB           ; PB0-PB3 -> 1
        JSR     L0B5E           ; Do Ram Clear
        ADD     0x0A
        CMP     #0x32
L0B53:
        BNE     L0B53
        LDA     0x0B
        CMP     #0xBB
L0B58:
        BNE     L0B58
        INC     PORTB           ; PB0-PB3 -> 2
        INC     PORTB           ; PB0-PB3 -> 3
L0B5D:
        BNE     L0B5D

; RAM clear, from $82-$9F

L0B5E:
        LDA     #0xFF
        COMA
L0B61:
        BNE     L0B61
        JSR     L0BCC
L0B64:
        BNE     L0B64
L0B65:
        STA     ,Y              ; Clear [Y]
        ROLA
        DEC     Y
        DEC     X
        BNE     L0B65

; RAM tests

        LDA     #0x55
L0B6C:
        JSR     L0BCC
        DEC     ,Y
L0B6F:
        CMP     ,Y
        STA     ,Y
        COMA 
        DEC     Y
        DEC     X
        BNE     L0B6F
        ADD     A
        BCC     L0B6C
        SUB     A
L0B7A:
        BCS     L0B7A

        JSR     L0BCC
L0B7D:
        CMP     ,Y
        STA     ,Y
        DEC     Y
        DEC     X
        BNE     L0B7D
        INC     X
        ADD     0x0A
        CMP     #0x3B
L0B87:
        BNE     L0B87
        ADD     0x0B
        CMP     #0xA1
L0B8C:
        BNE     L0B8C
        INC     ,X

        BCLR    #0,DDRB     ; PB0 Low

; Timer Test

        MVI     TSTATUS,#0x28
L0B93:
        LDA     PRESCALE
        LDA     ,X
        BRCLR   #7,TSTATUS,L0B93
        SUB     ,X
        BEQ     L0B8C-1                     ; ???
        BSET    #4,TSTATUS
        MVI     TCOUNT,#0x06
L0BA0:
        BRCLR   #0,PORTB,L0BA0
        BCLR    #4,TSTATUS
L0BA5:
        BRSET   #7,TSTATUS,L0BA5
L0BA8:
        MVI     TCOUNT,#0x04
        BCLR    #7,TSTATUS
        BSET    #0,DDRB     ; PB0 High
        BCLR    #5,TSTATUS
        BCLR    #4,A
        BEQ     L0BA8-1                     ; ???
        BEQ     L0BA8-1                     ; ???
        STA     TCOUNT
        INC     ,X
L0BB8:
        BCLR    #0,PRESCALE
L0BBA:
        BRCLR   #7,TSTATUS,L0BBA
        INC     TSTATUS
        INC     TCOUNT
        STA     PRESCALE
        ADD     A
        BCC     L0BB8

        LDA     V
        DEC     X
L0BC8:
        ADD     ,X
        INC     X
        BNE     L0BC8
        RTS 

L0BCC:
        MVI     X,#0x1E         ; #0x1E -> X (number of bytes)
        MVI     Y,#0x9F         ; #0x9F -> Y (last ram location)
        RTS
L0BD3:
        BRCLR   #2,W,L0BE2
L0BD6:
        BCLR    #7,PORTA        ; Clear PA7
        BSET    #3,PORTB        ; Set PB3
        BSET    #7,A
        JSR     L0AE0
        STA     ,Y
L0BDF:
        BCC     L0BDF
        DEC     W
        BEQ     L0BD3
L0BE2:
        RTI 

; SELF TEST IRQ HANDLER ENTRY

SELFIRQ:

        BCS     L0BD6
        BEQ     L0BEA
        BCLR    #7,DDRA
        BRSET   #0,TCOUNT,L0BDF
L0BEA:
        MVI     X,#0x02
        MVI     TSTATUS,#0x27
        LDA     W
        COMA 
        BEQ     L0BF8
        MVI     X,#0x06
        BSET    #4,TSTATUS
L0BF8:
        BSET    #7,TSTATUS
L0BFA:
        STA     ,X
        DEC     X
        BNE     L0BFA
        STA     ,X
        STA     W
L0BFF:
        SUB     A          ; Clear A
        RTI


        .ASCII  'MC6804J2 - ATX'
;
; VCP200 - USER PROGRAM START
;

START:

; Init pins
        MVI     DDRB,#0xFF      ; Port B - all outputs
        MVI     PORTB,#0xFE
        MVI     DDRA,#0x00      ; Port A - all inputs

; Init RAM
        BCLR    #1,V            ; clear test bit??
; Main loop
L0C1B:
        ; clear RAM from $83 to $9F
        MVI     Y,#0x1D
        MVI     X,#0x83
        LDA     #0x00
RAMCLR:
        STA     ,X
        INC     X
        DEC     Y
        BNE     RAMCLR

        MVI     Y,#0x93         ; Y points to 0x93
L0C2A:
        LDA     #0x00
        STA     FCNT
        STA     VCNT
        STA     SCNT
        JSR     L0FC7           ; Read and classify frames?
        BRCLR   #1,V,L0C39

        JMP     L0D14
L0C39:
        MVI     PORTB,#0x80     ; 1000 0000
        LDA     PORTA           ; check PORTA upper nibble
        AND     #0xF0
        CMP     #0xF0
        BNE     L0C45           ; always jump because PA6 is grounded?
        JMP     L0D14           ; PORTA is 1111 - unknown mode jump?

; Try to decode Normal mode or Special modes
L0C45:
        BCLR    #1,V
        MVI     PORTB,#0xFC     ; 1111 1100
        BRSET   #4,PORTA,L0C52  ; should be high
        MVI     RAM88,#0xDC
        JMP     L0CFD           ; PORTA is XXX0 - secret code 0xdc?
L0C52:
        BRSET   #5,PORTA,L0C5A  ; should be high
        MVI     RAM88,#0x74
        JMP     L0CFD           ; PORTA is XX01 - secret code 0x74?
L0C5A:
        BRSET   #6,PORTA,L0C64  ; should be low
        BSET    #1,V
        MVI     PORTB,#0xFF     ; 1111 1111
        JMP     L0D14           ; PORTA is X011 - normal mode
L0C64:
        BRSET   #7,PORTA,L0C6C  ;
        MVI     RAM88,#0x78
        JMP     L0CFD           ; PORTA is 0111 - secret code 0x78?

L0C6C:
        MVI     PORTB,#0xFA     ; PORTA is 1111 - 1111 1010
        BRSET   #4,PORTA,L0C77     
        MVI     RAM88,#0xD8
        JMP     L0CFD           ; secret code 0xd8?
L0C77:
        BRSET   #5,PORTA,L0C7F
        MVI     RAM88,#0xBC         
        JMP     L0CFD           ; secret code 0xbc?
L0C7F:
        BRSET   #6,PORTA,L0C87
        MVI     RAM88,#0xEC
        JMP     L0CFD           ; secret code 0xec?

L0C87:
        MVI     PORTB,#0xF6     ; 1111 0110
        BRSET   #5,PORTA,L0C92
        MVI     RAM88,#0xB8
        JMP     L0CFD           ; secret code 0xb8?
L0C92:
        BRSET   #6,PORTA,L0C9A
        MVI     RAM88,#0xE8
        JMP     L0CFD           ; secret code 0xe8?
L0C9A:
        BRSET   #7,PORTA,L0CA2
        MVI     RAM88,#0xFC
        JMP     L0CFD           ; secret code 0xfc?

L0CA2:
        MVI     PORTB,#0xEE     ; 1110 1110
        BRSET   #5,PORTA,L0CAD
        MVI     RAM88,#0xB4
        JMP     L0CFD           ; secret code 0xb4?
L0CAD:
        BRSET   #6,PORTA,L0CB5
        MVI     RAM88,#0xE4
        JMP     L0CFD           ; secret code 0xe4?
L0CB5:
        BRSET   #7,PORTA,L0CBD
        MVI     RAM88,#0xF4
        JMP     L0CFD           ; secret code 0xf4?

L0CBD:
        MVI     PORTB,#0xDE     ; 1101 1110
        BRSET   #4,PORTA,L0CC8
        MVI     RAM88,#0xF8
        JMP     L0CFD           ; secret code 0xf8?
L0CC8:
        BRSET   #5,PORTA,L0CD0
        MVI     RAM88,#0x70
        JMP     L0CFD           ; secret code 0x70?
L0CD0:
        BRSET   #6,PORTA,L0CD8
        MVI     RAM88,#0xE0
        JMP     L0CFD           ; secret code 0xe0?
L0CD8:
        BRSET   #7,PORTA,L0CE0
        MVI     RAM88,#0xF0
        JMP     L0CFD           ; secret code 0xf0?

L0CE0:
        MVI     PORTB,#0xBE     ; 1011 1110
        BRSET   #4,PORTA,L0CEB
        MVI     RAM88,#0xD0
        JMP     L0CFD           ; secret code 0xd0?
L0CEB:
        BRSET   #6,PORTA,L0CF3
        MVI     RAM88,#0x7C
        JMP     L0CFD           ; secret code 0x7c?
L0CF3:
        BRSET   #7,PORTA,L0CFB
        MVI     RAM88,#0xD4
        JMP     L0CFD           ; secret code 0xd4?
L0CFB:
        JMP     L0D14

; do middle part of special mode
L0CFD:
        JSR     L0F7B           ; secret code trampoline

; do last part of special mode and go back to memory clear

        MVI     PORTB,#0x80     ; 1000 0000
L0D02:
        LDA     PORTA           ; wait loop until PORTA = 1111
        AND     #0xF0
        CMP     #0xF0
        BNE     L0D02
        MVI     TCOUNT,#0x40
        MVI     TSTATUS,#0x3F
L0D0F:
        BRCLR   #7,TSTATUS,L0D0F
        JMP     L0C1B

; Normal mode

L0D14:
        LDA     RAM8B           ; Shift 0x88:8B -> 89:8C
        STA     RAM8C
        LDA     RAM8A
        STA     RAM8B
        LDA     RAM89
        STA     RAM8A
        LDA     RAM88
        STA     RAM89

        LDA     FCNT
        ADD     VCNT
        ADD     SCNT
        CMP     #0x02
        BCC     L0D32
        MVI     RAM88,#0x00
        JMP     L0D4C
L0D32:
        LDA     SCNT
        CMP     #0x10
        BCC     L0D39
        JMP     L0D49
L0D39:
        CMP     VCNT
        BCS     L0D41
        MVI     RAM88,#0x02
        JMP     L0D4C
L0D41:
        LDA     FCNT
        BNE     L0D49
        MVI     RAM88,#0x02
        JMP     L0D4C
L0D49:
        MVI     RAM88,#0x01
L0D4C:
        MVI     FCNT,#0x00
        MVI     VCNT,#0x00
        MVI     SCNT,#0x00
        LDA     #0x85
        ADD     RAM88
        STA     X
        INC     ,X
        LDA     #0x85
        ADD     RAM89
        STA     X
        INC     ,X
        LDA     #0x85
        ADD     RAM8A
        STA     X
        INC     ,X
        LDA     #0x85
        ADD     RAM8B
        STA     X
        INC     ,X
        LDA     #0x85
        ADD     RAM8C
        STA     X
        INC     ,X
        LDA     FCNT
        CMP     #0x02
        BCS     L0D7D
        MVI     RAM92,#0x00
        JMP     L0D94
L0D7D:
        LDA     VCNT
        CMP     #0x04
        BCS     L0D87
        MVI     RAM92,#0x01
        JMP     L0D94
L0D87:
        LDA     SCNT
        CMP     #0x03
        BCS     L0D91
        MVI     RAM92,#0x02
        JMP     L0D94
L0D91:
        MVI     RAM92,#0x80
L0D94:
        INC     RAM8E
L0D96:
        BRCLR   #7,RAM92,L0D9B
        JMP     L0C2A
L0D9B:
        LDA     RAM92
        CMP     RAM8F
        BNE     L0DA2
        JMP     L0E08
L0DA2:
        LDA     RAM8D
        BNE     L0DB1
        LDA     RAM92
        STA     RAM8F
        MVI     RAM8D,#0x01
        MVI     RAM90,#0x01
L0DAF:
        JMP     L0C2A
L0DB1:
        LDA     RAM8F
        BEQ     L0DBE
        CMP     #0x01
        BNE     L0DB9
        JMP     L0DF8
L0DB9:
        CMP     #0x02
        BNE     L0DAF
        JMP     L0E01
L0DBE:
        LDA     RAM90
        CMP     #0x02
        BCS     L0DC5
        JMP     L0DD9
L0DC5:
        LDA     Y
        CMP     #0x93
        BNE     L0DCB
        JMP     L0C1B
L0DCB:
        DEC     Y
        LDA     ,Y
        AND     #0x03
        STA     RAM8F
        LDA     RAM91
        STA     RAM90
        DEC     RAM8D
        JMP     L0D96
L0DD9:
        LDA     RAM90
        ADD     A
        ADD     A
        ADD     RAM8F
        STA     ,Y
        INC     Y
        LDA     Y
        CMP     #0x9F
        BCS     L0DE9
        JMP     L0C1B
L0DE9:
        INC     RAM8D
        LDA     RAM92
        STA     RAM8F
        LDA     RAM90
        STA     RAM91
        MVI     RAM90,#0x01
        JMP     L0C2A
L0DF8:
        LDA     RAM90
        CMP     #0x04
        BCC     L0DFF
L0DFD:
        JMP     L0DC5
L0DFF:
        JMP     L0DD9
L0E01:
        LDA     RAM90
        CMP     #0x04
        BCS     L0DFD
        JMP     L0DD9
L0E08:
        LDA     RAM92
        BEQ     L0E19
        INC     RAM90
        LDA     RAM90
        CMP     #0x3F
        BCS     L0E15
        MVI     RAM90,#0x3F
L0E15:
        JMP     L0C2A
L0E17:
        JMP     L0C1B
L0E19:
        INC     RAM90
        LDA     RAM90
        CMP     #0x18
        BCS     L0E15
        LDA     Y
        CMP     #0x94
        BCC     L0E26
        JMP     L0E17
L0E26:
        SUB     #0x93
        STA     RAM8D
        STA     RAM8A
        LDA     RAM8E
        CMP     #0x20
        BCC     L0E33
        JMP     L0E17
L0E33:
        DEC     Y
        LDA     Y
        CMP     #0x95
        BCC     L0E3A
        JMP     L0E4A
L0E3A:
        DEC     Y
        LDA     ,Y
        AND     #0x03
        BNE     L0E4A
        INC     Y
        LDA     ,Y
        AND     #0x03
        CMP     #0x01
        BNE     L0E4C
        LDA     ,Y
        CMP     #0x1C
        BCS     L0E50
L0E4A:
        JMP     L0E59
L0E4C:
        LDA     ,Y
        CMP     #0x14
        BCC     L0E59
L0E50:
        DEC     RAM8A
        DEC     RAM8A
        LDA     RAM8A
        STA     X
        JMP     L0E33
L0E59:
        MVI     FCNT,#0xFF
        MVI     VCNT,#0xFF
        MVI     X,#0x18         ; Read from DATA ROM
        MVI     Y,#0x93
L0E65:
        LDA     ,X
        ROLA 
        ROLA 
        ROLA 
        ROLA 
        ROLA 
        AND     #0x0F
        STA     FCNT            ; Store upper nybble here
        LDA     ,X
        AND     #0x0F
        STA     SCNT            ; Store lower nybble here
        CMP     #0x0F
        BNE     L0E7C
        MVI     VCNT,#0x08
        JMP     L0F17
L0E7C:
        CMP     RAM8A
        BCS     L0E80
        BCC     L0E8A
L0E80:
        LDA     X
        ADD     SCNT
        STA     X
        INC     X
        MVI     Y,#0x93
        JMP     L0E65
L0E8A:
        INC     X
        LDA     ,X
        AND     #0x03
        STA     RAM8C
        LDA     ,Y
        AND     #0x03
        CMP     RAM8C
        BNE     L0E98
        JMP     L0EA7
L0E98:
        LDA     ,X
        BRCLR   #7,A,L0E9E
        JMP     L0EB3
L0E9E:
        LDA     X
        ADD     SCNT
        STA     X
        MVI     Y,#0x93
        JMP     L0E65
L0EA7:
        LDA     ,X
        BRCLR   #5,A,L0EAD
        JMP     L0EFD
L0EAD:
        BRCLR   #6,A,L0EB2
        JMP     L0EE1
L0EB2:
        INC     Y
L0EB3:        
        DEC     SCNT
        BEQ     L0EB8
        JMP     L0E8A
L0EB8:
        LDA     Y
        SUB     #0x93
        CMP     RAM8A
        BEQ     L0EC4
        INC     X
        MVI     Y,#0x93
        JMP     L0E65
L0EC4:
        LDA     FCNT
        STA     VCNT
        CMP     #0x0E
        BEQ     L0ECD
        JMP     L0F17
L0ECD:
        MVI     Y,#0x93
        INC     Y
        LDA     ,Y
        AND     #0xFC
        CMP     #0x77
        BCC     L0EDC
        MVI     VCNT,#0x03
        JMP     L0F17
L0EDC:
        MVI     VCNT,#0x01
        JMP     L0F17
L0EE1:
        BRCLR   #0,RAM8C,L0EEE
        LDA     ,Y
        AND     #0xFC
        CMP     #0x5B
        BCC     L0EEC
        JMP     L0E9E
L0EEC:
        JMP     L0EB2
L0EEE:
        CMP     #0x02
        BEQ     L0EF3
        JMP     L0EB2
L0EF3:
        LDA     ,Y
        AND     #0xFC
        CMP     #0x18
        BCC     L0EFB
        JMP     L0E9E
L0EFB:
        JMP     L0EB2
L0EFD:
        BRCLR   #0,RAM8C,L0F0A
        LDA     ,Y
        AND     #0xFC
        CMP     #0x5B
        BCC     L0F08
L0F06:
        JMP     L0EB2
L0F08:
        JMP     L0E9E
L0F0A:
        CMP     #0x02
        BNE     L0F06
        LDA     ,Y
        AND     #0xFC
        CMP     #0x18
        BCC     L0F15
        JMP     L0EB2
L0F15:
        JMP     L0E9E
L0F17:
        BRCLR   #1,V,L0F1C
        JMP     L0F4F
L0F1C:
        LDA     VCNT
        BRCLR   #3,A,L0F23
        JMP     L0C1B
L0F23:
        LDA     VCNT
        ADD     #0x55
        STA     Y
        LDA     ,Y
        STA     RAM88
        JSR     L0F7B
        MVI     TCOUNT,#0xFF
        MVI     TSTATUS,#0x3F
L0F33:
        BSET    #0,PORTB        ; XXXX XXX1
        LDA     #0x04
        DEC     A
        LDA     X
        BCLR    #0,PORTB        ; XXXX XXX0
        LDA     #0x04
        DEC     A
        LDA     X
        BRCLR   #7,TSTATUS,L0F33
        MVI     TCOUNT,#0x80
        MVI     TSTATUS,#0x3F
L0F4A:
        BRCLR   #7,TSTATUS,L0F4A
        JMP     L0C1B
L0F4F:
        MVI     X,#0xFE
        LDA     VCNT
        CMP     #0x02
        BCS     L0F5F
        BEQ     L0F5C
        MVI     X,#0xFB
        BNE     L0F5F
L0F5C:
        MVI     X,#0xFD
L0F5F:
        BRCLR   #7,PORTA,L0F6B  ; check mode bit

; mode bit is 1
        LDA     X
        STA     PORTB
        BCLR    #7,PORTB        ; 0XXX XXXX
        BSET    #7,PORTB        ; 1XXX XXXX
        JMP     L0C1B

; mode bit is 0
L0F6B:
        LDA     #0x01
L0F6D:
        DEC     VCNT
        BRSET   #7,VCNT,L0F76
        ADD     A
        JMP     L0F6D
L0F76:
        COMA 
        STA     PORTB
        JMP     L0C1B

; Middle part of special mode
; Secret code - parameter in RAM88

L0F7B:
        LDA     RAM88

        BCLR    #0,V
        MVI     RAM89,#0x06
        MVI     TSTATUS,#0x3B
        MVI     TCOUNT,#0x82
        BCLR    #7,PORTB        ; 0XXX XXXX
L0F8A:
        BRCLR   #7,TSTATUS,L0F8A
        MVI     TCOUNT,#0x34
        BSET    #7,PORTB        ; 1XXX XXXX
        BCLR    #7,TSTATUS
L0F94:
        BRCLR   #7,TSTATUS,L0F94
L0F97:
        MVI     TCOUNT,#0x34
        STA     PORTB           ; PPPP PPPP
        BCLR    #7,TSTATUS
        ADD     A
        DEC     RAM89      
        BEQ     L0FA5
        JMP     L0FC2
L0FA5:
        BRCLR   #0,V,L0FB8
L0FA8:
        BRCLR   #7,TSTATUS,L0FA8
        MVI     PORTB,#0xFE     ; 1111 1110
        MVI     TCOUNT,#0x40
        MVI     TSTATUS,#0x3F   ; 
L0FB4:
        BRCLR   #7,TSTATUS,L0FB4
        RTS 
L0FB8:
        LDA     RAM88
        COMA 
        AND     #0xFC
        MVI     RAM89,#0x06
        BSET    #0,V
L0FC2:
        BRCLR   #7,TSTATUS,L0FC2
        JMP     L0F97

; Read and classify Frames?
L0FC7:
        MVI     X,#0x52         ; X delay set to 0x52 - ~10ms frame?
        MVI     TSTATUS,#0x08   ; Timer input mode, count pulses
        MVI     TCOUNT,#0x80    ; count set to 128
        SUB     A               ; clear A
L0FD2:
        BRCLR   #7,TCOUNT,L0FDE ; if we got a transition, jump
        INC     Y
        DEC     Y
        INC     Y
        DEC     Y
        INC     A               ; increment the running counter
L0FDB:
        DEC     X
        BNE     L0FD2           ; Delay loop
        RTS
L0FDE:
        CMP     ROM5D           ; Compare against User Data ROM (0x02)
        BCC     L0FE9           ; If >= 2, jump
        INC     SCNT            ; count is 0 or 1, increment SCNT
L0FE3:
        MVI     TCOUNT,#0x80    ; reset the transition counter
        SUB     A               ; clear A
        BEQ     L0FDB           ; count down, loop around
L0FE9:
        CMP     ROM5E           ; Compare against User Data ROM (0x07)
        BCC     L0FF1           ; if >= 7, jump
        INC     VCNT            ; VCNT
        BNE     L0FE3           ; if VCNT is not zero, loop around
        JMP     L0FDB           ; else count down, loop around
L0FF1:
        CMP     ROM5F           ; Compare against User Data ROM (0x18)
        BCC     L0FF6           ; if >= 24, jump - too high
        INC     FCNT            ; FCNT
L0FF6:
        JMP     L0FE3           ; 

; VECTORS

        JMP     SELFIRQ         ; SELF-TEST IRQ VECTOR
        JMP     SELFTST         ; SELF-TEST RESTART VECTOR

        JMP     START           ; USER IRQ VECTOR
        JMP     START           ; USER RESTART VECTOR
