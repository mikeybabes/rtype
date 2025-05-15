VIDEORAM1_TILES:				; This seems triggered via IRQ handler and a jump table entry
0EE51: 8A C2                mov     al,dl	; al is the x column position
0EE53: 32 E4                xor     ah,ah	; clear high
0EE55: 03 C0                add     aw,aw	; double it
0EE57: 05 20 10             add     aw,1020h	; start down the sceen
0EE5A: 25 FF 10             and     aw,10FFh	; keep within the bounds of position. (assume al would't be a duff value!)
0EE5D: 8B F8                mov     iy,aw	; now is base screen position across
0EE5F: 8B D9                mov     bw,cw	; cw entry is the map memory pointer, put to bw for now
0EE61: FC                   clr1    dir		; set direction for copy mov instruction
0EE62: B9 05 00             mov     cw,5h	; we have 5 tiles down plot on each strip
0EE65: 51                   push    cw		; Save count
0EE66: 57                   push    iy		; Save screen tile base
0EE67: E8 2B 00             call    TILE_PLOT1	; 0EE95h
0EE6A: 5F                   pop     iy		; return back base
0EE6B: 81 C7 00 06          add     iy,600h	; add one chunk ie 6 rows
0EE6F: 59                   pop     cw		; back the count
0EE70: E2 F3                dbnz    0EE65h	; do the column now.
0EE72: C3                   ret     		; exit

VIDEORAM2_TILES:
0EE73: 8A C2                mov     al,dl	; al position across
0EE75: 32 E4                xor     ah,ah	; clear high byte
0EE77: 03 C0                add     aw,aw	; double it
0EE79: 05 20 10             add     aw,1020h	; Add offset down screen for main display tile data
0EE7C: 25 FF 10             and     aw,10FFh	; keep within the bounds
0EE7F: 8B F8                mov     iy,aw	; now the screen memory offset start is in iy for tile memory
0EE81: 8B D9                mov     bw,cw	; cw is called how many tiles down to plot
0EE83: FC                   clr1    dir		; set the direction flags
0EE84: B9 05 00             mov     cw,5h	; we have 5 tiles down plot on each strip
0EE87: 51                   push    cw		; Save count
0EE88: 57                   push    iy		; Save screen tile base
0EE89: E8 76 00             call    TILE_PLOT2	; 0EF02h
0EE8C: 5F                   pop     iy		; return back base
0EE8D: 81 C7 00 06          add     iy,600h	; add one chunk ie 6 rows
0EE91: 59                   pop     cw		; back the count
0EE92: E2 F3                dbnz    0EE87h	; do the column now
0EE94: C3                   ret 		; exit
    
TILE_PLOT1:
0EE95: 26 8B 87 27 C6       mov     aw,ds1:[bw-39D9h]	; Offset table which from 0 points to $1C627
0EE9A: 1E                   push    ds0
0EE9B: 06                   push    ds1
0EE9C: B9 00 30             mov     cw,3000h	; Tiles start at $30000
0EE9F: 8E D9                mov     ds0,cw
0EEA1: B9 00 D0             mov     cw,0D000h	; videoram1 $D0000
0EEA4: 8E C1                mov     ds1,cw
0EEA6: E9 6A 00             br      CHECK_FLIPS	; do the plotting 0EF13h

0EEA9: FF 76 04             push    word ptr [bp+4h]
0EEAC: FF 76 08             push    word ptr [bp+8h]
0EEAF: C7 46 04 44 02       mov     word ptr [bp+4h],244h
0EEB4: C7 46 08 7C 01       mov     word ptr [bp+8h],17Ch
0EEB9: E8 F9 33             call    22B5h
0EEBC: 8F 46 08             pop     [bp+8h]
0EEBF: 8F 46 04             pop     [bp+4h]
0EEC2: FC                   clr1    dir
0EEC3: 33 DB                xor     bw,bw
0EEC5: 57                   push    iy
0EEC6: E8 07 00             call    0EED0h
0EEC9: 5F                   pop     iy
0EECA: 8B C7                mov     aw,iy
0EECC: 04 20                add     al,20h
0EECE: 8B F8                mov     iy,aw
0EED0: B9 05 00             mov     cw,5h	; 5 chunk of 8x6 tiles to plot to screen
0EED3: 51                   push    cw		; save the count
0EED4: 57                   push    iy		; Save tile base
0EED5: E8 09 00             call    RAM1_PLOT	; plot a 8 x 6 downwards
0EED8: 5F                   pop     iy		; get back tile base
0EED9: 81 C7 00 06          add     iy,600h	; now add 6 rows to base
0EEDD: 59                   pop     cw		; and now finish off all column of 5 super tiles
0EEDE: E2 F3                dbnz    0EED3h	; until all done
0EEE0: C3                   ret			; return

RAM1_PLOT			; This plots in videoram1 Screen memory starting at $d0000
0EEE1: 26 8B 87 F3 EA       mov     aw,ds1:[bw-150Dh]	; read map data $1EAF3
0EEE6: 1E                   push    ds0
0EEE7: 06                   push    ds1
0EEE8: B9 00 30             mov     cw,3000h	; Tile data starts at $30000
0EEEB: 8E D9                mov     ds0,cw
0EEED: B9 00 D8             mov     cw,0D800h	; videoram2 $D8000
0EEF0: 8E C1                mov     ds1,cw
0EEF2: A9 00 80             test    aw,8000h
0EEF5: 75 54                bne     FLIP_YPLOT	; 0EF4Bh
0EEF7: A9 00 40             test    aw,4000h
0EEFA: 74 03                be      SKIP_FLIP	; 0EEFFh No idea why they didn't just brach to NORMAL_PLOT directly!
0EEFC: E9 87 00             br      FLIP_XPLOT	; 0EF86h

SKIP_FLIP:
0EEFF: E9 1E 00             br      NORMAL_PLOT	; 0EF20h

TILE_PLOT2			; This plots in videoram2 Screen memory starting at $d8000
0EF02: 26 8B 87 8F D6       mov     aw,ds1:[bw-2971h]	; effective address $1D68F 
0EF07: 1E                   push    ds0		; save current segment values 
0EF08: 06                   push    ds1
0EF09: B9 00 30             mov     cw,3000h	; Tile data starts at $30000
0EF0C: 8E D9                mov     ds0,cw
0EF0E: B9 00 D8             mov     cw,0D800h	; Screen Tile memory starts at videoram2 $d8000
0EF11: 8E C1                mov     ds1,cw

CHECK_FLIPS:
0EF13: A9 00 80             test    aw,8000h	; Flip in the Y Plot bottom to top bit?
0EF16: 75 33                bne     FLIP_YPLOT	; 0EF4Bh Yes reverse plot
0EF18: A9 00 40             test    aw,4000h	; Flip in the X Plot right to left
0EF1B: 74 03                be      NORMAL_PLOT	; This is normal plotting top - bottom left - right
0EF1D: E9 66 00             br      FLIP_XPLOT	; 0EF86h Otherwise it's a right to left plotting

NORMAL_PLOT:
0EF20: 25 FF 3F             and     aw,3FFFh	; mask off any unwanted offsets (max character value)
0EF23: C1 E0 04             shl     aw,4h	; aw * 16
0EF26: 8B D0                mov     dw,aw	; save to temp
0EF28: C1 E0 03             shl     aw,3h	; aw * 128 now
0EF2B: 03 C2                add     aw,dw	; now add * 128 + * 16 =  144 
0EF2D: 8B F0                mov     ix,aw	; now ix is aw * 144. So this means each tile is 6*8 * 3 bytes = 144
0EF2F: B9 06 08             mov     cw,806h	; do tile count of 8 across and 6 heigh
0EF32: 51                   push    cw		; keep track of count
0EF33: 57                   push    iy		; save screen tile memory base position
0EF34: A5                   movbkw		; From ds0:ix to ds1:iy 1st word inc ix,iy + 2
0EF35: A5                   movbkw		; From ds0:ix to ds1:iy 2nd word inc ix,iy + 2
0EF36: 4E                   dec     ix		; reduce ix as we using tile data in 3 bytes / tile entry
0EF37: FE CD                dec     ch		; loop this 8 times for one strip across (as cw is $806)
0EF39: 75 F9                bne     0EF34h	; repeat across until all done

0EF3B: 5F                   pop     iy		; get back screen base
0EF3C: 81 C7 00 01          add     iy,100h	; now add to next row
0EF40: 59                   pop     cw		; get height back and technically also reset the x
0EF41: FE C9                dec     cl		; now do for all height
0EF43: 75 ED                bne     0EF32h	; repeat and rinse.
0EF45: 83 C3 02             add     bw,2h	; So BW must be map data pointer?
0EF48: 07                   pop     ds1		; put back both source/dest segments
0EF49: 1F                   pop     ds0
0EF4A: C3                   ret  		; return
 
 
FLIP_YPLOT: 
0EF4B: A9 00 40             test    aw,4000h	; has to be reverse block plotting?
0EF4E: 74 03                be      PLOT_BOTTOM_UP ; 0EF53h if this bit is set then adjust plotting
0EF50: E9 68 00             br      FLIP_XYPLOT	; This means flip both x and y 0EFBBh

PLOT_BOTTOM_UP
0EF53: 81 C7 00 05          add     iy,500h	; start at bottom of tile
0EF57: 25 FF 3F             and     aw,3FFFh	; mask off the control bits
0EF5A: C1 E0 04             shl     aw,4h
0EF5D: 8B D0                mov     dw,aw
0EF5F: C1 E0 03             shl     aw,3h
0EF62: 03 C2                add     aw,dw
0EF64: 8B F0                mov     ix,aw	; multiply * 144
0EF66: B9 06 08             mov     cw,806h
0EF69: 51                   push    cw
0EF6A: 57                   push    iy
0EF6B: AD                   ldmw    		; Get ds0:ix ix+ 2
0EF6C: 35 00 80             xor     aw,8000h	; Flip the bits must be flip on the vertical
0EF6F: AB                   stmw    		; Save ds1:iy iy + 2
0EF70: A5                   movbkw  		; From ds0:ix to ds1:iy 2st word inc ix,iy + 2
0EF71: 4E                   dec     ix		; one back on source so it's not + 4 but + 3
0EF72: FE CD                dec     ch		; 8 countdown
0EF74: 75 F5                bne     0EF6Bh	; do more
0EF76: 5F                   pop     iy
0EF77: 81 EF 00 01          sub     iy,100h	; reverse plot so back up screen.
0EF7B: 59                   pop     cw
0EF7C: FE C9                dec     cl
0EF7E: 75 E9                bne     0EF69h
0EF80: 83 C3 02             add     bw,2h	; advance map memory pointer
0EF83: 07                   pop     ds1
0EF84: 1F                   pop     ds0
0EF85: C3                   ret    		; exit
 
FLIP_XPLOT:		; Plot reverse direction ie flip x
0EF86: 83 C7 1C             add     iy,1Ch	; start lsat tile pointer so it's like 00 04 08 0C 10 14 18 1C
0EF89: 25 FF 3F             and     aw,3FFFh	; clear all other bits from tile value
0EF8C: C1 E0 04             shl     aw,4h	; aw * 16
0EF8F: 8B D0                mov     dw,aw
0EF91: C1 E0 03             shl     aw,3h	; aw * 128
0EF94: 03 C2                add     aw,dw
0EF96: 8B F0                mov     ix,aw	; ix now tile * 144 (126 + 16)
0EF98: B9 06 08             mov     cw,806h
0EF9B: 51                   push    cw
0EF9C: 57                   push    iy
0EF9D: AD                   ldmw    
0EF9E: 35 00 40             xor     aw,4000h	; Has a flip x horizontal set in tiledata
0EFA1: AB                   stmw    
0EFA2: A5                   movbkw		; From ds0:ix to ds1:iy 1st word inc ix,iy + 2
0EFA3: 4E                   dec     ix		; source -1 so three bytes / tile entry
0EFA4: 83 EF 08             sub     iy,8h	; destination go back two tiles (that's one before the initial plot)
0EFA7: FE CD                dec     ch
0EFA9: 75 F2                bne     0EF9Dh
0EFAB: 5F                   pop     iy
0EFAC: 81 C7 00 01          add     iy,100h	; advance down one line
0EFB0: 59                   pop     cw
0EFB1: FE C9                dec     cl
0EFB3: 75 E6                bne     0EF9Bh
0EFB5: 83 C3 02             add     bw,2h	; advance memory for map pointer
0EFB8: 07                   pop     ds1
0EFB9: 1F                   pop     ds0
0EFBA: C3                   ret    

FLIP_XYPLOT:		; Plot both X and Y directions the full monty.
0EFBB: 81 C7 1C 05          add     iy,51Ch	; Screen memory is bottom right now
0EFBF: 25 FF 3F             and     aw,3FFFh
0EFC2: C1 E0 04             shl     aw,4h
0EFC5: 8B D0                mov     dw,aw
0EFC7: C1 E0 03             shl     aw,3h
0EFCA: 03 C2                add     aw,dw	; ; ix now tile * 144 (126 + 16)
0EFCC: 8B F0                mov     ix,aw
0EFCE: B9 06 08             mov     cw,806h
0EFD1: 51                   push    cw
0EFD2: 57                   push    iy
0EFD3: AD                   ldmw    
0EFD4: 35 00 C0             xor     aw,0C000h	; Set both X&Y flipper 
0EFD7: AB                   stmw    
0EFD8: A5                   movbkw		; From ds0:ix to ds1:iy 1st word inc ix,iy + 2  
0EFD9: 4E                   dec     ix
0EFDA: 83 EF 08             sub     iy,8h	; work backwards
0EFDD: FE CD                dec     ch
0EFDF: 75 F2                bne     0EFD3h
0EFE1: 5F                   pop     iy
0EFE2: 81 EF 00 01          sub     iy,100h	; and also reverse up screen
0EFE6: 59                   pop     cw
0EFE7: FE C9                dec     cl
0EFE9: 75 E6                bne     0EFD1h
0EFEB: 83 C3 02             add     bw,2h	; always remember to advance map data
0EFEE: 07                   pop     ds1
0EFEF: 1F                   pop     ds0
0EFF0: C3                   ret    
 