create or replace PACKAGE BODY entEMPLOYEES
AS

  PROCEDURE payrise (
    p_employee_id IN EMPLOYEES.EMPLOYEE_ID % TYPE,
    p_salary      IN EMPLOYEES.SALARY % TYPE := NULL)
  AS
    v_maxsalary JOBS.MAX_SALARY % TYPE;
    v_newsalary EMPLOYEES.SALARY % TYPE;
  BEGIN

    SELECT MAX_SALARY
      INTO v_maxsalary
      FROM JOBS
      WHERE JOB_ID =
        (SELECT JOB_ID
            FROM EMPLOYEES
          WHERE EMPLOYEE_ID = p_employee_id);
    SELECT NVL2 (p_salary, p_salary, SALARY * 1.1)
      INTO v_newsalary
      FROM EMPLOYEES
      WHERE EMPLOYEE_ID = p_employee_id;

    IF v_newsalary > v_maxsalary THEN
      RAISE_APPLICATION_ERROR (-20001, 'GREATER THEN MAX SALARY.');
    END IF;
    UPDATE EMPLOYEES
      SET SALARY = v_newsalary
    WHERE EMPLOYEE_ID = p_employee_id;

  --send_message();
  END payrise;

  PROCEDURE leave (
    p_employee_id IN EMPLOYEES.EMPLOYEE_ID % TYPE)
  AS
  BEGIN
    UPDATE EMPLOYEES
      SET DEPARTMENT_ID = NULL
    WHERE EMPLOYEE_ID = p_employee_id;
  -- send_message();
  END leave;

  PROCEDURE employment (
    p_first_name     IN EMPLOYEES.FIRST_NAME % TYPE,
    p_last_name      IN EMPLOYEES.LAST_NAME % TYPE,
    p_email          IN EMPLOYEES.EMAIL % TYPE,
    p_phone_number   IN EMPLOYEES.PHONE_NUMBER % TYPE,
    p_job_id         IN EMPLOYEES.JOB_ID % TYPE,
    p_department_id  IN EMPLOYEES.department_id % TYPE,
    p_salary         IN EMPLOYEES.SALARY % TYPE         := NULL,
    p_commission_pct IN EMPLOYEES.COMMISSION_PCT % TYPE := NULL)
  AS
    emp_rec      EMPLOYEES % ROWTYPE;
    v_salary     EMPLOYEES.SALARY % TYPE;
    v_pct        EMPLOYEES.COMMISSION_PCT % TYPE;
    v_manager_id EMPLOYEES.MANAGER_ID % TYPE;
    CURSOR c_dept
    IS
      SELECT NVL (AVG (SALARY), 0) AS avg_salary, NVL (AVG (COMMISSION_PCT), 0) AS avg_commission_pct
        FROM EMPLOYEES
        WHERE department_id = p_department_id
          AND JOB_ID = p_job_id;
    CURSOR c_manager 
    IS
      SELECT MANAGER_ID
        FROM DEPARTMENTS 
        WHERE DEPARTMENT_ID = p_department_id;
  BEGIN
      IF p_salary IS NULL OR p_commission_pct IS NULL THEN
        OPEN c_dept;
        FETCH c_dept INTO v_salary, v_pct;
        CLOSE c_dept;
      END IF;

      OPEN c_manager;
      FETCH c_manager INTO v_manager_id;
      CLOSE c_manager;

      emp_rec.FIRST_NAME := p_first_name;
      emp_rec.LAST_NAME := p_last_name;
      emp_rec.EMAIL := p_email;
      emp_rec.PHONE_NUMBER := p_phone_number;
      emp_rec.HIRE_DATE := SYSDATE;
      emp_rec.JOB_ID := p_job_id;
      emp_rec.SALARY := NVL (p_salary, v_salary);
      emp_rec.COMMISSION_PCT := NVL (p_commission_pct, v_pct);
      emp_rec.MANAGER_ID := v_manager_id;
      emp_rec.department_id := p_department_id;

      tabEMPLOYEES.ins (emp_rec);

    -- send_message();
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
   END employment;

PROCEDURE send_message (
    p_type        IN VARCHAR2,
    p_empid       IN EMPLOYEES.EMPLOYEE_ID % TYPE,
    p_title       IN JOBS.JOB_TITLE % TYPE,
    p_department_id IN EMPLOYEES.DEPARTMENT_ID % TYPE)
  AS

    v_text VARCHAR2(300);
    CURSOR c_manager (p_dept_id EMPLOYEES.DEPARTMENT_ID % TYPE)
    IS
      SELECT d.MANAGER_ID, j.JOB_TITLE, d.DEPARTMENT_NAME, mm.JOB_ID, mm.FIRST_NAME, mm.LAST_NAME
        FROM DEPARTMENTS d,
             EMPLOYEES mm,
             JOBS j
        WHERE d.department_id = p_dept_id
          AND d.MANAGER_ID = mm.EMPLOYEE_ID
          AND mm.JOB_ID = j.JOB_ID;
  BEGIN

    IF p_type = 'ins'
    THEN
      NULL;
    -- v_text = '????????? < FIRST_NAME > < LAST_NAME >! ?? ??????? ? ???????? < JOB_TITLE > ? ????????????? < DEPARTMENT_NAME >. ??? ????????????: < JOB_TITLE > < FIRST_NAME > < LAST_NAME >?. ';
    -- v_text = '????????? < FIRST_NAME > < LAST_NAME >! ? ???? ????????????? ?????? ????? ????????? < FIRST_NAME > < LAST_NAME > ? ????????? < JOB_TITLE > ? ??????? < SALARY >?. ';
    --INSERT  INTO MESSAGES(MSG_TEXT,                MSG_TYPE,                DEST_ADDR)  VALUES (V_TEXT,          'E-MAIL',          P_EMPID);
    -- v_text = '????????? < FIRST_NAME > < LAST_NAME >! ?????? ?????????? < FIRST_NAME > < LAST_NAME > ???????? ????? ? < SALARY old > ?? < SALARY new >? ';
    -- v_text = '????????? < FIRST_NAME > < LAST_NAME >! ?? ?????? ????????????? ?????? ????????? < FIRST_NAME > < LAST_NAME > ? ????????? < JOB_TITLE >.? ';
    END IF;

  END send_message;
END entEMPLOYEES;