; Простой частотомер с ATtiny2313 (A) до 10 МГц.
; Используется кварцевый резонатор на 20 MHz
; Автор исходного кода: DANYK
; http://danyk.cz

.NOLIST
.INCLUDE "tn2313def.inc"
.LIST

.DEF CIF1=R9		; младшая цифра
.DEF CIF2=R10		; ...
.DEF CIF3=R11		; ...
.DEF CIF4=R12		; ...
.DEF CIF5=R13		; ...
.DEF CIF6=R14		; ...
.DEF CIF7=R15		; старшая цифра

.DEF REG=R16		; временный регистр

.DEF UDAJ1=R17		; младшие 8 бит 24-битного результата
.DEF UDAJ2=R18		;
.DEF UDAJ3=R19		; старшие 8 бит 24-битного результата

.DEF DELREG=R20		; 2 регистра деления частоты от 625 до 1 Гц
.DEF DELREG2=R21
.DEF PRETREG=R22	; регистр, в который перетекает 16-битный счетчик1
.DEF MULTREG=R23	; Регистр запоминает состояние мультиплекса

.DEF ROZREG=R24		; диапазон

.EQU SMER=DDRB		; Display PORT - сегментный анод
.EQU PORT=PORTB
.EQU SMER2=DDRD 	; Мультиплекс PORT - катодный сегмент, вход
.EQU PORT2=PORTD


.CSEG
.ORG 0
RJMP START

; сюда программа переходит при возникновении прерывания
.ORG OVF1addr
INC PRETREG
RETI

.ORG OC0Aaddr
RJMP CITAC0

START:
; устанавливаем порт как выход, для управления анодами
LDI REG,0xFF
OUT SMER,REG
LDI REG,0xFF
OUT PORT,REG

; устанавливаем биты 0,1,2,3 в качестве вывода, для управления катодами
; устанавливаем биты 4,5,6 в качестве входных
LDI REG,0b00001111
OUT SMER2,REG
LDI REG,0b11010000
OUT PORT2,REG

LDI REG,LOW(RAMEND)
OUT SPL,REG

; выключает аналоговый компаратор (экономия энергии)
LDI REG,0b10000000
OUT ACSR,REG

; спящий режим IDLE
LDI REG,0b00100000
OUT MCUCR,REG

; НАСТРОЙКИ СЧЕТЧИКА / ТАЙМЕРА
LDI	REG,0b00000010 	; установливаем счетчик-0 в ноль при достижении сравнения ...
OUT	TCCR0A,REG    	; ...значения (так называемый CTC), OC0 не используется, деление 256
LDI	REG,0b00000100 	; 
OUT	TCCR0B,REG 
LDI	REG,124      	; сравниваемое значение, генерируется 625 Гц (мультиплексирование 156,25 Гц)
OUT	OCR0A,REG     	; 

LDI	REG,0b00000000	; устанавливаем счетчик-1 в нормальный режим
OUT	TCCR1A,REG    	; 
LDI	REG,0b00000111 	; внешний таймер
OUT	TCCR1B,REG

LDI	REG,0b10000001	; разрешаем прерывание
OUT	TIMSK,REG    	; (бит 0 разрешает счетчик-0а, бит 7 разрешает переполнение прерывания-1)

; сбрасываем / устанавливаем регистры
CLR REG
LDI DELREG,1
LDI DELREG2,1
CLR PRETREG
LDI MULTREG,1
CLR CIF1
CLR CIF2
CLR CIF3
CLR CIF4
CLR CIF5
CLR CIF6
CLR CIF7

SEI ; разрешаем глобальные прерывания


; основной цикл
SMYCKA:
SLEEP
RJMP SMYCKA


MULT:
LDI REG,0b11010000
OUT PORT2,REG

CPI MULTREG,1
BREQ MULT1
CPI MULTREG,2
BREQ MULT2
CPI MULTREG,3
BREQ MULT3
CPI MULTREG,4
BREQ MULT4


MULT1:
MOV REG,CIF1
RCALL ZOBRAZ
CPI ROZREG,3
BRNE TECKA1NE
SUBI REG,128   		; это загорится точка
TECKA1NE:
OUT PORT,REG
LDI REG,0b11010001      ; с порта log1 на порт bit0
OUT PORT2,REG
RET

MULT2:
MOV REG,CIF2
RCALL ZOBRAZ
CPI ROZREG,2
BRNE TECKA2NE
SUBI REG,128   		; это загорится точка
TECKA2NE:
OUT PORT,REG
LDI REG,0b11010010      ; с порта log1 на порт bit1
OUT PORT2,REG
RET

MULT3:
MOV REG,CIF3
RCALL ZOBRAZ
CPI ROZREG,1
BRNE TECKA3NE
SUBI REG,128   		; это загорится точка
TECKA3NE:
OUT PORT,REG
LDI REG,0b11010100      ; с порта log1 на порт bit2
OUT PORT2,REG
RET

MULT4:
MOV REG,CIF4
RCALL ZOBRAZ
CPI ROZREG,0
BRNE TECKA4NE
SUBI REG,128   		; это загорится точка
TECKA4NE:
OUT PORT,REG
LDI REG,0b11011000     ; с порта log1 на порт bit3
OUT PORT2,REG
RET


ZOBRAZ:

