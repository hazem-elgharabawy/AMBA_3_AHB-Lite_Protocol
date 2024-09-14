# AMBA_3_AHB-Lite_Protocol
## system block diagram
![alt text](report/system_block_diagram.png)

## Master interface
 ![alt text](report/block_diagram.png)

 ## slaves
 ### SLAVE1 => memory
 ### SLAVE2 => UART

## STATE DIAGRAM 
   ![alt text](report/state_diagram.png)


 ## opcode
 |SIGNAL    | Description |
 |:--------:|:--------:|
 |opcode[3] | if high this transfer is burst if low this transfer is single   |
 |opcode[2] | if high Write  if low read|
 |opcode[1:0] | 00 for byte transfers 01 for half word 10 for word 11 means UART operation (size is byte) |

 ## Functions
  |FUNCTION    | opcode |
  |:--------:|:--------:|
   |single_load_byte |0|
   |single_load_halfword |1|
   |single_load_word |2|
   |single_UART_RX |3|
   |single_store_byte |4|
   |single_store_halfword |5|
   |single_store_word |6|
   |single_UART_TX |7|
   |burst_Load_byte |8|
   |burst_Load_halfword |9|
   |burst_Load_word |10|
   |burst_UART_RX |11|
   |burst_store_byte |12|
   |burst_store_halfword |13|
   |burst_store_word |14|
   |burst_UART_TX |15|
      
 ## FEATURES NOT INCLUDED

 * HPROT
 * HMASTLOCK
 * HBURST
    1. WRAP4
    2. INCR4
    3. WRAP8
    4. INCR8
    5. WRAP16
    6. INCR16
   
 ## TEST CASES
 ### simple read or write
  ![alt text](report/simple_read_write.png)
 ### consecutive with wait state
  ![alt text](<report/cosecutive_with wait_state.png>)
 ### simple burst 
  ![alt text](report/simple_burst.png)
 ### burst with busy state
  ![alt text](<report/burst_with busy.png>)
 ### error
  ![alt text](report/error.png)

