	org	0000h

	DI
	IM	1					
	JP	initsys				; inicializalas
	


;---------------------------------------------------------------------------------

cursoron:

	PUSH	HL
	
	LD	HL,(8000h)			;Kurzor aktualis pozicioja a kepernyon (8000h- 8001h)
	LD	(HL),0A0h
	
	POP	HL
	RET
;--------------------------------------------------------------------------------

cursoroff:

	PUSH	AF
	PUSH	HL	

	LD	HL,(8000h)			;Kurzor aktualis pozicioja a kepernyon (8000h- 8001h)
	LD	A,(8004h)			;A Kurzor poziciojaban levo karakter kodja (8004h)
	LD	(HL),A
	
	POP	HL
	POP	AF
	RET

;------------------------------------------------------------------------------------------
putcursor:					; Kurzort a HL altal mutatott poziciora helyezi  (2000-23FFh)  
	
	PUSH	AF	
	DI

	LD	A,H
	AND	03h
	ADD	A,20h
	LD	H,A

	PUSH	HL
	LD	HL,(8000h)			;Kurzor eddigi pozicioja a kepernyon (8000h- 8001h)
	LD	A,(8004h)			;A Kurzor poziciojaban levo karakter kodja (8004h)
	LD	(HL),A				;Eredeti kepernyotartalom visszaallitasa
	POP	HL					
						;Kurzor uj aktualis pozicioja (8000h-8001h)
	LD	(8000h),HL			;Ezt a cimet hasznaljuk!! 8000h-8001h
	LD	A,(HL)
	LD	(8004h),A	
	POP	AF
	EI
	RET


;---------------------------------------------------------------------------------
	org	0038h				;Interrupt belepesi pont
	
	PUSH   AF
	PUSH   HL
	PUSH   DE
	PUSH   BC
	PUSH   IX
	PUSH   IY
	EX     AF,AF'
	PUSH   AF
	EXX
	PUSH   HL
	PUSH   DE
	PUSH   BC
	

	CALL	clockstep		;Ora leptetese
	CALL	blink			;Villogtato mechanizmus mukodtetese
	CALL	showclock		;Ora kijelzese
	CALL	keyscan			;Billentyumatrix tapogatas, ASCII eredmeny A-ban
	CALL	keyrep			;Ismetelt billentyulenyomas feldolgozas
	CALL	showcursor		;Kurzor villogtatasa a helyen

	POP   BC
	POP   DE
	POP   HL
	EXX
	POP   AF
	EX    AF,AF'
	POP   IY
	POP   IX
	POP   BC
	POP   DE
	POP   HL
	POP   AF
	EI
	RET					;Interrupt kiszolgalas vege
	
;-----------------------------------------------------------------------------------------
clockstep:			;A belso orat lepteti, a szamlalas a megszakitas szerint megy                           
	
	LD	HL,8010h	
		
	LD	A,(HL)		;25-os oszto		(8010h)
	INC	A
	LD	(HL),A
	CP	19h
	RET	NZ
	XOR	A
	LD	(HL),A
	INC	L
	
	LD	A,(HL)		;Masodperc x 1		(8011h)
	INC	A
	LD	(HL),A
	CP	0Ah
	RET	NZ
	XOR	A
	LD	(HL),A
	INC	L
	
	LD	A,(HL)		;Masodperc x 10		(8012h)
	INC	A
	LD	(HL),A
	CP	06h
	RET	NZ
	XOR	A
	LD	(HL),A
	INC	L

	LD	A,(HL)		;Perc x 1		(8013h)
	INC	A
	LD	(HL),A
	CP	0Ah
	RET	NZ
	XOR	A
	LD	(HL),A
	INC	L

	LD	A,(HL)		;Perc x 10		(8014h)
	INC	A
	LD	(HL),A
	CP	06h
	RET	NZ
	XOR	A
	LD	(HL),A
	INC	L

	LD	A,(HL)		;Ora x 1		(8015h)
	INC	A
	LD	(HL),A
	CP	0Ah
	RET	NZ
	XOR	A
	LD	(HL),A
	INC	L

	LD	A,(HL)		;Ora x 10		(8016h)
	INC	A
	LD	(HL),A
	CP	0Ah
	RET	NZ
	XOR	A
	LD	(HL),A

	RET

;--------------------------------------------------------------------------------------
blink:							;Villogtato mechanizmus, eredmeny (8018h)-ban
	LD	HL,8017h	
	
	LD	A,(HL)		;8-as oszto		(8017h)
	INC	A
	LD	(HL),A
	CP	08h
	RET	NZ
	XOR	A
	LD	(HL),A
	INC	L
	
	LD	A,(HL)		;Kurzor 1-be, 0-ki	(8018h)
	INC	A
	LD	(HL),A
	CP	02h
	RET	NZ
	XOR	A
	LD	(HL),A

	RET

