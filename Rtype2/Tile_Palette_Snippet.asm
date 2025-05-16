

FG_PLOT_ENTRY:			; called from IRQ handler
1ED36: 8A C2                mov     al,dl			; al is offset 00 - f0
1ED38: 32 E4                xor     ah,ah
1ED3A: 05 20 10             add     aw,1020h			; add somewhere down screen
1ED3D: 25 FF 10             and     aw,10FFh			; wrap if > $10ff
1ED40: 2D 00 01             sub     aw,100h			; now go back one character line
1ED43: 8B F8                mov     iy,aw			; Save offset address
1ED45: 8B D9                mov     bw,cw			; set bw to master map data pointer
1ED47: FC                   clr1    dir				; set direction flag
1ED48: B9 08 00             mov     cw,8h			; 8 4x4 tiles to plot ie one column
PLOT_COLUMN:
1ED4B: 51                   push    cw
1ED4C: 57                   push    iy
1ED4D: F6 06 FE 37 FF       test    byte ptr [37FEh],0FFh	; status flag
1ED52: 74 06                be      1ED5Ah
1ED54: 81 FF 00 1F          cmp     iy,1F00h
1ED58: 72 0D                bc      SKIP_PLOT			; 1ED67h

1ED5A: F6 06 FF 37 FF       test    byte ptr [37FFh],0FFh	; a status
1ED5F: 74 0C                be      DO_PLOT_THEN		; 1ED6Dh
1ED61: 81 FF 00 1F          cmp     iy,1F00h
1ED65: 72 06                bc      DO_PLOT_THEN		; 1ED6Dh
SKIP_PLOT:
1ED67: 83 C3 02             add     bw,2h			; advance map
1ED6A: E9 03 00             br      NO_PLOT			; 1ED70h don't plot anything
DO_PLOT_THEN:
1ED6D: E8 8A 01             call    FG_PLOT_4X4_TILE		; 1EEFAh
NO_PLOT:
1ED70: 5F                   pop     iy
1ED71: 81 C7 00 04          add     iy,400h			; Move 4 rows
1ED75: 59                   pop     cw
1ED76: E2 D3                dbnz    PLOT_COLUMN			;1ED4Bh
1ED78: C3                   ret  
   
BG_TILE_PLOT:   
1ED79: 8A C2                mov     al,dl			; al is offset 00 - fo
1ED7B: 32 E4                xor     ah,ah
1ED7D: 05 20 10             add     aw,1020h			; add somewhere down screen
1ED80: 25 FF 10             and     aw,10FFh			; wrap if > $10ff
1ED83: 2D 00 01             sub     aw,100h			; now go back one line
1ED86: 8B F8                mov     iy,aw			; save offset address
1ED88: 8B D9                mov     bw,cw			; set bw to master map data pointer
1ED8A: FC                   clr1    dir				; set direction flag
1ED8B: B9 08 00             mov     cw,8h			; 8 4x4 tiles to plot ie one column
PLOT_COLUMN2:
1ED8E: 51                   push    cw
1ED8F: 57                   push    iy
1ED90: F6 06 00 38 FF       test    byte ptr [3800h],0FFh	; skip plot status
1ED95: 75 03                bne     1ED9Ah
1ED97: E8 78 01             call    BG_PLOT_4X4_TILE		; 1EF12h
1ED9A: 5F                   pop     iy
1ED9B: 81 C7 00 04          add     iy,400h			; Move 4 rows
1ED9F: 59                   pop     cw
1EDA0: E2 EC                dbnz    PLOT_COLUMN2		; 1ED8Eh
1EDA2: C3                   ret  

BG_TILE_PLOT  
1EDA3: 8A C2                mov     al,dl
1EDA5: 32 E4                xor     ah,ah
1EDA7: 05 20 30             add     aw,3020h
1EDAA: 25 FF 30             and     aw,30FFh
1EDAD: 2D 00 01             sub     aw,100h
1EDB0: 8B F8                mov     iy,aw
1EDB2: 8B D9                mov     bw,cw
1EDB4: FC                   clr1    dir
1EDB5: B9 10 00             mov     cw,10h
1EDB8: 51                   push    cw
1EDB9: 57                   push    iy
1EDBA: F6 06 00 38 FF       test    byte ptr [3800h],0FFh
1EDBF: 75 03                bne     1EDC4h
1EDC1: E8 4E 01             call    1EF12h
1EDC4: 5F                   pop     iy
1EDC5: 81 C7 00 04          add     iy,400h
1EDC9: 59                   pop     cw
1EDCA: E2 EC                dbnz    1EDB8h
1EDCC: C3                   ret   
  
