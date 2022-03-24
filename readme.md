## WCCS - Wireless Calculator Communication System
This project aims to interface an arduino and TI-Nspire calculator with an arduino and wireless transceiver to create a texting-like communication system. 


**My Hardware**

I am using a TI-Nspire CX II CAS, and I haven't tested anything on other Nspire calculators, so no promises that it will work for you. I am also using an arduino micro and NRF24L01 SPI based radio board to send wireless signals.
There will soon be a fritzing file/image up for you to follow along.


**Testing So Far**

This software works on the student software, but is untested between two actual calculators. Currently, I am working on improving @tangrs' version of a serial port connector for calculators


**Serial Communication For Nspire**

I have done minimal testing with calculator onboard serial, but imagine that it should work file. Serial is supposed to be used for the hub connector, but I would imagine the purpose I'm using it for shouldn't give th calculator any trouble. I have been hesitant to solder headers directly onto my pins due to stories of bad connections bricking calculators, and the fact that it would be difficult to remove.


**Instructions**

Whenever I update the code majorly, I will add a new release containing tns files that you can directly put on your calculator. If you want to use the most recent commit though, you can clone the repo/copy the code and upload the arduino.ino file to an arduino board and copy the calculator.lua file to a student/teacher software document and save that to you calculator. 
One more thing, *make sure* to change the values for transmission/recieving addresses and radio initialization pins. These have the potential to greatly throw off any communication.