;-------------------------------------------------------------------------------
showclock:					

	LD	HL,(8019h)			;Az ora megjelenitesi helyenek pozicioja (cim: 8019h - 801Ah)  (poz: 0000-03FFh)
						;Ha ez ,00' akkor nincs ora megjelenites
	LD	A,H				;Ha a 7. bit 1, akkor inverz megjelenites (801Ah)
	OR	L
	RET	Z
	
	LD	A,H
	AND	80h				;Inverz bit kimaszkolasa
	ADD	A,30h				;30h hozzaadas az ASCII kod eloallitasara
	LD	C,A
	
	LD	A,H
	AND	03h				;Felso folosleges bitek kimaszkolasa
	ADD	A,20h				;Tenyleges memoriacim eloallitasa
	LD	H,A	
		
	LD	DE,8016h	
	
	LD	A,(DE)				;Ora x 10
	ADD	A,C
	LD	(HL),A
	INC	HL
	DEC	E
	
	LD	A,(DE)				;Ora x 1
	ADD	A,C
	LD	(HL),A
	INC	HL
	DEC	E
	
	LD	A,0Ah				;Kettospont
	ADD	A,C
	LD	(HL),A
	INC	HL
	
	LD	A,(DE)				;Perc x 10
	ADD	A,C
	LD	(HL),A
	INC	HL
	DEC	E
	
	LD	A,(DE)				;Perc x 1
	ADD	A,C
	LD	(HL),A
	INC	HL
	DEC	E

	LD	A,0Ah				;Kettospont
	ADD	A,C
	LD	(HL),A
	INC	HL
	
	LD	A,(DE)				;Masodperc x 10
	ADD	A,C
	LD	(HL),A
	INC	HL
	DEC	E
	
	LD	A,(DE)				;Masodperc x 1
	ADD	A,C
	LD	(HL),A
	
	RET
		
						
	


;--------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------	


;SZUBRUTINOK

;---------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------

curposchck:		;Ellenõrzi, hogy a HL-be beírt, kiadni kívánt
			;kurzorpozíció benne van-e a lehetséges tartományban.
			;-Kisebb esetén a kurzort a bal felsõ sarokba rakja.
			;-Nagyobb esetén Scrolloz és a kurzort az utsó sor elejére rakja.
			;Visszatereskor HL-ben az uj kurzorpozicio, oda kell
			;rakni a kurzort a putcursorral.

	PUSH	AF
	LD	A,H
	CP	24h
	CALL	Z,scrollup
		
	LD	A,H	
	CP	1Fh
	JR	NZ,curposchckend
	LD	HL,2000h

curposchckend:	
	POP	AF
	RET


;------------------------------------------------------------------------------------------
showcursor:					;A Kurzort az eppen aktualis szineben mutatja
	PUSH	AF
	LD	A,(8002h)			;Ha 8002h-ban levo ertek 00h, akkor nincs kurzor megjelenites
	OR	A
	JR	Z,showcurs1
	LD	A,(8018h)			;Kurzor 1-be, 0-ki	(8018h)
	OR	A
	CALL	NZ,cursoron
	
showcurs1:
	CALL	Z,cursoroff
	POP	AF
	RET


;--------------------------------------------------------------------------------
cls:
	LD	HL,2000h
clsloop:
	LD	(HL),20h
	INC	HL
	LD	A,H
	CP	24h
	RET	Z
	JR	clsloop				;  Kepernyo torles
	

;------------------------------------------------------------------------------------------
initsys:					; Rendszer inicializalas
	
	LD    HL,2000h

vgatest01:

	LD    (HL),$ff
	NOP
	LD    A,(HL)
	INC   A
	JP    NZ,initsys                             ;Video RAM hiba
	INC   HL
	LD    A,H
	CP    24h
	JR    NZ,vgatest01
	LD    HL,2000h	

vgatest02:

	LD    (HL),00h
	NOP
	LD    A,(HL)
	OR    A
	JP    NZ,initsys                             ;Video RAM hiba
	INC   HL
	LD    A,H
	CP    24h
	JR    NZ,vgatest02
	

	LD    HL,8000h

ramtest01:

	LD    (HL),00h
	NOP
	LD    A,(HL)
	OR    A
	JP    NZ,initsys                             ;Program RAM hiba
	INC   HL
	LD    A,H
	OR    L
	JR    NZ,ramtest01
	LD    H,80h				; RAM tesztelo ciklus 1

