create or replace PACKAGE entEMPLOYEES
AS
  PROCEDURE employment (
    p_first_name     IN EMPLOYEES.FIRST_NAME % TYPE,
    p_last_name      IN EMPLOYEES.LAST_NAME % TYPE,
    p_email          IN EMPLOYEES.EMAIL % TYPE,
    p_phone_number   IN EMPLOYEES.PHONE_NUMBER % TYPE,
    p_job_id         IN EMPLOYEES.JOB_ID % TYPE,
    p_department_id  IN EMPLOYEES.DEPARTMENT_ID % TYPE,
    p_salary         IN EMPLOYEES.SALARY % TYPE         := NULL,
    p_commission_pct IN EMPLOYEES.COMMISSION_PCT % TYPE := NULL);
  PROCEDURE payrise (
    p_employee_id IN EMPLOYEES.EMPLOYEE_ID % TYPE,
    p_salary      IN EMPLOYEES.salary % TYPE := NULL);
  PROCEDURE leave (
    p_employee_id IN EMPLOYEES.EMPLOYEE_ID % TYPE);
END entEMPLOYEES;