; haribote-os boot asm

BOTPAK  equ     0x00280000      ; bootpackのロード先
DSKCAC  equ     0x00100000      ; ディスクキャッシュの場所
DSKCAC0 equ     0x00008000      ; ディスクキャッシュの場所（リアルモード）

; BOOT_INFO関係
CYLS    equ     0x0ff0          ; ブートセクタが設定する
LEDS    equ     0x0ff1
VMODE   equ     0x0ff2          ; 色数に関する情報。何ビットカラーか?
SCRNX   equ     0x0ff4          ; 解像度のX
SCRNY   equ     0x0ff6          ; 解像度のY
VRAM    equ     0x0ff8          ; グラフィックバッファの開始番地

        org     0xc200          ; このプログラムがどこに読み込まれるのか

; 画面モードを設定
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

; PICが一切の割り込みを受け付けないようにする
; AT互換機の使用では、PICの初期化をするなら、
; こいつをCLI前にやっておかないと、たまにハングアップする
; PICの初期化はあとでやる
        mov     al, 0xff
        out     0x21, al
        nop                     ; OUT命令を連続させるとうまくいかない機種があるらしいので
        out     0xa1, al

        cli                     ; さらにCPUレベルでも割り込み禁止

; CPUから1MB以上のメモリにアクセスできるように、A20GATEを設定
        call    waitkbdout
        mov     al, 0xd1
        out     0x64, al
        call    waitkbdout
        mov     al, 0xdf        ; enable A20
        out     0x60, al
        call    waitkbdout

; プロテクトモード移行
[INSTRSET "i486p"]              ; 486の命令まで使いたいという記述

        lgdt    [GDTR0]         ; 暫定のGDTを設定
        mov     eax, cr0
        and     eax, 0x7fffffff ; bit31を0にする（ページング禁止のため）
        or      eax, 0x00000001 ; bit0を1にする（プロテクトモード移行のため）
        mov     cr0, eax
        jmp     pipelineflush
pipelineflush:
        mov     ax, 1*8         ; 読み書き可能セグメント32bit
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
        mov     ss, ax

; bootpackの転送
        mov     esi, bootpack   ; 転送元
        mov     edi, BOTPAK     ; 転送先
        mov     ecx, 512*1024/4
        call    memcpy

; ついでにディスクデータも本来の位置へ転送

; まずはブートセクタから
        mov     esi, 0x7c00     ; 転送元
        mov     edi, DSKCAC     ; 転送先
        mov     ecx, 512/4
        call    memcpy

; 残り全部
        mov     esi, DSKCAC0+512        ; 転送元
        mov     edi, DSKCAC+512         ; 転送先
        mov     ecx, 0
        mov     cl, byte [CYLS]
        imul    ecx, 512*18*2/4         ; シリンダ数からバイト数/4に変換
        sub     ecx, 512/4              ; IPLの分だけ差し引く
        call    memcpy

; asmheadでしなければいけないことは全部し終わったので、
; あとはbootpackに任せる

; bootpackの起動
        mov     ebx, BOTPAK
        mov     ecx, [ebx+16]
        add     ecx, 3          ; ECX += 3;
        shr     ecx, 2          ; ECX /= 4;
        jz      skip            ; 転送するべきものがない
        mov     esi, [ebx+20]   ; 転送元
        add     esi, ebx
        mov     edi, [ebx+12]   ; 転送先
        call    memcpy
skip:
        mov     esp, [ebx+12]   ; スタック初期値
        jmp     dword 2*8:0x0000001b

waitkbdout:
        in      al, 0x64
        and     al, 0x02
        jnz     waitkbdout      ; ANDの結果が0でなければwaitkbdoutへ
        ret

memcpy:
        mov     eax, [esi]
        add     esi, 4
        mov     [edi], eax
        add     edi, 4
        sub     ecx, 1
        jnz     memcpy          ; 引き算した結果が0でなければmemcpyへ
        ret
; memcpyはアドレスサイズプリフィックスを入れ忘れなければ、ストリング命令でも書ける
        alignb 16
GDT0:
        resb    8               ; ヌルセレクタ
        dw      0xffff, 0x0000, 0x9200, 0x00cf  ; 読み書き可能セグメント32bit
        dw      0xffff, 0x0000, 0x9a28, 0x0047  ; 実行可能セグメント32bit（bootpack用）

        dw      0
GDTR0:
        dw      8*3-1
        dd      GDT0

        alignb  16
bootpack:
