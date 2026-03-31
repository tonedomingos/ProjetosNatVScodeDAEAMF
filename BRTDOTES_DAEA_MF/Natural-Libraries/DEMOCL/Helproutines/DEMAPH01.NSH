* >Natural Source Header 000000
* :Mode S
* :CP IBM01140
* :LineIncrement 10
* <Natural Source Header
************************************************************************
*  APPLICATION : DEMAPP - DEMO APPLICATION FOR ARF/ALA PRODUCTS
*  HELPROUTINE : DEMAPH01
*              : LIST AND SELECT EXISTING EMPLOYEES
*  CREATED BY  : LUCIANO PIMENTA
************************************************************************
DEFINE DATA
PARAMETER
1 #PARM-PERSONNEL-ID  (A08)
LOCAL
1 EMPL VIEW OF EMPLOYEES
  2 PERSONNEL-ID
  2 NAME

1 #TL-TAB-SEL                  (A01/1:300)
1 #PERSONNEL-ID                (A08/1:300)
1 #NAME                        (A20/1:300)
1 #PERSONNEL-ID-INIC           (A08)
1 #CV-SEL                      (C/1:300)
1 #IND-TAB                     (N7)
1 #IND-FIM                     (P3)
1 #IND                         (P3)
1 #INDEX                       (P3)
1 #FLG                         (L)
END-DEFINE

SET KEY ALL

PERFORM LOAD-EMP-LIST

REPEAT
  SET CONTROL 'WL47C21FB2/35'
  SET CONTROL 'M19'
  INPUT USING MAP 'DEMAPM01'

  DECIDE ON FIRST VALUE *PF-KEY
    VALUE 'PF3'
      SET CONTROL 'WB'
      SET CONTROL 'MT'
      ESCAPE BOTTOM
    VALUE 'PF7'
      IF #PERSONNEL-ID-INIC NE ' '
        PERFORM LOAD-EMP-LIST
        ESCAPE TOP
      END-IF
      IF #IND-TAB = 1
        REINPUT 'First Page...' ALARM
      END-IF
      SUBTRACT 10 FROM #IND-TAB
    VALUE 'PF8'
      IF #PERSONNEL-ID-INIC NE ' '
        PERFORM LOAD-EMP-LIST
        ESCAPE TOP
      END-IF
      IF #IND < (#IND-TAB + 10)
        REINPUT 'Last Page...' ALARM
      END-IF
      ADD 10 TO #IND-TAB
    VALUE 'ENTR'
      IF #PERSONNEL-ID-INIC NE ' '
        PERFORM LOAD-EMP-LIST
        ESCAPE TOP
      END-IF

      PERFORM SCAN-SELECTION
      IF NOT #FLG
        IF #IND < (#IND-TAB + 10)
          REINPUT 'Last Page...' ALARM
        END-IF
        ADD 10 TO #IND-TAB
      ELSE
        SET CONTROL 'WB'
        SET CONTROL 'MT'
        ESCAPE BOTTOM
      END-IF
    NONE VALUE
      REINPUT 'Invalid <PF-Key> pressed.' ALARM
  END-DECIDE
END-REPEAT

DEFINE SUBROUTINE LOAD-EMP-LIST
RESET #TL-TAB-SEL(*) #PERSONNEL-ID (*) #NAME (*) #IND
MOVE 1       TO #IND-TAB
MOVE (AD=PN) TO #CV-SEL(*)
READ EMPL WITH PERSONNEL-ID = #PERSONNEL-ID-INIC
  IF #IND < 300
    ADD 1 TO #IND
    MOVE EMPL.PERSONNEL-ID TO #PERSONNEL-ID (#IND)
    MOVE EMPL.NAME TO #NAME (#IND)
  END-IF
END-READ
IF #IND NE 0
  MOVE (AD=I) TO #CV-SEL(1:#IND)
END-IF
RESET #PERSONNEL-ID-INIC
END-SUBROUTINE

DEFINE SUBROUTINE SCAN-SELECTION
COMPUTE #IND-FIM = #IND-TAB + 9
RESET #FLG  #PARM-PERSONNEL-ID
FOR #INDEX #IND-TAB #IND-FIM
  DECIDE ON FIRST VALUE #TL-TAB-SEL(#INDEX)
    VALUE ' '
      IGNORE
    VALUE 'X'
      IF #FLG
        REINPUT 'Select just one Personnel ID.' MARK *#TL-TAB-SEL(#INDEX)
          ALARM
      ELSE
        MOVE TRUE TO #FLG
        MOVE #PERSONNEL-ID (#INDEX) TO #PARM-PERSONNEL-ID
      END-IF
    NONE VALUE
      REINPUT 'Select with a "X"' MARK *#TL-TAB-SEL(#INDEX) ALARM
  END-DECIDE
END-FOR

END-SUBROUTINE
END
