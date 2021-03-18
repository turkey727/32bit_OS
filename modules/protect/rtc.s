rtc_get_time:
;内蔵RAMアドレスの値を各ポートに書き込むことでデータを取得できる

	push	ebp
	mov	ebp, esp

	push	ebx

;以下3行、時間データを取得する処理
	mov	al, 0x04		;alに時間データを得るためのアドレスを代入
	out	0x70, al		;0x70ポートにアドレスを出力
	in	al, 0x71		;alに時間データを入力

	shl	eax, 8			;alレジスタに入ってる時間データをahレジスタに退避

;以下3行、分データを取得する処理
	mov	al, 0x02
	out	0x70, al
	in	al, 0x71
	
	shl	eax, 8			;時間データをeaxの上位アドレスに、分データをahに退避

;以下3行、秒データを取得する処理
	mov	al, 0x00
	out	0x70, al
	in	al, 0x71

;これまでの処理でeaxレジスタの中身は、0x00_時間データ_分データ_秒データのようになっている
;以下3行は、取得した時刻データを指定したアドレスに保存する処理
	and	eax, 0x00_FF_FF_FF		;時刻データのみをマスク
	mov	ebx, [ebp + 8]			;引数で指定した保存先アドレスをebxに代入
	mov	[ebx], eax			;保存先アドレスに時刻データを代入

	pop	ebx

	mov	esp, ebp
	pop	ebp
	
	ret