1EDCD: 1E                   push    ds0
1EDCE: 06                   push    ds1
1EDCF: B8 00 6A             mov     aw,6A00h
1EDD2: 8E C0                mov     ds1,aw
1EDD4: 26 8B 37             mov     ix,ds1:[bw]
1EDD7: 8B CE                mov     cw,ix
1EDD9: 81 E1 FC FF          and     cw,0FFFCh
1EDDD: 8E D9                mov     ds0,cw
1EDDF: B8 40 00             mov     aw,40h
1EDE2: 8E C0                mov     ds1,aw
1EDE4: 81 E6 03 00          and     ix,3h
1EDE8: 03 F6                add     ix,ix
1EDEA: 26 8B 84 A8 8A       mov     aw,ds1:[ix-7558h]       ; jump table for control byte for normal flip x, Flipy y and both x/y
1EDEF: 33 F6                xor     ix,ix
1EDF1: B9 00 D0             mov     cw,0D000h
1EDF4: 8E C1                mov     ds1,cw
1EDF6: B9 04 04             mov     cw,404h
1EDF9: FF E0                br      aw                      ; do jump

1EDFB: 51                   push    cw
1EDFC: 52                   push    dw
1EDFD: 8A CA                mov     cl,dl
1EDFF: 57                   push    iy
1EE00: 8B D7                mov     dw,iy
1EE02: 81 E7 FF 3F          and     iy,3FFFh
1EE06: 8B 44 02             mov     aw,[ix+2h]
1EE09: 80 E4 0E             and     ah,0Eh
1EE0C: 3A E1                cmp     ah,cl
1EE0E: 73 09                bnc     1EE19h
1EE10: 33 C0                xor     aw,aw
1EE12: AB                   stmw    
1EE13: 83 C6 02             add     ix,2h
1EE16: E9 01 00             br      1EE1Ah
1EE19: A5                   movbkw  
1EE1A: A5                   movbkw  
1EE1B: 80 C2 04             add     dl,4h
1EE1E: 8B FA                mov     iy,dw
1EE20: FE CD                dec     ch
1EE22: 75 DC                bne     1EE00h
1EE24: 5F                   pop     iy
1EE25: 81 C7 00 01          add     iy,100h
1EE29: 5A                   pop     dw
1EE2A: 59                   pop     cw
1EE2B: FE C9                dec     cl
1EE2D: 75 CC                bne     1EDFBh
1EE2F: 83 C3 02             add     bw,2h
1EE32: 07                   pop     ds1
1EE33: 1F                   pop     ds0
1EE34: C3                   ret   
  
1EE35: 81 C7 00 03          add     iy,300h
1EE39: 51                   push    cw
1EE3A: 52                   push    dw
1EE3B: 8A CA                mov     cl,dl
1EE3D: 57                   push    iy
1EE3E: 81 E7 FF 3F          and     iy,3FFFh
1EE42: 8B D7                mov     dw,iy
1EE44: 8B 44 02             mov     aw,[ix+2h]
1EE47: 80 E4 0E             and     ah,0Eh
1EE4A: 3A E1                cmp     ah,cl
1EE4C: 73 09                bnc     1EE57h
1EE4E: 33 C0                xor     aw,aw
1EE50: AB                   stmw    
1EE51: 83 C6 02             add     ix,2h
1EE54: E9 01 00             br      1EE58h
1EE57: A5                   movbkw  
1EE58: AD                   ldmw    
1EE59: 35 40 00             xor     aw,40h
1EE5C: AB                   stmw    
1EE5D: 80 C2 04             add     dl,4h
1EE60: 8B FA                mov     iy,dw
1EE62: FE CD                dec     ch
1EE64: 75 D8                bne     1EE3Eh
1EE66: 5F                   pop     iy
1EE67: 81 EF 00 01          sub     iy,100h
1EE6B: 5A                   pop     dw
1EE6C: 59                   pop     cw
1EE6D: FE C9                dec     cl
1EE6F: 75 C8                bne     1EE39h
1EE71: 83 C3 02             add     bw,2h
1EE74: 07                   pop     ds1
1EE75: 1F                   pop     ds0
1EE76: C3                   ret 
    
