#ifndef CONFIG_H
#define CONFIG_H

//#define BAUDRATE 19200l
#define BAUDRATE 57600l

#define F_CPU 32000000l

#define IO_BASE_ADDR 0xB000

#define PAR_I_A0 (*((uint8_t *)(IO_BASE_ADDR+0x200)))
#define PAR_I_A1 (*((uint8_t *)(IO_BASE_ADDR+0x201)))
#define PAR_I_A2 (*((uint8_t *)(IO_BASE_ADDR+0x202)))
#define PAR_I_A3 (*((uint8_t *)(IO_BASE_ADDR+0x203)))

#define BUTTON_I PAR_I_A2
#define SWITCH_I PAR_I_A3

#define PAR_I_B0 (*((uint8_t *)(IO_BASE_ADDR+0x208)))
#define PAR_I_B1 (*((uint8_t *)(IO_BASE_ADDR+0x209)))
#define PAR_I_B2 (*((uint8_t *)(IO_BASE_ADDR+0x20A)))
#define PAR_I_B3 (*((uint8_t *)(IO_BASE_ADDR+0x20B)))


#define PAR_O_A0 (*((uint8_t *)(IO_BASE_ADDR+0x204)))
#define PAR_O_A1 (*((uint8_t *)(IO_BASE_ADDR+0x205)))
#define PAR_O_A2 (*((uint8_t *)(IO_BASE_ADDR+0x206)))
#define PAR_O_A3 (*((uint8_t *)(IO_BASE_ADDR+0x207)))

#define RESET_O PAR_O_A1
#define WPE_O PAR_O_A2

#define DISP_C   (*((uint8_t *)(IO_BASE_ADDR+0x210)))
#define DISP_D   (*((uint8_t *)(IO_BASE_ADDR+0x211)))
#define DISP_D_DDR (*((uint8_t *)(IO_BASE_ADDR+0x212)))

#define SPI_DATA (*((uint8_t *)(IO_BASE_ADDR+0x500)))
#define SPI_CTRL (*((uint8_t *)(IO_BASE_ADDR+0x501)))
#define SPI_PORT (*((uint8_t *)(IO_BASE_ADDR+0x502)))
#define SPI_DIVIDE (*((uint8_t *)(IO_BASE_ADDR+0x504)))

#define REG_UART_DATA (*((uint8_t *)(IO_BASE_ADDR+0x100)))
#define REG_UART_FLAG (*((uint8_t *)(IO_BASE_ADDR+0x102)))
#define REG_UART_BAUD (*((uint16_t *)(IO_BASE_ADDR+0x104)))

#define BIT_DATA_AVAIL 0x01
#define BIT_TRANSMIT   0x02

#define GCR_REG ((uint8_t *)(IO_BASE_ADDR+0x300))


#define PAGE_REG (*((uint16_t *)(IO_BASE_ADDR+0xE00)))
#define PAGE_DATA ((uint8_t *)(IO_BASE_ADDR+0xF00))

#define D_BPX0 (*((uint16_t *)(IO_BASE_ADDR+0x400)))
#define D_B_ENABLE (*((uint8_t *)(IO_BASE_ADDR+0x410)))
#define D_B_FLAG (*((uint8_t *)(IO_BASE_ADDR+0x411)))
#define D_A (*((uint8_t *)(IO_BASE_ADDR+0x420)))
#define D_X (*((uint8_t *)(IO_BASE_ADDR+0x421)))
#define D_Y (*((uint8_t *)(IO_BASE_ADDR+0x422)))
#define D_P (*((uint8_t *)(IO_BASE_ADDR+0x423)))

#define LOG_ADDR (*((uint16_t *)(IO_BASE_ADDR+0x430)))


#define print uart_putstr
#define putc uart_putc
#define getc uart_getc


#endif