ramtest02:

	LD    (HL),$ff
	NOP
	LD    A,(HL)
	INC   A
	JP    NZ,initsys                             ;Program RAM hiba
	INC   HL
	LD    A,H
	OR    L
	JR    NZ,ramtest02
	
	LD    SP,$ffff				; RAM tesztelo ciklus 2



	LD	HL,8000h			;Inicializalas, Kezdoertekek betoltese
kezdert:
	LD	(HL),00h
	INC	HL
	LD	A,H
	CP	90h
	JR	NZ,kezdert		
	
	CALL	cls				; Kepernyo torles

	EI					; Megszakitasok engedelyezese
	JP	start				; Ugras a foprogramra
;------------------------------------------------------------------------------------

keyscan:
	LD	HL,8020h		;Billentyumatrix masolatanak cime:(8020h - 802Fh)
	LD	B,70h			;Billentyuzetmatrix cime: (7020h - 702Fh)
	
	LD	C,L			;1. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;2. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;3. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;4. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;5. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;6. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;7. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;8. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;9. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;10. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;11. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;12. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;13. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;14. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;15. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A
	INC	L

	LD	C,L			;16. Sor
	LD	A,(BC)
	CPL
	LD	(HL),A



keyshift:
	LD	L,21h			;Shift helye a masolatban 2.sor (8021h)
	LD	C,00h	
 	LD	A,(HL)
	OR	A
	JR	Z,keycode
	LD	(HL),00h
	LD	C,80h			; C reg valtobillentyu jelzo (00 = alap , 80 = shift ) 
	
	
keycode:	


	LD	B,10h			;16 db sor lesz
	LD	L,20h			;Kezdes
	LD	E,00h
keyrow:

	LD	A,(HL)
	OR	A
	JR	NZ,keycol1
	INC	L
	INC	E
	DJNZ	keyrow
	JR	keyend			;Ha nincs billentyu lenyomva, akkor ugras a vegere

keycol1:
	
	LD	B,00h			; E tartalmazza, hogy hanyadik sor

keycol2:

	SRL	A
	JR	C,keyback
	INC	B
	JR	keycol2			; B tartalmazza, hogy hanyadik oszlop (hanyadik bit)

keyback:

	LD	A,E
	SLA	A
	SLA	A
	SLA	A
	ADD	A,B			; A tartalmazza a baziscimtol valo eltolast
	ADD	A,C			; Ez tulajdonkeppen a SCAN kod
	LD	H,0Bh			; ASCII tablazat baziscime ( 0B00h )
	LD	L,A
	LD	A,(HL)
	RET

keyend:

	XOR	A			;Ha nincs lenyomva billentyu, akkor 00h -val ter vissza
	RET

;-------------------------------------------------------------------------------

keyrep:					; Ujra ugyanazt a gombot nyomtuk-e le??
	
	LD	HL,8030h
	CP	(HL)
	JR	NZ,repnew
	XOR	A
	INC	L
	LD	(HL),A
	RET
repnew:
	LD	(HL),A
	INC	L
	LD	(HL),A	
	RET				;(8031h) cimen akiolvasando ASCII kod
					;Kiolvasaskor torlendo!!!
;--------------------------------------------------------------------------------

getchar:
	PUSH	HL
	LD	HL,8031h
	DI
	LD	A,(HL)
	LD	(HL),00h
	EI
	POP	HL
	RET				; Az A regiszterben az utoljara lenyomott 
					; billentyu ASCII kodjaval ter vissza
;-----------------------------------------------------------------------------------

pause: 					;Ez a rutin az A regben tarolt ertek-szer 0,42 sec-ig var (-4 MHz CPU-).
					;Ha A-ban 0 volt, akkor visszater
	OR	A
	RET	Z
	
	PUSH	AF
	PUSH	HL
	LD	HL,0000h

pause01:

	DEC	HL
	LD	A,H
	OR	L
	JR	NZ,pause01
	POP	HL
	POP	AF
	
	DEC	A
	JR	pause
   
;------------------------------------------------------------------------------------

wrttxt:						;A szubrutin hivast koveto byte-okra el kell helyezni egy
	EX	(SP),HL				;szoveget .. 'Szoveg',00h formaban
	PUSH	AF				;A regiszterek tartalmát a végén visszaállítja
wrttxt2:	
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,wrttxt1
	CALL	putchstp
	JR	wrttxt2
	
wrttxt1:
	POP	AF
	EX	(SP),HL
	RET

;---------------------------------------------------------------------------------

waitch:
	
	CALL	getchar
	OR	A
	JR	Z,waitch
	RET				;Billentyulenyomasra varakozik, visszatereskor
					;a leutott billentyu ASCII kodja van az A regben.

