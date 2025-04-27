                              1 
                              2 .include "vcp200.def"
                              1 
                              2 ; MC6804P2 Data Space Defines
                              3 
                     0000     4 PORTA   .equ    0x00
                     0001     5 PORTB   .equ    0x01
                     0004     6 DDRA    .equ    0x04
                     0005     7 DDRB    .equ    0x05
                              8 
                     0009     9 TSTATUS .equ    0x09
                             10 
                     005D    11 ROM5D   .equ    0x5D
                     005E    12 ROM5E   .equ    0x5E
                     005F    13 ROM5F   .equ    0x5F
                             14 
                     0080    15 X       .equ    0x80
                     0081    16 Y       .equ    0x81
                     0082    17 V       .equ    0x82
                     0083    18 W       .equ    0x83
                     0084    19 RAM84   .equ    0x84
                             20 
                     0085    21 SCNT    .equ    0x85
                     0086    22 VCNT    .equ    0x86
                     0087    23 FCNT    .equ    0x87
                             24 
                     0088    25 RAM88   .equ    0x88        ; N?
                     0089    26 RAM89   .equ    0x89
                     008A    27 RAM8A   .equ    0x8A
                     008B    28 RAM8B   .equ    0x8B
                     008C    29 RAM8C   .equ    0x8C
                     008D    30 RAM8D   .equ    0x8D
                     008E    31 RAM8E   .equ    0x8E
                     008F    32 RAM8F   .equ    0x8F
                     0090    33 RAM90   .equ    0x90
                     0091    34 RAM91   .equ    0x91
                     0092    35 RAM92   .equ    0x92
                             36 
                     009E    37 RAM9E   .equ    0x9E
                     009F    38 RAM9F   .equ    0x9F
                             39 
                     00FD    40 PRESCALE    .equ    0xFD
                     00FE    41 TCOUNT  .equ    0xFE
                     00FF    42 A       .equ    0xFF
                              3 
                              4         ; VCP200 - Self Test
                              5 
                              6         .area   CODE1   (ABS)
                              7 
                              8         ; Self-test ROM area start
   0AE0                       9         .org    0x0ae0
                             10 
   0AE0                      11 L0AE0:
   0AE0 65            [ 2]   12         BCS     L0AE6
   0AE1 8A E6         [ 4]   13         JSR     L0AE6
   0AE3 EA 00         [ 4]   14         ADD     #0x00
   0AE5 B3            [ 2]   15         RTS
                             16 
   0AE6                      17 L0AE6:
   0AE6 F9 9E         [ 4]   18         STA     RAM9E
   0AE8 B4            [ 4]   19         COMA 
   0AE9 F5            [ 4]   20         AND     ,Y
   0AEA B4            [ 4]   21         COMA 
   0AEB F9 9F         [ 4]   22         STA     RAM9F
   0AED F0            [ 4]   23         LDA     ,Y
   0AEE B4            [ 4]   24         COMA 
   0AEF FD 9E         [ 4]   25         AND     RAM9E
   0AF1 B4            [ 4]   26         COMA 
   0AF2 FD 9F         [ 4]   27         AND     RAM9F
   0AF4 B4            [ 4]   28         COMA 
   0AF5 B3            [ 2]   29         RTS
                             30 
                             31 ; SELF-TEST START
                             32 
   0AF6                      33 SELFTST:
                             34 
   0AF6 B0 83 04      [ 4]   35         MVI     W,#0x04	        ; 0x04 -> W register
   0AF9                      36 L0AF9:
   0AF9 3F            [ 2]   37         BEQ     L0AF9           ; ???
   0AFA                      38 L0AFA:
   0AFA 7F            [ 2]   39         BCS     L0AFA           ; ???
   0AFB E8 00         [ 4]   40         LDA     #0x00           ; A = 0
   0AFD F9 00         [ 4]   41         STA     PORTA           ; Clear PORTA
   0AFF DF 04         [ 4]   42         BSET    #7,DDRA         ; Set PA7 As OUTPUT
                             43 
                             44 ; Stack Test
                             45 
                             46 ; JSR 4 times
   0B01 BE            [ 4]   47         STA     V               ; Clear V Register
   0B02                      48 L0B02:
   0B02 CA 82 03      [ 5]   49         BRSET   #2,V,L0B08      ; exit if V == 4
   0B05 AA            [ 4]   50         INC     V               ; V = V + 1
   0B06 8B 02         [ 4]   51         JSR     L0B02           ; add a stack level
                             52 
                             53 ; RTS 5 times
   0B08                      54 L0B08:
   0B08 CF 82 02      [ 5]   55         BRSET   #7,V,L0B0D      ; Exit if V == -1
   0B0B BA            [ 4]   56         DEC     V               ; V = V - 1
   0B0C B3            [ 2]   57         RTS
   0B0D                      58 L0B0D:
   0B0D 8B FF         [ 4]   59         JSR     L0BFF           ; A=0, Clear interrupt mask?
   0B0F                      60 L0B0F:
   0B0F C9 09 FD      [ 5]   61         BRSET   #1,0x09,L0B0F   ; wait for timer?
                             62 
   0B12 68            [ 2]   63         BCS     L0B1B
   0B13 E8 06         [ 4]   64         LDA     #0x06           ; DDRC into X
   0B15 BC            [ 4]   65         STA     X
   0B16 EB 04         [ 4]   66         SUB     #0x04           ; DDRA into Y
   0B18 BD            [ 4]   67         STA     Y
   0B19                      68 L0B19:
   0B19 E8 0F         [ 4]   69         LDA     #0x0F
   0B1B                      70 L0B1B:
   0B1B F9 84         [ 4]   71         STA     RAM84           ; 0x0F into $84
   0B1D AE            [ 4]   72         LDA     V               ; Put V into DDRA (should be 0xff)
   0B1E F1            [ 4]   73         STA     ,Y              ; Select PORTA as all outputs
   0B1F FD 84         [ 4]   74         AND     RAM84           ; A = 0x0F
   0B21 E1            [ 4]   75         STA     ,X              ; Select PC0-PC3 as all outputs
   0B22 AE            [ 4]   76         LDA     V
   0B23                      77 L0B23:
   0B23 F1            [ 4]   78         STA     ,Y              ; Select PORTA as all outputs, again
   0B24 FC FF         [ 4]   79         CMP     0xFF            ; All outputs?
   0B26                      80 L0B26:
   0B26 7F            [ 2]   81         BCS     L0B26           ; 
   0B27 DB 01         [ 4]   82         BSET    #3,PORTB        ; Set PB3 HIGH - nIRQ
   0B29 DE 00         [ 4]   83         BSET    #6,PORTA        ; Set PA6 as Output - turn on LED
   0B2B D2 02         [ 4]   84         BCLR    #2,0x02         ; Set PC2 LOW - no effect
   0B2D F4            [ 4]   85         CMP     ,Y              ; DDRA all outputs?
   0B2E B4            [ 4]   86         COMA                    ; A = 0xff
   0B2F 33            [ 2]   87         BEQ     L0B23
   0B30 E0            [ 4]   88         LDA     ,X
   0B31 B4            [ 4]   89         COMA 
   0B32 CF FF E6      [ 5]   90         BRSET   #7,0xFF,L0B1B
   0B35 ED 00         [ 4]   91         AND     #0x00
   0B37 E1            [ 4]   92         STA     ,X
   0B38 B8            [ 4]   93         DEC     X
   0B39 B9            [ 4]   94         DEC     Y
   0B3A C5 81 DC      [ 5]   95         BRCLR   #5,Y,L0B19
                             96 
   0B3D E8 0F         [ 4]   97         LDA     #0x0F
   0B3F F9 05         [ 4]   98         STA     DDRB            ; PB0-PB3 as outputs
   0B41 FB 0A         [ 4]   99         SUB     0x0A
   0B43 EB EE         [ 4]  100         SUB     #0xEE
   0B45                     101 L0B45:
   0B45 1F            [ 2]  102         BNE     L0B45
   0B46 F8 0B         [ 4]  103         LDA     0x0B
   0B48 EC 1B         [ 4]  104         CMP     #0x1B
   0B4A                     105 L0B4A:
   0B4A 1F            [ 2]  106         BNE     L0B4A
                            107 
   0B4B FE 01         [ 4]  108         INC     PORTB           ; PB0-PB3 -> 1
   0B4D 8B 5E         [ 4]  109         JSR     L0B5E           ; Do Ram Clear
   0B4F FA 0A         [ 4]  110         ADD     0x0A
   0B51 EC 32         [ 4]  111         CMP     #0x32
   0B53                     112 L0B53:
   0B53 1F            [ 2]  113         BNE     L0B53
   0B54 F8 0B         [ 4]  114         LDA     0x0B
   0B56 EC BB         [ 4]  115         CMP     #0xBB
   0B58                     116 L0B58:
   0B58 1F            [ 2]  117         BNE     L0B58
   0B59 FE 01         [ 4]  118         INC     PORTB           ; PB0-PB3 -> 2
   0B5B FE 01         [ 4]  119         INC     PORTB           ; PB0-PB3 -> 3
   0B5D                     120 L0B5D:
   0B5D 1F            [ 2]  121         BNE     L0B5D
                            122 
                            123 ; RAM clear, from $82-$9F
                            124 
   0B5E                     125 L0B5E:
   0B5E E8 FF         [ 4]  126         LDA     #0xFF
   0B60 B4            [ 4]  127         COMA
   0B61                     128 L0B61:
   0B61 1F            [ 2]  129         BNE     L0B61
   0B62 8B CC         [ 4]  130         JSR     L0BCC
   0B64                     131 L0B64:
   0B64 1F            [ 2]  132         BNE     L0B64
   0B65                     133 L0B65:
   0B65 F1            [ 4]  134         STA     ,Y              ; Clear [Y]
   0B66 B5            [ 4]  135         ROLA
   0B67 B9            [ 4]  136         DEC     Y
   0B68 B8            [ 4]  137         DEC     X
   0B69 1B            [ 2]  138         BNE     L0B65
                            139 
                            140 ; RAM tests
                            141 
   0B6A E8 55         [ 4]  142         LDA     #0x55
   0B6C                     143 L0B6C:
   0B6C 8B CC         [ 4]  144         JSR     L0BCC
   0B6E F7            [ 4]  145         DEC     ,Y
   0B6F                     146 L0B6F:
   0B6F F4            [ 4]  147         CMP     ,Y
   0B70 F1            [ 4]  148         STA     ,Y
   0B71 B4            [ 4]  149         COMA 
   0B72 B9            [ 4]  150         DEC     Y
   0B73 B8            [ 4]  151         DEC     X
   0B74 1A            [ 2]  152         BNE     L0B6F
   0B75 FA FF         [ 4]  153         ADD     A
   0B77 54            [ 2]  154         BCC     L0B6C
   0B78 FB FF         [ 4]  155         SUB     A
   0B7A                     156 L0B7A:
   0B7A 7F            [ 2]  157         BCS     L0B7A
                            158 
   0B7B 8B CC         [ 4]  159         JSR     L0BCC
   0B7D                     160 L0B7D:
   0B7D F4            [ 4]  161         CMP     ,Y
   0B7E F1            [ 4]  162         STA     ,Y
   0B7F B9            [ 4]  163         DEC     Y
   0B80 B8            [ 4]  164         DEC     X
   0B81 1B            [ 2]  165         BNE     L0B7D
   0B82 A8            [ 4]  166         INC     X
   0B83 FA 0A         [ 4]  167         ADD     0x0A
   0B85 EC 3B         [ 4]  168         CMP     #0x3B
   0B87                     169 L0B87:
   0B87 1F            [ 2]  170         BNE     L0B87
   0B88 FA 0B         [ 4]  171         ADD     0x0B
   0B8A EC A1         [ 4]  172         CMP     #0xA1
   0B8C                     173 L0B8C:
   0B8C 1F            [ 2]  174         BNE     L0B8C
   0B8D E6            [ 4]  175         INC     ,X
                            176 
   0B8E D0 05         [ 4]  177         BCLR    #0,DDRB     ; PB0 Low
                            178 
                            179 ; Timer Test
                            180 
   0B90 B0 09 28      [ 4]  181         MVI     TSTATUS,#0x28
   0B93                     182 L0B93:
   0B93 F8 FD         [ 4]  183         LDA     PRESCALE
   0B95 E0            [ 4]  184         LDA     ,X
   0B96 C7 09 FA      [ 5]  185         BRCLR   #7,TSTATUS,L0B93
   0B99 E3            [ 4]  186         SUB     ,X
   0B9A 30            [ 2]  187         BEQ     L0B8C-1                     ; ???
   0B9B DC 09         [ 4]  188         BSET    #4,TSTATUS
   0B9D B0 FE 06      [ 4]  189         MVI     TCOUNT,#0x06
   0BA0                     190 L0BA0:
   0BA0 C0 01 FD      [ 5]  191         BRCLR   #0,PORTB,L0BA0
   0BA3 D4 09         [ 4]  192         BCLR    #4,TSTATUS
   0BA5                     193 L0BA5:
   0BA5 CF 09 FD      [ 5]  194         BRSET   #7,TSTATUS,L0BA5
   0BA8                     195 L0BA8:
   0BA8 B0 FE 04      [ 4]  196         MVI     TCOUNT,#0x04
   0BAB D7 09         [ 4]  197         BCLR    #7,TSTATUS
   0BAD D8 05         [ 4]  198         BSET    #0,DDRB     ; PB0 High
   0BAF D5 09         [ 4]  199         BCLR    #5,TSTATUS
   0BB1 D4 FF         [ 4]  200         BCLR    #4,A
   0BB3 33            [ 2]  201         BEQ     L0BA8-1                     ; ???
   0BB4 32            [ 2]  202         BEQ     L0BA8-1                     ; ???
   0BB5 F9 FE         [ 4]  203         STA     TCOUNT
   0BB7 E6            [ 4]  204         INC     ,X
   0BB8                     205 L0BB8:
   0BB8 D0 FD         [ 4]  206         BCLR    #0,PRESCALE
   0BBA                     207 L0BBA:
   0BBA C7 09 FD      [ 5]  208         BRCLR   #7,TSTATUS,L0BBA
   0BBD FE 09         [ 4]  209         INC     TSTATUS
   0BBF FE FE         [ 4]  210         INC     TCOUNT
   0BC1 F9 FD         [ 4]  211         STA     PRESCALE
   0BC3 FA FF         [ 4]  212         ADD     A
   0BC5 52            [ 2]  213         BCC     L0BB8
                            214 
   0BC6 AE            [ 4]  215         LDA     V
   0BC7 B8            [ 4]  216         DEC     X
   0BC8                     217 L0BC8:
   0BC8 E2            [ 4]  218         ADD     ,X
   0BC9 A8            [ 4]  219         INC     X
   0BCA 1D            [ 2]  220         BNE     L0BC8
   0BCB B3            [ 2]  221         RTS 
                            222 
   0BCC                     223 L0BCC:
   0BCC B0 80 1E      [ 4]  224         MVI     X,#0x1E         ; #0x1E -> X (number of bytes)
   0BCF B0 81 9F      [ 4]  225         MVI     Y,#0x9F         ; #0x9F -> Y (last ram location)
   0BD2 B3            [ 2]  226         RTS
   0BD3                     227 L0BD3:
   0BD3 C2 83 0C      [ 5]  228         BRCLR   #2,W,L0BE2
   0BD6                     229 L0BD6:
   0BD6 D7 00         [ 4]  230         BCLR    #7,PORTA        ; Clear PA7
   0BD8 DB 01         [ 4]  231         BSET    #3,PORTB        ; Set PB3
   0BDA DF FF         [ 4]  232         BSET    #7,A
   0BDC 8A E0         [ 4]  233         JSR     L0AE0
   0BDE F1            [ 4]  234         STA     ,Y
   0BDF                     235 L0BDF:
   0BDF 5F            [ 2]  236         BCC     L0BDF
   0BE0 BB            [ 4]  237         DEC     W
   0BE1 31            [ 2]  238         BEQ     L0BD3
   0BE2                     239 L0BE2:
   0BE2 B2            [ 2]  240         RTI 
                            241 
                            242 ; SELF TEST IRQ HANDLER ENTRY
                            243 
   0BE3                     244 SELFIRQ:
                            245 
   0BE3 72            [ 2]  246         BCS     L0BD6
   0BE4 25            [ 2]  247         BEQ     L0BEA
   0BE5 D7 04         [ 4]  248         BCLR    #7,DDRA
   0BE7 C8 FE F5      [ 5]  249         BRSET   #0,TCOUNT,L0BDF
   0BEA                     250 L0BEA:
   0BEA B0 80 02      [ 4]  251         MVI     X,#0x02
   0BED B0 09 27      [ 4]  252         MVI     TSTATUS,#0x27
   0BF0 AF            [ 4]  253         LDA     W
   0BF1 B4            [ 4]  254         COMA 
   0BF2 25            [ 2]  255         BEQ     L0BF8
   0BF3 B0 80 06      [ 4]  256         MVI     X,#0x06
   0BF6 DC 09         [ 4]  257         BSET    #4,TSTATUS
   0BF8                     258 L0BF8:
   0BF8 DF 09         [ 4]  259         BSET    #7,TSTATUS
   0BFA                     260 L0BFA:
   0BFA E1            [ 4]  261         STA     ,X
   0BFB B8            [ 4]  262         DEC     X
   0BFC 1D            [ 2]  263         BNE     L0BFA
   0BFD E1            [ 4]  264         STA     ,X
   0BFE BF            [ 4]  265         STA     W
   0BFF                     266 L0BFF:
   0BFF FB FF         [ 4]  267         SUB     A          ; Clear A
   0C01 B2            [ 2]  268         RTI
                            269 
                            270 ; VECTORS
                            271 
   0FF8                     272         .org    0x0FF8
                            273 
   0FF8 9B E3         [ 4]  274         JMP     SELFIRQ         ; SELF-TEST IRQ VECTOR
   0FFA 9A F6         [ 4]  275         JMP     SELFTST         ; SELF-TEST RESTART VECTOR