1EE77: 83 C7 0C             add     iy,0Ch
1EE7A: 51                   push    cw
1EE7B: 52                   push    dw
1EE7C: 8A CA                mov     cl,dl
1EE7E: 57                   push    iy
1EE7F: 8B D7                mov     dw,iy
1EE81: 81 E7 FF 3F          and     iy,3FFFh
1EE85: 8B 44 02             mov     aw,[ix+2h]
1EE88: 80 E4 0E             and     ah,0Eh
1EE8B: 3A E1                cmp     ah,cl
1EE8D: 73 09                bnc     1EE98h
1EE8F: 33 C0                xor     aw,aw
1EE91: AB                   stmw    
1EE92: 83 C6 02             add     ix,2h
1EE95: E9 01 00             br      1EE99h
1EE98: A5                   movbkw  
1EE99: AD                   ldmw    
1EE9A: 35 20 00             xor     aw,20h
1EE9D: AB                   stmw    
1EE9E: 80 EA 04             sub     dl,4h
1EEA1: 8B FA                mov     iy,dw
1EEA3: FE CD                dec     ch
1EEA5: 75 D8                bne     1EE7Fh
1EEA7: 5F                   pop     iy
1EEA8: 81 C7 00 01          add     iy,100h
1EEAC: 5A                   pop     dw
1EEAD: 59                   pop     cw
1EEAE: FE C9                dec     cl
1EEB0: 75 C8                bne     1EE7Ah
1EEB2: 83 C3 02             add     bw,2h
1EEB5: 07                   pop     ds1
1EEB6: 1F                   pop     ds0
1EEB7: C3                   ret  
   
1EEB8: 81 C7 0C 03          add     iy,30Ch
1EEBC: 51                   push    cw
1EEBD: 52                   push    dw
1EEBE: 8A CA                mov     cl,dl
1EEC0: 57                   push    iy
1EEC1: 8B D7                mov     dw,iy
1EEC3: 81 E7 FF 3F          and     iy,3FFFh
1EEC7: 8B 44 02             mov     aw,[ix+2h]
1EECA: 80 E4 0E             and     ah,0Eh
1EECD: 3A E1                cmp     ah,cl
1EECF: 73 09                bnc     1EEDAh
1EED1: 33 C0                xor     aw,aw
1EED3: AB                   stmw    
1EED4: 83 C6 02             add     ix,2h
1EED7: E9 01 00             br      1EEDBh
1EEDA: A5                   movbkw  
1EEDB: AD                   ldmw    
1EEDC: 35 60 00             xor     aw,60h
1EEDF: AB                   stmw    
1EEE0: 80 EA 04             sub     dl,4h
1EEE3: 8B FA                mov     iy,dw
1EEE5: FE CD                dec     ch
1EEE7: 75 D8                bne     1EEC1h
1EEE9: 5F                   pop     iy
1EEEA: 81 EF 00 01          sub     iy,100h
1EEEE: 5A                   pop     dw
1EEEF: 59                   pop     cw
1EEF0: FE C9                dec     cl
1EEF2: 75 C8                bne     1EEBCh
1EEF4: 83 C3 02             add     bw,2h
1EEF7: 07                   pop     ds1
1EEF8: 1F                   pop     ds0
1EEF9: C3                   ret

FG_PLOT_4X4_TILE:
1EEFA: 1E                   push    ds0
1EEFB: 06                   push    ds1
1EEFC: B8 00 6A             mov     aw,6A00h	; tile map data 16 long words
1EEFF: 8E C0                mov     ds1,aw
1EF01: 26 8B 37             mov     ix,ds1:[bw] ; bw is map pointer for tile
1EF04: 8B CE                mov     cw,ix	; align to every 4th byte
1EF06: 81 E1 FC FF          and     cw,0FFFCh
1EF0A: 8E D9                mov     ds0,cw	; use as the datasegmen offset
1EF0C: B9 00 D0             mov     cw,0D000h	; videoram1
1EF0F: E9 15 00             br      DO_PLOT	; 1EF27h

