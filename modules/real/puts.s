puts:
	push	bp
	mov	bp, sp

	push	ax
	push	bx
	push	si

	mov	si, [bp + 4]	;SIに[bp + 4]の値、つまり文字列へのアドレスを代入

	mov	ah, 0x0E	;ah = 0x0Eで、テレタイプ式1文字出力に指定
	mov	bx, 0x0000	;ページ番号と文字色を0に指定
	cld			;DFレジスタをクリア
.10L:
	lodsb			;ALに、siレジスタの値を代入した後、siの値をインクリメント

	cmp	al, 0		;もしALが0なら.10Eに飛んで終了処理
	je	.10E

	int	0x10		;もし0以外ならビデオBIOSコールを呼び出し、
	jmp	.10L		;.10Lに飛んで次の文字を0と比較
.10E:
	pop	si
	pop	bx
	pop	ax

	mov	sp, bp
	pop	bp

	ret