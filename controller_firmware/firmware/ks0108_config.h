
/*Pinout von HQM1286404 Display:
1		Vcc
2		GND
3		Vee (mittelabgriff von 20k Poti) - es wird anscheinend kein Kondensator gebraucht.
4-11	DB0-DB7
12		CS0
13		CS1
14		RESET
15		R/W		READ=1
16		D/I
17		EN
18		Vee out - über nen 20k Poti nach Masse auf Pin3
19		LED Anode		80mA/4,0V
20		LED Kathode
*/

// Ports
#define PORT_CMD		DISP_C		// Command Output Register
#define DDR_CMD			void		// Data Direction Register for Command Port

#define PIN_DATA		DISP_D		// Data Input Register
#define PORT_DATA		DISP_D		// Data Output Register
#define DDR_DATA		DISP_D_DDR		// Data Direction Register for Data Port

// Command Port Bits
#define CSEL0				0x00		// CS0 Bit Number
#define CSEL1				0x01		// CS1 Bit Number
#define RESET				0x02
#define R_W					0x03		// R/W Bit Number
#define D_I					0x04		// D/I Bit Number
#define EN					0x05		// EN Bit Number
