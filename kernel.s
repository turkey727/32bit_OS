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

;以下4行、割り込み処理を実装するための処理
	cdecl	init_int		;割り込みゲートディスクリプタを設定。
	cdecl	init_pic
	set_vect	0x00, int_zero_div	;割り込み処理の登録(ゼロ除算)
	set_vect	0x28, int_rtc		;割り込み処理の登録(RTC)

;以下、RTCの割り込みを実装するコード
	cdecl	rtc_int_en, 0x10	;RTCの割り込みを許可する処理
	outp	0x21, 0b1111_1011	;マスタPICのIRQ2を0にセットして割り込みを許可
	outp	0xA1, 0b1111_1110	;スレーブPICのIRQ0を0にセットし、割り込みを許可
	sti


	cdecl	draw_font, 63, 13		;フォントデータ一覧を出力
	
	cdecl	draw_str, 25, 14, 0x010F, .s0	;文字列を出力する処理

.10L:
	mov	eax, [RTC_TIME]
	cdecl	draw_time, 72, 0, 0x0700, eax	;出力

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
%include	"..\modules\protect\interrupt.s"
%include	"..\modules\protect\int_rtc.s"
%include	"..\modules\protect\pic.s"


	times	KERNEL_SIZE - ($ - $$)	db	0x00