; haribote-os

; BOOT_INFO関係
CYLS    equ     0x0ff0          ; ブートセクタが設定する
LEDS    equ     0x0ff1
VMODE   equ     0x0ff2          ; 色数に関する情報。何ビットカラーか?
SCRNX   equ     0x0ff4          ; 解像度のX
SCRNY   equ     0x0ff6          ; 解像度のY
VRAM    equ     0x0ff8          ; グラフィックバッファの開始番地

        org     0xc200          ; このプログラムがどこに読み込まれるのか

        mov     al, 0x13        ; VGAグラフィックス、320x200x8bitカラー
        mov     ah, 0x00
        int     0x10
        mov     byte [VMODE], 8 ; 画面モードをメモする
        mov     word [SCRNX], 320
        mov     word [SCRNY], 200
        mov     dword [VRAM], 0x000a0000

; キーボードのLED状態をBIOSに教えてもらう
        mov     ah, 0x02
        int     0x16            ; keyboard BIOS
        mov     [LEDS], al

fin:
        hlt
        jmp     fin