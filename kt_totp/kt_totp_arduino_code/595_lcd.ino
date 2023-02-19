#include "lcd.h"

#define DS 11
#define SHCP 13
#define STCP 12
#define RS 1
#define E 3
#define D4 4
#define D5 7
#define D6 6
#define D7 2


#define RS_bit 1b00000010
#define E_bit  1b00001000
#define D4_bit 1b00010000
#define D5_bit 1b00100000
#define D6_bit 1b01000000
#define D7_bit 1b10000000

LiquidCrystal_74HC595 lcd(DS, SHCP, STCP, RS, E, D4, D5, D6, D7);

void setup() {
  lcd.begin(16, 2);
  Serial.begin(19200);
  lcd.print("Kouvosto Telecom");
  
}

void loop() {
  lcd.begin(16, 2);
  lcd.print("Kouvosto Telecom");
  lcd.setCursor(0, 1);
  char s[64];
  sprintf(s, "TOTP %04d DISOBEY[W3N33DbIggeRScr3en]", millis() / 1000 % 10000);
  lcd.print(s);
  delay(500);
  Serial.println(".");
}
