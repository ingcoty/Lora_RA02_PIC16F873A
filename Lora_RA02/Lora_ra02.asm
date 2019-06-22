
_lora_reset:

;Lora_ra02.c,58 :: 		void lora_reset(){
;Lora_ra02.c,59 :: 		reset = 0;
	BCF        PORTC+0, 2
;Lora_ra02.c,60 :: 		Delay_ms(1);
	MOVLW      2
	MOVWF      R12+0
	MOVLW      75
	MOVWF      R13+0
L_lora_reset0:
	DECFSZ     R13+0, 1
	GOTO       L_lora_reset0
	DECFSZ     R12+0, 1
	GOTO       L_lora_reset0
;Lora_ra02.c,61 :: 		reset = 1;
	BSF        PORTC+0, 2
;Lora_ra02.c,62 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_lora_reset1:
	DECFSZ     R13+0, 1
	GOTO       L_lora_reset1
	DECFSZ     R12+0, 1
	GOTO       L_lora_reset1
	NOP
	NOP
;Lora_ra02.c,63 :: 		}
L_end_lora_reset:
	RETURN
; end of _lora_reset

_lora_read_reg:

;Lora_ra02.c,65 :: 		unsigned char lora_read_reg(unsigned char reg){
;Lora_ra02.c,66 :: 		int dato =  0;
	CLRF       lora_read_reg_dato_L0+0
	CLRF       lora_read_reg_dato_L0+1
;Lora_ra02.c,67 :: 		cs = 0;
	BCF        PORTB+0, 0
;Lora_ra02.c,68 :: 		SPI1_Read(reg);
	MOVF       FARG_lora_read_reg_reg+0, 0
	MOVWF      FARG_SPI1_Read_buffer+0
	CALL       _SPI1_Read+0
;Lora_ra02.c,69 :: 		dato = SPI1_Read(0xFF);
	MOVLW      255
	MOVWF      FARG_SPI1_Read_buffer+0
	CALL       _SPI1_Read+0
	MOVF       R0+0, 0
	MOVWF      lora_read_reg_dato_L0+0
	CLRF       lora_read_reg_dato_L0+1
;Lora_ra02.c,70 :: 		cs = 1;
	BSF        PORTB+0, 0
;Lora_ra02.c,71 :: 		return(dato);
	MOVF       lora_read_reg_dato_L0+0, 0
	MOVWF      R0+0
;Lora_ra02.c,72 :: 		}
L_end_lora_read_reg:
	RETURN
; end of _lora_read_reg

_lora_write_reg:

;Lora_ra02.c,74 :: 		void lora_write_reg(unsigned char reg, unsigned char val){
;Lora_ra02.c,75 :: 		unsigned char out[2] = {0};
	CLRF       lora_write_reg_out_L0+0
	CLRF       lora_write_reg_out_L0+1
	CLRF       lora_write_reg_i_L0+0
;Lora_ra02.c,77 :: 		out[0] = (0x80|reg);
	MOVLW      128
	IORWF      FARG_lora_write_reg_reg+0, 0
	MOVWF      lora_write_reg_out_L0+0
;Lora_ra02.c,78 :: 		out[1] = val;
	MOVF       FARG_lora_write_reg_val+0, 0
	MOVWF      lora_write_reg_out_L0+1
;Lora_ra02.c,79 :: 		cs = 0;
	BCF        PORTB+0, 0
;Lora_ra02.c,80 :: 		for(i=0; i<2; i++){
	CLRF       lora_write_reg_i_L0+0
L_lora_write_reg2:
	MOVLW      2
	SUBWF      lora_write_reg_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_lora_write_reg3
;Lora_ra02.c,81 :: 		SPI1_Write(out[i]);
	MOVF       lora_write_reg_i_L0+0, 0
	ADDLW      lora_write_reg_out_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_SPI1_Write_data_+0
	CALL       _SPI1_Write+0
;Lora_ra02.c,80 :: 		for(i=0; i<2; i++){
	INCF       lora_write_reg_i_L0+0, 1
;Lora_ra02.c,82 :: 		}
	GOTO       L_lora_write_reg2
L_lora_write_reg3:
;Lora_ra02.c,83 :: 		cs = 1;
	BSF        PORTB+0, 0
;Lora_ra02.c,84 :: 		}
L_end_lora_write_reg:
	RETURN
; end of _lora_write_reg

_lora_idle:

;Lora_ra02.c,86 :: 		void lora_idle(void)
;Lora_ra02.c,88 :: 		lora_write_reg(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_STDBY);
	MOVLW      1
	MOVWF      FARG_lora_write_reg_reg+0
	MOVLW      129
	MOVWF      FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,89 :: 		}