CPI REG,0
BREQ ZOBRAZ0
CPI REG,1
BREQ ZOBRAZ1
CPI REG,2
BREQ ZOBRAZ2
CPI REG,3
BREQ ZOBRAZ3
CPI REG,4
BREQ ZOBRAZ4
CPI REG,5
BREQ ZOBRAZ5
CPI REG,6
BREQ ZOBRAZ6
CPI REG,7
BREQ ZOBRAZ7
CPI REG,8
BREQ ZOBRAZ8
CPI REG,9
BREQ ZOBRAZ9

LDI REG,0b11110111
RET

ZOBRAZ0:
LDI REG,0b11000000
RET

ZOBRAZ1:
LDI REG,0b11111001
RET

ZOBRAZ2:
LDI REG,0b10100100
RET

ZOBRAZ3:
LDI REG,0b10110000
RET

ZOBRAZ4:
LDI REG,0b10011001
RET

ZOBRAZ5:
LDI REG,0b10010010
RET

ZOBRAZ6:
LDI REG,0b10000010
RET

ZOBRAZ7:
LDI REG,0b11111000
RET

ZOBRAZ8:
LDI REG,0b10000000
RET

ZOBRAZ9:
LDI REG,0b10010000
RET


OBNOVA:
MOV UDAJ3,PRETREG
IN UDAJ1,TCNT1L
IN UDAJ2,TCNT1H
CLR PRETREG
OUT	TCNT1H,PRETREG
OUT	TCNT1L,PRETREG

CLR ROZREG
CLR CIF1
CLR CIF2
CLR CIF3
CLR CIF4
CLR CIF5
CLR CIF6
CLR CIF7

CPI UDAJ1,128		; 24-битное состояние менее 10 000 000
LDI REG,150
CPC UDAJ2,REG
LDI REG,152
CPC UDAJ3,REG
BRLO DO9999999
SER REG
MOV CIF7,REG
MOV CIF6,REG
MOV CIF5,REG
MOV CIF4,REG
MOV CIF3,REG
MOV CIF2,REG
MOV CIF1,REG
SER ROZREG
RJMP KONEC_OBNOVY
DO9999999:

ZNOVU_7:
CPI UDAJ1,64		; 24-битное состояние меньше 1 000 000
LDI REG,66
CPC UDAJ2,REG
LDI REG,15
CPC UDAJ3,REG
BRLO MENSI_7
SUBI UDAJ1,64		; 24-битное чтение 1 000 000 из результата
SBCI UDAJ2,66
SBCI UDAJ3,15
INC CIF7
RJMP ZNOVU_7
MENSI_7:

ZNOVU_6:
CPI UDAJ1,160		; 24-битное состояние меньше 100 000
LDI REG,134
CPC UDAJ2,REG
LDI REG,1
CPC UDAJ3,REG
BRLO MENSI_6
SUBI UDAJ1,160		; 24-битное чтение 100 000 из результата
SBCI UDAJ2,134
SBCI UDAJ3,1
INC CIF6
RJMP ZNOVU_6
MENSI_6:

ZNOVU_5:
CPI UDAJ1,16		; 24-битное состояние меньше 10 000
LDI REG,39
CPC UDAJ2,REG
LDI REG,0
CPC UDAJ3,REG
BRLO MENSI_5
SUBI UDAJ1,16		; 24-битное чтение 10 000 из результата
SBCI UDAJ2,39
SBCI UDAJ3,0
INC CIF5
RJMP ZNOVU_5
MENSI_5:

ZNOVU_4:
CPI UDAJ1,232		; 16-битное состояние меньше 1 000
LDI REG,3
CPC UDAJ2,REG
BRLO MENSI_4
SUBI UDAJ1,232		; 16-битное чтение 1000 из результата
SBCI UDAJ2,3
INC CIF4
RJMP ZNOVU_4
MENSI_4:

ZNOVU_3:
CPI UDAJ1,100		; 16-битное состояние меньше 100
LDI REG,0
CPC UDAJ2,REG
BRLO MENSI_3
SUBI UDAJ1,100		; 16-битное чтение 100 из результата
SBCI UDAJ2,0
INC CIF3
RJMP ZNOVU_3
MENSI_3:

ZNOVU_2:
CPI UDAJ1,10		; 8-битное состояние меньше 10
BRLO MENSI_2
SUBI UDAJ1,10		; 8-битное чтение 10 из результата
INC CIF2
RJMP ZNOVU_2
MENSI_2:

MOV CIF1,UDAJ1


POSUN_ZNOVU:
CLR REG
CP CIF7,REG
BRNE POSUN
CP CIF6,REG
BRNE POSUN
CP CIF5,REG
BRNE POSUN
RJMP POSUN_KONEC
POSUN:
MOV CIF1,CIF2
MOV CIF2,CIF3
MOV CIF3,CIF4
MOV CIF4,CIF5
MOV CIF5,CIF6
MOV CIF6,CIF7
CLR CIF7
INC ROZREG
RJMP POSUN_ZNOVU
POSUN_KONEC:

KONEC_OBNOVY:
RET

; прерывистое управление мультиплексированием и источник 1 Гц
CITAC0:
RCALL MULT
DEC MULTREG
BRNE MULTHOP
LDI MULTREG,4
MULTHOP:

DEC DELREG
BRNE DELHOP
LDI DELREG,125
DEC DELREG2
BRNE DELHOP
LDI DELREG2,5
RCALL OBNOVA
DELHOP:

RETI
