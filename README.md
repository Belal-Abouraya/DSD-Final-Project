# Real-Time Image Compression and Decompression Using FPGA

This project is the culmination of our Digital Systems Design (DSD) course, where we utilized VHDL and two FPGAs to implement the LZ77 compression algorithm for real-time image processing.

## Project Overview

The system comprises four main components:

1. **Image Preprocessing (Python)**:
   - A Python script reads the input image file, resizes it, and converts it into a binary format. Each pair of pixels is encoded into three bytes, optimizing the data for transmission and processing.

2. **Data Transmission (MATLAB)**:
   - A MATLAB program processes the binary data and transmits it to the first FPGA using the UART protocol. This step ensures efficient communication between the software and hardware components.

3. **Compression FPGA**:
   - The first FPGA receives the data from the PC and performs real-time compression using the LZ77 algorithm. The compressed data is then sent to the second FPGA via UART.

4. **Decompression FPGA**:
   - The second FPGA receives the compressed data, decompresses it in real time, and buffers the image until it is fully received. The final output is displayed on a screen using VGA, showcasing the complete image restoration process.

## Repository Contents

This repository includes all the essential files for each component, the constraint files for each FPGA, and comprehensive test benches used throughout the project for validation and verification.

## Demonstration

For a visual demonstration of the project's capabilities, please refer to the following [video link](https://drive.google.com/file/d/1rt0XxeWRW5qbvtYYrE22Ww3B-QG6COpl/view?usp=drive_link).
