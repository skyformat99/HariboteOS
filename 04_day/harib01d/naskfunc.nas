; naskfunc

[FORMAT "WCOFF"]                ; �I�u�W�F�N�g�t�@�C������郂�[�h
[INSTRSET "i486p"]              ; 486�̖��߂܂Ŏg�������Ƃ����L�q
[BITS 32]                       ; 32�r�b�g���[�h�p�̋@�B�����点��
[FILE "naskfunc.nas"]           ; �\�[�X�t�@�C�������

        global  _io_hlt

[SECTION .text]

_io_hlt:    ; void io_hlt(void);
        hlt
        ret

