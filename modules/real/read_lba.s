read_lba:
	push	bp
	mov	bp, sp

	push	si

	mov	si, [bp + 4]		;siにドライブ情報を格納

;以下2行、LBAからCHSに変換するための処理
	mov	ax, [bp + 6]		;axにLBAを格納
	cdecl	lba_to_chs, si, .chs, ax	;lba_to_chsを呼び出してヘッド番号とセクタ番号を保存

;以下2行、ドライブ番号をコピーする処理
	mov	al, [si + drive.no]		;alにドライブ番号を格納
	mov	[.chs + drive.no], al		;alを介してドライブ番号を格納

	cdecl	read_chs, .chs, word [bp + 8], word [bp + 10]	;read_chsを呼び出してchs方式でセクタを読み込む

	pop	si

	leave
	ret

ALIGN 2
.chs:	times	drive_size	db	0