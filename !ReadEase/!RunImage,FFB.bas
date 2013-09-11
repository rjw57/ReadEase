REM >!RunImage
REM ReadEase main program.
:
PROCinit
:
WHILE NOT quit%
PROCpoll
ENDWHILE
SYS "Wimp_CloseDown"
END
:
DEF PROCinit
DIM words(2000)
DIM iblock% 32
word_len=0
percent_syll=7
file_loaded=FALSE
maxws%=&300

DIM block% 1000,name% 11,mainind% maxws%
DIM mainind2% maxws%
DIM wimpicon% 20
DIM imenu% 99,te1% 30,te2% 30,te3% 30,te4% 30
DIM font% 256,P% 2048,Q% 2048
DIM icontext% 40
quit%=FALSE:app$="ReadEase"
SYS "Wimp_Initialise",200,&4B534154,app$
ON ERROR PROCerror(REPORT$+" at line "+STR$ERL)
file%=OPENIN"<ReadEase$Dir>.!Sprites"
size%=EXT#file%+4:CLOSE#file%
DIM sparea% size%
!sparea%=size%:sparea%!4=0
sparea%!8=16
sparea%!12=16
SYS "OS_SpriteOp",&10A,sparea%,"<ReadEase$Dir>.!Sprites"
SYS "Wimp_OpenTemplate",,"<ReadEase$Dir>.Templates"
SYS "Wimp_LoadTemplate",,P%,mainind%,mainind%+maxws%,-1,"indicator",0
SYS "Wimp_LoadTemplate",,Q%,mainind2%,mainind2%+maxws%,-1,"info",0
SYS "Wimp_CreateWindow",,P% TO indicator%
SYS "Wimp_CreateWindow",,Q% TO info%
SYS "Wimp_CloseTemplate"
PROCsetupmenu(imenu%)
$wimpicon%="eyecross"
block%!0=-1:block%!4=0:block%!8=0:block%!12=34*2:block%!16=17*4
block%!20=&0700311A:block%!24=wimpicon%:block%!28=-1:REM sparea%
block%!32=LEN("eyecross")
SYS "Wimp_CreateIcon",,block% TO ibhandle%
REM ibhandle%=FNcreate_icon(-1,0,0,68,68,&3002,"!drawcad",0,0,0)
PROCwrite_t(info%,4,"1.07 (5th May 1994)")
ENDPROC
:
DEF PROCpoll
SYS "Wimp_Poll",0,block% TO reason%
CASE reason% OF
WHEN 2:SYS "Wimp_OpenWindow",,block%
WHEN 3:SYS "Wimp_CloseWindow",,block%
WHEN 6:PROCclick(block%!12)
WHEN 9:PROCmenuselect
WHEN 17,18:PROCreceive
ENDCASE
ENDPROC
:
DEF PROCreport(err$,flag%)
name$=app$
IF flag% AND 16 THEN name$="Message from "+name$
!block%=255
$(block%+4)=err$+CHR$0
SYS "Wimp_ReportError",block%,flag%,name$ TO ,errclick%
ENDPROC
:
DEF PROCerror(a$)
SYS "Hourglass_Smash"
*CLOSE
PROCreport(a$,1)
SYS "Wimp_CloseDown"
END
ENDPROC
:
DEF PROCreceive
CASE block%!16 OF
WHEN 0:quit%=TRUE
WHEN 3:PROCdataload(block%!40)
ENDCASE
ENDPROC
:
DEF PROCdataload(type%)
IF type%<>&FFF THEN ENDPROC
SYS "Hourglass_On"
path$=FNstring(block%+44)
PROCload_file(path$)
SYS "Hourglass_Off"
$wimpicon%="eye"
block%!0=-2:block%!4=ibhandle%:block%!8=0:block%!12=0
SYS "Wimp_SetIconState",,block%
ENDPROC
:
DEF FNstring(ptr%)
LOCAL a$
WHILE ?ptr%<>0
a$+=CHR$(?ptr%):ptr%+=1
ENDWHILE
=a$
:
DEF PROCclick(win%)
CASE win% OF
WHEN info%:PROCinfo_sel(block%!16)
WHEN -2:PROCibar(block%!8)
ENDCASE
ENDPROC
:
DEF PROCinfo_sel(no)
IF no=10 THEN *Filer_Run <ReadEase$Dir>.Manual
ENDPROC
:
DEF PROCibar(button%)
CASE button% OF
WHEN 1,4:PROCibar_click
WHEN 2:PROCshowmenu(imenu%,!block%-64,200)
ENDCASE
ENDPROC
:
DEF PROCibar_click
IF file_loaded=FALSE THEN PROCreport("No file loaded!",19):ENDPROC
PROCwrite_l(indicator%,2,percent_syll)
PROCwrite_t(indicator%,3,STR$(percent_syll)+"% Words containing 3 or more syllables")
PROCwrite_t(indicator%,4,"Mean number of words per sentence = "+STR$(word_len))
PROCwrite_t(indicator%,5,"Reading Ease Quotient = 0.4("+STR$(word_len)+"+"+STR$(percent_syll)+")+5")
RA=0.4*(percent_syll+word_len)
RA+=5
PROCwrite_t(indicator%,6,"Reading Ease Quotient = "+STR$(RA))
!block%=indicator%
SYS "Wimp_GetWindowState",,block%
block%!28=-1
SYS "Wimp_OpenWindow",,block%
ENDPROC
:
DEF PROCsetupmenu(menu%)
READ title$,num%:$menu%=title$
width%=(LEN(title$)-2)*16
menu%!12=&70207:menu%!20=44:menu%!24=0
ptr%=menu%+28:FOR i%=1 TO num%
READ mflags%,subptr%,item$
!ptr%=mflags%:ptr%!4=subptr%
ptr%!8=&7000021:$(ptr%+12)=item$
a%=(LEN(item$)+1)*16
IF a%>width% width%=a%
ptr%+=24:NEXT
menu%!16=width%
ENDPROC
:
DEF PROCshowmenu(menu%,mx%,my%)
SYS "Wimp_CreateMenu",,menu%,mx%,my%
ENDPROC
:
DEF PROCmenuselect
sel1%=!block%:sel2%=block%!4
SYS "Wimp_GetPointerInfo",,block%
button%=block%!8
CASE sel1% OF
WHEN 1:quit%=TRUE
ENDCASE
IF button%=1 THEN PROCshowmenu(imenu%,0,0)
ENDPROC
:
DEF FNcreate_icon(whan%,ix%,iy%,iw%,ih%,flag%,text$,ptr1%,ptr2%,ptr3%)
!block%=whan%
block%!4=ix%
block%!8=iy%
block%!12=ix%+iw%
block%!16=iy%+ih%
block%!20=flag%
IF ptr1%=0 THEN
$(block%+24)=text$
ELSE
block%!24=ptr1%
block%!28=ptr2%
block%!32=ptr3%
ENDIF
SYS "Wimp_CreateIcon",,block% TO ihandle%
=ihandle%
:
DEF PROCwrite_l(win%,ic%,plu)
!block%=win%:block%!4=ic%
SYS "Wimp_DeleteIcon",,block%
a%=FNcreate_icon(win%,24,-254,6.32*plu,50,&A7000039," ",0,0,0)
ENDPROC
:
DEF PROCwrite_t(win%,ic%,text$)
!block%=win%:block%!4=ic%
SYS "Wimp_GetIconState",,block%
$(block%!28)=text$
!block%=win%:block%!4=ic%
block%!8=0:block%!12=0
SYS "Wimp_SetIconState",,block%
ENDPROC
:
DEF PROCload_file(path$)
file_loaded=TRUE
TEMP$=""
cnt=0
cnt2=0
TEMP$=""
byte_no=0
SY3=0
f=OPENIN(path$)
tot_size=EXT#f+4
REPEAT
REPEAT
T=BGET#f
byte_no+=1
SYS "Hourglass_Percentage",INT((byte_no/tot_size)*100)
IF T>=ASC("a") AND T<=ASC("z") THEN T-=32
TEMP$+=CHR$(T)
UNTIL T=32 OR T=10 OR T=13 OR T=ASC(".") OR T=ASC(";") OR T=ASC(":") OR T=ASC("?") OR T=ASC("!") OR EOF#f
TEMP$=LEFT$(TEMP$,LEN(TEMP$)-1)
IF FNsyllables(TEMP$)>=3 THEN SY3+=1
ENDIF
TEMP$=""
cnt+=1
IF T<>32 THEN words(cnt2)=cnt:cnt2+=1:cnt=0
UNTIL EOF#f
CLOSE #f
T=0
FOR LOOP=0 TO cnt2-1
T+=words(LOOP)
NEXT
percent_syll=(SY3/T)*100
percent_syll=INT(percent_syll)
word_len=T/(cnt2-1)
word_len=INT(word_len)
PROCibar_click
ENDPROC
:
DEF FNsyllables(word$)
LOCAL Letter$,NextLetter$,Scan
PRINT
PRINT "Scanning : ";word$
PRINT
Syllables=0
FOR Scan=1 TO LEN(word$)
Letter$=MID$(word$,Scan,1)
NextLetter$=MID$(word$,Scan+1,1)
CASE Letter$ OF
WHEN "A","E","I","O","U":Syllables+=1
CASE NextLetter$ OF
WHEN "E","O","I":Syllables-=1
WHEN "A","U":IF Letter$="I" THEN
REM Do nothing -----
ELSE
Syllables-=1
ENDIF
ENDCASE
WHEN "H":IF NextLetter$="M" THEN Syllables+=1
ENDCASE
IF NextLetter$="Y" AND Letter$<>"A" AND Letter$<>"E" AND Letter$<>"I" AND Letter$<>"O" AND Letter$<>"U" THEN Syllables+=1
NEXT
IF RIGHT$(word$,3)="ES " THEN Syllables-=1
IF RIGHT$(word$,3)="EA " THEN Syllables+=1
IF RIGHT$(word$,3)="ED " THEN Syllables-=1
PRINT
PRINT "Number of syllables in word : ";Syllables
=Syllables
:
DATA ReadEase,2,%10,info%,Info,&80,-1,Quit
