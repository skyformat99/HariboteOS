; haribote-ipl

        org     0x7c00      ; ���̃v���O�������ǂ��ɓǂݍ��܂��̂�

; �ȉ��͕W���I��FAT12�t�H�[�}�b�g�t���b�s�[�f�B�X�N�̂��߂̋L�q
        jmp     entry
        db      0x90
        db      "HARIBOTE"      ; �u�[�g�Z�N�^�̖��O�i8�o�C�g�j
        dw      512             ; 1�Z�N�^�̑傫���i512�j
        db      1               ; �N���X�^�̑傫���i1�Z�N�^�j
        dw      1               ; FAT���ǂ�����n�܂邩�i�ӂ���1�Z�N�^�ځj
        db      2               ; FAT�̌��i2�ɂ��Ȃ���΂����Ȃ��j
        dw      224             ; ���[�g�f�B���N�g���̈�̑傫���i���ʂ�224�G���g���j
        dw      2880            ; ���̃h���C�u�̑傫���i2880�Z�N�^�ɂ��Ȃ���΂����Ȃ��j
        db      0xf0            ; ���f�B�A�̃^�C�v�i0xf0�ɂ��Ȃ���΂����Ȃ��j
        dw      9               ; FAT�̈�̒����i9�Z�N�^�ɂ��Ȃ���΂����Ȃ��j
        dw      18              ; 1�g���b�N�ɂ����̃Z�N�^�����邩�i18�ɂ��Ȃ���΂����Ȃ��j
        dw      2               ; �w�b�h�̐��i2�ɂ��Ȃ���΂����Ȃ��j
        dd      0               ; �p�[�e�B�V�������g���ĂȂ��̂ł�����0
        dd      2880            ; ���̃h���C�u�̑傫����������x����
        db      0,0,0x29        ; �悭�킩��Ȃ����ǂ��̒l�ɂ��Ă����Ƃ���
        dd      0xffffffff      ; ���Ԃ�{�����[���V���A���ԍ�
        db      "HARIBOTEOS "   ; �f�B�X�N�̖��O�i11�o�C�g�j
        db      "FAT12   "      ; �t�H�[�}�b�g�̖��O�i8�o�C�g�j
        resb    18              ; �Ƃ肠����18�o�C�g�����Ă���

; �v���O�����{��
entry:
        mov     ax, 0           ; ���W�X�^������
        mov     ss, ax
        mov     sp, 0x7c00
        mov     ds, ax

; �f�B�X�N��ǂ�
        mov     ax, 0x0820
        mov     es, ax
        mov     ch, 0           ; �V�����_0
        mov     dh, 0           ; �w�b�h0
        mov     cl, 2           ; �Z�N�^2
readloop:
        mov     si, 0           ; ���s�񐔂𐔂��郌�W�X�^
retry:
        mov     ah, 0x02        ; AH=0x02 : �f�B�X�N�ǂݍ���
        mov     al, 1           ; 1�Z�N�^
        mov     bx, 0
        mov     dl, 0x00        ;�@A�h���C�u
        int     0x13            ; �f�B�X�NBISO�Ăяo��
        jnc     fin             ; �G���[���N���Ȃ����fin��
        add     si, 1           ; SI��1�𑫂�
        cmp     si, 5           ; SI��5�Ɣ�r
        jae     error           ; SI >= 5 ��������error��
        mov     ah, 0x00
        mov     dl, 0x00        ; A�h���C�u
        int     0x13            ; �h���C�u�̃��Z�b�g
        jc      error
next:
        mov     ax, es          ; �A�h���X��0x200�i�߂�
        add     ax, 0x0020
        mov     es, ax          ; ADD ES, 0x200 �Ƃ������߂��Ȃ��̂ł�������
        add     cl, 1           ; CL��1�𑫂�
        cmp     cl, 18          ; CL��18���r
        jbe     readloop        ; CL <= 18 ��������readloop��
fin:
        hlt                     ; ��������܂�CPU���~
        jmp     fin             ; �������[�v

error:
        mov     si, msg
putloop:
        mov     al, [si]
        add     si, 1           ; SI��1�𑫂�
        cmp     al, 0
        je      fin
        mov     ah, 0x0e        ; �ꕶ���\���t�@���N�V����
        mov     bx, 15        ; �J���[�R�[�h
        int     0x10            ; �r�f�IBIOS�Ăяo��
        jmp     putloop
msg:
        db      0x0a, 0x0a      ; ���sx2
        db      "load error"
        db      0x0a            ; ���s
        db      0

        resb    0x7dfe-$        ; 0x7dfe�܂ł�0x00�Ŗ��߂閽��

        db      0x55, 0xaa