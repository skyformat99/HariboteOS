; haribote-os

        org     0xc200          ; このプログラムがどこに読み込まれるのか

        mov     al, 0x13        ; VGAグラフィックス、320x200x8bitカラー
        mov     ah, 0x00
        int     0x10
fin:
        hlt
        jmp     fin