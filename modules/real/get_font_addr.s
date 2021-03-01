get_font_addr:

	push 	bp
	mov	bp, sp

	push	ax
	push	bx
	push	si
	push	es
	push	bp
	
	mov	si, [bp + 4]		;フォントアドレスの保存先をsiに代入

	mov	ax, 0x1130		;ax = 0x1130で、フォントアドレスの取得
	mov	bh, 0x06		;bh = 0x06で8*16のタイプに設定
	int 	10h			;フォントアドレスの取得のBIOSコール

;以下2行、フォントアドレスの保存
	mov	[si + 0], es
	mov	[si + 2], bp

	pop	bp
	pop	es
	pop	si
	pop	bx
	pop	ax

	mov	sp, bp
	pop	bp

	ret
