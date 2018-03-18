; haribote-os

; BOOT_INFO�֌W
CYLS    equ     0x0ff0          ; �u�[�g�Z�N�^���ݒ肷��
LEDS    equ     0x0ff1
VMODE   equ     0x0ff2          ; �F���Ɋւ�����B���r�b�g�J���[��?
SCRNX   equ     0x0ff4          ; �𑜓x��X
SCRNY   equ     0x0ff6          ; �𑜓x��Y
VRAM    equ     0x0ff8          ; �O���t�B�b�N�o�b�t�@�̊J�n�Ԓn

        org     0xc200          ; ���̃v���O�������ǂ��ɓǂݍ��܂��̂�

        mov     al, 0x13        ; VGA�O���t�B�b�N�X�A320x200x8bit�J���[
        mov     ah, 0x00
        int     0x10
        mov     byte [VMODE], 8 ; ��ʃ��[�h����������
        mov     word [SCRNX], 320
        mov     word [SCRNY], 200
        mov     dword [VRAM], 0x000a0000

; �L�[�{�[�h��LED��Ԃ�BIOS�ɋ����Ă��炤
        mov     ah, 0x02
        int     0x16            ; keyboard BIOS
        mov     [LEDS], al

fin:
        hlt
        jmp     fin