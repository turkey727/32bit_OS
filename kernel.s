%include "../include/define.s"
%include "../include/macro.s"

	ORG	KERNEL_LOAD

[BITS 32]

kernel:
;以下6行、フォントアドレスを取得する処理
	mov	esi, BOOT_LOAD + SECT_SIZE
	movzx	eax, word [esi + 0]
	movzx	ebx, word [esi + 2]
	shl	eax, 4
	add	eax, ebx
	mov	[FONT_ADDR], eax

	cdecl	draw_font, 63, 13		;フォントデータ一覧を出力
	
	cdecl	draw_str, 25, 14, 0x010F, .s0	;文字列を出力する処理

;以下2行、割り込み処理を実装するための処理
	cdecl	init_int		;割り込みゲートディスクリプタを設定。
	set_vect	0x00, int_zero_div	;割り込み処理の登録(ゼロ除算)

;以下2行、ゼロ除算時に割り込みが発生するかのテスト
	mov	al, 0
	div	al

.10L:
	cdecl	rtc_get_time, RTC_TIME		;RTC_TIMEに取得した時刻データを保存
	cdecl	draw_time, 72, 0, 0x0700, dword [RTC_TIME]	;出力

	jmp	.10L

	jmp	$


.s0:	db	"  Hello world!  ", 0

ALIGN	4, db	0
FONT_ADDR:	dd	0
RTC_TIME:	dd	0

%include	"..\modules\protect\vga.s"
%include	"..\modules\protect\draw_char.s"
%include	"..\modules\protect\draw_font.s"
%include	"..\modules\protect\draw_str.s"
%include	"..\modules\protect\itoa.s"
%include	"..\modules\protect\rtc.s"
%include	"..\modules\protect\draw_time.s"
%include	".\modules\interrupt.s"

	times	KERNEL_SIZE - ($ - $$)	db	0x00