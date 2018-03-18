; naskfunc

[FORMAT "WCOFF"]                ; オブジェクトファイルを作るモード
[INSTRSET "i486p"]              ; 486の命令まで使いたいという記述
[BITS 32]                       ; 32ビットモード用の機械語を作らせる
[FILE "naskfunc.nas"]           ; ソースファイル名情報

        global  _io_hlt, _write_mem8

[SECTION .text]

_io_hlt:    ; void io_hlt(void);
        hlt
        ret

_write_mem8:    ; void write_mem8(int addr, int data);
        mov     ecx, [esp+4]    ; [ESP+4]にaddrが入っているのでそれをECXに読み込む
        mov     al, [esp+8]     ; [ESP+8]にdataが入っているのでそれをALに読み込む
        mov     [ecx], al
        ret