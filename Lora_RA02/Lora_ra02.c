#define reset PORTC.F2
#define cs PORTB.F0

#define REG_FIFO                       0x00
#define REG_OP_MODE                    0x01
#define REG_FRF_MSB                    0x06
#define REG_FRF_MID                    0x07
#define REG_FRF_LSB                    0x08
#define REG_PA_CONFIG                  0x09
#define REG_LNA                        0x0c
#define REG_FIFO_ADDR_PTR              0x0d
#define REG_FIFO_TX_BASE_ADDR          0x0e
#define REG_FIFO_RX_BASE_ADDR          0x0f
#define REG_FIFO_RX_CURRENT_ADDR       0x10
#define REG_IRQ_FLAGS                  0x12
#define REG_RX_NB_BYTES                0x13
#define REG_PKT_SNR_VALUE              0x19
#define REG_PKT_RSSI_VALUE             0x1a
#define REG_MODEM_CONFIG_1             0x1d
#define REG_MODEM_CONFIG_2             0x1e
#define REG_PREAMBLE_MSB               0x20
#define REG_PREAMBLE_LSB               0x21
#define REG_PAYLOAD_LENGTH             0x22
#define REG_MODEM_CONFIG_3             0x26
#define REG_RSSI_WIDEBAND              0x2c
#define REG_DETECTION_OPTIMIZE         0x31
#define REG_DETECTION_THRESHOLD        0x37
#define REG_SYNC_WORD                  0x39
#define REG_DIO_MAPPING_1              0x40
#define REG_VERSION                    0x42
/*
 * Transceiver modes
 */
#define MODE_LONG_RANGE_MODE           0x80
#define MODE_SLEEP                     0x00
#define MODE_STDBY                     0x01
#define MODE_TX                        0x03
#define MODE_RX_CONTINUOUS             0x05
#define MODE_RX_SINGLE                 0x06

/*
 * PA configuration
 */
#define PA_BOOST                       0x80

/*
 * IRQ masks
 */
#define IRQ_TX_DONE_MASK               0x08
#define IRQ_PAYLOAD_CRC_ERROR_MASK     0x20
#define IRQ_RX_DONE_MASK               0x40

#define PA_OUTPUT_RFO_PIN              0
#define PA_OUTPUT_PA_BOOST_PIN         1

static long __frequency;

void lora_reset(){
   reset = 0;
   Delay_ms(1);
   reset = 1;
   Delay_ms(10);
}

unsigned char lora_read_reg(unsigned char reg){
    int dato =  0;
    cs = 0;
    SPI1_Read(reg);
    dato = SPI1_Read(0xFF);
    cs = 1;
    return(dato);
}

void lora_write_reg(unsigned char reg, unsigned char val){
    unsigned char out[2] = {0};
    unsigned char i=0;
    out[0] = (0x80|reg);
    out[1] = val;
    cs = 0;
    for(i=0; i<2; i++){
       SPI1_Write(out[i]);
    }
    cs = 1;
}

void lora_idle(void)
{
   lora_write_reg(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_STDBY);
}

void printf(char num){
    char buff[5] = {0};
    ByteToStr(num, buff);
    UART1_Write_Text(buff);
    UART1_Write_Text("\r\n");
}

void lora_send_packet(unsigned char *buf, int size)
{   int i = 0;
   /*
    * Transfer data to radio.
    */
   lora_idle();
   lora_write_reg(REG_FIFO_ADDR_PTR, 0);

   for(i=0; i<size; i++)
      lora_write_reg(REG_FIFO, *buf++);

   lora_write_reg(REG_PAYLOAD_LENGTH, size);
   /*
    * Start transmission and wait for conclusion.
    */
   lora_write_reg(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_TX);
   while((lora_read_reg(REG_IRQ_FLAGS) & IRQ_TX_DONE_MASK) == 0){
      Delay_ms(100);
      UART1_Write_Text("Enviando...\r\n");
      printf(lora_read_reg(REG_IRQ_FLAGS));
   }

   UART1_Write_Text("OK\r\n");
   printf(lora_read_reg(REG_IRQ_FLAGS));
   lora_write_reg(REG_IRQ_FLAGS, IRQ_TX_DONE_MASK);
}

void lora_enable_crc(void)
{
   lora_write_reg(REG_MODEM_CONFIG_2, lora_read_reg(REG_MODEM_CONFIG_2) | 0x04);
}

void lora_set_frequency()
{
   lora_write_reg(REG_FRF_MSB, 108);
   lora_write_reg(REG_FRF_MID, 64);
   lora_write_reg(REG_FRF_LSB, 0);
}


void lora_set_tx_power(int level)
{
   if (level < 2) level = 2;
   else if (level > 17) level = 17;
   lora_write_reg(REG_PA_CONFIG, PA_BOOST | (level - 2));
}

void lora_sleep(void)
{
   lora_write_reg(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_SLEEP);
}

unsigned char lora_init(){
   unsigned char i = 0;
   //SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_LOW_2_HIGH);
   SPI1_Init();
   TRISB.F0 = 0;
   TRISC.F2 = 0;
   cs = 1;
   reset = 1;
   Delay_ms(10);
   lora_reset();
   for(i=0; i<100; i++){
      if(lora_read_reg(REG_VERSION) == 0x12){
         break;
      }
      Delay_ms(2);
   }
   if(i==99)
      return(0);
   lora_sleep();
   lora_write_reg(REG_FIFO_RX_BASE_ADDR, 0);
   lora_write_reg(REG_FIFO_TX_BASE_ADDR, 0);
   lora_write_reg(REG_LNA, lora_read_reg(REG_LNA) | 0x03);
   lora_write_reg(REG_MODEM_CONFIG_3, 0x04);
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