BG_PLOT_4X4_TILE:
1EF12: 1E                   push    ds0
1EF13: 06                   push    ds1
1EF14: B8 00 6A             mov     aw,6A00h	; tile map data 16 long words from $6a000 + bw
1EF17: 8E C0                mov     ds1,aw
1EF19: 26 8B 37             mov     ix,ds1:[bw]	; get tile data start from 6a000+bw map data
1EF1C: 8B CE                mov     cw,ix	; align to every 4th byte
1EF1E: 81 E1 FC FF          and     cw,0FFFCh
1EF22: 8E D9                mov     ds0,cw	; use this as source data offset
1EF24: B9 00 D4             mov     cw,0D400h	; videoram2 this is our Screen tile RAM segment

DO_PLOT:
1EF27: B8 40 00             mov     aw,40h	; low segment memory
1EF2A: 8E C0                mov     ds1,aw
1EF2C: 81 E6 03 00          and     ix,3h	; only use 0-3 of value
1EF30: 03 F6                add     ix,ix	; double it
1EF32: 26 8B 84 B0 8A       mov     aw,ds1:[ix-7550h] ; looks like a jump table based on ix (0-3) * 2
1EF37: 33 F6                xor     ix,ix	; set to read offset to 0
1EF39: 8E C1                mov     ds1,cw	; now set destination tile movbkw
1EF3B: B9 04 04             mov     cw,404h	; 4x4 tile?
1EF3E: FF E0                br      aw		; jump table would be x y and x&y plot
	; Jump table value 0 normal left right top bottom plotting
NEXT_ROW:
1EF40: 51                   push    cw
1EF41: 57                   push    iy
NEXT_CHAR:
1EF42: 8B D7                mov     dw,iy
1EF44: 81 E7 FF 3F          and     iy,3FFFh	; keep inside
1EF48: A5                   movbkw		; From ds0:ix to ds1:iy 1st word inc ix,iy + 2
1EF49: A5                   movbkw  		; From ds0:ix to ds1:iy 2nd word inc ix,iy + 2
1EF4A: 80 C2 04             add     dl,4h	; next character
1EF4D: 8B FA                mov     iy,dw
1EF4F: FE CD                dec     ch		; do one line count of 4
1EF51: 75 EF                bne     NEXT_CHAR	; 1EF42h
1EF53: 5F                   pop     iy		; get screen tile address
1EF54: 81 C7 00 01          add     iy,100h	; next row just 256 (why not just inc lh?)
1EF58: 59                   pop     cw		; get back rows counter
1EF59: FE C9                dec     cl		; -1 less
1EF5B: 75 E3                bne     NEXT_ROW	;1EF40h	; another
1EF5D: 83 C3 02             add     bw,2h	; advance map word offset into tile at $30000+
1EF60: 07                   pop     ds1
1EF61: 1F                   pop     ds0
1EF62: C3                   ret
	; Jump table value 2 Y Flip 					
1EF63: 81 C7 00 03          add     iy,300h	; Advance 3 rows so plot bottom up
1EF67: 51                   push    cw
1EF68: 57                   push    iy
1EF69: 81 E7 FF 3F          and     iy,3FFFh	; keep inside
1EF6D: 8B D7                mov     dw,iy
1EF6F: A5                   movbkw		; From ds0:ix to ds1:iy 1st word inc ix,iy + 2
1EF70: AD                   ldmw    		; Get palette
1EF71: 35 40 00             xor     aw,40h	; Now set the Y flip bit
1EF74: AB                   stmw    
1EF75: 80 C2 04             add     dl,4h	; next character
1EF78: 8B FA                mov     iy,dw
1EF7A: FE CD                dec     ch
1EF7C: 75 EB                bne     1EF69h
1EF7E: 5F                   pop     iy
1EF7F: 81 EF 00 01          sub     iy,100h	; back one row
1EF83: 59                   pop     cw
1EF84: FE C9                dec     cl		; all rows
1EF86: 75 DF                bne     1EF67h
1EF88: 83 C3 02             add     bw,2h	; advance map data
1EF8B: 07                   pop     ds1
1EF8C: 1F                   pop     ds0
1EF8D: C3                   ret  
	; Jump table value 1 which is flip X position
