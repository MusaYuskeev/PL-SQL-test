create or replace PACKAGE BODY entEMPLOYEES
AS
PROCEDURE get_Manager (p_employee_id IN EMPLOYEES.EMPLOYEE_ID % TYPE:=NULL,
                       p_department_id IN EMPLOYEES.DEPARTMENT_ID % TYPE:=NULL,
                       p_first_name OUT EMPLOYEES.FIRST_NAME % TYPE,
                       p_last_name OUT EMPLOYEES.LAST_NAME % TYPE,
                       p_job_title OUT JOBS.JOB_TITLE % TYPE,
                       p_email OUT EMPLOYEES.EMAIL % TYPE,
                       p_department_name OUT DEPARTMENTS.DEPARTMENT_NAME % TYPE
                       )
  AS
    v_text VARCHAR2(300);
    CURSOR c_manager_employee 
    IS
    SELECT e.FIRST_NAME, e.LAST_NAME, j.JOB_TITLE, e.EMAIL, d.DEPARTMENT_NAME
      FROM EMPLOYEES e,
           JOBS j,
           DEPARTMENTS d
      WHERE e.DEPARTMENT_ID = d.DEPARTMENT_ID
        AND e.JOB_ID = j.JOB_ID
        AND e.EMPLOYEE_ID =
        (SELECT MANAGER_ID FROM EMPLOYEES WHERE EMPLOYEE_ID = p_employee_id);
 CURSOR c_manager_department 
    IS
 SELECT e.FIRST_NAME, e.LAST_NAME, j.JOB_TITLE, e.EMAIL, d.DEPARTMENT_NAME
   FROM EMPLOYEES e,
        JOBS j,
        DEPARTMENTS d
   WHERE e.DEPARTMENT_ID = d.DEPARTMENT_ID
     AND e.JOB_ID = j.JOB_ID
     AND e.EMPLOYEE_ID = d.MANAGER_ID
     AND d.DEPARTMENT_ID = P_DEPARTMENT_ID;
  BEGIN
    IF p_employee_id IS NOT NULL THEN
      OPEN c_manager_employee;
      FETCH c_manager_employee INTO p_first_name,p_last_name,p_job_title,p_email,p_department_name;
      CLOSE c_manager_employee;
    ELSIF p_department_id IS NOT NULL THEN
      OPEN c_manager_department;
      FETCH c_manager_department INTO p_first_name,p_last_name,p_job_title,p_email,p_department_name;
      CLOSE c_manager_department;
    END IF;
  END get_Manager;

  PROCEDURE get_Job_Title(p_JOB_ID IN JOBS.JOB_ID % TYPE,p_job_title OUT JOBS.JOB_TITLE % TYPE)
  AS
    BEGIN
    SELECT JOB_TITLE
      INTO p_job_title
      FROM  JOBS 
      WHERE 
        JOB_ID = p_JOB_ID;

  END;

  PROCEDURE payrise (
    p_employee_id IN EMPLOYEES.EMPLOYEE_ID % TYPE,
    p_salary      IN EMPLOYEES.SALARY % TYPE := NULL)
  AS
    emp_rec EMPLOYEES%ROWTYPE;
    v_maxsalary JOBS.MAX_SALARY % TYPE;
    v_newsalary EMPLOYEES.SALARY % TYPE;
    v_oldsalary EMPLOYEES.SALARY % TYPE;
  BEGIN
    SELECT MAX_SALARY
      INTO v_maxsalary
      FROM JOBS
      WHERE JOB_ID =
        (SELECT JOB_ID
            FROM EMPLOYEES
          WHERE EMPLOYEE_ID = p_employee_id);

    tabEMPLOYEES.sel(p_employee_id, emp_rec, TRUE);
    v_oldsalary := emp_rec.SALARY;


    v_newsalary := p_salary;
    IF p_salary IS NULL THEN
      v_newsalary := v_oldsalary * 1.1;
    END IF;

    IF v_newsalary > v_maxsalary THEN
       RAISE_APPLICATION_ERROR (-20001, 'Превышена величина максимального оклада.');
    END IF;

    tabEMPLOYEES.upd(emp_rec);
 /*  UPDATE EMPLOYEES
      SET SALARY = v_newsalary
    WHERE EMPLOYEE_ID = p_employee_id;
*/
   DECLARE
      v_first_name_mgr EMPLOYEES.FIRST_NAME % TYPE;
      v_last_name_mgr EMPLOYEES.LAST_NAME % TYPE;
      v_job_title_mgr JOBS.JOB_TITLE % TYPE;
      v_email_mgr EMPLOYEES.EMAIL % TYPE ;
      v_department_name_mgr DEPARTMENTS.DEPARTMENT_NAME % TYPE;
