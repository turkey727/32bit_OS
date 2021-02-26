get_drive_param:
	push	bp
	mov	bp, sp

	push	bx
	push	cx
	push	es
	push	si
	push	di

	mov	si, [bp + 4]		;si��drive�\���̂̃A�h���X����

;�ȉ�3�s�Aax���g���ăf�B�X�N�x�[�X�e�[�u���|�C���^�̏�����
	mov	ax, 0
	mov	es, ax
	mov	di, ax

	mov	ah, 8			;�h���C�u�p�����[�^���擾
	mov	dl, [si + drive.no]	;�h���C�u�ԍ��̎w��A
	int	0x13			;BIOS�R�[���Ăяo��
.10Q:	jc	.10F			;CF��1�Ȃ�A�܂莸�s������.10F�ɔ��

;�ȉ��A���ɃZ�N�^���A�V�����_���A�w�b�h����ݒ肷�閽��
.10T:
	mov	al, cl		
	and	ax, 0x3F

	shr	cl, 6
	ror	cx, 8
	inc	cx
	
	movzx	bx, dh
	inc	bx

;�ȉ��A�ォ�珇�ɃV�����_���A�w�b�h���A�Z�N�^�����w�肵���A�h���X�Ɋi�[���閽��
	mov	[si + drive.cyln], cx
	mov	[si + drive.head], bx
	mov	[si + drive.sect], ax
	
	jmp	.10E
.10F:
	mov	ax, 0
.10E:
	pop	di
	pop	si
	pop	es
	pop	cx
	pop	bx

	mov	sp, bp
	pop	bp

	ret
