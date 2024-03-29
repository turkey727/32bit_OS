;cdecl呼び出し規約を実装するためのコード
%macro	cdecl 1-*.nolist	;1-*で、可変長引数を扱えるように

;以下6行、スタックに引数をプッシュする処理
	%rep	%0 - 1		;repは繰り返し命令で「%0 - 1」回、つまり引数の数だけ繰り返す

		push	%{-1:-1}	;%{-1:-1}は最後の引数を1つだけ指定する時の書き方
		%rotate -1		;rotate -1で、引数を右にづらす。
	%endrep				;ここまでを繰り返し、右の引数から順にスタックにpush。

;以下2行、関数を呼び出す処理
	%rotate -1
		call	%1

;以下3行、呼び出し後のスタックポインタの調整を行う処理
	%if 1 < %0
		add	sp, (__BITS__ >> 3) * (%0 - 1)	;__BITS__で、16bitと32bitの判定を行い、
							;スタックポインタの調整を自動で行ってくれる
	%endif

%endmacro

;セクタ読み出しを関数で行うために各パラメータを構造体でまとめる
struc drive
	.no	resw	1	;ドライブ番号
	.cyln	resw	1	;シリンダ
	.head	resw	1	;ヘッダ
	.sect	resw	1	;セクタ
endstruc

;第一引数で指定したベクタ番号に、第二引数で指定した割り込み処理を設定するためのコード
;もし3つ目の引数が指定されたらそれをゲートディスクリプタの属性として設定する。
%macro	set_vect 1-*
	push	eax
	push	edi
	
	mov	edi, VECT_BASE + (%1 * 8)	;ベースアドレスと指定したベクタ番号*8を
						;加算したもの(ベクタアドレス)を代入

	mov	eax, %2				;指定した割り込み処理を代入

	%if 3 == %0
		mov	[edi + 4], %3
	%endif

	mov	[edi + 0], ax
	shr	eax, 16
	mov	[edi + 6], ax

	pop	edi
	pop	eax
%endmacro


%macro	outp 2
	mov	al, %2
	out	%1, al
%endmacro
