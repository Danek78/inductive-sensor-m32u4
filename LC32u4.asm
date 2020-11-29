
 ;функция перевода в ASCII:
 .macro ADCtransfer
 ;r25 - LSB, r26 - MSB
 ;проверка 1000:
 clr r21
 ldi r20, 0b00000011
 cp r26, r20
 brlo abort1000
 ldi r20, 0b11101000
 cp r25, r20
 brlo abort1000
 ldi r21, 0b00000001
 abort1000:
 ldi r23, 0b00110000
 add r21, r23
 delay64 10
 r16r17_Rtransfer r21
 clr r21
 clr r22

 ;деление на 100:
 ldi r20, 0b01100100
 decrement100:
 cp r25, r20
 brlo MSBdecrement
 inc r22
 subi r25, 0b01100100
 jmp decrement100
 MSBdecrement:
 cp r26, r21
 breq result100
 dec r26
 inc r22
 ldi r23, 0b10011100
 add r25, r23
 jmp decrement100
 result100:
 ldi r23, 0b00001010
 cp r22, r23
 brne not10
 ldi r22, 0b00000000
 not10:
 ldi r23, 0b00110000
 add r22, r23
 delay64 10
 r16r17_Rtransfer r22

 ;деление на 10:
 clr r22
 ldi r20, 0b00001010
 decrement10:
 cp r25, r20
 brlo result10
 inc r22
 subi r25, 0b00001010
 jmp decrement10
 result10:
 ldi r23, 0b00110000
 add r22, r23
 delay64 10
 r16r17_Rtransfer r22

 ldi r23, 0b00110000
 add r25, r23
 delay64 10
 r16r17_Rtransfer r25

 clr r20
 clr r21
 clr r22
 clr r23
 clr r25
 clr r26
 .endm
 ;--------------------------------------------------------------------
 ;функция, позволяющая создавать временные паузы работы микроконтроллера:
 ; работает на прерывании по переполнению OCR1A

 .macro delay64
ldi r17, @0

clr r16
sts TCNT1L,r16 ;сброс таймера
sts TCNT1H,r16
sts OCR1AH,r16
sts OCR1AL,r17
ldi r16, 0b00000011
ldi r17, 0b11111111
sts TCCR1B, r16;  //clk/64, пуск таймера

;МК ожидает, пока значение в TCNT1 не превысит запрошенную переменную:
delay_cycle1:
cp r17, r16
brne delay_cycle1

clr r16
sts TCCR1B, r16 ;остановка таймера
clr r17

 .endm
 ;-------------------------------------------------------------
 ;2-я функция, позволяющая создавать временные паузы работы микроконтроллера:
 ; сначала - младший, потом - старший
 ; работает на прерывании по переполнению OCR1A
  .macro delay64_2

ldi r17, @0
ldi r16, @1
sts OCR1AH, r16
sts OCR1AL, r17
clr r16
sts TCNT1H, r16
sts TCNT1L, r16 ;сброс таймера
ldi r16, 0b00000011
sts TCCR1B, r16;  //clk/64, пуск таймера
ldi r17, 0b11111111

;МК ожидает, пока значение в TCNT1 не превысит запрошенную переменную:
delay_cycle2:
;lds r15, TCNT1H
;out PORTF, r15
cp r17, r16
brne delay_cycle2
clr r16
sts TCCR1B, r16 ;остановка таймера
clr r17

 .endm
 ;-------------------------------------------------------------