L_end_lora_idle:
	RETURN
; end of _lora_idle

_printf:

;Lora_ra02.c,91 :: 		void printf(char num){
;Lora_ra02.c,92 :: 		char buff[5] = {0};
	CLRF       printf_buff_L0+0
	CLRF       printf_buff_L0+1
	CLRF       printf_buff_L0+2
	CLRF       printf_buff_L0+3
	CLRF       printf_buff_L0+4
;Lora_ra02.c,93 :: 		ByteToStr(num, buff);
	MOVF       FARG_printf_num+0, 0
	MOVWF      FARG_ByteToStr_input+0
	MOVLW      printf_buff_L0+0
	MOVWF      FARG_ByteToStr_output+0
	CALL       _ByteToStr+0
;Lora_ra02.c,94 :: 		UART1_Write_Text(buff);
	MOVLW      printf_buff_L0+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Lora_ra02.c,95 :: 		UART1_Write_Text("\r\n");
	MOVLW      ?lstr1_Lora_ra02+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Lora_ra02.c,96 :: 		}
L_end_printf:
	RETURN
; end of _printf

_lora_send_packet:

;Lora_ra02.c,98 :: 		void lora_send_packet(unsigned char *buf, int size)
;Lora_ra02.c,99 :: 		{   int i = 0;
	CLRF       lora_send_packet_i_L0+0
	CLRF       lora_send_packet_i_L0+1
;Lora_ra02.c,103 :: 		lora_idle();
	CALL       _lora_idle+0
;Lora_ra02.c,104 :: 		lora_write_reg(REG_FIFO_ADDR_PTR, 0);
	MOVLW      13
	MOVWF      FARG_lora_write_reg_reg+0
	CLRF       FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,106 :: 		for(i=0; i<size; i++)
	CLRF       lora_send_packet_i_L0+0
	CLRF       lora_send_packet_i_L0+1
L_lora_send_packet5:
	MOVLW      128
	XORWF      lora_send_packet_i_L0+1, 0
	MOVWF      R0+0
	MOVLW      128
	XORWF      FARG_lora_send_packet_size+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__lora_send_packet34
	MOVF       FARG_lora_send_packet_size+0, 0
	SUBWF      lora_send_packet_i_L0+0, 0
L__lora_send_packet34:
	BTFSC      STATUS+0, 0
	GOTO       L_lora_send_packet6
;Lora_ra02.c,107 :: 		lora_write_reg(REG_FIFO, *buf++);
	CLRF       FARG_lora_write_reg_reg+0
	MOVF       FARG_lora_send_packet_buf+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
	INCF       FARG_lora_send_packet_buf+0, 1
;Lora_ra02.c,106 :: 		for(i=0; i<size; i++)
	INCF       lora_send_packet_i_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       lora_send_packet_i_L0+1, 1
;Lora_ra02.c,107 :: 		lora_write_reg(REG_FIFO, *buf++);
	GOTO       L_lora_send_packet5
L_lora_send_packet6:
;Lora_ra02.c,109 :: 		lora_write_reg(REG_PAYLOAD_LENGTH, size);
	MOVLW      34
	MOVWF      FARG_lora_write_reg_reg+0
	MOVF       FARG_lora_send_packet_size+0, 0
	MOVWF      FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,113 :: 		lora_write_reg(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_TX);
	MOVLW      1
	MOVWF      FARG_lora_write_reg_reg+0
	MOVLW      131
	MOVWF      FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,114 :: 		while((lora_read_reg(REG_IRQ_FLAGS) & IRQ_TX_DONE_MASK) == 0){
L_lora_send_packet8:
	MOVLW      18
	MOVWF      FARG_lora_read_reg_reg+0
	CALL       _lora_read_reg+0
	MOVLW      8
	ANDWF      R0+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_lora_send_packet9
;Lora_ra02.c,115 :: 		Delay_ms(100);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_lora_send_packet10:
	DECFSZ     R13+0, 1
	GOTO       L_lora_send_packet10
	DECFSZ     R12+0, 1
	GOTO       L_lora_send_packet10
	NOP
	NOP
;Lora_ra02.c,116 :: 		UART1_Write_Text("Enviando...\r\n");
	MOVLW      ?lstr2_Lora_ra02+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Lora_ra02.c,117 :: 		printf(lora_read_reg(REG_IRQ_FLAGS));
	MOVLW      18
	MOVWF      FARG_lora_read_reg_reg+0
	CALL       _lora_read_reg+0
	MOVF       R0+0, 0
	MOVWF      FARG_printf_num+0
	CALL       _printf+0
;Lora_ra02.c,118 :: 		}
	GOTO       L_lora_send_packet8
L_lora_send_packet9:
;Lora_ra02.c,120 :: 		UART1_Write_Text("OK\r\n");
	MOVLW      ?lstr3_Lora_ra02+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Lora_ra02.c,121 :: 		printf(lora_read_reg(REG_IRQ_FLAGS));
	MOVLW      18
	MOVWF      FARG_lora_read_reg_reg+0
	CALL       _lora_read_reg+0
	MOVF       R0+0, 0
	MOVWF      FARG_printf_num+0
	CALL       _printf+0
;Lora_ra02.c,122 :: 		lora_write_reg(REG_IRQ_FLAGS, IRQ_TX_DONE_MASK);
	MOVLW      18
	MOVWF      FARG_lora_write_reg_reg+0
	MOVLW      8
	MOVWF      FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,123 :: 		}
L_end_lora_send_packet:
	RETURN
; end of _lora_send_packet

_lora_enable_crc:

;Lora_ra02.c,125 :: 		void lora_enable_crc(void)
;Lora_ra02.c,127 :: 		lora_write_reg(REG_MODEM_CONFIG_2, lora_read_reg(REG_MODEM_CONFIG_2) | 0x04);
	MOVLW      30
	MOVWF      FARG_lora_read_reg_reg+0
	CALL       _lora_read_reg+0
	MOVLW      4
	IORWF      R0+0, 0
	MOVWF      FARG_lora_write_reg_val+0
	MOVLW      30
	MOVWF      FARG_lora_write_reg_reg+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,128 :: 		}
L_end_lora_enable_crc:
	RETURN
; end of _lora_enable_crc

_lora_set_frequency:

;Lora_ra02.c,130 :: 		void lora_set_frequency()
;Lora_ra02.c,132 :: 		lora_write_reg(REG_FRF_MSB, 108);
	MOVLW      6
	MOVWF      FARG_lora_write_reg_reg+0
	MOVLW      108
	MOVWF      FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,133 :: 		lora_write_reg(REG_FRF_MID, 64);
	MOVLW      7
	MOVWF      FARG_lora_write_reg_reg+0
	MOVLW      64
	MOVWF      FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,134 :: 		lora_write_reg(REG_FRF_LSB, 0);
	MOVLW      8
	MOVWF      FARG_lora_write_reg_reg+0
	CLRF       FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,135 :: 		}
L_end_lora_set_frequency:
	RETURN
; end of _lora_set_frequency

_lora_set_tx_power:

;Lora_ra02.c,138 :: 		void lora_set_tx_power(int level)
;Lora_ra02.c,140 :: 		if (level < 2) level = 2;
	MOVLW      128
	XORWF      FARG_lora_set_tx_power_level+1, 0
	MOVWF      R0+0
	MOVLW      128
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__lora_set_tx_power38
	MOVLW      2
	SUBWF      FARG_lora_set_tx_power_level+0, 0
L__lora_set_tx_power38:
	BTFSC      STATUS+0, 0
	GOTO       L_lora_set_tx_power11
	MOVLW      2
	MOVWF      FARG_lora_set_tx_power_level+0
	MOVLW      0
	MOVWF      FARG_lora_set_tx_power_level+1
	GOTO       L_lora_set_tx_power12
L_lora_set_tx_power11:
;Lora_ra02.c,141 :: 		else if (level > 17) level = 17;
	MOVLW      128
	MOVWF      R0+0
	MOVLW      128
	XORWF      FARG_lora_set_tx_power_level+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__lora_set_tx_power39
	MOVF       FARG_lora_set_tx_power_level+0, 0
	SUBLW      17
L__lora_set_tx_power39:
	BTFSC      STATUS+0, 0
	GOTO       L_lora_set_tx_power13
	MOVLW      17
	MOVWF      FARG_lora_set_tx_power_level+0
	MOVLW      0
	MOVWF      FARG_lora_set_tx_power_level+1
L_lora_set_tx_power13:
L_lora_set_tx_power12:
;Lora_ra02.c,142 :: 		lora_write_reg(REG_PA_CONFIG, PA_BOOST | (level - 2));
	MOVLW      9
	MOVWF      FARG_lora_write_reg_reg+0
	MOVLW      2
	SUBWF      FARG_lora_set_tx_power_level+0, 0
	MOVWF      R0+0
	MOVLW      128
	IORWF      R0+0, 0
	MOVWF      FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,143 :: 		}
L_end_lora_set_tx_power:
	RETURN
; end of _lora_set_tx_power

_lora_sleep:

;Lora_ra02.c,145 :: 		void lora_sleep(void)
;Lora_ra02.c,147 :: 		lora_write_reg(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_SLEEP);
	MOVLW      1
	MOVWF      FARG_lora_write_reg_reg+0
	MOVLW      128
	MOVWF      FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,148 :: 		}
L_end_lora_sleep:
	RETURN
; end of _lora_sleep

_lora_init:

;Lora_ra02.c,150 :: 		unsigned char lora_init(){
;Lora_ra02.c,151 :: 		unsigned char i = 0;
	CLRF       lora_init_i_L0+0
;Lora_ra02.c,153 :: 		SPI1_Init();
	CALL       _SPI1_Init+0
;Lora_ra02.c,154 :: 		TRISB.F0 = 0;
	BCF        TRISB+0, 0
;Lora_ra02.c,155 :: 		TRISC.F2 = 0;
	BCF        TRISC+0, 2
;Lora_ra02.c,156 :: 		cs = 1;
	BSF        PORTB+0, 0
;Lora_ra02.c,157 :: 		reset = 1;
	BSF        PORTC+0, 2
;Lora_ra02.c,158 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_lora_init14:
	DECFSZ     R13+0, 1
	GOTO       L_lora_init14
	DECFSZ     R12+0, 1
	GOTO       L_lora_init14
	NOP
	NOP
;Lora_ra02.c,159 :: 		lora_reset();
	CALL       _lora_reset+0
;Lora_ra02.c,160 :: 		for(i=0; i<100; i++){
	CLRF       lora_init_i_L0+0
L_lora_init15:
	MOVLW      100
	SUBWF      lora_init_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_lora_init16
;Lora_ra02.c,161 :: 		if(lora_read_reg(REG_VERSION) == 0x12){
	MOVLW      66
	MOVWF      FARG_lora_read_reg_reg+0
	CALL       _lora_read_reg+0
	MOVF       R0+0, 0
	XORLW      18
	BTFSS      STATUS+0, 2
	GOTO       L_lora_init18
;Lora_ra02.c,162 :: 		break;
	GOTO       L_lora_init16
;Lora_ra02.c,163 :: 		}
L_lora_init18:
;Lora_ra02.c,164 :: 		Delay_ms(2);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_lora_init19:
	DECFSZ     R13+0, 1
	GOTO       L_lora_init19
	DECFSZ     R12+0, 1
	GOTO       L_lora_init19
	NOP
	NOP
;Lora_ra02.c,160 :: 		for(i=0; i<100; i++){
	INCF       lora_init_i_L0+0, 1
;Lora_ra02.c,165 :: 		}
	GOTO       L_lora_init15
L_lora_init16:
;Lora_ra02.c,166 :: 		if(i==99)
	MOVF       lora_init_i_L0+0, 0
	XORLW      99
	BTFSS      STATUS+0, 2
	GOTO       L_lora_init20
;Lora_ra02.c,167 :: 		return(0);
	CLRF       R0+0
	GOTO       L_end_lora_init
L_lora_init20:
;Lora_ra02.c,168 :: 		lora_sleep();
	CALL       _lora_sleep+0
;Lora_ra02.c,169 :: 		lora_write_reg(REG_FIFO_RX_BASE_ADDR, 0);
	MOVLW      15
	MOVWF      FARG_lora_write_reg_reg+0
	CLRF       FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,170 :: 		lora_write_reg(REG_FIFO_TX_BASE_ADDR, 0);
	MOVLW      14
	MOVWF      FARG_lora_write_reg_reg+0
	CLRF       FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,171 :: 		lora_write_reg(REG_LNA, lora_read_reg(REG_LNA) | 0x03);
	MOVLW      12
	MOVWF      FARG_lora_read_reg_reg+0
	CALL       _lora_read_reg+0
	MOVLW      3
	IORWF      R0+0, 0
	MOVWF      FARG_lora_write_reg_val+0
	MOVLW      12
	MOVWF      FARG_lora_write_reg_reg+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,172 :: 		lora_write_reg(REG_MODEM_CONFIG_3, 0x04);
	MOVLW      38
	MOVWF      FARG_lora_write_reg_reg+0
	MOVLW      4
	MOVWF      FARG_lora_write_reg_val+0
	CALL       _lora_write_reg+0
;Lora_ra02.c,173 :: 		lora_set_tx_power(17);
	MOVLW      17
	MOVWF      FARG_lora_set_tx_power_level+0
	MOVLW      0
	MOVWF      FARG_lora_set_tx_power_level+1
	CALL       _lora_set_tx_power+0
;Lora_ra02.c,174 :: 		lora_idle();
	CALL       _lora_idle+0
;Lora_ra02.c,175 :: 		return(1);
	MOVLW      1
	MOVWF      R0+0
;Lora_ra02.c,176 :: 		}
L_end_lora_init:
	RETURN
; end of _lora_init

_main:

;Lora_ra02.c,178 :: 		void main() {
;Lora_ra02.c,179 :: 		unsigned char msg[30] = "Hola mundo";
	MOVLW      72
	MOVWF      main_msg_L0+0
	MOVLW      111
	MOVWF      main_msg_L0+1
	MOVLW      108
	MOVWF      main_msg_L0+2
	MOVLW      97
	MOVWF      main_msg_L0+3
	MOVLW      32
	MOVWF      main_msg_L0+4
	MOVLW      109
	MOVWF      main_msg_L0+5
	MOVLW      117
	MOVWF      main_msg_L0+6
	MOVLW      110
	MOVWF      main_msg_L0+7
	MOVLW      100
	MOVWF      main_msg_L0+8
	MOVLW      111
	MOVWF      main_msg_L0+9
	CLRF       main_msg_L0+10
	CLRF       main_msg_L0+11
	CLRF       main_msg_L0+12
	CLRF       main_msg_L0+13
	CLRF       main_msg_L0+14
	CLRF       main_msg_L0+15
	CLRF       main_msg_L0+16
	CLRF       main_msg_L0+17
	CLRF       main_msg_L0+18
	CLRF       main_msg_L0+19
	CLRF       main_msg_L0+20
	CLRF       main_msg_L0+21
	CLRF       main_msg_L0+22
	CLRF       main_msg_L0+23
	CLRF       main_msg_L0+24
	CLRF       main_msg_L0+25
	CLRF       main_msg_L0+26
	CLRF       main_msg_L0+27
	CLRF       main_msg_L0+28
	CLRF       main_msg_L0+29
;Lora_ra02.c,180 :: 		UART1_Init(9600);
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;Lora_ra02.c,181 :: 		while(1){
L_main21:
;Lora_ra02.c,182 :: 		if(lora_init()){
	CALL       _lora_init+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main23
;Lora_ra02.c,183 :: 		UART1_Write_Text("Lora Inicializado [OK]\r\n");
	MOVLW      ?lstr4_Lora_ra02+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Lora_ra02.c,184 :: 		lora_set_frequency();
	CALL       _lora_set_frequency+0
;Lora_ra02.c,185 :: 		lora_enable_crc();
	CALL       _lora_enable_crc+0
;Lora_ra02.c,186 :: 		while(1){
L_main24:
;Lora_ra02.c,187 :: 		Delay_ms(1000);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_main26:
	DECFSZ     R13+0, 1
	GOTO       L_main26
	DECFSZ     R12+0, 1
	GOTO       L_main26
	DECFSZ     R11+0, 1
	GOTO       L_main26
	NOP
	NOP
;Lora_ra02.c,188 :: 		lora_send_packet(msg, strlen(msg));
	MOVLW      main_msg_L0+0
	MOVWF      FARG_strlen_s+0
	CALL       _strlen+0
	MOVF       R0+0, 0
	MOVWF      FARG_lora_send_packet_size+0
	MOVF       R0+1, 0
	MOVWF      FARG_lora_send_packet_size+1
	MOVLW      main_msg_L0+0
	MOVWF      FARG_lora_send_packet_buf+0
	CALL       _lora_send_packet+0
;Lora_ra02.c,189 :: 		UART1_Write_Text("Paquete enviado [OK]\r\n");
	MOVLW      ?lstr5_Lora_ra02+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Lora_ra02.c,190 :: 		}
	GOTO       L_main24
;Lora_ra02.c,191 :: 		}
L_main23:
;Lora_ra02.c,193 :: 		UART1_Write_Text("No Inicializado [ERR]\r\n");
	MOVLW      ?lstr6_Lora_ra02+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Lora_ra02.c,195 :: 		}
	GOTO       L_main21
;Lora_ra02.c,196 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
