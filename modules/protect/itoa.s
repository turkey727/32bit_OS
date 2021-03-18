itoa:
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	
	mov	eax, [ebp + 8]		;[ebp + 8]、つまり変換する値をaxに代入
	mov	esi, [ebp + 12]		;[ebp + 12]、つまりバッファアドレスをsiに代入
	mov	ecx, [ebp + 16]		;[ebp + 16]、つまりバッファサイズをcxに代入

 	mov	edi, esi			;ediにバッファアドレスを代入
	add	edi, ecx			;edi = バッファアドレス + バッファサイズ
	dec	edi			;edi --

	mov	ebx, [ebp + 24]	;[bp + 24]、つまりフラグをebxに代入

;以下.10Eまで、変換する値を符号付整数として扱うかどうか判定する命令
	test	ebx, 0b0001		;ebxの最下位ビットを1でand演算
.10Q:	je	.10E			;演算結果が0なら.10Eにジャンプ
	cmp	eax, 0			;0以外ならeaxと0を比較
.12Q:	jge	.12E			;eaxが0以上なら.12Eにジャンプ
	or	ebx, 0b0010		;eaxが負の数ならbxと0b0010(0x0002)でor演算
.12E:
.10E:

;以下.20Eまで、符号付整数として扱う場合の処理
	test	ebx, 0b0010		;ebxと0x0002でand演算
.20Q:	je	.20E			;演算結果が0なら.20Eにジャンプ
	cmp	eax, 0			;0以外ならeaxと0を比較
.22Q:	jge	.22F			;eaxが0以上なら.22Fにジャンプ
	neg	eax			;eaxが負の数ならeaxの値を正の数に符号反転する(-の符号はこの下の行で出力するため)
	mov	[esi], byte '-'		;文字「-」を、バッファアドレスに代入
	jmp	.22E			;そのあと.22Eにジャンプ
.22F:

	mov	[esi], byte '+'		;eaxが正の数なら文字「+」をバッファアドレスに代入
.22E:
	dec	ecx			;それぞれ符号をバッファアドレスに代入したあと、
					;使用可能なバッファサイズであるcxをデクリメントする

.20E:
;以下.30Eまで、文字列への変換
	mov	ebx, [ebp + 20]		;[ebp + 20]、つまり基数をbxに代入
.30L:
	mov	edx, 0			;除算を行うためにedxをクリア(edxには余りが格納されるため)
	div	ebx			;ebx / eaxを行い、商をeaxに格納し、余りをedxに格納する

	mov 	esi, edx			;
	mov	dl, byte [.ascii + esi]	;変換テーブル参照

	mov	[edi], dl		;
	dec	edi

	cmp	eax, 0
	loopnz	.30L
.30E:
;以下.40Eまで、空欄を埋める
	cmp	ecx, 0
.40Q:	je	.40E
	mov	al, ' '
	cmp	[ebp + 24], word 0b0100
.42Q:	jne	.42E
	mov	al, '0'
.42E:
	std
	rep stosb
.40E:
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp
	
	ret

.ascii	db	"0123456789ABCDEF"