#include "xc.inc"

GLOBAL  _is_prime

PSECT mytext, local, class=CODE, reloc=2
_is_prime:
    ; 將輸入 n 從 0x001 複製到暫存器 0x20
    MOVFF 0x001, WREG       ; W = n
    MOVWF 0x20              ; n -> 0x20

    ; 判斷 n 是否為 0
    MOVF 0x20, W
    BZ not_prime

    ; 判斷 n 是否為 1
    MOVF 0x20, W
    XORLW 0x01
    BZ not_prime

    ; 判斷 n 是否為 2
    MOVF 0x20, W
    XORLW 0x02
    BZ prime

    ; 初始化除數 i = 2
    MOVLW 0x02
    MOVWF 0x21              ; i -> 0x21

check_loop:
    ; 若 i >= n → 結束，為質數
    MOVF 0x21, W
    CPFSGT 0x20              ; skip if n > i
    BRA prime

    ; 準備除法檢查 n % i
    MOVFF 0x20, 0x22         ; temp_n = n

div_loop:
    ; 若 temp_n < i → 跳出除法
    MOVF 0x21, W
    CPFSLT 0x22
    BRA div_continue
    BRA div_end

div_continue:
    ; temp_n -= i
    MOVF 0x21, W
    SUBWF 0x22, F
    BRA div_loop

div_end:
    ; 若 temp_n == 0 → 可整除，非質數
    MOVF 0x22, W
    BZ not_prime

    ; i++
    INCF 0x21, F
    BRA check_loop

prime:
    MOVLW 0x01
    MOVWF 0x001
    RETURN

not_prime:
    MOVLW 0xFF
    MOVWF 0x001
    RETURN
