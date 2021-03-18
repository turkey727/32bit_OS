draw_time:
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx

	mov	eax, [ebp + 20]		;時刻データをeaxに代入

	movzx	ebx, al			;ebxに秒データを代入
	cdecl	itoa, ebx, .sec, 2, 16, 0b0100		;文字列に変換

	mov	bl, ah			;blに分データを代入
	cdecl	itoa, ebx, .min, 2, 16, 0b0100		;文字列に変換
	
	shr	eax, 16			;eaxの値をシフトして時間データだけにする
	cdecl	itoa, eax, .hour, 2, 16, 0b0100		;文字列に変換

	cdecl	draw_str, dword [ebp + 8], dword [ebp + 12], dword [ebp + 16], .hour	;出力

	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

.hour:	db	"ZZ:"
.min:	db	"ZZ:"
.sec:	db	"ZZ", 0