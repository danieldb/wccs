#include <SPI.h> // you can find all libraries on github or the arduino library manager
#include <nRF24L01.h>
#include <RF24.h>
RF24 radio(9, 10); // CE, CSN // pins 3 & 5 on micro, and 9 & 10 on uno using my pinout. MAKE SURE THESE ARE CORRECT!
const byte addressIn[6] = "00002"; // these values are reversed for the two calculators.
const byte addressOut[6] = "00001"; // in the future, I may make these assignable by user, making a broader 'calculator phone number' approach possible
String inputString = "";         // a String to hold incoming data
bool stringComplete = true;
bool needHash = false;
int millisAtRadio = 0;
int millisSinceRadio = 0;
void setup() {
  Serial.begin(9600);
  radio.begin();   //Setting the address at which we will receive the data
  radio.openReadingPipe(0, addressIn);
  radio.openWritingPipe(addressOut);
  radio.setPALevel(RF24_PA_MIN);       //You can set this as minimum or maximum depending on the distance between the transmitter and receiver.
  radio.startListening(); 
  inputString.reserve(200);
}
void loop(){
  while (Serial.available()){
    char a = (char)Serial.read();
    inputString += a;
    if (a == '#'){
      stringComplete = true;
      while (Serial.available()) Serial.read(); 
      break;
    }
  }
  if (stringComplete) {
    char ch[inputString.length()+1];
    inputString.toCharArray(ch, inputString.length()+1);
    radio.stopListening();
    for(int i = 0; i<strlen(ch); i+=1){
      bool rslt;
      rslt = radio.write(&ch[i], 1);
    }
    radio.startListening();
    // clear the string:
    inputString = "";
    stringComplete = false;
  }
  while (radio.available()){
    char text[32] = "";   
    needHash = true;
    radio.read(&text, 1);
    Serial.print(text);
    int millisAtRadio = millis();
    needHash = true;
  }
}