1EF8E: 83 C7 0C             add     iy,0Ch	; 0 4 8 C so we start memory at character 4
1EF91: 51                   push    cw
1EF92: 57                   push    iy
1EF93: 8B D7                mov     dw,iy
1EF95: 81 E7 FF 3F          and     iy,3FFFh	; keep inside
1EF99: A5                   movbkw 		; From ds0:ix to ds1:iy 1st word inc ix,iy + 2 
1EF9A: AD                   ldmw    
1EF9B: 35 20 00             xor     aw,20h
1EF9E: AB                   stmw    
1EF9F: 80 EA 04             sub     dl,4h
1EFA2: 8B FA                mov     iy,dw
1EFA4: FE CD                dec     ch
1EFA6: 75 EB                bne     1EF93h
1EFA8: 5F                   pop     iy
1EFA9: 81 C7 00 01          add     iy,100h	; next line down
1EFAD: 59                   pop     cw
1EFAE: FE C9                dec     cl		; all rows
1EFB0: 75 DF                bne     1EF91h
1EFB2: 83 C3 02             add     bw,2h	; advance map data
1EFB5: 07                   pop     ds1
1EFB6: 1F                   pop     ds0
1EFB7: C3                   ret 
	; Jump table value 3 which is flip X & Y position
1EFB8: 81 C7 0C 03          add     iy,30Ch	; Three rows and 3 char across
1EFBC: 51                   push    cw
1EFBD: 57                   push    iy
1EFBE: 8B D7                mov     dw,iy
1EFC0: 81 E7 FF 3F          and     iy,3FFFh	; keep inside
1EFC4: A5                   movbkw		; From ds0:ix to ds1:iy 1st word inc ix,iy + 2  
1EFC5: AD                   ldmw		; Get 2nd Word
1EFC6: 35 60 00             xor     aw,60h	; 2nd world enable the xy flip
1EFC9: AB                   stmw		; Save to Screen
1EFCA: 80 EA 04             sub     dl,4h	; destination back one character
1EFCD: 8B FA                mov     iy,dw
1EFCF: FE CD                dec     ch
1EFD1: 75 EB                bne     1EFBEh
1EFD3: 5F                   pop     iy
1EFD4: 81 EF 00 01          sub     iy,100h	; back up one row
1EFD8: 59                   pop     cw
1EFD9: FE C9                dec     cl		; all rows
1EFDB: 75 DF                bne     1EFBCh
1EFDD: 83 C3 02             add     bw,2h	; advance map data
1EFE0: 07                   pop     ds1
1EFE1: 1F                   pop     ds0
1EFE2: C3                   ret  

   
1EFE3: 1E                   push    ds0
1EFE4: 06                   push    ds1
1EFE5: B8 00 6A             mov     aw,6A00h
1EFE8: 8E C0                mov     ds1,aw
1EFEA: 26 8B 37             mov     ix,ds1:[bw]
1EFED: 8B CE                mov     cw,ix
1EFEF: 81 E1 FC FF          and     cw,0FFFCh
1EFF3: 8E D9                mov     ds0,cw
1EFF5: B9 00 D0             mov     cw,0D000h
1EFF8: E9 15 00             br      1F010h

1EFFB: 1E                   push    ds0
1EFFC: 06                   push    ds1
1EFFD: B8 00 6A             mov     aw,6A00h
1F000: 8E C0                mov     ds1,aw
1F002: 26 8B 37             mov     ix,ds1:[bw]
1F005: 8B CE                mov     cw,ix
1F007: 81 E1 FC FF          and     cw,0FFFCh
1F00B: 8E D9                mov     ds0,cw
1F00D: B9 00 D4             mov     cw,0D400h

1F010: B8 40 00             mov     aw,40h
1F013: 8E C0                mov     ds1,aw
1F015: 81 E6 03 00          and     ix,3h
1F019: 03 F6                add     ix,ix
1F01B: 26 8B 84 B8 8A       mov     aw,ds1:[ix-7548h]
1F020: 33 F6                xor     ix,ix
1F022: 8E C1                mov     ds1,cw
1F024: B9 04 04             mov     cw,404h
1F027: FF E0                br      aw

		; Control table 0
1F029: 51                   push    cw
1F02A: 57                   push    iy
1F02B: 8B D7                mov     dw,iy
1F02D: 81 E7 FF 3F          and     iy,3FFFh
1F031: 26 8B 45 02          mov     aw,ds1:[iy+2h]
1F035: 80 E4 0E             and     ah,0Eh
1F038: 80 FC 06             cmp     ah,6h
1F03B: 75 06                bne     1F043h
1F03D: 83 C6 04             add     ix,4h
1F040: E9 02 00             br      1F045h