;------------------------------------------------------------------------------------

waitchcur:
	
	CALL	getchar
	OR	A
	JR	Z,waitchcur
	RET				;Billentyulenyomasra varakozik, visszatereskor
					;a leutott billentyu ASCII kodja van az A regben.

					;kozben kurzort is mutat
;-----------------------------------------------------------------------------------------

putchar:
	LD	(8004h),A
	RET				;Kurzor aktualis poziciojara A-ban tarolt karaktert tesz
;-------------------------------------------------------------------------------------------

putchstp:				;Kurzor aktualis poziciojara A-ban tarolt karaktert tesz
	
	PUSH	HL			;majd a kurzort eggyel lepteti
	LD	(8004h),A
	LD	HL,(8000h)
	INC	HL
	CALL	curposchck	
	CALL	putcursor
	POP	HL
	RET	

;------------------------------------------------------------------------------------------------------
newline:
	PUSH	AF
	PUSH	HL
	LD	HL,(8000h)
	LD	A,L
	OR	1Fh
	LD	L,A
	INC	HL
	CALL	curposchck
	CALL	putcursor
	POP	HL
	POP	AF
	RET
;--------------------------------------------------------------------------------------------

scrollup:				;Ha HL-ben levo ertek 2400h, vagy nagyobb, 
	DI
	CALL	cursoroff		;akkor a kepernyot gorgeti
	
	LD	HL,2020h
	LD	DE,2000h
	LD	BC,03E0h		;992-szer ismetles
	LDIR

	

	LD	B,20h
	LD	HL,23E0h
	LD	A,20h
scruploop1:
	LD	(HL),A
	INC	L
	DJNZ	scruploop1
	
	LD	L,$E0
	CALL	putcursor		;  EI   -> A putcursor engedelyezi a vegen a megszakitasokat
	RET				
;-----------------------------------------------------------------------------------------	
scrtop:
	
	LD	HL,2000h
	CALL	putcursor
	RET
;------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;Billentyunyomasra mukodesbe lepo szubrutinok
;Mindegyik vegen A-t 0-ra kell allitani (XOR A)
;--------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------


	
enterkey:
	
	CALL	cmnddetct
	XOR	A
	RET

;-------------------------------------------------------------------------------------------------


backspc:
	
	PUSH	HL
	LD	HL,(8000h)
	DEC	HL
	CALL	curposchck
	CALL	putcursor
	LD	A,20h
	CALL	putchar
	POP	HL
	XOR	A
	RET


;----------------------------------------------------------------------------------------------------

left:
	
	PUSH	HL
	LD	HL,(8000h)
	DEC	HL
	CALL	curposchck
	CALL	putcursor
	POP	HL
	XOR	A
	RET


;-------------------------------------------------------------------------------------------------------

right:
	
	PUSH	HL
	LD	HL,(8000h)
	INC	HL
	CALL	curposchck
	CALL	putcursor
	POP	HL
	XOR	A
	RET

;----------------------------------------------------------------------------------------------------------------

up:
	
	PUSH	HL
	PUSH	BC
	LD	HL,(8000h)
	LD	BC,0020h
	SBC	HL,BC
	CALL	curposchck
	CALL	putcursor
	POP	BC
	POP	HL
	XOR	A
	RET

;---------------------------------------------------------------------------------------------------------------

down:
	
	PUSH	HL
	PUSH	BC
	LD	HL,(8000h)
	LD	BC,0020h
	ADC	HL,BC
	CALL	curposchck
	CALL	putcursor
	POP	BC
	POP	HL
	XOR	A
	RET

;-----------------------------------------------------------------------------------------------------------------
tabulate:
	
	PUSH	HL
	LD	HL,(8000h)
	LD	A,L
	AND	$F8
	ADD	A,08h
	LD	L,A
	LD	A,H
	ADC	A,00h
	LD	H,A
	CALL	curposchck
	CALL	putcursor
	POP	HL
	XOR	A
	RET

;----------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------

start:						; Innentol kezdve a vezerles a foprograme			
			

	CALL	login
	LD	HL,2000h
	CALL	putcursor			; Kurzor poziciojat a 2000h cimre allitja	
	
	CALL	wrttxt
	db	'    Monitor program ',00h
	CALL	newline
	CALL	wrttxt
	db	' Kun-Szabo Marton, 2008',00h
	CALL	newline
	CALL	newline

	LD	HL,8002h
	LD	(HL),01h			; Kurzort engedelyezi
	
	LD	HL,8016h
	LD	(8019h),HL			;Inverz ora megjelenites engedelyezese