--      v_first_name EMPLOYEES.FIRST_NAME % TYPE;
--      v_last_name EMPLOYEES.LAST_NAME % TYPE;
--      v_job_title JOBS.JOB_TITLE % TYPE;
--      v_email EMPLOYEES.EMAIL % TYPE % TYPE;
    BEGIN

      get_Manager (p_employee_id,NULL, v_first_name_mgr, v_last_name_mgr,v_job_title_mgr,v_email_mgr,v_department_name_mgr);
      INSERT INTO MESSAGES(msg_text, msg_type, dest_addr, msg_state) VALUES (
      'Уважаемый '+v_first_name_mgr+ ' '+ v_last_name_mgr+'! Вашему сотруднику  '+
      emp_rec.first_name+' '+emp_rec.last_name+' увеличен оклад с '+v_oldsalary+' до '+v_newsalary+'.',
      'Email',
      v_email_mgr,
      0
      );             
    END;
  END payrise;

  PROCEDURE leave (
    p_employee_id IN EMPLOYEES.EMPLOYEE_ID % TYPE)
  AS
  emp_rec EMPLOYEES%ROWTYPE;
  BEGIN
 /*   UPDATE EMPLOYEES
      SET DEPARTMENT_ID = NULL
    WHERE EMPLOYEE_ID = p_employee_id;
*/
    tabEMPLOYEES.sel(p_employee_id, emp_rec, TRUE);
    emp_rec.DEPARTMENT_ID := NULL;
    tabEMPLOYEES.upd(emp_rec);

    DECLARE
      v_first_name_mgr EMPLOYEES.FIRST_NAME % TYPE;
      v_last_name_mgr EMPLOYEES.LAST_NAME % TYPE;
      v_job_title_mgr JOBS.JOB_TITLE % TYPE;
      v_email_mgr EMPLOYEES.EMAIL % TYPE;
      v_department_name_mgr DEPARTMENTS.DEPARTMENT_NAME % TYPE;
      v_job_title JOBS.JOB_TITLE % TYPE;

    BEGIN
      get_Job_Title(emp_rec.JOB_ID,v_job_title);
      get_Manager (p_employee_id,NULL, v_first_name_mgr, v_last_name_mgr,v_job_title_mgr,v_email_mgr,v_department_name_mgr);
      INSERT INTO MESSAGES(msg_text, msg_type, dest_addr, msg_state) VALUES (
      'Уважаемый '+v_first_name_mgr+ +' '+ v_last_name_mgr+'! Из вашего подразделения уволен сотрудник '+
      emp_rec.first_name+' '+emp_rec.last_name+' с должности '+v_job_title+'.',
      'Email',
      v_email_mgr,
      0
      );                   
    END;
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
      emp_rec.DEPARTMENT_ID := p_department_id;

      tabEMPLOYEES.ins (emp_rec);

    DECLARE
      v_first_name_mgr EMPLOYEES.FIRST_NAME % TYPE;
      v_last_name_mgr EMPLOYEES.LAST_NAME % TYPE;
      v_job_title_mgr JOBS.JOB_TITLE % TYPE;
      v_email_mgr EMPLOYEES.EMAIL % TYPE;
      v_department_name_mgr DEPARTMENTS.DEPARTMENT_NAME % TYPE;
      v_first_name EMPLOYEES.FIRST_NAME % TYPE;
      v_last_name EMPLOYEES.LAST_NAME % TYPE;
      v_job_title JOBS.JOB_TITLE % TYPE;
      v_email EMPLOYEES.EMAIL % TYPE ;
    BEGIN
      get_Job_Title(emp_rec.JOB_ID,v_job_title);
      get_Manager (NULL, emp_rec.DEPARTMENT_ID, v_first_name_mgr, v_last_name_mgr,v_job_title_mgr,v_email_mgr,v_department_name_mgr);
       INSERT INTO MESSAGES(msg_text, msg_type, dest_addr, msg_state) VALUES (
      'Уважаемый '+v_first_name+' '+v_last_name+'! Вы приняты в качестве '+v_job_title+' в подразделение '+v_department_name_mgr+
      '. Ваш руководитель: '+v_job_title_mgr+' '+v_first_name_mgr+ +' '+ v_last_name_mgr+'.',
      'Email',
      v_email,
      0
      );      
      INSERT INTO MESSAGES(msg_text, msg_type, dest_addr, msg_state) VALUES (
      'Уважаемый '+v_first_name_mgr+ +' '+ v_last_name_mgr+'! В ваше подразделение принят новый сотрудник '+
      v_first_name+' '+v_last_name+' в должности '+v_job_title+' с окладом '+emp_rec.SALARY+'.',
      'Email',
      v_email_mgr,
      0
      );  
      END;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
   END employment;


END entEMPLOYEES;
