/*  Action Fontana prototype www.mci.supsi.ch/senseable-art/action-fontana
 *  Senseable Art Workshop www.mci.supsi.ch/senseable-art
 *  MCI project www.mci.supsi.ch
 *  CC BY-NC-SA
 */

#include <OSCBundle.h>
#include <OSCBoards.h>

#ifdef BOARD_HAS_USB_SERIAL
#include <SLIPEncodedUSBSerial.h>
SLIPEncodedUSBSerial SLIPSerial( thisBoardsSerialUSB );
#else
#include <SLIPEncodedSerial.h>
 SLIPEncodedSerial SLIPSerial(Serial1);
#endif

struct LightValue {
  int value;
  long counter;
};

struct beforeProcessing {
  long counter;
  int sum;
  int num_values;
};

#define NUMSENSORS 25
#define DEBUG false
#define BOTTOM_CUT 200

int val;
int sensor;
int sensors[] = {A0, A1, A2, A3, A4, A5 ,A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, A23, A24};
long counter = 1;
long globalCounter = 0;
LightValue values[NUMSENSORS];
int led = 2;
int encoder_input = A25;
int encoder = 1023;
beforeProcessing beforeValues[NUMSENSORS];

void setup() {
  pinMode(led, OUTPUT);
  digitalWrite(led, HIGH);                
  Serial.begin(9600);
  SLIPSerial.begin(9600);
  if (DEBUG) {
    delay(10000);
  }
  
  for(int i = 0; i < NUMSENSORS; i++) {
    values[i] = {0, 0}; 
    if (DEBUG) {
      Serial.print("added sensor: ");
      Serial.println(i);
    }
  }
}

void loop() {
  // first we check the stepper
  // if the difference is small enough
  // we are not moving thus after
  // a short delay we return
  int temp = analogRead(encoder_input);
  if (DEBUG) {
    Serial.print("encoder value:");
    Serial.println(temp);
    Serial.println(abs(encoder - temp));
  }
  if (abs(encoder - temp) < 20) {
    delay(15);
    //Serial.print("we are not moving");
    //Serial.println(abs(encoder - temp));
    return;
  }
  encoder = temp;
  if (DEBUG) {
     Serial.print("we are moving");
  }

  // read all the stuff from the sensors
  // preprocess it
  // put it in the array
  // get the values from the old array
  // calculate the stuff
  // send it via serial or whatever

  for(int i = 0; i < NUMSENSORS; i++) {
    val = analogRead(sensors[i]) - BOTTOM_CUT;
    // if it is low we just empty the value
    if (val < 100) {
      values[i].counter = 0;
      values[i].value = 0;
      continue;
      if(DEBUG) {
        Serial.print(val);
        Serial.println("writing empty data");
      }
    }
    // these are the slot numbers for additional checks
    // if we are at the edge we use other numbers
    int y;
    int z;
    if (i == 0 || i == 1) {
      y = i + 1;
      z = i + 2; 
    }
    else if (i == NUMSENSORS - 1) {
      y = i - 2;
      z = i - 1;
    }
    else {
      y = i - 1;
      z = i + 1;
    }
    // we found a new one
    if (values[i].counter == 0) {
      // let's check the other ones around
      if (values[z].counter == 0 && values[y].counter == 0) {
        // we found a new one
        // we get a new internal counter
        // we update the globalcounter
        values[i].counter = getNextCounter();
        globalCounter++;
      }
      if(values[z].counter != 0) {
        values[i].counter = values[z].counter;
      }
      if(values[y].counter != 0) {
        values[i].counter = values[y].counter;
      }
      values[i].value = val;
      if(DEBUG) {
        //Serial.print(val);
        Serial.println("i found a new one");
      }
      
      continue;
    }
    // now let's see if we have a hit
    if (values[i].counter != 0 && values[y].counter != 0 && values[z].counter != 0) {
      values[i].value = val;
      if(DEBUG) {
        //Serial.print(val);
        //Serial.println("i got a hit");
      }
    }
  }
  
  // now the values array is filled with the correct values
  for(int i = 0; i < NUMSENSORS; i++) {
    if (values[i].counter == 0) {
      continue;
    }
    LightValue value = values[i];
    for(int y = 0; i < NUMSENSORS; y++) {
      if(beforeValues[y].counter == value.counter || beforeValues[y].counter == 0) {
        beforeValues[y].counter = value.counter;
        beforeValues[y].sum += value.value;
        beforeValues[y].num_values += 1;
        if (DEBUG) {
          //Serial.print("value: ");
          //Serial.println(value.value);
          //Serial.println(value.value);
        }
        break;
      }
    }
  }

  // now the beforeValues has the unprocessed values
  // lets process them and send them over the wire
  OSCBundle bundle;
  for(int i = 0; i < NUMSENSORS; i++) {
    // we reached the end
    if (beforeValues[i].counter == 0) {
      break;
    }
    float avg = (float)beforeValues[i].sum / (float)beforeValues[i].num_values / 10;
    if (DEBUG) {
      //Serial.print(beforeValues[i].counter);
      //Serial.print(": ");
      //Serial.println(avg);
    }

    // we just send the globalCounter
    // the other counter values are for internal use only
   
    bundle.add("/hole").add((int32_t)globalCounter).add((float)avg);
    // clear it
    beforeValues[i].sum = 0;
    beforeValues[i].num_values = 0;
    beforeValues[i].counter = 0;
  }

    SLIPSerial.beginPacket();
    bundle.send(SLIPSerial); // send the bytes to the SLIP stream
    SLIPSerial.endPacket(); // mark the end of the OSC Packet
    bundle.empty(); // empty the bundle to free room for a new one
  delay(15);
}

int getNextCounter () {
  counter = counter + 1;
  return counter;
}
