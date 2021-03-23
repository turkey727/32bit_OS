int_rtc:
;割り込み処理の内容

;以下3行、割り込み処理後に元の処理に復帰するためにレジスタを保存
	pusha
	push	ds
	push	es

;以下3行、GDTの先頭からのバイト数である0x0010をds,esレジスタに代入する処理。
	mov	ax, 0x0010
	mov	ds, ax
	mov	es, ax

	cdecl	rtc_get_time, RTC_TIME	;時刻データを一時RTC_TIMEに保存する

	outp	0x70, 0x0C	;RTC内部レジスタCを選択
	in	al, 0x71	;0x71ポートのデータをalに代入

	outp	0xA0, 0x20	;スレーブPICにEOIを書き込む
	outp	0x20, 0x20	;マスタPICにEOIを書き込む

	pop	es
	pop	ds
	popa

	iret

rtc_int_en:
;RTCの割り込みを許可する処理


	push	ebp
	mov	ebp, esp

	push	eax

	outp	0x70, 0x0B	;RTC内部レジスタBを選択
	
	in	al, 0x71	;0x71ポートのデータをalに代入
	or	al, [ebp + 8]	;引数で指定したビット(UIE)をセット

	out	0x71, al	;レジスタBに書き込む

	pop	eax
	
	mov	esp, ebp
	pop	ebp

	ret