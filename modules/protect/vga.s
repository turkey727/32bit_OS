vga_set_read_plane:
;後に読み込みを行うプレーンの指定を行う関数
	push	ebp
	mov	ebp, esp

	push	eax
	push	edx

	mov	ah, [ebp + 8]		;引数で指定したプレーンを代入
	and	ah, 0x03		
	mov	al, 0x04
	mov	dx, 0x03CE
	out	dx, ax
	
	pop	edx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

vga_set_write_plane:
;後に書き込みを行うプレーンの指定を行う関数
	push	ebp
	mov	ebp, esp

	push	eax
	push	edx

	mov	ah, [ebp + 8]
	and	ah, 0x0F
	mov	al, 0x02
	mov	dx, 0x03C4
	out	dx, ax
	
	pop	edx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

vram_font_copy:
;VRAMアドレスにフォントデータを書き込む関数
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

	mov	esi, [ebp + 8]
	mov	edi, [ebp + 12]
	movzx	eax, byte [ebp + 16]
	movzx	ebx, word [ebp + 20]
	test	bh, al
	setz	dh
	dec	dh

	test	bl, al
	setz	dl
	dec	dl

	cld

	mov	ecx, 16
.10L:
	lodsb
	mov	ah, al
	not	ah

	and	al, dl

	test	ebx, 0x0010
	jz	.11F
	and	ah, [edi]
	jmp	.11E
.11F:
	and	ah, dh
.11E:
	or	al, ah

	mov	[edi], al

	add	edi, 80
	loop	.10L
.10E:

	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret


