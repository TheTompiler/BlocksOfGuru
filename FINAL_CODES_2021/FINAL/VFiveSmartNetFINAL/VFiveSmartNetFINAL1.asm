%define JUMP_DIST 0x7E00
%define CALL_AMOUNT 0x55
%define GAP 0x19
%define CALL_DIST (CALL_AMOUNT * (GAP - 0x4) - 0x4)

%define SHARE_LOC 0xE1D4
%define SHARE_LOC_1 0x8701

%define ZOMB_WRITE_DIST 0x6C
%define DX_INT_86 0xD7C4
%define LB_ZOMB_START 0x17F
; %define LB_WRITE_AX 0xB6
%define LB_WRITE_SEG 0x8F
%define LB_DIV_OFFSET 0x6
%define LB_AX_LES_OFFSET 0x8
%define LB_ADD_BP 0xC
%define LB_FF6 0xE

%define INT_87_AX 0xCCCC
%define INT_87_DX 0xFFCC



jmp @our_start

@top_decoy:
xlatb
xchg ah,al
xlatb
xlatb
xchg ah,al
xlatb

@our_start:
xchg bx,[SHARE_LOC]
dw 0xF08B ; mov si,ax
dw 0xC38B ; mov ax,bx
div word [bx + LB_DIV_OFFSET]
add dx,[bx + LB_FF6]

mov cl,(@copy_end-@copy)/0x2 - 0x1
dw 0xEA8B ; mov bp,dx
rcr bp,cl
add bp,[bx+LB_ADD_BP]
les ax,[bx + LB_AX_LES_OFFSET]
mov [bp + 0x2],dx

mov dx,DX_INT_86
lea di,[si-0x100]
int 0x86
add si,@copy
add di,@end
push ss
int 0x86

lea ax,[bx + 0x7000]

dw 0xFF33 ; xor di,di
pop es

add word [bp+(@copy_end - @copy) - 0x2],JUMP_DIST - GAP - CALL_DIST
mov byte [bp + (@loop - @copy)],GAP

rep movsw
push cs
movsw

push bp
mov al,0xA7

xchg [bp],ax

;
add bx,LB_ZOMB_START
mov [si-@copy_end+@write_ah+0x3],bh
mov [si-@copy_end+@write_al+0x4],bl
dec di
dw 0xEF8B ; mov bp,di
lea bx,[si-@copy_end+@array]
mov [SHARE_LOC_1],bx
mov cl,0x4
@bomb_sec:
mov [0x4501],al
mov [0x4701],al
mov [0x4401],al
mov [0x4101],al
mov [0x4201],al
mov [0x4301],al

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@xchg:
xchg sp,[di - 0x1B + 0x8100]
xchg dx,[di - 0x1B + 0x8300]
xchg ax,[di - 0x1B + 0x8500]
xchg si,[di - 0x1B + 0x8700]

; registers order: ax,dx,sp,si
@start:
nop
xlatb
xchg ah,al
xlatb
dw 0xE032 ; xor ah,al
xchg di,ax
@write_ah:
mov word [di + ZOMB_WRITE_DIST + 0x2],0xFFCC
@write_al:
mov word [di + ZOMB_WRITE_DIST],0xCCB9
add byte [bx - @array + @start],0x2
loop @start

mov byte [bx - @array + @start],0x90

inc bp
mov cl,0x4
dw 0xFD8B ; mov di,bp
mov sp,0x7FC

jnp @bomb_sec
;

pop bx
dw 0xF633 ; xor si,si
pop es
push ss
mov cl,(@loop_end - @loop)/0x2
pop ds
mov dx,INT_87_DX
push cs
mov ax,INT_87_AX
pop ss

int 0x87

les di,[bx+si]
mov ax,0xA5F3
lea sp,[di + bx + 0x2 - 0x100 - CALL_DIST]
dec di
mov dx,JUMP_DIST

movsw
movsw
dw 0xED33 ; xor bp,bp
movsw
add di,(-0x2)

call far [bx]

@copy:
@call_far:
db 0x69
add sp,[bx+si]
call far [bx]
db 0x65

@loop:
mov cl,(@loop_end - @loop)/0x2
add di,[si]
add sp,[bx+si]
dw 0xF633 ; xor si,si
add [bx+si],dx
movsw
movsw
movsw
add di,(-0x2)
dec bp
db 0x78
call far [bx]
@loop_end:
dw (JUMP_DIST - (@loop_end - @loop) - 0x2 - 0x4)
@copy_end:

