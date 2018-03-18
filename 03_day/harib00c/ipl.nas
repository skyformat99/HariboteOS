; haribote-ipl

        org     0x7c00      ; このプログラムがどこに読み込まれるのか

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述
        jmp     entry
        db      0x90
        db      "HARIBOTE"      ; ブートセクタの名前（8バイト）
        dw      512             ; 1セクタの大きさ（512）
        db      1               ; クラスタの大きさ（1セクタ）
        dw      1               ; FATがどこから始まるか（ふつうは1セクタ目）
        db      2               ; FATの個数（2にしなければいけない）
        dw      224             ; ルートディレクトリ領域の大きさ（普通は224エントリ）
        dw      2880            ; このドライブの大きさ（2880セクタにしなければいけない）
        db      0xf0            ; メディアのタイプ（0xf0にしなければいけない）
        dw      9               ; FAT領域の長さ（9セクタにしなければいけない）
        dw      18              ; 1トラックにいくつのセクタがあるか（18にしなければいけない）
        dw      2               ; ヘッドの数（2にしなければいけない）
        dd      0               ; パーティションを使ってないのでここは0
        dd      2880            ; このドライブの大きさをもう一度書く
        db      0,0,0x29        ; よくわからないけどこの値にしておくといい
        dd      0xffffffff      ; たぶんボリュームシリアル番号
        db      "HARIBOTEOS "   ; ディスクの名前（11バイト）
        db      "FAT12   "      ; フォーマットの名前（8バイト）
        resb    18              ; とりあえず18バイトあけておく

; プログラム本体
entry:
        mov     ax, 0           ; レジスタ初期化
        mov     ss, ax
        mov     sp, 0x7c00
        mov     ds, ax

; ディスクを読む
        mov     ax, 0x0820
        mov     es, ax
        mov     ch, 0           ; シリンダ0
        mov     dh, 0           ; ヘッド0
        mov     cl, 2           ; セクタ2
readloop:
        mov     si, 0           ; 失敗回数を数えるレジスタ
retry:
        mov     ah, 0x02        ; AH=0x02 : ディスク読み込み
        mov     al, 1           ; 1セクタ
        mov     bx, 0
        mov     dl, 0x00        ;　Aドライブ
        int     0x13            ; ディスクBISO呼び出し
        jnc     fin             ; エラーが起きなければfinへ
        add     si, 1           ; SIに1を足す
        cmp     si, 5           ; SIを5と比較
        jae     error           ; SI >= 5 だったらerrorへ
        mov     ah, 0x00
        mov     dl, 0x00        ; Aドライブ
        int     0x13            ; ドライブのリセット
        jc      error
next:
        mov     ax, es          ; アドレスを0x200進める
        add     ax, 0x0020
        mov     es, ax          ; ADD ES, 0x200 という命令がないのでこうする
        add     cl, 1           ; CLに1を足す
        cmp     cl, 18          ; CLと18を比較
        jbe     readloop        ; CL <= 18 だったらreadloopへ
fin:
        hlt                     ; 何かあるまでCPUを停止
        jmp     fin             ; 無限ループ

error:
        mov     si, msg
putloop:
        mov     al, [si]
        add     si, 1           ; SIに1を足す
        cmp     al, 0
        je      fin
        mov     ah, 0x0e        ; 一文字表示ファンクション
        mov     bx, 15        ; カラーコード
        int     0x10            ; ビデオBIOS呼び出し
        jmp     putloop
msg:
        db      0x0a, 0x0a      ; 改行x2
        db      "load error"
        db      0x0a            ; 改行
        db      0

        resb    0x7dfe-$        ; 0x7dfeまでを0x00で埋める命令

        db      0x55, 0xaa