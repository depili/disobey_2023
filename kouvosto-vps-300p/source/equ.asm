SIO_CMD_NULL		EQU	0x00
SIO_CMD_TX_ABORT	EQU	0x08
SIO_CMD_RST_STATUS	EQU	0x10
SIO_CMD_CH_RESET	EQU	0x18
SIO_CMD_EI_RX		EQU	0x20
SIO_CMD_TX_IR_RST	EQU	0x28
SIO_CMD_ERROR_RST	EQU	0x30
SIO_CMD_RETI		EQU	0x38
; IO PORTS
CTC_CH1			EQU	0x10
CTC_CH2			EQU	0x11
CTC_CH3			EQU	0x12
CTC_CH4			EQU	0x13
SIO_A_DATA		EQU	0x18
SIO_A_CMD		EQU	0x19
SIO_B_DATA		EQU	0x1A
SIO_B_CMD		EQU	0x1B
PIO_A_DATA		EQU	0x1C
PIO_A_CMD		EQU	0x1D
PIO_B_DATA		EQU	0x1E
PIO_B_CMD		EQU	0x1F

; Memory
MAIN_COUNTER		EQU	0x8010
; Serial receive
RX_COUNTER		EQU	0x9000
RX_POINTER		EQU	0x9002  ; Write pointer
RX_READ			EQU	0x9004  ; Read pointer
RX_TYPE			EQU	0x9006  ; first byte of the message
RX_MAX_BYTES		EQU	0xFF - 0x06
; LCD
LCD_FLAG		EQU	0xE800
LCD_SRC			EQU	0xE801  ; Source for LCD data in shared memory
LCD_DEST		EQU	0xA000  ; Local memory copy destination for lcd data
LCD_BYTES		EQU	0xA0    ; 40 bytes per line, 4 lines = 160 = 0xA0 bytes
LCD_POINTER		EQU	0x8100  ; Pointer for writing bytes to the LCD_DEST buffer
LCD_WRITE_DEST		EQU	LCD_DEST
; Lamps
LAMP_SRC		EQU	0xEA00  ; Source for lamp data in shared memory
LAMP_DEST		EQU	0x9500  ; Local memory destination for lamp data
LAMP_BYTES		EQU	0x1B    ; 27 bytes for lamp data