foprogram:	



	
	
	CALL	waitchcur
	
	CP	0Dh
	CALL	Z,enterkey				;Enter
	CP	0Eh
	CALL	Z,backspc				;Backspace
	CP	04h
	CALL	Z,left					;Balra nyil	
	CP	06h
	CALL	Z,right					;Jobbra nyil	
	CP	08h
	CALL	Z,up					;Fel nyil	
	CP	02h
	CALL	Z,down					;Le nyil
	CP	05h
	CALL	Z,tabulate				;TAB gomb

	CP	00h
	CALL	NZ,putchstp				;Egyebkent karakter kiirasa, kurzor leptetese
	
	JP	foprogram				; Foprogram ciklus


;--------------------------------------------------------------------------------------------------------------------------



login:							;Udvozlo uzenet kiiratasa
	
	LD	HL,0C00h
	LD	DE,2000h
	LD	BC,0400h
	LDIR

	LD	A,0Fh
	CALL	pause
	CALL	cls
	RET
;------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------

;HEX-ASCII HIGH

;'A' felso 4 bitjet konvertalja
;ASCII eredmeny A-ban

hexasch:
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	
;       a hexascl rutin a kozvetlen folytatas!!

;--------------
;HEX-ASCII LOW

;'A' also 4 bitjet konvertalja 
;ASCII eredmeny A-ban

hexascl:
	AND	0Fh		; also 4 bit maszk
	ADD	A,30h
	CP	3Ah
	JP	M,hexascl1
	ADD	A,07h
	
hexascl1:
	RET


;---------------------------------------------------------------------------------------------



;ASCII-HEX 1 digit

; 'A' -t konvertalja
; HEX Eredmeny A-also 4 bitjen


aschex:
	SUB	30h
	BIT	4,A
	JR	Z,aschex1	
	SUB	07h
aschex1:
	AND	0Fh
	RET	



;-----------------------------------------------------------------------------------------------------

;ASCII-HEX 2 digit

; HL a felso HEX cimere mutat
; HEX Eredmeny A-ban


asc2hex:
	PUSH	BC
	LD	A,(HL)
	CALL	aschex
	SLA	A
	SLA	A
	SLA	A
	SLA	A
	LD	B,A
	INC	HL
	LD	A,(HL)
	CALL	aschex
	OR	B
	POP	BC
	RET
;----------------------------------------------------------------------------------------


;ASCII-HEX 4 digit

; 'HL' a felso HEX cimre mutat
; HEX eredmeny 'HL'-ben

asc4hex:
	PUSH	BC
	CALL	asc2hex
	LD	B,A
	INC	HL
	CALL	asc2hex
	LD	L,A
	LD	H,B
	POP	BC
	RET

;-----------------------------------------------------------------
;KARAKTER KERESESE A TARBAN	
; Az 'A'-ban van, amit keresunk, HL cimtol kezdve
; Visszatereskor HL ramutat, BC mutatja hogy hanyadik elem, Z=0
; Ha nem talalta meg, akkor Z=1
;
;charsrch:
;	
;	LD	BC,0000h
;charsrch2:
;	LD	D,A
;	LD	A,(HL)
;	CP	D
;	JR	Z,charsrch1
;	INC	HL
;	INC	BC
;	
;	LD	A,B
;	SUB	04h		;1kByte-ot nez at, ha nincs benne akkor nem talalja, Z=1
;	RET	Z
;	
;	JR	charsrch2
;
;charsrch1:
;	AND	A
;	RET	
;
;-----------------------------------------------------------------

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Pelda:	
	;
	;sanyi    <enter>
	;?
	;
	;Ismeretlen parancs eseten kerdojelet ir ki
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


cmdntfnd:
	CALL	newline		;uj sor
	LD	A,3Fh
	CALL	putchstp	;Kerdojel
	CALL	newline
	CALL	newline
	RET
;-----------------------------------------------------------------
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Pelda:	
	;
	;M086F    <enter>
	;>086F,A3
	;
	;memoriacimrol adat kiiratasa
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



monmemrd:
	DI			;A beolvasasig a kurzor letiltasa
	CALL	cursoroff	
	LD	HL,(8000h)
	LD	A,L
	AND	0E0H		;Sor elejere, 
	INC	A		;1-el jobbra
	LD	L,A	
	cALL	asc4hex
	EI
		
	CALL	newline		;Uj sor
	LD	A,3Eh
	CALL	putchstp	; '>' jel
		
	LD	A,H
	CALL	hexasch		;Cim Elso hexaja
	CALL	putchstp
	
	LD	A,H
	CALL	hexascl		;Cim Masodik hexaja
	CALL	putchstp
	
	LD	A,L
	CALL	hexasch		;Cim Harmadik hexaja
	CALL	putchstp

	LD	A,L
	CALL	hexascl		;Cim Negyedik hexaja
	CALL	putchstp
	
	LD	A,2Ch		;Vesszo
	CALL	putchstp
	
	LD	A,(HL)
	CALL	hexasch		;Adat Elso hexaja
	CALL	putchstp

	LD	A,(HL)
	CALL	hexascl		;Adat Masodik hexaja
	CALL	putchstp
	
	RET

