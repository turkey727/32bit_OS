itoa:
	push	bp
	mov	bp, sp

	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	
	mov	ax, [bp + 4]		;[bp + 4]、つまり変換する値をaxに代入
	mov	si, [bp + 6]		;[bp + 6]、つまりバッファアドレスをsiに代入
	mov	cx, [bp + 8]		;[bp + 8]、つまりバッファサイズをcxに代入

 	mov	di, si			;diにバッファアドレスを代入
	add	di, cx			;di = バッファアドレス + バッファサイズ
	dec	di			;di --

	mov	bx, word [bp + 12]	;[bp + 12]、つまりフラグをbxに代入

;以下.10Eまで、変換する値を符号付整数として扱うかどうか判定する命令
	test	bx, 0b0001		;bxの最下位ビットを1でand演算
.10Q:	je	.10E			;演算結果が0なら.10Eにジャンプ
	cmp	ax, 0			;0以外ならaxと0を比較
.12Q:	jge	.12E			;axが0以上なら.12Eにジャンプ
	or	bx, 0b0010		;axが負の数ならbxと0b0010(0x0002)でor演算
.12E:
.10E:

;以下.20Eまで、符号付整数として扱う場合の処理
	test	bx, 0b0010		;bxと0x0002でand演算
.20Q:	je	.20E			;演算結果が0なら.20Eにジャンプ
	cmp	ax, 0			;0以外ならaxと0を比較
.22Q:	jge	.22F			;axが0以上なら.22Fにジャンプ
	neg	ax			;axが負の数ならaxの値を正の数に符号反転する(-の符号はこの下の行で出力するため)
	mov	[si], byte '-'		;文字「-」を、バッファアドレスに代入
	jmp	.22E			;そのあと.22Eにジャンプ
.22F:

	mov	[si], byte '+'		;axが正の数なら文字「+」をバッファアドレスに代入
.22E:
	dec	cx			;それぞれ符号をバッファアドレスに代入したあと、
					;使用可能なバッファサイズであるcxをデクリメントする

.20E:
;以下.30Eまで、文字列への変換
	mov	bx, [bp + 10]		;[bp + 10]、つまり基数をbxに代入
.30L:
	mov	dx, 0			;除算を行うためにdxをクリア(dxには余りが格納されるため)
	div	bx			;bx / axを行い、商をaxに格納し、余りをdxに格納する

	mov 	si, dx			;
	mov	dl, byte [.ascii + si]	;変換テーブル参照

	mov	[di], dl		;
	dec	di

	cmp	ax, 0
	loopnz	.30L
.30E:
;以下.40Eまで、空欄を埋める
	cmp	cx, 0
.40Q:	je	.40E
	mov	al, ' '
	cmp	[bp + 12], word 0b0100
.42Q:	jne	.42E
	mov	al, '0'
.42E:
	std
	rep stosb
.40E:
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	mov	sp, bp
	pop	bp
	
	ret

.ascii	db	"0123456789ABCDEF"