1F043: A5                   movbkw		; From ds0:ix to ds1:iy 1st word inc ix,iy + 2  
1F044: A5                   movbkw		; From ds0:ix to ds1:iy 1st word inc ix,iy + 2  
1F045: 80 C2 04             add     dl,4h
1F048: 8B FA                mov     iy,dw
1F04A: FE CD                dec     ch
1F04C: 75 DD                bne     1F02Bh
1F04E: 5F                   pop     iy
1F04F: 81 C7 00 01          add     iy,100h	; Next Line
1F053: 59                   pop     cw
1F054: FE C9                dec     cl
1F056: 75 D1                bne     1F029h
1F058: 83 C3 02             add     bw,2h
1F05B: 07                   pop     ds1
1F05C: 1F                   pop     ds0
1F05D: C3                   ret

		; Control table 2 Flip Y
1F05E: 81 C7 00 03          add     iy,300h
1F062: 51                   push    cw
1F063: 57                   push    iy
1F064: 8B D7                mov     dw,iy
1F066: 81 E7 FF 3F          and     iy,3FFFh
1F06A: 26 8B 45 02          mov     aw,ds1:[iy+2h]
1F06E: 80 E4 0E             and     ah,0Eh
1F071: 80 FC 06             cmp     ah,6h
1F074: 75 06                bne     1F07Ch
1F076: 83 C6 04             add     ix,4h
1F079: E9 06 00             br      1F082h

1F07C: A5                   movbkw		; From ds0:ix to ds1:iy 1st word inc ix,iy + 2
1F07D: AD                   ldmw
1F07E: 35 40 00             xor     aw,40h	; Flip Y bits
1F081: AB                   stmw    

1F082: 80 C2 04             add     dl,4h
1F085: 8B FA                mov     iy,dw
1F087: FE CD                dec     ch
1F089: 75 D9                bne     1F064h
1F08B: 5F                   pop     iy
1F08C: 81 EF 00 01          sub     iy,100h	; Line before
1F090: 59                   pop     cw
1F091: FE C9                dec     cl
1F093: 75 CD                bne     1F062h
1F095: 83 C3 02             add     bw,2h
1F098: 07                   pop     ds1
1F099: 1F                   pop     ds0
1F09A: C3                   ret  
 
		; Control table 1 Flip X
1F09B: 83 C7 0C             add     iy,0Ch
1F09E: 51                   push    cw
1F09F: 57                   push    iy
1F0A0: 8B D7                mov     dw,iy
1F0A2: 81 E7 FF 3F          and     iy,3FFFh
1F0A6: 26 8B 45 02          mov     aw,ds1:[iy+2h]
1F0AA: 80 E4 0E             and     ah,0Eh
1F0AD: 80 FC 06             cmp     ah,6h
1F0B0: 75 06                bne     1F0B8h
1F0B2: 83 C6 04             add     ix,4h
1F0B5: E9 06 00             br      1F0BEh
1F0B8: A5                   movbkw  
1F0B9: AD                   ldmw    
1F0BA: 35 20 00             xor     aw,20h		; Flip X bits
1F0BD: AB                   stmw    
1F0BE: 80 EA 04             sub     dl,4h		; back one character
1F0C1: 8B FA                mov     iy,dw
1F0C3: FE CD                dec     ch
1F0C5: 75 D9                bne     1F0A0h
1F0C7: 5F                   pop     iy
1F0C8: 81 C7 00 01          add     iy,100h		; Down to next line
1F0CC: 59                   pop     cw
1F0CD: FE C9                dec     cl
1F0CF: 75 CD                bne     1F09Eh
1F0D1: 83 C3 02             add     bw,2h		; advance map
1F0D4: 07                   pop     ds1
1F0D5: 1F                   pop     ds0
1F0D6: C3                   ret  

		; Control table 3 Flip X & Y
