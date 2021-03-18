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

	cdecl	draw_font, 63, 13
	
;以下、文字列を出力する処理
	cdecl	draw_str, 25, 14, 0x010F, .s0

.10L:
	cdecl	rtc_get_time, RTC_TIME		;RTC_TIMEに取得した時刻データを保存
	cdecl	draw_time, 72, 0, 0x0700, dword [RTC_TIME]	;出力

	jmp	.10L

	jmp	$


.s0:	db	" Hello world! ", 0

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

	times	KERNEL_SIZE - ($ - $$)	db	0x00