	BOOT_LOAD	equ	0x7C00  ;ブートプログラムのロード位置
	ORG	BOOT_LOAD;		;これで、最初にロードするアドレスをアセンブラに指示

%include	"..\include\macro.s"

entry:
	jmp	ipl         		;最初はiplから処理

	times	90 - ($ - $$) db 0x90
	
ipl:
	cli				;割り込み禁止命令

	mov	ax, 0x0000		;セグメントレジスタを初期化する値をAXに代入
	mov	ds, ax			;AXを介してセグメントレジスタを初期化
	mov	es, ax
	mov	ss, ax
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

;以下6行、セクタ読み出しBIOSコールの準備
	mov	ah, 0x02		;ah=0x02でセクタ読み込み命令の設定
	mov	al, 1			;読み込みセクタ数を1に設定
	mov	cx, 0x0002		;cxでシリンダ/セクタ番号の設定
	mov	dh, 0x00		;ヘッド位置を指定
	mov	dl, [BOOT.DRIVE]	;dlが0のときFDD,1の時HDDの読み込み
	mov	bx, 0x7C00 + 512	;オフセットの設定
	int	0x13			;セクタ読み出しコール
.10Q:	jnc	.10E			;CFレジスタが0、つまり読み込みに成功したらジャンプ
.10T:	cdecl	puts, .e0		;失敗したら、e0の文字列を出力
	call	reboot			;再起動処理
.10E:
	jmp	stage_2			;セクタ読み出しに成功し、次のブートプログラムの実行

.s0	db	"Booting now...", 0x0A, 0x0D, 0
.s1	db	"--------", 0x0A, 0x0D, 0
.e0	db	"Error:Failed to read of sector", 0

ALIGN 2, db 0
BOOT:
.DRIVE:	dw 0;

%include	"..\modules\real\puts.s"
%include	"..\modules\real\itoa.s"
%include	"..\modules\real\reboot.s"

	times 	510 - ($ - $$) db 0x00;
	db	0x55, 0xAA;


stage_2:
	cdecl	puts, .s0

	jmp	$;

.s0	db	"start 2nd stage!", 0x0A, 0x0D, 0

	times (1024 * 8) - ($ - $$) db 0	;8Kバイトのサイズの命令を実行できる。

	