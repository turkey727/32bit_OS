reboot:
	cdecl	puts, .s0
	
.10L:
	mov	ah, 0x00	;ah=0x00で入力待ち
	int	0x16		;キーコードサービスの呼び出し
	
	cmp	al, ' '		;スペースが入力されるまでループ
	jne	.10L

	cdecl	puts, .s1	;改行

	int	0x19

.s0	db 0x0A, 0x0D, "Push SPACE key to reboot...", 0
.s1	db 0x0A, 0x0D, 0x0A, 0x0D, 0			;改行のためのs1