1F0D7: 81 C7 0C 03          add     iy,30Ch
1F0DB: 51                   push    cw
1F0DC: 57                   push    iy
1F0DD: 8B D7                mov     dw,iy
1F0DF: 81 E7 FF 3F          and     iy,3FFFh
1F0E3: 26 8B 45 02          mov     aw,ds1:[iy+2h]
1F0E7: 80 E4 0E             and     ah,0Eh
1F0EA: 80 FC 06             cmp     ah,6h
1F0ED: 75 06                bne     1F0F5h
1F0EF: 83 C6 04             add     ix,4h
1F0F2: E9 06 00             br      1F0FBh
1F0F5: A5                   movbkw  
1F0F6: AD                   ldmw    
1F0F7: 35 60 00             xor     aw,60h		; Flip X & Y
1F0FA: AB                   stmw    
1F0FB: 80 EA 04             sub     dl,4h		; back one character
1F0FE: 8B FA                mov     iy,dw
1F100: FE CD                dec     ch
1F102: 75 D9                bne     1F0DDh
1F104: 5F                   pop     iy
1F105: 81 EF 00 01          sub     iy,100h		; up one line
1F109: 59                   pop     cw
1F10A: FE C9                dec     cl
1F10C: 75 CD                bne     1F0DBh
1F10E: 83 C3 02             add     bw,2h		; advance map
1F111: 07                   pop     ds1
1F112: 1F                   pop     ds0
1F113: C3                   ret  

; -------------------------------
; R-TYPE PALETTE LOAD FUNCTION
; -------------------------------
; Inputs:
;   IY = Pointer to packed RGB data (3 bytes per color, 16 colors = 48 bytes total)
;   BW = Palette index (0–31), multiplied by 32 to find destination slot
;
; Behavior:
;   Copies 16 RGB entries (3 bytes each) into the palette RAM at segment $D800.
;   Data is unpacked into 3 separate planes:
;     - Red   → [D8000 + offset]
;     - Green → [D8000 + offset + $400]
;     - Blue  → [D8000 + offset + $800]
;
;   The destination offset is:
;     offset = (BW << 5) = BW * 32
;
; Notes:
; - Palette RAM layout mimics hardware decoding expected by video hardware.
; - This routine enables dynamic palette loading from ROM or RAM.
; - Used both for static level palettes and real-time animated effects.
;
; Memory mapping (from MAME):
;   map(0xC8000, 0xC8BFF) = Palette bank 0 (R)
;   map(0xD8000, 0xCCBFF) = Palette bank 1 (R)
;   Palette RAM is split in 3 planes: Red @ +$000, Green @ +$400, Blue @ +$800
;
; Typically, IY points to RAM at $E0000–$E3FFF during animations.

228C0: 1E                   push    ds0              ; Save data segment register (ds0)
228C1: 06                   push    ds1              ; Save another data segment register (ds1)
228C2: B8 00 E0             mov     aw,0E000h        ; Set address 0E000h for **System RAM**
228C5: 8E D8                mov     ds0,aw           ; Set ds0 to 0E000h, pointing to **System RAM**
228C7: B8 00 C8             mov     aw,0C800h        ; Set address 0C800h for **foreground/sprite palette RAM**
228CA: 8E C0                mov     ds1,aw           ; Set ds1 to 0C800h, pointing to **foreground/sprite palette RAM**
228CC: BD 26 34             mov     bp,3426h         ; Set base pointer (bp) to address 3426h, likely for loop control or memory offset
228CF: B9 10 00             mov     cw,10h           ; Set counter (cw) to 16 (for looping through 16 colors)
228D2: BE 20 28             mov     ix,2820h         ; Set index register (ix) to address 2820h (starting point for color data)
228D5: 33 FF                xor     iy,iy            ; Clear iy (used as an index pointer for data)
228D7: F7 46 00 FF FF       test    word ptr [bp+0h],0FFFFh  ; Test if the word at address bp is non-zero (continue if true)
228DC: 74 2A                be      22908h           ; If false, jump to 22908h (skip the color fading update)
228DE: C7 46 00 00 00       mov     word ptr [bp+0h],0h     ; Reset word at bp+0h to 0 (clear previous flag or data)
228E3: 51                   push    cw               ; Save counter register (cw) to stack
228E4: 57                   push    iy               ; Save index register (iy) to stack
228E5: 56                   push    ix               ; Save index register (ix) to stack
228E6: B9 10 00             mov     cw,10h           ; Set counter to 16 (for 16 colors)
228E9: F3 A5                rep     movbkw           ; Repeat move block (write memory) to update RED color values
228EB: 81 C7 E0 03          add     iy,3E0h          ; Increment iy by 0x3E0 (992 bytes) to move to the next block in the palette (likely next color set)
228EF: 81 C6 E0 01          add     ix,1E0h          ; Increment ix by 0x1E0 (480 bytes) to move to the next set of color data
228F3: B9 10 00             mov     cw,10h           ; Set counter to 16 (repeat for next color)
228F6: F3 A5                rep     movbkw           ; Repeat memory write for the next set of GREEN colors
228F8: 81 C7 E0 03          add     iy,3E0h          ; Increment iy by 0x3E0 for the next color block (992 bytes)
228FC: 81 C6 E0 01          add     ix,1E0h          ; Increment ix by 0x1E0 for the next color block (480 bytes)
22900: B9 10 00             mov     cw,10h           ; Set counter to 16
22903: F3 A5                rep     movbkw           ; Repeat memory write for the final set of BLUE color values
22905: 5E                   pop     ix               ; Restore ix from stack (end of loop)
22906: 5F                   pop     iy               ; Restore iy from stack
22907: 59                   pop     cw               ; Restore counter (cw) from stack
22908: 83 C5 0C             add     bp,0Ch           ; Increment base pointer (bp) by 12 (advance to next block of data)
2290B: 83 C6 20             add     ix,20h           ; Increment ix by 0x20 (32 bytes) to adjust for color data offsets
2290E: 83 C7 20             add     iy,20h           ; Increment iy by 0x20 (32 bytes) to adjust for color data offsets
22911: E2 C4                dbnz    228D7h           ; Decrement and branch if non-zero, loop back to start of update cycle
22913: B8 00 E0             mov     aw,0E000h        ; Set address 0E000h for **System RAM** (reset for second part of update)
22916: 8E D8                mov     ds0,aw           ; Set ds0 to 0E000h again (System RAM reset)
22918: B8 00 D8             mov     aw,0D800h        ; Set address 0D800h for **background palette RAM**
2291B: 8E C0                mov     ds1,aw           ; Set ds1 to 0D800h again (background palette RAM)
2291D: BD E6 34             mov     bp,34E6h         ; Set base pointer (bp) to another address, 34E6h
22920: BE 20 2E             mov     ix,2E20h         ; Set index register (ix) to memory RAM location

