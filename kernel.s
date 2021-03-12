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

;以下21行、4色の横線を出力する処理、
	mov	ah, 0x07
	mov	al, 0x02
	mov	dx, 0x03C4
	out	dx, ax

	mov	[0x000A_0000 + 0], byte 0xFF

	mov	ah, 0x04
	out	dx, ax
	
	mov	[0x000A_0000 + 1], byte 0xFF

	mov	ah, 0x02
	out	dx, ax
	
	mov	[0x000A_0000 + 2], byte 0xFF

	mov	ah, 0x01
	out	dx, ax
	
	mov	[0x000A_0000 + 3], byte 0xFF

;以下7行、画面を横切る線を出力する処理
	mov	ah, 0x02
	out	dx, ax

	lea	edi, [0x000A_0000 + 80]
	mov	ecx, 80
	mov	al, 0xFF
	rep	stosb

;以下13行、四角形を出力する処理
	mov	edi, 1
	
	shl	edi, 8
	lea	edi, [edi * 4 + edi + 0xA_0000]

	mov	[edi + (80 * 0)], word 0xFF
	mov	[edi + (80 * 1)], word 0xFF
	mov	[edi + (80 * 2)], word 0xFF
	mov	[edi + (80 * 3)], word 0xFF
	mov	[edi + (80 * 4)], word 0xFF
	mov	[edi + (80 * 5)], word 0xFF
	mov	[edi + (80 * 6)], word 0xFF
	mov	[edi + (80 * 7)], word 0xFF
	
	mov	esi, 'A'
	shl	esi, 4
	add	esi, [FONT_ADDR]

	mov	edi, 2
	mov	edi, 8
	lea	edi, [edi * 4 + edi + 0xA_0000]

	mov	ecx, 16
.10L:
	movsb
	add	edi, 80 - 1
	loop	.10L

	jmp	$

ALIGN	4, db	0
FONT_ADDR:	dd	0

	times	KERNEL_SIZE - ($ - $$)	db	0