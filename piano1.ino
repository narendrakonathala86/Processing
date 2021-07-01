/**
  Music Lamp - Narendra Konathala
  Maps tone to color

  Do Re Mi Fa Sol La Ti Do
   OR
  Sa Re Ga Ma Pa Da Ni Sa

  Frequencies used from
  https://en.wikipedia.org/wiki/Saptak
  https://licn.typepad.com/my_weblog/2011/07/the-unsolvable-problem-john-dunn-consultant-ambertec-pe-pc.html

  Colors obtained from - Based on tone and color - Walter Rusell - The universal One
  https://roelhollander.eu/en/tuning-frequency/sound-light-colour/

  Music notes obtained from https://sky-music.herokuapp.com/
**/


const int piezo = 13; //Restricted 11 or 3 - Per documentation

//Only using PWM digital pins for analog writes
const int redPWM = 11;
const int greenPWM = 9;
const int bluePWM = 10;


int pushButtons[] = {8, 7, 6, 5, 4, 3, 2, 12};

int frequencies[] = {440, 493, 554, 587, 659, 739, 830, 880};

int redVariant[] =   {255, 127, 0,    0,    241,   255,  255,  255};
int greenVariant[] = {73,  0,   0,    255,  196,   165,  0,    73};
int blueVariant[] =  {108, 255, 255,  0,    15,    0,    0,    108};


void setup() {
  pinMode(piezo, OUTPUT);
  pinMode(redPWM, OUTPUT);
  pinMode(greenPWM, OUTPUT);
  pinMode(bluePWM, OUTPUT);

  for (int i = 0; i < 8; i++) {
    pinMode(pushButtons[i], INPUT);
  }

  Serial.begin( 9600 );

}

void loop() {

  int val = analogRead( A0 );
  int mappedValue = map(val, 0, 1023, 1, 4);

  if (mappedValue == 1) {
    manualMode();
  } else if (mappedValue == 2) {
    automaticMode(1, val);
  } else if (mappedValue == 3) {
    automaticMode(2, val);
  } else if (mappedValue == 4) {
    automaticMode(3, val);
  }


}

//Automatic song feed
void automaticMode(int song, int meterValue) {

  //Ode to joy - Beethoven
  int notes1[] = { 6, 6, 7, 8, 8, 7, 6, 5, 4, 4, 5, 6, 6, 5, 5, 6, 6, 7, 8, 8, 7, 6, 5, 4, 4, 5, 6, 5, 4, 4, 5, 5, 6, 4, 5, 6, 7, 6, 4, 5, 6, 7, 6, 5, 4, 5, 1, 6, 6, 7, 8, 8, 7, 6, 5, 4, 4, 5, 6, 5, 4, 4 };
  int timing1[] = {423, 450, 483, 428, 450, 456, 445, 460, 452, 458, 460, 467, 719, 237, 996, 473, 489, 427, 467, 436, 456, 436, 455, 456, 428, 446, 585, 761, 210, 977, 442, 483, 468, 453, 443, 233, 267, 449, 451, 421, 206, 281, 460, 484, 466, 493, 991, 450, 466, 431, 441, 442, 457, 454, 463, 469, 427, 521, 489, 773, 251, 500};

  //Do-Re-Mi  - Sound of music
  int notes2[] = { 0, 1, 2, 0, 2, 0, 2, 1, 2, 3, 3, 2, 1, 3, 2, 3, 4, 2, 4, 2, 4, 3, 4, 5, 5, 4, 3, 5, 4, 0, 1, 2, 3, 4, 5, 5, 1, 2, 3, 4, 5, 6, 6, 2, 3, 4, 5, 6, 7, 7, 6, 5, 3, 6, 4, 7, 4, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 4, 7 };
  int timing2[] = { 710, 219, 716, 281, 445, 466, 974, 662, 272, 205, 252, 210, 271, 1889, 733, 268, 777, 254, 469, 484, 933, 654, 292, 182, 263, 231, 247, 1816, 652, 254, 207, 230, 223, 270, 1991, 648, 229, 224, 228, 194, 268, 1896, 653, 244, 233, 213, 256, 228, 1322, 223, 286, 467, 442, 490, 524, 402, 475, 450, 491, 227, 207, 247, 193, 229, 221, 366, 498, 489, 450 };

  //Kal-ho-na-ho - Hindi Music
  int notes3[] = { 7, 6, 7, 6, 7, 6, 7, 9, 8, 7, 6, 5, 6, 5, 6, 7, 6, 7, 6, 7, 6, 7, 9, 8, 7, 6, 5, 6, 5, 6, 4, 5, 7, 5, 3, 4, 5, 4, 4, 5, 7, 7, 5, 4, 3, 3, 5, 5 };
  int timing3[] = { 600, 240, 600, 240, 540, 240, 240, 240, 240, 240, 600, 240, 540, 240, 1230, 540, 240, 540, 240, 540, 240, 240, 240, 240, 240, 540, 240, 540, 240, 600, 240, 240, 240, 1080, 240, 240, 240, 1260, 240, 240, 240, 240, 990, 240, 600, 480, 240, 400 };

  int* notes;
  int* timing;
  int length; //Lenght of notes and timing array should be same
  if (song == 1) {
    notes = notes1;
    timing = timing1;
    length = sizeof(notes1)/sizeof(notes1[0]);
  }else if (song == 2) {
    notes = notes2;
    timing = timing2;
    length = sizeof(notes2)/sizeof(notes2[0]);
  }else if (song == 3) {
    notes = notes3;
    timing = timing3;
    length = sizeof(notes3)/sizeof(notes3[0]);
  }

  for (int i = 0; i < length; i++) {
    int val = notes[i];

    if (val > 7) {
      val = val - 7;
    }

    
    int newVal = analogRead( A0 );
    if (newVal != meterValue) {
      int mappedValue = map(newVal, 0, 1023, 1, 4);
      if (mappedValue == 1 || (mappedValue - 1) != song){
        noTone(piezo);
        setLEDColor(255, 255, 255);     //Default Color
        return; //If meter is changed during the song
      }
        
    }

    setLEDColor(redVariant[val],      //Writing Color based on song
                greenVariant[val], blueVariant[val]);
    tone(piezo, frequencies[val], 220);
    delay(timing[i]);

  }

  delay(2000); //Song ended

}


void manualMode() {
  int j = 0;
  bool pushed = false;

  for (int i = 0; i < 8; i++) {

    if ( digitalRead(pushButtons[i]) == LOW) {

      //Writing Color based on button pressed
      setLEDColor(redVariant[i], greenVariant[i], blueVariant[i]);

      tone(piezo, frequencies[i], 220);
      delay(220);

      pushed = true;
    }
  }

  if (pushed == false) {
    noTone(piezo);
    setLEDColor(255, 255, 255);     //Default Color
  }

}


void setLEDColor(int r, int g, int b) {
  analogWrite(redPWM, r);
  analogWrite(greenPWM, g);
  analogWrite(bluePWM, b);
}
