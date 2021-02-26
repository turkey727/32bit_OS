read_chs:
	push	bp
	mov	bp, sp
	push	3		;リトライする回数
	push	0		;読み込むセクタの数

	push	bx
	push	cx
	push	dx
	push	es
	push	si

	mov	si, [bp + 4]		;[bp + 4]、つまりdrive構造体のアドレスをsiに代入

;以下4行、セクタ読み出しBIOSコール時に、シリンダ番号とセクタ番号の指定で使われるcxの設定
	mov	ch, [si + drive.cyln + 0]	;chに下位バイトのシリンダ番号を代入
	mov	cl, [si + drive.cyln + 1]	;clに上位バイトのシリンダ番号を代入
	shl	cl, 6				;clをシフトして、最上位2ビットをシリンダ番号に、残った6ビットをセクタに
	or	cl, [si + drive.sect]		;clとセクタ番号でor演算

;以下5行、dxとbxの設定
	mov	dh, [si + drive.head]		;dhにヘッド番号を代入
	mov	dl, [si + 0]			;dlにドライブ番号を代入
	mov	ax, 0x0000			;axを0でクリア
	mov	es, ax				;axを介してesを0でクリア
	mov	bx, [bp + 8]			;[bp + 8]、つまり読み出し先アドレスをbxに代入
.10L:
	mov	ah, 0x02
	mov	al, [bp+ 6]

	int	0x13		;セクタ読み出しBIOSコールの実行
	jnc	.11E		;CFが1なら(失敗したら)、.11Eにジャンプ
	
	mov	al, 0		;CFが0なら(成功したら)、alをクリアして.10Eにジャンプ
	jmp	.10E
.11E:
	cmp	al, 0		;もしalが0なら(読み込んだセクタがなければ)、.10Eにジャンプ
	jne	.10E

	mov	ax, 0		;alが1以上なら(読み込んだセクタがあれば)、戻り値を設定
	dec	word [bp - 2]
	jnz	.10L		;0になるまで繰り返し
.10E:
	mov	ah, 0

	pop	si
	pop	es
	pop	dx
	pop	cx
	pop	bx

	mov	sp, bp
	pop	bp

	ret
