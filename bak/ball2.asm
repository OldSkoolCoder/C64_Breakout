;C64 screen and sprite memory addresses
enable_sprite       = $D015
sprite0_mem_pointer = $07f8
sprite0_color       = $D027
sprite0_x           = $D000
sprite0_y           = $D001
msb_x               = $D010
background_color    = $d021
boarder_color       = $d020
clear_screen        = $E544
raster_line         = $D012
status_register     = $030F

; 10 SYS (49152)
*=$801
        byte $0E,$08,$0A,$00,$9E,$20,$28,$34,$39,$31,$35,$32,$29,$00,$00,$00

        
* = 16320
        ;small 8x8 ball top left corner
        byte $38,$00,$00,$7c,$00,$00,$fe,$00,$00,$fe,$00,$00,$fe,$00,$00,$7c
        byte $00,$00,$38,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
 
* = 49152 ;$C000-$CFFF, 49152-53247 Upper RAM area (4096 bytes).
        lda  #255
        sta  $07f8

ball_x    =  679 ;these are memory addresses for the variables starting at 679
ball_y    =  681
dir_x     =  682
dir_y     =  683
mask_temp =  684

left   = #24 ;const left border
top    = #50 ;const top
bottom = #243 ;const bottom
right  = #81 ;const right NOTE: this is 1/2 the x-axis actual resolution
        ; 81 with bit set true 256+81= 337
 
        lda #1
        sta dir_x ;set x direction
        lda #1
        sta dir_y ;set y direction
 
        ;lda #20 ;left
        ;sta ball_x
        ;lda #48 ;top
        ;sta ball_y
 
        lda #1
        sta sprite0_color       ;sprite color 1=white

        lda #1
        sta enable_sprite       ;enable sprite

        ;set ball start location
        lda left
        sta sprite0_x ; X
        ; bit 0 in $d010 is set, sprite 0's x coordinate is 256, plus the value in $d000
        lda #0
        sta msb_x

        lda top
        sta sprite0_y  ; Y
        
        ;init_screen      
        lda #6                  ;0 = black
        sta background_color    ;set background color
        lda #14                 ;15 = light gray
        sta boarder_color       ;set border color  
        ;clear screen
        jsr clear_screen

;wait for raster scan line to be off screen (>250)
raster
        ;inc $D020 ;flickering border color
        lda raster_line ;$D012
        cmp #250
        bne raster

main
        
        jsr move_ball_horizontally
        
        ;check wall collisions
        lda msb_x
        cmp #1
        bne look_left
        lda sprite0_x

        cmp right 
        ;bcs ball_dir_set_left
        beq ball_dir_set_left
look_left
        lda sprite0_x
        cmp left
        bcc ball_dir_set_right

        jmp raster

ball_dir_set_right
        lda #1
        sta dir_x
        jmp main
ball_dir_set_left
        lda #0
        sta dir_x
        jmp main        

move_ball_horizontally
        lda dir_x
        cmp #0
        beq moveball_left
        cmp #1
        beq moveball_right
        rts
moveball_right
        ;lda #1
        ;adc sprite0_x
        ;sta sprite0_x
        ;sta 251
        ;brk
        ;bcs set_msb

        inc sprite0_x
        beq set_msb

        ;jsr check_msb
        ;lda status_register
        ;lda msb_x
        ;and #1
        ;beq set_msb
        rts




moveball_left
        dec sprite0_x
        jsr check_msb
        rts
set_msb
        ;brk
        lda #1
        sta msb_x
        lad #0
        sta sprite0_x
        rts 
clear_msb
        lda #0
        sta msb_x
        rts
check_msb
        lda sprite0_x
        cmp #255
        bcs set_msb
        cmp #255
        bcc clear_msb
        rts
        