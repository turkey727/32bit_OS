draw_str:
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

;以下4行、レジスタに引数で受け取った値を代入する処理
	mov	ecx, [ebp + 8]
	mov	edx, [ebp + 12]
	movzx	ebx, word [ebp + 16]
	mov	esi, [ebp + 20]

	cld

;以下.10Eまで、文字の終端(0)を探して、0ならbreak。0以外ならループを行う処理。
.10L:
	lodsb
	cmp	al, 0
	je	.10E

	cdecl	draw_char, ecx, edx, ebx, eax

	inc	ecx
	cmp	ecx, 80
	jl	.12E
	mov	ecx, 0
	inc	edx
	cmp	edx, 30
	jl	.12E
	mov	edx, 0
.12E:
	jmp	.10L
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