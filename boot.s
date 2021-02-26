%include	"..\include\define.s"
%include	"..\include\macro.s"

	ORG	BOOT_LOAD		;これで、最初にロードするアドレスをアセンブラに指示

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

	mov	[BOOT + drive.no], dl	;dlレジスタには、ブートプログラムが保存されていた
					;ストレージデバイスの番号が設定されており、
					;それを指定したアドレスに保存し、今後も使っていく。

	cdecl	puts, .s0
	
	mov	bx, BOOT_SECT - 1		;HDDのロードできる残りのセクタ数
	mov	cx, BOOT_LOAD + SECT_SIZE	;次に読み込むブートプログラムのアドレス(0x7c00 + 512)
	
	cdecl	read_chs, BOOT, bx, cx		;AXにread_chs(BOOT, bx, cx)の戻り値が入る

	cmp	ax, bx				
.10Q:	jz	.10E				;もしax=bxなら成功。ax!=bxなら再起動
.10T:	cdecl	puts, .e0
	call	reboot
.10E:
	jmp	stage_2

.s0	db	"Booting now...", 0x0A, 0x0D, 0
.e0	db	"Error:Failed to read of sector", 0

ALIGN 2, db 0
BOOT:
	istruc	drive
	    at	drive.no,	dw 0	;ドライブ番号
	    at	drive.cyln,	dw 0	;シリンダ
	    at	drive.head,	dw 0	;ヘッド
	    at	drive.sect,	dw 2	;セクタ
	iend

%include	"..\modules\real\puts.s"
%include	"..\modules\real\itoa.s"
%include	"..\modules\real\reboot.s"
%include	"..\modules\real\read_chs.s"

	times 	510 - ($ - $$) db 0x00;
	db	0x55, 0xAA;

stage_2:
	cdecl	puts, .s0

	jmp	$;

.s0	db	"start 2nd stage...", 0x0A, 0x0D, 0

	times BOOT_SIZE - ($ - $$) db 0

	