22923: B9 10 00             mov     cw,10h           ; Set counter to 16 colours
22926: 33 FF                xor     iy,iy            ; Clear iy again palette entry offset starts at 0
22928: F7 46 00 FF FF       test    word ptr [bp+0h],0FFFFh  ; Test if the word at address bp is non-zero (continue if true)
2292D: 74 2A                be      22959h           ; If false, jump to 22959h (skip color fading update)
2292F: C7 46 00 00 00       mov     word ptr [bp+0h],0h     ; Clear the flag/data at [bp+0h]
22934: 51                   push    cw               ; Save counter (cw) to stack
22935: 57                   push    iy               ; Save iy to stack
22936: 56                   push    ix               ; Save ix to stack

22937: B9 10 00             mov     cw,10h           ; Set counter to 16 REDs
2293A: F3 A5                rep     movbkw           ; From ds0:ix to ds1:iy Repeat memory write for palette RED update
2293C: 81 C7 E0 03          add     iy,3E0h          ; Increment iy for the next color block (992 bytes)
22940: 81 C6 E0 01          add     ix,1E0h          ; Increment ix for the next color block (480 bytes)
22944: B9 10 00             mov     cw,10h           ; Set counter to 16 Greens
22947: F3 A5                rep     movbkw           ; Repeat memory write for next color GREEN block
22949: 81 C7 E0 03          add     iy,3E0h          ; Increment iy
2294D: 81 C6 E0 01          add     ix,1E0h          ; Increment ix
22951: B9 10 00             mov     cw,10h           ; Set counter to 16 Blues
22954: F3 A5                rep     movbkw           ; Final memory write cycle for colors BLUE

22956: 5E                   pop     ix               ; Restore ix from stack
22957: 5F                   pop     iy               ; Restore iy from stack
22958: 59                   pop     cw               ; Restore counter (cw) from stack
22959: 83 C5 0C             add     bp,0Ch           ; Increment base pointer for next memory access
2295C: 83 C6 20             add     ix,20h           ; Increment index pointer (ix)
2295F: 83 C7 20             add     iy,20h           ; Increment index pointer (iy)
22962: E2 C4                dbnz    22928h           ; Decrement and branch if non-zero, loop to the next fade cycle
22964: 07                   pop     ds1              ; Restore ds1 from stack
22965: 1F                   pop     ds0              ; Restore ds0 from stack
22966: C3                   ret                      ; Return from function

  