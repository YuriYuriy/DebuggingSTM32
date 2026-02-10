# Debugging-STM32
The material for my YouTube video: 


It is necessary to install:
```
sudo apt update
```
```
sudo apt install openocd gdb-multiarch binutils-multiarch
```


Function for working with printf():
```
int _write(int file, char *ptr, int len)
{
  for(int i = 0; i < len; i++)
  {
    ITM_SendChar(*ptr++);
  }
  return len;
}
```


Launch Commands:
```
mkfifo -m 600 swo.fifo
```
```
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "tcl_port disabled" -c "init" -c "tpiu config internal swo.fifo uart off 72000000 1000000" -c "itm ports on"  -c "reset run" &
```
```
cat swo.fifo
```
