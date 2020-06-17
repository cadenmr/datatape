# datatape

### Purpose
This project aims to use a FPGA to store high-speed data on a S-VHS tape using an unmodified VCR.
This project is also my introduction to FPGAs and signal processing. 

## Features/Goals
- Works with any unmodified S-VHS VCR in good condition with composite in/out
    - S-VHS ET may work but your mileage may vary
    - *NOT* compatible with standard VHS
- Read/Write any file to a S-VHS tape
- High speed, capable of (properly compressed) 4K digital video in realtime 
- Realtime data transfer, allows for playing media in realtime
- Communication with computer over 100MBPS ethernet

## Hardware
FPGA used: Altera DE2-115
VCR used: JVC HR-S3700U
