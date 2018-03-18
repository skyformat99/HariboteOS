; naskfunc

[FORMAT "WCOFF"]                ; �I�u�W�F�N�g�t�@�C������郂�[�h
[INSTRSET "i486p"]              ; 486�̖��߂܂Ŏg�������Ƃ����L�q
[BITS 32]                       ; 32�r�b�g���[�h�p�̋@�B�����点��
[FILE "naskfunc.nas"]           ; �\�[�X�t�@�C�������

        global  _io_hlt, _write_mem8

[SECTION .text]

_io_hlt:    ; void io_hlt(void);
        hlt
        ret

_write_mem8:    ; void write_mem8(int addr, int data);
        mov     ecx, [esp+4]    ; [ESP+4]��addr�������Ă���̂ł����ECX�ɓǂݍ���
        mov     al, [esp+8]     ; [ESP+8]��data�������Ă���̂ł����AL�ɓǂݍ���
        mov     [ecx], al
        ret