;------------------------------------------------------------------
	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Pelda:	
	;
	;
	;>086F,A3	<enter>
	;
	;memoriacimbe kozvetlen adatiras
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





monmemwr:
	DI			;A beolvasasig a kurzor letiltasa
	CALL	cursoroff	
	LD	HL,(8000h)
	LD	A,L
	AND	0E0H		;Sor elejere, 
	INC	A		;1-el jobbra
	LD	L,A	
	cALL	asc4hex
	PUSH	HL		;A cimet eltaroljuk
	
	LD	HL,(8000h)
	LD	A,L
	AND	0E0H		;Sor elejere, 
	ADD	A,06h		;6-tal jobbra
	LD	L,A	
	CALL	asc2hex
	POP	HL
	LD	(HL),A
	CALL	newline

	EI
	RET
;-----------------------------------------------------------------

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Pelda:	
	;
	;
	;G086F   	<enter>
	;
	;felhasznaloi progi inditasa
	;visszateres, a program vegen kiadott RET-tel
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mongo:
	DI			;A beolvasasig a kurzor letiltasa
	CALL	cursoroff	
	LD	HL,(8000h)
	LD	A,L
	AND	0E0H		;Sor elejere, 
	INC	A		;1-el jobbra
	LD	L,A	
	cALL	asc4hex
	EI
	CALL	newline
	JP	(HL)
	
;----------------------------------------------------------------------

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Pelda:	
	;                    -16:45:00-
	;
	;T16:45:00  	<enter>
	;
	;ido beallitasa
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

montimeset:

	DI			;A beolvasasig a kurzor letiltasa
	CALL	cursoroff	
	LD	HL,(8000h)
	LD	BC,8016h
	
	LD	A,L
	AND	0E0H		;Sor elejere, 
	INC	A		;1-el jobbra
	LD	L,A	
	LD	A,(HL)
	cALL	aschex
	LD	(BC),A
	DEC	C

	INC	L
	LD	A,(HL)
	cALL	aschex
	LD	(BC),A
	DEC	C

	INC	L
	INC	L	
	LD	A,(HL)
	cALL	aschex
	LD	(BC),A
	DEC	C

	INC	L	
	LD	A,(HL)
	cALL	aschex
	LD	(BC),A
	DEC	C

	INC	L	
	INC	L
	LD	A,(HL)
	cALL	aschex
	LD	(BC),A
	DEC	C

	INC	L	
	LD	A,(HL)
	cALL	aschex
	LD	(BC),A
	
	EI
	CALL	newline
	RET
;-----------------------------------------------------------------
; Parancs detektálása
; Amelyik sorban a kurzor eppen van, ott megnezi, h van-e a sor elejen parancs, eloallitja a
; parancsvegrehajto belepesi cimet, odaugrik


cmnddetct:	

	LD	HL,(8000h)
	LD	A,L
	AND	0E0H		;Sor elejere
	LD	L,A	
	
	DI			;A beolvasasig a kurzor letiltasa
	CALL	cursoroff	
	LD	A,(HL)		;A sor elso karakterenek kodja A-ban
	EI
	CALL	cmdsrch		;Eredmeny C-ben
	SLA	C
	SLA	C		;4 byte-onkent vannak az ugroutasitasok
	LD	H,0Ah		;Baziscim: 0A00h
	LD	L,C
	JP	(HL)


;-----------------------------------------------------------------
;PARANCS KERESESE A TARBAN	
; Az 'A'-ban van, amit keresunk, HL cimtol kezdve
; Visszatereskor C mutatja hogy hanyadik elem
; Ha nem talalta meg, akkor A=0Fh

cmdsrch:
	LD	HL,0AC0h	;Baziscim, ahol keresunk
	LD	C,00h
	LD	B,A		;B-be rakjuk a keresendo karaktert
cmdsrch2:
	LD	A,(HL)		;A-ba toltjuk a memoriahelyen levo betut
	CP	B		;Osszehasonlitjuk a keresettel
	JR	Z,cmdsrch3	;Ha ugyanaz, akkor kilepes
	INC	HL		;Ha nem, akkor noveles eggyel
	INC	C		
	LD	A,C		
	CP	0Fh		;16 Byte-ot nez at, 
	JR	NZ,cmdsrch2	;Ha meg nem volt meg mind a 16, akkor folytatja
	
