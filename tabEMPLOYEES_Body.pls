create or replace PACKAGE BODY tabEMPLOYEES
AS
  PROCEDURE doUpdate (p_row IN EMPLOYEES % ROWTYPE)
  AS
  BEGIN
    UPDATE EMPLOYEES
      SET FIRST_NAME = p_row.FIRST_NAME, 
          LAST_NAME = p_row.LAST_NAME, 
          EMAIL = p_row.EMAIL, 
          PHONE_NUMBER = p_row.PHONE_NUMBER, 
          HIRE_DATE = p_row.HIRE_DATE,
          JOB_ID = p_row.JOB_ID, 
          SALARY = p_row.SALARY, 
          COMMISSION_PCT = p_row.COMMISSION_PCT, 
          MANAGER_ID = p_row.MANAGER_ID, 
          DEPARTMENT_ID = p_row.DEPARTMENT_ID
    WHERE EMPLOYEE_ID = p_row.EMPLOYEE_ID;
  END doUpdate;

  PROCEDURE doInsert ( p_row IN EMPLOYEES % ROWTYPE)
  AS
  BEGIN
    INSERT
      INTO EMPLOYEES(EMPLOYEE_ID,
                     FIRST_NAME,
                     LAST_NAME,
                     EMAIL,
                     PHONE_NUMBER,
                     HIRE_DATE,
                     JOB_ID,
                     SALARY,
                     COMMISSION_PCT,
                     MANAGER_ID,
                     DEPARTMENT_ID)
      VALUES (p_row.EMPLOYEE_ID,
              p_row.FIRST_NAME,
              p_row.LAST_NAME,
              p_row.EMAIL,
              p_row.PHONE_NUMBER,
              p_row.HIRE_DATE,
              p_row.JOB_ID,
              p_row.SALARY,
              p_row.COMMISSION_PCT,
              p_row.MANAGER_ID,
              p_row.DEPARTMENT_ID);
  END doInsert;

  PROCEDURE sel (
    p_id        IN  EMPLOYEES.EMPLOYEE_ID % TYPE,
    p_row       OUT EMPLOYEES % ROWTYPE,
    p_forUpdate IN  BOOLEAN := FALSE,
    p_rase      IN  BOOLEAN := TRUE)
  AS
  BEGIN
    IF p_forUpdate THEN
      SELECT *
        INTO p_row
        FROM EMPLOYEES
        WHERE EMPLOYEE_ID = p_id FOR UPDATE;
    ELSE
      SELECT *
        INTO p_row
        FROM EMPLOYEES
        WHERE EMPLOYEE_ID = p_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF p_rase THEN
        RAISE;
      END IF;
  END sel;


  PROCEDURE ins (
    p_row    IN EMPLOYEES % ROWTYPE,
    p_update IN BOOLEAN := FALSE)
  AS
  BEGIN
    IF p_update AND tabEMPLOYEES.exist (p_row.EMPLOYEE_ID) THEN
      doUpdate (p_row);
    ELSE
      doInsert (p_row);
    END IF;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR (-20001, 'Попытка вставки дублирующегося значения ключа.');
    WHEN OTHERS THEN
      RAISE;
  END ins;

 PROCEDURE upd (
    p_row    IN EMPLOYEES % ROWTYPE,
    p_insert IN BOOLEAN := FALSE)
  AS
  BEGIN
    IF NOT tabEMPLOYEES.exist (p_row.EMPLOYEE_ID) AND p_insert THEN
      doInsert (p_row);
    ELSE
      doUpdate (p_row);
    END IF;
  END upd;

  PROCEDURE del (
    p_id IN EMPLOYEES.EMPLOYEE_ID % TYPE)
  AS
  BEGIN
    IF tabEMPLOYEES.exist (p_id) THEN
      DELETE FROM EMPLOYEES
        WHERE EMPLOYEE_ID = p_id;
    ELSE
      RAISE_APPLICATION_ERROR (-20992, 'Не нвйдена запись для удаления!');
    END IF;
  END del;

  FUNCTION exist (
    p_id IN EMPLOYEES.EMPLOYEE_ID % TYPE)
    RETURN BOOLEAN
  AS
    v_exist INTEGER;
  BEGIN
    SELECT COUNT (1)
      INTO v_exist
      FROM EMPLOYEES
      WHERE EMPLOYEE_ID = p_id;
    IF v_exist = 1  THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END exist;



END tabEMPLOYEES;
