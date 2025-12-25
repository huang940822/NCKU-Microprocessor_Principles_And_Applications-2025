#include <xc.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h> // for isprint
#include <stdbool.h>

// CONFIG1H
#pragma config OSC = INTIO67
#pragma config FCMEN = OFF
#pragma config IESO = OFF
// CONFIG2L
#pragma config PWRT = OFF
#pragma config BOREN = SBORDIS
#pragma config BORV = 3
// CONFIG2H
#pragma config WDT = OFF
#pragma config WDTPS = 1
// CONFIG3H
#pragma config CCP2MX = PORTC
#pragma config PBADEN = ON
#pragma config LPT1OSC = OFF
#pragma config MCLRE = ON
// CONFIG4L
#pragma config STVREN = ON
#pragma config LVP = OFF
#pragma config XINST = OFF
// CONFIG5L - CONFIG7H
#pragma config CP0 = OFF, CP1 = OFF, CP2 = OFF, CP3 = OFF
#pragma config CPB = OFF, CPD = OFF
#pragma config WRT0 = OFF, WRT1 = OFF, WRT2 = OFF, WRT3 = OFF
#pragma config WRTC = OFF, WRTB = OFF, WRTD = OFF
#pragma config EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTR3 = OFF
#pragma config EBTRB = OFF

#define _XTAL_FREQ 4000000
#define STR_MAX 100
#define VR_MAX ((1 << 10) - 1)

// ================= 全域變數 =================
char buffer[STR_MAX];
int buffer_size = 0;
bool btn_interr = false;
int last_output_val = -1; // 避免 UART 重複刷屏用

// ================= UART 函式 (保留 Template) =================

void putch(char data) {
    if (data == '\n' || data == '\r') {
        while (!TXSTAbits.TRMT);
        TXREG = '\r';
        while (!TXSTAbits.TRMT);
        TXREG = '\n';
    } else {
        while (!TXSTAbits.TRMT);
        TXREG = data;
    }
}

void ClearBuffer() {
    for (int i = 0; i < STR_MAX; i++)
        buffer[i] = '\0';
    buffer_size = 0;
}

// Template 版本：使用 isprint
void MyusartRead() {
    char data = RCREG;
    if (!isprint(data) && data != '\r') return;
    buffer[buffer_size++] = data;
    putch(data);
}

int GetString(char *str) {
    if (buffer_size > 0 && buffer[buffer_size - 1] == '\r') {
        buffer[buffer_size - 1] = '\0';
        strcpy(str, buffer);
        ClearBuffer();
        return 1;
    } else {
        str[0] = '\0';
        return 0;
    }
}

// ================= OOP / Helper Functions (全部保留) =================

int get_LED() {
    // 這裡回傳 LATD 的高四位狀態
    return (LATD >> 4);
}

// [修改重點]：修改此函式以符合 RD7-RD4 的需求
void set_LED(int value) {
    // value: 4 ~ 15
    // 我們要將這個值顯示在 RD7 ~ RD4
    // 1. 清除高四位 (保留低四位，假設可能有其他用途)
    LATD &= 0x0F;
    // 2. 將數值移位到高四位並寫入
    LATD |= ((value & 0x0F) << 4);
}

// 保留未使用的函式
void set_LED_separately(int a, int b, int c, int d) {
    // 僅作範例保留
    LATD = (a << 7) + (b << 6) + (c << 5) + (d << 4);
}

void set_LED_analog(int value) {
    CCPR2L = (value >> 2);
    CCP2CONbits.DC2B = (value & 0b11);
}

int current_servo_angle = 0;
int get_servo_angle() {
    return current_servo_angle;
}

int set_servo_angle(int angle) {
    // 保留原本的 Servo 邏輯
    int current = (CCPR1L << 2) + CCP1CONbits.DC1B;
    int target = (int)((500 + (double)(angle + 90) / 180 * (2400 - 500)) / 8 / 4) * 8; 
    btn_interr = false;
    while (current != target) {
        if (btn_interr) return -1;
        if (current < target) current++;
        else current--;
        CCPR1L = (current >> 2);
        CCP1CONbits.DC1B = (current & 0b11);
        __delay_ms(1);
    }
    current_servo_angle = angle;
    return 0;
}

int VR_value_to_servo_angle(int value) {
    return (int)(((double)value / VR_MAX * 180) - 90);
}

int VR_value_to_LED_analog(int value) {
    return value;
}

int delay(double sec) {
    btn_interr = false;
    for (int i = 0; i < sec * 1000 / 10; i++) {
        if (btn_interr) return -1;
        __delay_ms(10);
    }
    return 0;
}

