	BOOT_LOAD	equ	0x7C00  ;ブートプログラムのロード位置
	ORG	BOOT_LOAD;		;これで、最初にロードするアドレスをアセンブラに指示

%include	"..\include\macro.s"

entry:
	jmp	ipl         		;最初はiplから処理

	times	90 - ($ - $$) db 0x90
	
ipl:
	cli;				;割り込み禁止命令

	mov	ax, 0x0000		;セグメントレジスタを初期化する値をAXに代入
	mov	ds, ax			;AXを介してセグメントレジスタを初期化
	mov	es, ax;
	mov	ss, ax;
	mov	sp, BOOT_LOAD		;スタックポインタを0x7C00に設定

	sti				;割り込みを許可

	mov	[BOOT.DRIVE], dl	;dlレジスタには、ブートプログラムが保存されていた
					;ストレージデバイスの番号が設定されており、
					;それを指定したアドレスに保存し、今後も使っていく。

	cdecl	puts, .s0

	cdecl	itoa,	8086, .s1, 8, 10, 0b0001
	cdecl	puts, .s1

	cdecl	itoa,	8086, .s1, 8, 10, 0b0011
	cdecl	puts, .s1
	
	cdecl	reboot

	jmp	$;

.s0	db	"Booting now...", 0x0A, 0x0D, 0
.s1	db	"--------", 0x0A, 0x0D, 0

ALIGN 2, db 0
BOOT:
.DRIVE:	dw 0;

%include	"..\modules\real\puts.s"
%include	"..\modules\real\itoa.s"
%include	"..\modules\real\reboot.s"

	times 	510 - ($ - $$) db 0x00;
	db	0x55, 0xAA;