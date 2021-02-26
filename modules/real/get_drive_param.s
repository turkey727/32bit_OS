get_drive_param:
	push	bp
	mov	bp, sp

	push	bx
	push	cx
	push	es
	push	si
	push	di

	mov	si, [bp + 4]		;siにdrive構造体のアドレスを代入

;以下3行、axを使ってディスクベーステーブルポインタの初期化
	mov	ax, 0
	mov	es, ax
	mov	di, ax

	mov	ah, 8			;ドライブパラメータを取得
	mov	dl, [si + drive.no]	;ドライブ番号の指定、
	int	0x13			;BIOSコール呼び出し
.10Q:	jc	.10F			;CFが1なら、つまり失敗したら.10Fに飛ぶ

;以下、順にセクタ数、シリンダ数、ヘッド数を設定する命令
.10T:
	mov	al, cl		
	and	ax, 0x3F

	shr	cl, 6
	ror	cx, 8
	inc	cx
	
	movzx	bx, dh
	inc	bx

;以下、上から順にシリンダ数、ヘッド数、セクタ数を指定したアドレスに格納する命令
	mov	[si + drive.cyln], cx
	mov	[si + drive.head], bx
	mov	[si + drive.sect], ax
	
	jmp	.10E
.10F:
	mov	ax, 0
.10E:
	pop	di
	pop	si
	pop	es
	pop	cx
	pop	bx

	mov	sp, bp
	pop	bp

	ret
