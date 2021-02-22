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
