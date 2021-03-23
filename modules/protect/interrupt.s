ALIGN 4
IDTR:	dw	8 * 256 -1
	dd	VECT_BASE


int_default:
;割り込み発生後にスタックの中身を表示するためにスタックを保存しておく関数。
;（これがないと、iret命令で割り込みに使ったスタックが破棄されるため、スタックを表示できない)

	pushf			;フラグレジスタの値をスタックにプッシュ
	push	cs		;csレジスタをプッシュ
	push	int_stop	;関数int_stop(EIP)をプッシュ

	mov	eax, .s0	;eaxに割り込み種別を表す文字列を代入
	iret			;IP、CS、フラグレジスタをポップして割り込み処理から復帰

.s0:	db	" <    STOP    > ", 0

int_stop:
	sti

	cdecl	draw_str, 25, 15, 0x060F, eax

	mov	eax, [esp + 0]
	cdecl	itoa, eax, .p1, 8, 16, 0b0100

	mov	eax, [esp + 4]
	cdecl	itoa, eax, .p2, 8, 16, 0b0100

	mov	eax, [esp + 8]
	cdecl	itoa, eax, .p3, 8, 16, 0b0100

	mov	eax, [esp + 12]
	cdecl	itoa, eax, .p4, 8, 16, 0b0100

	cdecl	draw_str, 25, 16, 0x0F04, .s1
	cdecl	draw_str, 25, 17, 0x0F04, .s2
	cdecl	draw_str, 25, 18, 0x0F04, .s3
	cdecl	draw_str, 25, 19, 0x0F04, .s4

	jmp	$

.s1:	db	"ESP + 0:"
.p1:	db	"________ ", 0
.s2:	db	"ESP + 4:"
.p2:	db	"________ ", 0
.s3:	db	"ESP + 8:"
.p3:	db	"________ ", 0
.s4:	db	"ESP +12:"
.p4:	db	"________ ", 0

init_int:
;割り込みゲートディスクリプタを定義する処理
	push	eax
	push	ebx
	push	ecx
	push	edi

;割り込みゲートディスクリプタは、64ビットで構成されるのでeaxとebxを使って定義する
	lea	eax, [int_default]
	mov	ebx, 0x0008_8E00
	xchg	ax, bx

	mov	ecx, 256
	mov	edi, VECT_BASE	;VECT_BASE(割り込みディスクリプタテーブルの開始アドレス)を代入

;割り込み要因は0～255までの256ベクタ分作成するので、その分のテーブルを定義
.10L:
	mov	[edi + 0], ebx
	mov	[edi + 4], eax
	add	edi, 8
	loop	.10L

	lidt	[IDTR]		;ディスクリプタテーブルをCPUに登録する処理

	pop	edi
	pop	ecx
	pop	ebx
	pop	eax

	ret

int_zero_div:
;以下3行、ゼロ除算が行われた際のスタックを表示するための処理
	pushf
	push	cs
	push	int_stop

	mov	eax, .s0
	iret

.s0:	db	" <   ZERO DIV   > ", 0
