;LBA方式からCHS方式へ変換するために必要な、ヘッド番号とセクタ番号を求め、
;指定したアドレスに格納する

lba_to_chs:
	push	bp
	mov	bp, sp

	push	ax
	push	bx
	push	dx
	push	si
	push	di

	mov	si, [bp + 4]			;siにドライブパラメータを格納
	mov	di, [bp + 6]			;diに変換後のシリンダ、ヘッド、セクタ番号を保存するためのバッファを格納

;以下7行、シリンダ番号を計算する処理。シリンダ番号 = LBA / (最大ヘッド数 * トラックあたりのセクタ数)
	mov	al, [si + drive.head]		;alに最大ヘッド数を代入
	mul	byte [si + drive.sect]		;ax = シリンダあたりのセクタ数(最大ヘッド数 * トラックあたりのセクタ数)
	mov	bx, ax				;bxにシリンダあたりのセクタ数を代入

	mov	dx, 0				;後で除算の余りを格納するdxを0でクリア
	mov	ax, [bp + 8]			;axにLBAの値を代入
	div	bx				;ax = シリンダ番号(ax / bx)
						;dx = シリンダ番号の余り(ax % bx)
	
	mov	[di + drive.cyln], ax		;シリンダ番号を代入

;以下2行、ヘッド番号とトラック番号の余りを計算する処理。ヘッド番号 = シリンダ番号の余り / トラックあたりのセクタ数
	mov	ax, dx				;シリンダ番号の余りをaxに代入
	div	byte [si + drive.sect]		;al = ヘッド番号(ax / トラックあたりのセクタ数)
						;ah = トラック番号の余り(ax % トラックあたりのセクタ数)

;以下2行、セクタ番号を計算する処理。　セクタ番号 = トラック番号の余り + 1
	movzx	dx, ah				;ahをdxに拡大コピー
	inc	dx				;dxをインクリメント

	mov	ah, 0x00			;ahを0でクリア

	mov	[di + drive.head], ax		;ヘッド番号をdrv_chs.headに格納
	mov	[di + drive.sect], dx		;セクタ番号をdrv_chs.sectに格納

	pop	di
	pop	si
	pop	dx
	pop	bx
	pop	ax

	mov	sp, bp
	pop	bp

	ret