cmdsrch3:
	RET



;---------------------------------------------------------------------;
;;-------------------------------------------------------------------;;
;;								     ;;
;;   			TABLAZATOK				     ;;
;;								     ;;
;;--------------------------------------------------------------------;
;---------------------------------------------------------------------;

	
;Monitorparancs ugrótáblák  0A00h

	org	0A00h
	JP	newline
			
	org	0A04h
	JP	monmemrd

	org	0A08h
	JP	monmemwr

	org	0A0Ch
	JP	mongo
	
	org	0A10h
	JP	montimeset

	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	JP	cmdntfnd


;Monitorparancsok
	org	0AC0h

	db	' M',03Eh,'GTFHCSLVRX',00h,00h,00h,00h		;Monitorprogram egybyte-os parancsai
	db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
	
;	Szóköz		00
;	M		01
;	>		02
;	R		03
;	C		04
;	F		05
;	H		06
;	T		07
;	S		08
;	L		09
;	V		0A
;	G		0B
;	X		0C
;	Vege		0D
;
;
;
;
;
;
;
;

;---------------------------------------------------------------------------------------------------------------------


	org	0B00h						
	
	;ASCII kodtablazat
	
	
	
	db	27h,'q','1',05h,0Bh,00h,'z','a'			;Alap
	db	00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h
	db	81h,'w','2',00h,00h,00h,'x','s'
	db	82h,'e','3',83h,84h,00h,'c','d'
	db	'5','r','4','t','g','b','v','f'
	db	'6','u','7','y','h','n','m','j'
	db	88h,'o','9',87h,00h,00h,2Eh,'l'
	db	00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,2Bh,00h,00h,00h,00h,00h,00h
	db	00h,'9',00h,'6',2Ch,2Dh,2Ah,'3'
	db	00h,'8',00h,'5','0',00h,2Fh,'2'
	db	00h,'7',00h,'4',00h,00h,00h,'1'
	db	2Dh,'p','0',5Bh,27h,2Fh,5Ch,3Bh
	db	3Dh,'i','8',5Dh,86h,00h,2Ch,'k'
	db	89h,00h,8Ah,0Eh,85h,20h,0Dh,00h

		
	
	
	db	00h,'Q',21h,00h,00h,00h,'Z','A'			;Shift
	db	00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,'W',40h,00h,00h,00h,'X','S'
	db	00h,'E',23h,00h,00h,00h,'C','D'
	db	25h,'R',24h,'T','G','B','V','F'
	db	5Eh,'U',26h,'Y','H','N','M','J'
	db	00h,'O',28h,00h,00h,00h,3Eh,'L'
	db	00h,00h,00h,00h,00h,00h,00h,00h
	db	00h,2Bh,00h,00h,00h,00h,00h,00h
	db	00h,09h,00h,06h,0Fh,2Dh,2Ah,03h
	db	00h,08h,00h,00h,0Ah,00h,2Fh,02h
	db	00h,07h,00h,04h,00h,00h,00h,01h
	db	2Dh,'P',29h,7Bh,22h,3Fh,00h,3Ah
	db	2Bh,'I',2Ah,7Dh,00h,00h,3Ch,'K'
	db	00h,00h,00h,00h,00h,20h,0Dh,00h
	

	;
	;
	;End:			01h
	;Le nyil:		02h	
	;Page down:		03h
	;Balra nyil:		04h
	;TAB:			05h
	;Jobbra nyil:		06h
	;Home:			07h
	;Fel nyil:		08h
	;Pageup:		09h
	;Insert:		0Ah	
	;Escape:		0Bh
	;			
	;Enter:			0Dh
	;Backspace:		0Eh
	;Del:			0Fh
	;
	;F1:			81H
	;F2:			82h
	;F3:			83h
	;F4:			84h
	;F5:			85h
	;F6:			86h
	;F7:			87h
	;F8:			88h
	;F9:			89h
	;F10:			8Ah
	;
	;
	
	
	
	
	
	
	
	


;---------------------------------------------------------------------------------------

