; haribote-os

        org     0xc200          ; ���̃v���O�������ǂ��ɓǂݍ��܂��̂�

        mov     al, 0x13        ; VGA�O���t�B�b�N�X�A320x200x8bit�J���[
        mov     ah, 0x00
        int     0x10
fin:
        hlt
        jmp     fin