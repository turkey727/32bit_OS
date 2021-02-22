putc:
	push	bp		;呼び出し元の関数のbpをスタックにpush
	mov	bp, sp		;bpにspを代入してから、putc関数を開始

;今回使うのはaxレジスタとbxレジスタ
	push	ax
	push	bx

	mov	al, [bp + 4]		;alに[bp + 4]の値、つまり出力する文字を代入
	mov	ah, 0x0E		;ah = 0x0Eで、テレタイプ式1文字出力に
	mov	bx, 0x0000		;bx = 0x0000で、ページ番号と文字色を0に設定
	int	0x10   			;ビデオBIOSコールの呼び出し
	
;使い終わったレジスタを解放
	pop	bx			
	pop	ax

	mov	sp, bp		;spにbpを代入して、putc関数の終了処理
	pop	bp		;bpをpop

	ret			;retでスタックに積まれているIPのアドレスに復帰