entry:
	jmp	ipl		;最初はipl(ブートプログラム)から開始

	times	90 - ($ - $$) db 0x90		;BPBと呼ばれる領域。後で記述するため、
						;今はとりあえず90byte分のNOPで埋める
	
ipl:
	jmp	$;

	times 	510 - ($ - $$) db 0x00;
	db	0x55, 0xAA;