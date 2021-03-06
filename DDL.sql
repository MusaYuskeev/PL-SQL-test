
ALTER TABLE EMPLOYEES
ADD
(
"UPD_COUNTER" NUMBER (6, 0),
"CRT_USER" VARCHAR2 (20 BYTE),
"CRT_DATE" DATE,
"UPD_USER" VARCHAR2 (20 BYTE),
"UPD_DATE" DATE
);


CREATE OR REPLACE TRIGGER TRG_EMPLOYEES_LOG
  BEFORE INSERT OR UPDATE
  ON EMPLOYEES
  FOR EACH ROW
BEGIN

  IF INSERTING
  THEN
    :NEW."CRT_USER" := USER;
    :NEW."CRT_DATE" := SYSDATE;
  ELSE
    :NEW."UPD_USER" := USER;
    :NEW."UPD_DATE" := SYSDATE;
  END IF;

END;


CREATE TABLE MESSAGES
(
  "ID"        NUMBER(10, 0) NOT NULL,
  "MSG_TEXT"  VARCHAR2(120 BYTE),
  "MSG_TYPE"  VARCHAR2(6 BYTE),
  "DEST_ADDR" VARCHAR2(20 BYTE),
  "MSG_STATE" NUMBER(1, 0)
);

CREATE UNIQUE INDEX MESSAGES_ID_PK ON MESSAGES ("ID");


ALTER TABLE MESSAGES ADD CONSTRAINT MESSAGES_ID_PK PRIMARY KEY ("ID")
USING INDEX MESSAGES_ID_PK ENABLE;
CREATE SEQUENCE MESSAGES_SEQ MINVALUE 1 INCREMENT BY 1 START WITH 1;

CREATE OR REPLACE TRIGGER TRG_MESSAGES_INSERTS
  BEFORE INSERT
  ON MESSAGES
  FOR EACH ROW
BEGIN

  IF :NEW.ID IS NULL
  THEN
    SELECT MESSAGES_SEQ.NEXTVAL
      INTO :NEW.ID
      FROM SYS.DUAL;

  END IF;

END;






