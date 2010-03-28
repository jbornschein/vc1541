
#include <stdio.h>
#include <stdint.h>


int main(int argc, char * argv[]){
	if(argc != 3){
			fprintf(stderr,"usage: rom2vhdl file.bin <entity_name>\n");
		   	return(-1);
	}

	FILE * fp;

	fp = fopen(argv[1], "r");
	if(!fp){
			perror("cant open file");
		   	return (-1);
	}

	fseek(fp, 0, SEEK_END);
	uint32_t size,tmp;
	size= ftell(fp);
	uint32_t bits = 0;

	tmp = size;
	while((tmp>>=1)){
		bits++;	
	}
	bits--;

	fseek(fp, 0, SEEK_SET);
	
	printf("\nlibrary ieee;\n");
	printf("use ieee.std_logic_1164.all;\n\n");
	printf("use ieee.numeric_std.all;\n\n");
	printf("entity %s is\n",argv[2]);
	printf("port (addr	:in std_logic_vector (%d downto 0);\n",bits);
	printf("        data  :out std_logic_vector (7 downto 0); \n"
		   "		clk  : in std_logic		);\n" );
	printf("end %s;\n\n\n",argv[2]);
	printf("architecture rtl of %s is\n",argv[2]);
	printf("\ttype rom_array is array (0 to %d) of std_logic_vector(7 downto 0);\n"
		"constant ROM : ROM_ARRAY := (\n\t\t",size-1);
	
	unsigned int addr = 0;
	
	while(1){
		unsigned char data;
		data = fgetc(fp);
		if(feof(fp)) break;
		if(addr != 0) printf(",");
		printf("x\"%02X\"" ,data);
		addr++;	
		if((addr % 8)==0){
			printf("\n\t\t");
		}
	}
	
	printf("\t);\n"
		"begin\n"
		"\tp_rom : process(clk, addr)\n"
		"\tbegin\n"
		"\tif clk'event and clk = '0' then\n"
		"\t\tdata <= ROM(to_integer(unsigned(addr)));\n"
		"\tend if;\n"
		"\tend process;\n"
		"end rtl;\n");
	return(0);
}