;Z80 inside logo:
;-------------------------------------------------------------------------------------
	org 	0C00h

	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Bh,03h,03h,03h,03h,00h,00h,01h,03h,03h,03h,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Bh,03h,02h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Bh,02h,00h,00h,00h,00h,0Ch,0Ch,0Ch,0Fh,0Fh,0Fh,0Fh,0Fh,0Eh,0Ch,0Fh,0Ch,00h,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Bh,03h,00h,00h,04h,0Ch,0Ch,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,03h,03h,00h,01h,03h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Bh,00h,00h,04h,0Dh,0Fh,0Fh,0Fh,0Fh,0Fh,0Bh,04h,0Ch,08h,07h,0Fh,08h,00h,00h,00h,00h,00h,03h,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,02h,00h,04h,0Dh,0Fh,0Fh,0Fh,0Bh,0Ch,01h,0Fh,02h,0Fh,0Fh,0Fh,08h,0Fh,0Fh,0Fh,0Eh,0Ch,00h,00h,00h,03h,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,03h,00h,0Ch,03h,04h,08h,04h,0Fh,0Ah,0Fh,06h,0Fh,00h,0Fh,0Fh,0Fh,0Ah,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,08h,00h,01h,0Fh,0Fh
	db 0Fh,0Fh,02h,00h,0Dh,0Fh,05h,0Fh,0Ah,0Dh,0Fh,0Eh,04h,01h,07h,0Ah,07h,0Fh,0Fh,04h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Eh,00h,05h,0Fh
	db 0Fh,0Bh,00h,0Dh,0Fh,0Fh,0Fh,0Fh,02h,0Fh,0Fh,0Fh,05h,0Eh,05h,0Fh,08h,03h,0Ch,0Fh,0Bh,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,08h,01h,0Fh
	db 0Fh,0Ah,05h,0Fh,0Fh,0Fh,0Fh,0Ah,05h,0Fh,0Fh,07h,05h,0Bh,0Dh,0Fh,0Fh,0Fh,0Fh,0Fh,0Ah,05h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Ah,00h,0Fh
	db 0Fh,00h,0Dh,0Fh,0Fh,0Fh,0Fh,0Ah,0Dh,03h,02h,0Dh,0Eh,0Dh,0Fh,0Fh,0Ah,05h,0Fh,0Fh,02h,05h,02h,0Ch,01h,0Fh,0Fh,0Fh,0Fh,0Fh,00h,0Fh
	db 0Ah,04h,0Fh,0Fh,0Fh,0Fh,0Fh,0Ch,0Ch,0Dh,0Fh,0Fh,0Fh,0Fh,0Fh,01h,0Bh,07h,0Bh,00h,08h,05h,00h,02h,0Dh,0Fh,0Fh,0Fh,0Fh,0Ah,00h,0Fh
	db 0Ah,05h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,00h,0Ch,0Ah,05h,02h,04h,0Ah,05h,00h,0Dh,03h,0Fh,0Fh,0Fh,0Fh,0Ah,05h,0Fh
	db 0Ah,05h,0Fh,0Fh,0Fh,0Fh,0Fh,0Eh,00h,0Bh,03h,03h,03h,0Ah,01h,0Fh,0Ah,05h,00h,01h,00h,05h,08h,00h,0Dh,0Fh,0Fh,0Fh,0Fh,00h,0Dh,0Fh
	db 0Ah,01h,0Fh,0Fh,0Fh,0Fh,0Fh,0Bh,03h,0Ah,00h,08h,00h,0Fh,0Ah,00h,0Ah,05h,0Ah,04h,0Ah,05h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,00h,05h,0Fh,0Fh
	db 0Fh,08h,07h,0Fh,0Fh,0Fh,0Fh,0Ah,00h,0Ah,00h,0Fh,00h,0Fh,00h,04h,0Eh,0Dh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,02h,04h,0Fh,0Fh,0Fh
	db 0Fh,0Eh,01h,0Fh,0Fh,0Fh,0Fh,0Eh,00h,0Eh,0Ch,0Fh,0Ch,0Fh,0Ch,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,03h,00h,04h,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,08h,00h,07h,0Fh,0Fh,0Fh,00h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Bh,02h,00h,0Ch,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Ch,00h,03h,07h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Bh,03h,00h,00h,04h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Eh,00h,00h,00h,01h,03h,03h,03h,03h,03h,03h,03h,03h,03h,03h,00h,00h,00h,04h,0Dh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Eh,0Ch,0Ch,00h,00h,00h,00h,00h,00h,00h,00h,04h,0Ch,0Ch,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh
	db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh


	db 0Fh,0Fh,0Fh,0EBh,0F5h,0EEh,0F3h,0FAh,0E1h,0E2h,0EFh,0EDh,0E1h,0F2h,0F4h,0EFh,0EEh,0E0h,0E8h,0EFh,0F4h,0EDh,0E1h,0E9h,0ECh,0AEh,0E3h,0EFh,0EDh,0Fh,0Fh,0Fh

;---------------------------------------------------------------------------------------------

