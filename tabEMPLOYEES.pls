create or replace PACKAGE tabEMPLOYEES
AS
  PROCEDURE sel (
    p_id        IN  EMPLOYEES.EMPLOYEE_ID % TYPE,
    p_row       OUT EMPLOYEES % ROWTYPE,
    p_forupdate IN  BOOLEAN := FALSE,
    p_rase      IN  BOOLEAN := TRUE);

 PROCEDURE ins (
    p_row    IN EMPLOYEES % ROWTYPE,
    p_update IN BOOLEAN := FALSE);

 PROCEDURE upd (
    p_row    IN EMPLOYEES % ROWTYPE,
    p_insert IN BOOLEAN := FALSE);

 PROCEDURE del (
    p_id IN EMPLOYEES.EMPLOYEE_ID % TYPE);

  FUNCTION exist (
    p_id IN EMPLOYEES.EMPLOYEE_ID % TYPE)
    RETURN BOOLEAN;

END tabEMPLOYEES;