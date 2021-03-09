BOOT_LOAD	equ	0x7C00			;ブートプログラムの最初にロードするアドレスの定義
BOOT_END	equ	(BOOT_LOAD + BOOT_SIZE)

BOOT_SIZE	equ	(1024 * 8)		;ブートプログラムのサイズ(8Kバイト)
SECT_SIZE	equ	(512)			;セクタサイズの定義
BOOT_SECT	equ	(BOOT_SIZE / SECT_SIZE)	;ブートプログラムのセクタ数の定義

E820_RECORD_SIZE	equ	20		;BIOSコールで取得したメモリ情報を格納する領域のサイズの定義

KERNEL_LOAD	equ	0x0010_1000		;ロードするアドレス
KERNEL_SIZE	equ	(1024 * 8)		;カーネルのサイズ
KERNEL_SECT	equ	(KERNEL_SIZE / SECT_SIZE)	;カーネルのセクタ数の定義