void button_pressed() {
    // 保留空函式
}

// ================= 題目邏輯核心 =================

// 這會在 ISR 中被呼叫
void variable_register_changed(int value) { // value: 0 ~ 1023
    int out;

    // 1. Boundary Mapping
    if      (value < 85)  out = 4;
    else if (value < 170) out = 5;
    else if (value < 256) out = 6;
    else if (value < 341) out = 7;
    else if (value < 426) out = 8;
    else if (value < 512) out = 9;
    else if (value < 597) out = 10;
    else if (value < 682) out = 11;
    else if (value < 767) out = 12;
    else if (value < 852) out = 13;
    else if (value < 938) out = 14;
    else                  out = 15;

    // 2. 更新邏輯 (In-Place Update)
    if (out != last_output_val) {
        last_output_val = out;

        // [使用 template 函式] 更新 LED
        set_LED(out);

        // UART 更新 (Backspace trick + printf)
        // \b\b\b\b 清除舊字元 (假設最多 4 位數)
        // 4 個空白蓋掉
        // 再 \b\b\b\b 回到原位
        printf("\b\b\b\b    \b\b\b\b"); 
        
        // 印出新數值
        printf("%d", out);
    }
}

void keyboard_input(char *str) { 
    // 保留空函式
}

// ================= ISR =================

void __interrupt(high_priority) H_ISR() {
    // 1. ADC Interrupt
    if (PIR1bits.ADIF) { 
        int value = (ADRESH << 8) + ADRESL;
        variable_register_changed(value);
        PIR1bits.ADIF = 0;
        // Template 原本有的 delay，保留可增加穩定性
        __delay_ms(5); 
    }

    // 2. Button Interrupt (保留)
    if (INTCONbits.INT0IF) { 
        button_pressed();
        __delay_ms(50); 
        btn_interr = true;
        INTCONbits.INT0IF = 0;
    }
}

void __interrupt(low_priority) Lo_ISR(void) {
    // UART RX Interrupt (Template 放在 Low Priority)
    if (PIR1bits.RCIF) {
        if (RCSTAbits.OERR) {
            RCSTAbits.CREN = 0; Nop(); RCSTAbits.CREN = 1;
        }
        MyusartRead();
    }
}

// ================= Initialization =================

void Initialize(void) {
    OSCCONbits.IRCF = 0b110; // 4 MHz
    
    // ADC Config
    TRISAbits.RA0 = 1;      
    ADCON1bits.PCFG = 0b1110; // AN0 Analog
    ADCON0bits.CHS = 0b0000; 
    ADCON1bits.VCFG0 = 0;   
    ADCON1bits.VCFG1 = 0;   
    ADCON2bits.ADCS = 0b001; 
    ADCON2bits.ACQT = 0b010; 
    ADCON2bits.ADFM = 1;    
    ADCON0bits.ADON = 1;    

    // LED I/O Config (RD7-RD4)
    TRISD &= 0x0F; // RD7-RD4 Output
    LATD &= 0x0F;  // Clear

    // UART Config
    TRISCbits.TRISC6 = 1;
    TRISCbits.TRISC7 = 1;
    TXSTAbits.SYNC = 0;
    BAUDCONbits.BRG16 = 0;
    TXSTAbits.BRGH = 0;
    SPBRG = 51; // 1200 baud
    RCSTAbits.SPEN = 1;
    TXSTAbits.TXEN = 1;
    RCSTAbits.CREN = 1;

    // Interrupt Config
    INTCONbits.INT0IF = 0;
    INTCONbits.INT0IE = 1; // Button enable
    
    PIR1bits.ADIF = 0;
    PIE1bits.ADIE = 1;     // ADC enable
    IPR1bits.ADIP = 1;     // ADC High Priority

    PIE1bits.RCIE = 1;     // RX enable
    IPR1bits.RCIP = 0;     // RX Low Priority (依照 Template 預設)

    RCONbits.IPEN = 1;
    INTCONbits.GIEH = 1;
    INTCONbits.GIEL = 1;

    ADCON0bits.GO = 1;
}

// ================= Main =================

void main() {
    Initialize();

    char str[STR_MAX];

    while (1) {
        // Handle UART Input (即使本題不需鍵盤輸入，仍保留結構)
        if (GetString(str)) keyboard_input(str);
        
        // Auto-restart ADC
        if (ADCON0bits.GO == 0) {
            __delay_ms(10); // 簡單控制採樣率
            ADCON0bits.GO = 1;
        }
    }
}
