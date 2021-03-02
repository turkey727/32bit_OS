get_mem_info:
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	si
	push	di
	push	bp
	
	cdecl	puts, .s0

	mov	bp, 0			;行数を0に設定
	mov	ebx, 0			;後にインデックスとして扱うebxを0に設定
.10L:
	mov	eax, 0x0000E820		;メモリ情報を取得するBIOSコールの指定

	mov	ecx, E820_RECORD_SIZE	;書き込み先バイトサイズの指定
	mov	edx, 'PAMS'		;固定の引数であるSMAPをリトルエンディアンで書いたもの
	mov	di, .b0			;書き込み先アドレスの代入
	int	0x15			;メモリ情報を取得するBIOSコールの呼び出し

	cmp	eax, 'PAMS'		;まず、このBIOSコール自体が対応されているかどうかを確認
	je	.12E			;対応されていたら.12Eにジャンプ
	cdecl	puts, .s1
	jmp	.10E			;対応されていなかったらbreak
.12E:
	jnc	.14E			;CFが0なら(成功していたら)、14Eにジャンプ
	jmp	.10E			;CFが1なら(失敗していたら)、break
.14E:
	cdecl	put_mem_info, di	;メモリ領域1つ分の情報の表示
	
;以下.15Eまで、シャットダウン機能を実装するために,
;データタイプを3番に設定し、ACPIテーブルからACPI dataのアドレスを取得し、保存
	mov	eax, [di + 16]		;eaxに[書き込み先アドレス + 16]、つまりデータタイプを代入
	cmp	eax, 3			;eax(データタイプ)と3を比較	
	jne	.15E			;もし、3じゃなかったら.15Eにジャンプ

	mov	eax, [di + 0]		;eaxにデータタイプ3番のメモリ領域のベースアドレスを代入
	mov	[ACPI_DATA.addr], eax	;ACPI_DATA.addrにベースアドレスを代入

	mov	eax, [di + 8]		;eaxにデータタイプ3番のメモリ領域のサイズを代入
	mov	[ACPI_DATA.len], eax	;ACPI_DATA.lenにメモリ領域のサイズを代入
.15E:

;以下.16Eまで、メモリ情報を8行分表示するたびにキー入力待ちにする処理
	cmp	ebx, 0			;ebx、つまりインデックスの値が0なら最終データである
	jz	.16E			;ということを表しており、終了する

	inc	bp			;0じゃなかった場合、行数をインクリメントしたものと、
	and	bp, 0x07		;0x07(0b0111)をand演算する。
	jnz	.16E			;演算結果が0以外なら(bp >= 0b0000 && bp < 0b1000なら).16Eにジャンプ

	cdecl	puts, .s3		;0だったら(bp == 0b0111なら)指定した文字列を出力してキ－入力待ち
	mov	ah, 0x00
	int	0x16

	cdecl	puts, .s4
.16E:

;以下.10Eまで、インデックスをすべて出力したか判定する処理
	cmp	ebx, 0			;ebx(インデックス)と0を比較
	jne	.10L			;0じゃなかったら(最後のデータじゃなかったら)、
					;.10Lからもう一回処理を行う
.10E:
	cdecl	puts, .s2

	pop	bp
	pop	di
	pop	si
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	
	ret

.s0:	db " E820 Memory Map:", 0x0A, 0x0D
	db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:	db "doesn't support", 0x0A, 0x0D
.s2:	db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s3:	db "<more...>", 0
.s4:	db 0x0D, "        ", 0x0D, 0

ALIGN 4, db 0
.b0:	times E820_RECORD_SIZE db 0

put_mem_info:
	push	bp
	mov	bp, sp

	push	bx
	push	si
	
	mov	si, [bp + 4]		;siにバッファアドレスを代入

	;ベースアドレスの表示
	cdecl	itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100
	cdecl	itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
	cdecl	itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100
	cdecl	itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100

	;領域のサイズの表示
	cdecl	itoa, word [si + 14], .p4 + 0, 4, 16, 0b0100
	cdecl	itoa, word [si + 12], .p4 + 4, 4, 16, 0b0100
	cdecl	itoa, word [si + 10], .p5 + 0, 4, 16, 0b0100
	cdecl	itoa, word [si +  8], .p5 + 4, 4, 16, 0b0100

	;データタイプの表示
	cdecl	itoa, word [si + 18], .p6 + 0, 4, 16, 0b0100
	cdecl	itoa, word [si + 16], .p6 + 4, 4, 16, 0b0100

	cdecl	puts, .s1

;以下4行、s4～s9までのどの文字列を出力するか判定する処理
	mov	bx, [si + 16]		;bxにUnknownやusableといったメモリの情報を代入
	and	bx, 0x07
	shl	bx, 1
	add	bx, .t0

	cdecl	puts, word [bx]		;.t0の先頭から順に(s4, s5, s6 ...のように)出力

	pop	si
	pop	bx

	mov	sp, bp
	pop	bp

	ret

.s1:	db  " "
.p2:	db  "ZZZZZZZZ_"
.p3:	db  "ZZZZZZZZ "
.p4:	db  "ZZZZZZZZ_"
.p5:	db  "ZZZZZZZZ "
.p6:	db  "ZZZZZZZZ", 0

.s4:	db " (Unknown)", 0x0A, 0x0D, 0
.s5:	db " (usable)", 0x0A, 0x0D, 0
.s6:	db " (reserved)", 0x0A, 0x0D, 0
.s7:	db " (ACPI data)", 0x0A, 0x0D, 0
.s8:	db " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:	db " (bad memory)", 0x0A, 0x0D, 0

.t0:	dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4