;передача 4 бит информации на LCD экран, необходима при инициализации LCD (проверено)
.macro halftransfer
in r16, PORTD
ldi r17, 0b01111111
and r16,r17
out PORTD, r16	;  RPORTD.7=0  RS
ldi r17, @0
out PORTB, r17
in r16, PORTD
ldi r17, 0b01000000
or r16, r17
out PORTD, r16 ; PORTD.6=1  E
delay64 0b00000100; delay ~15 microseconds
in r16, PORTD
ldi r17, 0b10111111
and r16,r17
out PORTD, r16  ;  PORTD.6=0  E
clr r16 
out PORTB, r16
.endm
;---------------------------------------------------------------
;полная передача байта команды на LCD (проверено)
.macro fulltransfer
in r16, PORTD
ldi r17, 0b01111111
and r16,r17
out PORTD, r16  ;  RPORTD.7=0  RS
ldi r17, @0
out PORTB, r17
in r16, PORTD
ldi r17, 0b01000000
or r16, r17
out PORTD, r16 ; PORTD.6=1  E
delay64 4 ; //delay ~15 microseconds
ldi r17,0b10111111
in r16, PORTD
and r16, r17
out PORTD, r16
delay64 4 ; //delay ~15 microseconds
ldi r17, @0
lsl r17
lsl r17
lsl r17
lsl r17
out PORTB, r17
ldi r16,0b01000000
in r17, PORTD
or r16, r17
out PORTD, r16
delay64 4 ;
ldi r16,0b10111111
in r17, PORTD
and r16, r17
out PORTD, r16
clr r16
out PORTB, r16
clr r17
.endm
;---------------------------------------------------------------
;[ошибка+?]
;передача (запрос вывода) символа на LCD
.macro datatransfer
in r16, PORTD
ldi r17, 0b10000000
or r16,r17
out PORTD, r16  ;  RPORTD.7=1  RS
ldi r17, @0
out PORTB, r17
in r16, PORTD
ldi r17, 0b01000000
or r16,r17
out PORTD, r16  ;  RPORTD.6=1  E
delay64 4 ;
in r16, PORTD
ldi r17, 0b10111111
and r16,r17
out PORTD, r16  ;  RPORTD.6=0  E
delay64 4 ;
ldi r17, @0
lsl r17
lsl r17
lsl r17
lsl r17
out PORTB, r17
in r16, PORTD
ldi r17, 0b01000000
or r16,r17
out PORTD, r16  ;  RPORTD.6=1  E
delay64 4;
in r16, PORTD
ldi r17, 0b10111111
and r16,r17
out PORTD, r16  ;  RPORTD.6=0  E
clr r17
out PORTB, r17
in r16, PORTD
ldi r17, 0b01111111
and r16,r17
out PORTD, r16  ;  RPORTD.6=0  E
.endm
;---------------------------------------------------------------
.macro r16r17_Rtransfer
in r16, PORTD
ldi r17, 0b10000000
or r16,r17
out PORTD, r16  ;  RPORTD.7=1  RS
mov r17, @0;---------------------
out PORTB, r17
in r16, PORTD
ldi r17, 0b01000000
or r16,r17
out PORTD, r16  ;  RPORTD.6=1  E
delay64 4 ;
in r16, PORTD
ldi r17, 0b10111111
and r16,r17
out PORTD, r16  ;  RPORTD.6=0  E
delay64 4 ;
mov r17, @0;-------------------------
lsl r17
lsl r17
lsl r17
lsl r17
out PORTB, r17
in r16, PORTD
ldi r17, 0b01000000
or r16,r17
out PORTD, r16  ;  RPORTD.6=1  E
delay64 4;
in r16, PORTD
ldi r17, 0b10111111
and r16,r17
out PORTD, r16  ;  RPORTD.6=0  E
clr r17
out PORTB, r17
in r16, PORTD
ldi r17, 0b01111111
and r16,r17
out PORTD, r16  ;  RPORTD.6=0  E
.endm
;---------------------------------------------------------------

 .nolist
 .include "m32U4def.inc"  ;библиотека с адресами/именами регистров для atmega32u4
 .list

 .cseg
 .org 0x00

 ;таблица прерываний
 .org 0x0000 rjmp initial; выполняется при включении
 .org 0x0022 rjmp timer1_compA
 .org 0x003a rjmp adc_complete
 .org 0x0040 rjmp timer3_compA
 ;конец таблицы
 .org 0x0056

 ;ставим стек
 initial: ldi R16,low(RAMEND)
			out SPL,R16
			ldi R17,high(RAMEND)
			out SPH,R17
			clr r16
			clr r17

main:

ldi r16, 0b00000010
sts TIMSK1, r16; вкл прерыв. таймера 1
sts TIMSK3, r16; таймера 3
clr r16


ldi r20, 0b11111111
out DDRB, r20
out DDRD, r20
clr r20

sei

;//----------LCD initialisation---------
delay64_2 0b11010100, 0b00110000;  //delay 50ms   12500 
halftransfer 0b00110000 ;
delay64_2 0b11100010, 0b00000100 ;   //delay 5ms 1250
halftransfer 0b00110000;
delay64_2 0b11100010, 0b00000100;   //t1 1250
halftransfer 0b00110000;
delay64_2 0b11100010, 0b00000100;   //t2 1250
halftransfer 0b00110000; 
delay64_2 0b11100010, 0b00000100;   //t3 1250
;//copy from 1602a:
halftransfer 0b00100000;  //set to 4 bit interface
delay64_2 0b11100010, 0b00000100; 1250
fulltransfer 0b00100100;  //interface data - 4 bit, font, №oflines;
delay64_2 0b11100010, 0b00000100; 1250
fulltransfer 0b00001100;  //display on, cursor off, blinking off
delay64_2 0b11100010, 0b00000100; 1250
fulltransfer 0b00000001;  //clear display
delay64_2 0b11100010, 0b00000100; 1250
fulltransfer 0b00000110;  //entry mode
delay64_2 0b11010100, 0b00110000;  //delay 50ms   12500
;//-----------LCD initialisation ends--------
datatransfer 0b01000001

ldi r20, 0b01000111
sts ADMUX, r20
;не забудь подтянуть avcc к 5в
sbi DDRF, 7
cbi PORTF, 7

;установка таймера:
ldi r20, 0b00001001
sts OCR1AL, r20
ldi r20, 0b00111101
sts OCR1AH, r20
ldi r20, 0b00000101
sts TCCR3B, r20
clr r20

loop:
	ldi r19, 0b11111111;  -переведи  в константу
	cp r19,r25
	breq loop
	
	delay64_2 0b11100010, 0b00000100 ;   //delay 5ms 1250
	fulltransfer 0b00000001 ;clear display
	delay64_2 0b11100010, 0b00000100 ;   //delay 5ms 1250
	delay64 10
	ADCtransfer
	ldi r25, 0b11111111

rjmp loop

timer1_compA:
	ldi r16, 0b11111111
reti

timer3_compA:
	clr r20
	sts TCNT1L, r20
	sts TCNT1H, r20
	;запуск АЦП:
	ldi r20, 0b11001011
	sts ADCSRA, r20
reti

adc_complete:
	lds r25, ADCL
	lds r26, ADCH
reti