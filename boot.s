	BOOT_LOAD	equ	0x7C00  ;ブートプログラムのロード位置
	ORG	BOOT_LOAD;		;これで、最初にロードするアドレスをアセンブラに指示

entry:
	jmp	ipl         		;最初はiplから処理

	times	90 - ($ - $$) db 0x90
	
ipl:
	cli;				;割り込み禁止命令

	mov	ax, 0x0000		;セグメントレジスタを初期化する値をAXに代入
	mov	ds, ax			;AXを介してセグメントレジスタを初期化
	mov	es, ax;
	mov	ss, ax;
	mov	sp, BOOT_LOAD		;スタックポインタを0x7C00に設定

	sti				;割り込みを許可

	mov	[BOOT.DRIVE], dl	;dlレジスタには、ブートプログラムが保存されていた
					;ストレージデバイスの番号が設定されており、
					;それを指定したアドレスに保存し、今後も使っていく。

;以下3行、ビデオBIOSコールを呼び出すためのレジスタの設定
	mov	al, 'A'			;alレジスタで出力する文字を指定
	mov	ah, 0x0E		;ah=0x0Eで、テレタイプ式１文字出力に設定
	mov	bx, 0x0000		;bxレジスタでページ番号と文字色を指定

	int	0x10			;ビデオBIOSコールを呼び出す

	jmp	$;

ALIGN 2, db 0
BOOT:
.DRIVE:	dw 0;

	times 	510 - ($ - $$) db 0x00;
	db	0x55, 0xAA;