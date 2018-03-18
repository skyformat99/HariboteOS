; haribote-os boot asm

BOTPAK  equ     0x00280000      ; bootpack�̃��[�h��
DSKCAC  equ     0x00100000      ; �f�B�X�N�L���b�V���̏ꏊ
DSKCAC0 equ     0x00008000      ; �f�B�X�N�L���b�V���̏ꏊ�i���A�����[�h�j

; BOOT_INFO�֌W
CYLS    equ     0x0ff0          ; �u�[�g�Z�N�^���ݒ肷��
LEDS    equ     0x0ff1
VMODE   equ     0x0ff2          ; �F���Ɋւ�����B���r�b�g�J���[��?
SCRNX   equ     0x0ff4          ; �𑜓x��X
SCRNY   equ     0x0ff6          ; �𑜓x��Y
VRAM    equ     0x0ff8          ; �O���t�B�b�N�o�b�t�@�̊J�n�Ԓn

        org     0xc200          ; ���̃v���O�������ǂ��ɓǂݍ��܂��̂�

; ��ʃ��[�h��ݒ�
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

; PIC����؂̊��荞�݂��󂯕t���Ȃ��悤�ɂ���
; AT�݊��@�̎g�p�ł́APIC�̏�����������Ȃ�A
; ������CLI�O�ɂ���Ă����Ȃ��ƁA���܂Ƀn���O�A�b�v����
; PIC�̏������͂��Ƃł��
        mov     al, 0xff
        out     0x21, al
        nop                     ; OUT���߂�A��������Ƃ��܂������Ȃ��@�킪����炵���̂�
        out     0xa1, al

        cli                     ; �����CPU���x���ł����荞�݋֎~

; CPU����1MB�ȏ�̃������ɃA�N�Z�X�ł���悤�ɁAA20GATE��ݒ�
        call    waitkbdout
        mov     al, 0xd1
        out     0x64, al
        call    waitkbdout
        mov     al, 0xdf        ; enable A20
        out     0x60, al
        call    waitkbdout

; �v���e�N�g���[�h�ڍs
[INSTRSET "i486p"]              ; 486�̖��߂܂Ŏg�������Ƃ����L�q

        lgdt    [GDTR0]         ; �b���GDT��ݒ�
        mov     eax, cr0
        and     eax, 0x7fffffff ; bit31��0�ɂ���i�y�[�W���O�֎~�̂��߁j
        or      eax, 0x00000001 ; bit0��1�ɂ���i�v���e�N�g���[�h�ڍs�̂��߁j
        mov     cr0, eax
        jmp     pipelineflush
pipelineflush:
        mov     ax, 1*8         ; �ǂݏ����\�Z�O�����g32bit
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
        mov     ss, ax

; bootpack�̓]��
        mov     esi, bootpack   ; �]����
        mov     edi, BOTPAK     ; �]����
        mov     ecx, 512*1024/4
        call    memcpy

; ���łɃf�B�X�N�f�[�^���{���̈ʒu�֓]��

; �܂��̓u�[�g�Z�N�^����
        mov     esi, 0x7c00     ; �]����
        mov     edi, DSKCAC     ; �]����
        mov     ecx, 512/4
        call    memcpy

; �c��S��
        mov     esi, DSKCAC0+512        ; �]����
        mov     edi, DSKCAC+512         ; �]����
        mov     ecx, 0
        mov     cl, byte [CYLS]
        imul    ecx, 512*18*2/4         ; �V�����_������o�C�g��/4�ɕϊ�
        sub     ecx, 512/4              ; IPL�̕�������������
        call    memcpy

; asmhead�ł��Ȃ���΂����Ȃ����Ƃ͑S�����I������̂ŁA
; ���Ƃ�bootpack�ɔC����

; bootpack�̋N��
        mov     ebx, BOTPAK
        mov     ecx, [ebx+16]
        add     ecx, 3          ; ECX += 3;
        shr     ecx, 2          ; ECX /= 4;
        jz      skip            ; �]������ׂ����̂��Ȃ�
        mov     esi, [ebx+20]   ; �]����
        add     esi, ebx
        mov     edi, [ebx+12]   ; �]����
        call    memcpy
skip:
        mov     esp, [ebx+12]   ; �X�^�b�N�����l
        jmp     dword 2*8:0x0000001b

waitkbdout:
        in      al, 0x64
        and     al, 0x02
        jnz     waitkbdout      ; AND�̌��ʂ�0�łȂ����waitkbdout��
        ret

memcpy:
        mov     eax, [esi]
        add     esi, 4
        mov     [edi], eax
        add     edi, 4
        sub     ecx, 1
        jnz     memcpy          ; �����Z�������ʂ�0�łȂ����memcpy��
        ret
; memcpy�̓A�h���X�T�C�Y�v���t�B�b�N�X�����Y��Ȃ���΁A�X�g�����O���߂ł�������
        alignb 16
GDT0:
        resb    8               ; �k���Z���N�^
        dw      0xffff, 0x0000, 0x9200, 0x00cf  ; �ǂݏ����\�Z�O�����g32bit
        dw      0xffff, 0x0000, 0x9a28, 0x0047  ; ���s�\�Z�O�����g32bit�ibootpack�p�j

        dw      0
GDTR0:
        dw      8*3-1
        dd      GDT0

        alignb  16
bootpack:
