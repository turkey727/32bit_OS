;---------------------------1st stage------------------------------------

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
	mov	cx, BOOT_LOAD + SECT_SIZE	;0x7c00 + 512
	
	cdecl	read_chs, BOOT, bx, cx		;AXにread_chs(BOOT, bx, cx)の戻り値が入る

	cmp	ax, bx				
.10Q:	jz	.10E				;もしax=bxなら成功。ax!=bxなら再起動
.10T:	cdecl	puts, .e0
	call	reboot
.10E:
	jmp	stage_2nd

.s0	db	"Booting now...", 0x0A, 0x0D, 0
.e0	db	"Error:Failed to read of sector", 0

ALIGN 2, db 0
BOOT:
	istruc	drive
	    at	drive.no,	dw 0
	    at	drive.cyln,	dw 0
	    at	drive.head,	dw 0
	    at	drive.sect,	dw 2
	iend


%include	"..\modules\real\puts.s"
%include	"..\modules\real\reboot.s"
%include	"..\modules\real\read_chs.s"

	times 	510 - ($ - $$) db 0x00
	db	0x55, 0xAA

FONT:
.seg:	dw  0
.off:	dw  0
ACPI_DATA:
.addr:	dd  0
.len:	dd  0

;-----------------------------2nd stage---------------------------------

%include	"..\modules\real\get_drive_param.s"
%include	"..\modules\real\itoa.s"
%include	"..\modules\real\get_font_addr.s"
%include	"..\modules\real\get_mem_info.s"

stage_2nd:
	cdecl	puts, .s0

;以下.10Eまで、ドライブパラメータを取得する処理
	cdecl	get_drive_param, BOOT
	cmp	ax, 0		;もし成功したら、.10Eにジャンプ
.10Q:	jne	.10E
.10T:	cdecl	puts, .e0	;失敗したら再起動処理
	call	reboot
.10E:

;以下、取得したドライブパラメータを表示する処理
	mov	ax, [BOOT + drive.no]
	cdecl	itoa, ax, .p1, 2, 16, 0b0100
	mov	ax, [BOOT + drive.cyln]
	cdecl	itoa, ax, .p2, 4, 16, 0b0100
	mov	ax, [BOOT + drive.head]
	cdecl	itoa, ax, .p3, 2, 16, 0b0100
	mov	ax, [BOOT + drive.sect]
	cdecl	itoa, ax, .p4, 2, 16, 0b0100
	cdecl	puts, .s1

	jmp	stage_3rd		;次のブートプログラムを実行

.s0	db	"start 2nd stage...", 0x0A, 0x0D, 0

.s1	db	" Drive:0x"
.p1	db	"  , Cyln:0x"
.p2	db	"    , Head:0x"
.p3	db	"  , Sect:0x"
.p4	db	"  ", 0x0A, 0x0D, 0

.e0	db	"Can't get drive parameter.", 0

;-----------------------------------3rd stage-------------------------------------

stage_3rd:
	cdecl	puts, .s0

	cdecl	get_font_addr, FONT

	cdecl	itoa, word [FONT.seg], .p1, 4, 16, 0b0100
	cdecl	itoa, word [FONT.off], .p2, 4, 16, 0b0100
	cdecl	puts, .s1

	cdecl	get_mem_info

	mov	eax, [ACPI_DATA.addr]
	cmp	eax, 0
	je	.10E

	cdecl	itoa, ax, .p4, 4, 16, 0b0100
	shr	eax, 16
	cdecl	itoa, ax, .p3, 4, 16, 0b0100
	cdecl	puts, .s2
.10E:

	jmp	stage_4th

.s0	db	"start 3rd stage...", 0x0A, 0x0D, 0

.s1:	db	"  Font Address = "
.p1:	db	"ZZZZ:"
.p2:	db	"ZZZZ", 0x0A, 0x0D, 0
	db	0x0A, 0x0D, 0

.s2:	db	" ACPI data = "
.p3	db	"ZZZZ"
.p4	db	"ZZZZ", 0x0A, 0x0D, 0

;----------------------------------4th stage--------------------------------------------

%include	"..\modules\real\kbc.s"

stage_4th:
	cdecl	puts, .s0

;以下、A20ゲートを有効にする処理
	cli				;割り込み禁止
	cdecl	KBC_Cmd_Write, 0xAD	;キーボード操作無効化

	cdecl	KBC_Cmd_Write, 0xD0	;コマンド0xD0(出力ポートの値を読み出すコマンド)を0x64に書き込む
	cdecl	KBC_Data_Read, .key	;0x60ポートの値をkeyのアドレスに保存する

	mov	bl, [.key]		;blに0x60ポートの値を格納
	or	bl, 0x02		;0x60ポートの値と0b10でor演算

	cdecl	KBC_Cmd_Write, 0xD1	;コマンド0xD1(ステータスレジスタB1を、A20が有効か無効かを指定するビットとして
					;扱えるようにする)を0x64に書き込む
	cdecl	KBC_Data_Write, bx	;bxの値を0x60に書き込む(B1が4行前のor演算で1になっているため、A20が有効化)

	cdecl	KBC_Cmd_Write, 0xAE	;キーボード操作有効化
	sti				;割り込み許可

	cdecl	puts, .s1

	jmp	$

.s0:	db	"start 4th stage...", 0x0A, 0x0D, 0
.s1:	db	"  A20 gate Enabled.", 0x0A, 0x0D, 0

.key:	dw	0

	times BOOT_SIZE - ($ - $$) db 0