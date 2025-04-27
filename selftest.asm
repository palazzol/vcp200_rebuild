
.include "vcp200.def"

        ; VCP200 - Self Test

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

; VECTORS

        .org    0x0FF8

        JMP     SELFIRQ         ; SELF-TEST IRQ VECTOR
        JMP     SELFTST         ; SELF-TEST RESTART VECTOR