@bottom_decoy:
xlatb
xchg ah,al
xlatb
xlatb
xchg ah,al
xlatb

@array:
db 0x00
db 0x2e
db 0x88
db 0xa6
db 0x2b
db 0x05
db 0xa3
db 0x8d
db 0x93
db 0xbd
db 0x1b
db 0x35
db 0xb8
db 0x96
db 0x30
db 0x1e
db 0x4e
db 0x60
db 0xc6
db 0xe8
db 0x65
db 0x4b
db 0xed
db 0xc3
db 0xdd
db 0xf3
db 0x55
db 0x7b
db 0xf6
db 0xd8
db 0x7e
db 0x50
db 0xfa
db 0xd4
db 0x72
db 0x5c
db 0xd1
db 0xff
db 0x59
db 0x77
db 0x69
db 0x47
db 0xe1
db 0xcf
db 0x42
db 0x6c
db 0xca
db 0xe4
db 0xb4
db 0x9a
db 0x3c
db 0x12
db 0x9f
db 0xb1
db 0x17
db 0x39
db 0x27
db 0x09
db 0xaf
db 0x81
db 0x0c
db 0x22
db 0x84
db 0xaa
db 0x6a
db 0x44
db 0xe2
db 0xcc
db 0x41
db 0x6f
db 0xc9
db 0xe7
db 0xf9
db 0xd7
db 0x71
db 0x5f
db 0xd2
db 0xfc
db 0x5a
db 0x74
db 0x24
db 0x0a
db 0xac
db 0x82
db 0x0f
db 0x21
db 0x87
db 0xa9
db 0xb7
db 0x99
db 0x3f
db 0x11
db 0x9c
db 0xb2
db 0x14
db 0x3a
db 0x90
db 0xbe
db 0x18
db 0x36
db 0xbb
db 0x95
db 0x33
db 0x1d
db 0x03
db 0x2d
db 0x8b
db 0xa5
db 0x28
db 0x06
db 0xa0
db 0x8e
db 0xde
db 0xf0
db 0x56
db 0x78
db 0xf5
db 0xdb
db 0x7d
db 0x53
db 0x4d
db 0x63
db 0xc5
db 0xeb
db 0x66
db 0x48
db 0xee
db 0xc0
db 0x80
db 0xae
db 0x08
db 0x26
db 0xab
db 0x85
db 0x23
db 0x0d
db 0x13
db 0x3d
db 0x9b
db 0xb5
db 0x38
db 0x16
db 0xb0
db 0x9e
db 0xce
db 0xe0
db 0x46
db 0x68
db 0xe5
db 0xcb
db 0x6d
db 0x43
db 0x5d
db 0x73
db 0xd5
db 0xfb
db 0x76
db 0x58
db 0xfe
db 0xd0
db 0x7a
db 0x54
db 0xf2
db 0xdc
db 0x51
db 0x7f
db 0xd9
db 0xf7
db 0xe9
db 0xc7
db 0x61
db 0x4f
db 0xc2
db 0xec
db 0x4a
db 0x64
db 0x34
db 0x1a
db 0xbc
db 0x92
db 0x1f
db 0x31
db 0x97
db 0xb9
db 0xa7
db 0x89
db 0x2f
db 0x01
db 0x8c
db 0xa2
db 0x04
db 0x2a
db 0xea
db 0xc4
db 0x62
db 0x4c
db 0xc1
db 0xef
db 0x49
db 0x67
db 0x79
db 0x57
db 0xf1
db 0xdf
db 0x52
db 0x7c
db 0xda
db 0xf4
db 0xa4
db 0x8a
db 0x2c
db 0x02
db 0x8f
db 0xa1
db 0x07
db 0x29
db 0x37
db 0x19
db 0xbf
db 0x91
db 0x1c
db 0x32
db 0x94
db 0xba
db 0x10
db 0x3e
db 0x98
db 0xb6
db 0x3b
db 0x15
db 0xb3
db 0x9d
db 0x83
db 0xad
db 0x0b
db 0x25
db 0xa8
db 0x86
db 0x20
db 0x0e
db 0x5e
db 0x70
db 0xd6
db 0xf8
db 0x75
db 0x5b
db 0xfd
db 0xd3
db 0xcd
db 0xe3
db 0x45
db 0x6b
db 0xe6
db 0xc8
db 0x6e
db 0x40
@end: