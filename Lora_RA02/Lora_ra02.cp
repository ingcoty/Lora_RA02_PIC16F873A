#line 1 "//VBOXSVR/Compartida/Lora_RA02/Lora_ra02.c"
#line 56 "//VBOXSVR/Compartida/Lora_RA02/Lora_ra02.c"
static long __frequency;

void lora_reset(){
  PORTC.F2  = 0;
 Delay_ms(1);
  PORTC.F2  = 1;
 Delay_ms(10);
}

unsigned char lora_read_reg(unsigned char reg){
 int dato = 0;
  PORTB.F0  = 0;
 SPI1_Read(reg);
 dato = SPI1_Read(0xFF);
  PORTB.F0  = 1;
 return(dato);
}

void lora_write_reg(unsigned char reg, unsigned char val){
 unsigned char out[2] = {0};
 unsigned char i=0;
 out[0] = (0x80|reg);
 out[1] = val;
  PORTB.F0  = 0;
 for(i=0; i<2; i++){
 SPI1_Write(out[i]);
 }
  PORTB.F0  = 1;
}

void lora_idle(void)
{
 lora_write_reg( 0x01 ,  0x80  |  0x01 );
}

void printf(char num){
 char buff[5] = {0};
 ByteToStr(num, buff);
 UART1_Write_Text(buff);
 UART1_Write_Text("\r\n");
}

void lora_send_packet(unsigned char *buf, int size)
{ int i = 0;
#line 103 "//VBOXSVR/Compartida/Lora_RA02/Lora_ra02.c"
 lora_idle();
 lora_write_reg( 0x0d , 0);

 for(i=0; i<size; i++)
 lora_write_reg( 0x00 , *buf++);

 lora_write_reg( 0x22 , size);
#line 113 "//VBOXSVR/Compartida/Lora_RA02/Lora_ra02.c"
 lora_write_reg( 0x01 ,  0x80  |  0x03 );
 while((lora_read_reg( 0x12 ) &  0x08 ) == 0){
 Delay_ms(100);
 UART1_Write_Text("Enviando...\r\n");
 printf(lora_read_reg( 0x12 ));
 }

 UART1_Write_Text("OK\r\n");
 printf(lora_read_reg( 0x12 ));
 lora_write_reg( 0x12 ,  0x08 );
}

void lora_enable_crc(void)
{
 lora_write_reg( 0x1e , lora_read_reg( 0x1e ) | 0x04);
}

void lora_set_frequency()
{
 lora_write_reg( 0x06 , 108);
 lora_write_reg( 0x07 , 64);
 lora_write_reg( 0x08 , 0);
}


void lora_set_tx_power(int level)
{
 if (level < 2) level = 2;
 else if (level > 17) level = 17;
 lora_write_reg( 0x09 ,  0x80  | (level - 2));
}

void lora_sleep(void)
{
 lora_write_reg( 0x01 ,  0x80  |  0x00 );
}

unsigned char lora_init(){
 unsigned char i = 0;

 SPI1_Init();
 TRISB.F0 = 0;
 TRISC.F2 = 0;
  PORTB.F0  = 1;
  PORTC.F2  = 1;
 Delay_ms(10);
 lora_reset();
 for(i=0; i<100; i++){
 if(lora_read_reg( 0x42 ) == 0x12){
 break;
 }
 Delay_ms(2);
 }
 if(i==99)
 return(0);
 lora_sleep();
 lora_write_reg( 0x0f , 0);
 lora_write_reg( 0x0e , 0);
 lora_write_reg( 0x0c , lora_read_reg( 0x0c ) | 0x03);
 lora_write_reg( 0x26 , 0x04);
 lora_set_tx_power(17);
 lora_idle();
 return(1);
}

void main() {
 unsigned char msg[30] = "Hola mundo";
 UART1_Init(9600);
 while(1){
 if(lora_init()){
 UART1_Write_Text("Lora Inicializado [OK]\r\n");
 lora_set_frequency();
 lora_enable_crc();
 while(1){
 Delay_ms(1000);
 lora_send_packet(msg, strlen(msg));
 UART1_Write_Text("Paquete enviado [OK]\r\n");
 }
 }
 else{
 UART1_Write_Text("No Inicializado [ERR]\r\n");
 }
 }
}
