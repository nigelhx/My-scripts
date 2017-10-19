---STA(SQL Tuning Advisor) BEGIN
declare
v_name varchar2(200);
begin
v_name:=DBMS_SQLTUNE.CREATE_TUNING_TASK(time_limit=>60,sql_Id=>'7dtas40uhvhrg',task_name=>'t2_test');
end;
/

EXEC DBMS_SQLTUNE.EXECUTE_TUNING_TASK(TASK_NAME=>'t2_test');

SELECT *  FROM USER_ADVISOR_TASKS 

select DBMS_SQLTUNE.REPORT_TUNING_TASK('t2_test') from dual;

EXEC DBMS_SQLTUNE.DROP_TUNING_TASK(TASK_NAME=>'t2_test');
----STA(SQL Tuning Advisor) END

----in 10G check method---
select * from dba_sql_profiles   --where NAME='pro_lock_wip_temp';

----check sqlprofile
select * from SYS.SQLPROF$attr a,dba_sql_profiles b
where A.SIGNATURE=B.SIGNATURE and B.NAME='coe_upRUandHvFayKnfzfAEcQBlD';


select * from SYS.SQLPROF$ a,dba_sql_profiles b
where A.SIGNATURE=B.SIGNATURE and B.NAME='coe_pJllOeKCZqnuaeHEMUEzfEqs';

select * from SYS.SQLPROF$DESC a,dba_sql_profiles b
where A.SIGNATURE=B.SIGNATURE and B.NAME='coe_pJllOeKCZqnuaeHEMUEzfEqs';
---
---11G

select * from table(dbms_xplan.display_cursor('bpdtuptfhpmjm','','ADVANCED'))

EXEC DBMS_SPM.DROP_SQL_PLAN_BASELINE('SQL_0d273ed05acfbfe9','SQL_PLAN_0u9tyu1dczgz9def9ac8d')


   DECLARE
        v_basenum number ;
   BEGIN
    v_basenum:= DBMS_SPM.DROP_SQL_PLAN_BASELINE('SQL_0d273ed05acfbfe9','SQL_PLAN_0u9tyu1dczgz9def9ac8d');
   DBMS_OUTPUT.PUT_LINE(v_basenum);
   END;/


   SELECT *  FROM table(dbms_xplan.display_sql_plan_baseline(sql_handle => 'SQL_0d273ed05acfbfe9', plan_name  => 'SQL_PLAN_0u9tyu1dczgz9def9ac8d'));
   
----11G

select * from  V$version

----drop sqlprofile
exec DBMS_SQLTUNE.DROP_SQL_PROFILE(NAME=>'coe_upRUandHvFayKnfzfAEcQBlD');


select * from dba_sql_profiles



---Begin:Manual create sql profile for special sql when you known change sql plan metadata.  
---Get original sql plan metadata
SELECT ''''|| replace(wmsys.wm_concat(replace(EXTRACTVALUE (VALUE (d), '/hint'),'''','''''')),',',''',''')||'''' AS outline_hints
     FROM XMLTABLE (
             '/*/outline_data/hint'
             PASSING (SELECT xmltype (other_xml) AS xmlval
                        FROM v$sql_plan
                       WHERE     sql_id = '6wkqqj11k4g9h'  ------sql_Id is which you get profile 
                             AND child_number = '1'
                             AND other_xml IS NOT NULL)) d;
                             
                             
                             
---Update the sql plan metadata to the right sql plan metadata
Update outline_hints resule from previous sql;

----Using following pl/sql to fix sql profile to special sql
DECLARE
V_HINTS sys.sqlprof_attr;
V_SQLTEXT CLOB;
begin
V_HINTS:=sys.sqlprof_attr('IGNORE_OPTIM_EMBEDDED_HINTS,OPTIMIZER_FEATURES_ENABLE(''10.2.0.5''),ALL_ROWS,OUTLINE_LEAF(@"UPD$1"),INDEX_RS_ASC(@"UPD$1" "LOCK_WIP_TEMP"@"UPD$1"  "IX_WIP_TMP_WIP_NO")');
--SELECT SQL_FULLTEXT INTO V_SQLTEXT FROM v$SQLAREA WHERE SQL_iD='2sns9xs5za3y7';
SELECT SQL_TEXT INTO V_SQLTEXT FROM DBA_HIST_SQLTEXT WHERE SQL_iD='2sns9xs5za3y7';
--DBMS_SQLTUNE.IMPORT_SQL_PROFILE(SQL_TEXT=>'select /*+ full(a) full(b) */ * from t1 a,t2 b where a.object_id=b.object_id and a.object_id=100 and b.object_name=''T1''',
--PROFILE=>V_HINTS,NAME=>'HEXIN_TEST1',REPLACE=>TRUE,FORCE_MATCH=>TRUE);
DBMS_SQLTUNE.IMPORT_SQL_PROFILE(SQL_TEXT=>V_SQLTEXT,PROFILE=>V_HINTS,NAME=>'pro_lock_wip_temp',REPLACE=>TRUE,FORCE_MATCH=>TRUE);
END;
/

---End:Manual create sql profile for special sql when you known change sql plan metadata.  




'IGNORE_OPTIM_EMBEDDED_HINTS,OPTIMIZER_FEATURES_ENABLE(''10.2.0.5''),ALL_ROWS,OUTLINE_LEAF(@"UPD$1"),INDEX_RS_ASC(@"UPD$1" "LOCK_WIP_TEMP"@"UPD$1"  "IX_WIP_TMP_WIP_NO")'

PART    IX_WIP_TMP_WIP_NO    N        1    WIP_NO    Asc    1    DMPDB2

---Begin: Base on another similar sql which adding special hint to force change current sql plan.
---EXPLAM LET BELOW SQL RUNNING WIHT INDEX SCAN(COL TEMP_01 HAVE ONE INDEX)

SELECT /*+ FULL(ZY_TEST_01) */  * FROM ZY_TEST_01 WHERE TEMP_01='2013/05/14';


select * from V$sqlarea where sql_TEXT='SELECT /*+ FULL(ZY_TEST_01) */  * FROM ZY_TEST_01 WHERE TEMP_01=''2013/05/14''';

sql_id='5q4gh80a7c4f4';

SELECT /*+ index(ZY_TEST_01  test_zy) */  * FROM ZY_TEST_01 WHERE TEMP_01='2013/05/14';

select * from V$sqlarea where sql_TEXT='SELECT /*+ index(ZY_TEST_01  test_zy) */  * FROM ZY_TEST_01 WHERE TEMP_01=''2013/05/14''';

sql_id='a3u8d57jdrzxu'

---Using below pl/sql to force sql "SELECT /*+ FULL(ZY_TEST_01) */  * FROM ZY_TEST_01 WHERE TEMP_01='2013/05/14'" using ndex(ZY_TEST_01  test_zy) 

select * from V$sql_plan where sql_id='bpdtuptfhpmjm';


 SELECT EXTRACTVALUE (VALUE (d), '/hint') AS outline_hints
     FROM XMLTABLE (
             '/*/outline_data/hint'
             PASSING (SELECT xmltype (other_xml) AS xmlval
                        FROM v$sql_plan
                       WHERE     sql_id ='bpdtuptfhpmjm'  ------sql_Id is which you get profile 
                             AND child_number = 1
                             AND other_xml IS NOT NULL)) d;
                             
   SELECT 'coe_' || DBMS_RANDOM.STRING('A',24) INTO v_new_profile_name FROM DUAL
   
   
   select *     FROM v$sql_plan where sql_id = '7ctj375ftvkss' 

DECLARE
    V_SQLID_1   V$SQL.SQL_ID%TYPE:='bpdtuptfhpmjm';  -------------sql_Id is which you want to change
    V_CHILDNO_1  V$SQL.CHILD_NUMBER%TYPE:=0;
    V_SQLID_2   V$SQL.SQL_ID%TYPE:='7ctj375ftvkss'; --------------sql_Id is which you get profile 
    V_CHILDNO_2 V$SQL.CHILD_NUMBER%TYPE:=0;
    v_sqlprofile         SYS.sqlprof_attr;
    v_new_profile_name   VARCHAR2 (255);
    v_sql_text           V$SQL.SQL_FULLTEXT%type;
BEGIN
   SELECT sql_fulltext
     INTO v_sql_text
     FROM v$sql
    WHERE sql_id = V_SQLID_1 AND child_number = V_CHILDNO_1;  ----sql_Id is which you want to change
   SELECT EXTRACTVALUE (VALUE (d), '/hint') AS outline_hints
     BULK COLLECT INTO v_sqlprofile
     FROM XMLTABLE (
             '/*/outline_data/hint'
             PASSING (SELECT xmltype (other_xml) AS xmlval
                        FROM v$sql_plan
                       WHERE     sql_id =V_SQLID_2  ------sql_Id is which you get profile 
                             AND child_number = V_CHILDNO_2
                             AND other_xml IS NOT NULL)) d;
   SELECT 'coe_' || DBMS_RANDOM.STRING('A',24) INTO v_new_profile_name FROM DUAL;
   DBMS_SQLTUNE.import_sql_profile (sql_text      => v_sql_text, --old sql plan
                                    PROFILE       => v_sqlprofile,
                                    NAME          => v_new_profile_name,
                                    REPLACE       => TRUE,
                                    force_match   => TRUE /* TRUE:FORCE (match even when different literals in SQL). FALSE:EXACT(similar to CURSOR_SHARING) */
                                                         );
EXCEPTION WHEN OTHERS THEN
    RAISE;
END;
/




---End: Base on another similar sql which adding special hint to force change current sql plan.


Use special index When manual create sqlprofile:
example t1(object_name,object_id,owner) has two indexes one ix_t1 on (object_name,object_Id) another
ix_t1_id(object_id)
Method 1:
Using ix_t1
INDEX_RS_ASC(@"SEL$1" "A"@"SEL$1" ("T1"."OBJECT_NAME" "T1"."OBJECT_ID"));
Using ix_t1_id
INDEX_RS_ASC(@"SEL$1" "A"@"SEL$1" ("T1"."OBJECT_ID"));
Method 2:
Using ix_t1
INDEX_RS_ASC(@"SEL$1" "A"@"SEL$1" "IX_T1");
Using ix_t1_id
INDEX_RS_ASC(@"SEL$1" "A"@"SEL$1" "IX_T1_ID");


--生成dual語句:
SELECT 'SELECT '''||REPLACE(EXTRACTVALUE (VALUE (d), '/hint'),'''','''''')||''''||' VN FROM DUAL UNION ALL' AS outline_hints
     FROM XMLTABLE (
             '/*/outline_data/hint'
             PASSING (SELECT xmltype (other_xml) AS xmlval
                        FROM v$sql_plan
                       WHERE     sql_id ='gctckgar1vgnv'  ------sql_Id is which you get profile 
                             AND child_number = 2
                             AND other_xml IS NOT NULL)) d;
                             

DECLARE
    V_SQLID_1   V$SQL.SQL_ID%TYPE:='7hgw94xh8bg4g';  -------------sql_Id is which you want to change
    V_CHILDNO_1  V$SQL.CHILD_NUMBER%TYPE:=0;
    v_sqlprofile         SYS.sqlprof_attr;
    v_new_profile_name   VARCHAR2 (255);
    v_sql_text           V$SQL.SQL_FULLTEXT%type;
BEGIN
   SELECT sql_fulltext
     INTO v_sql_text
     FROM v$sql
    WHERE sql_id = V_SQLID_1 AND child_number = V_CHILDNO_1;  ----sql_Id is which you want to change
    SELECT *      BULK COLLECT INTO v_sqlprofile  FROM (SELECT 'IGNORE_OPTIM_EMBEDDED_HINTS' VN FROM DUAL UNION ALL
SELECT 'OPTIMIZER_FEATURES_ENABLE(''11.2.0.3'')' VN FROM DUAL UNION ALL
SELECT 'DB_VERSION(''11.2.0.3'')' VN FROM DUAL UNION ALL
SELECT 'OPT_PARAM(''_b_tree_bitmap_plans'' ''false'')' VN FROM DUAL UNION ALL
SELECT 'OPT_PARAM(''optimizer_index_cost_adj'' 25)' VN FROM DUAL UNION ALL
SELECT 'OPT_PARAM(''optimizer_index_caching'' 90)' VN FROM DUAL UNION ALL
SELECT 'ALL_ROWS' VN FROM DUAL UNION ALL
SELECT 'OUTLINE_LEAF(@"SEL$1")' VN FROM DUAL UNION ALL
SELECT 'OUTLINE_LEAF(@"INS$1")' VN FROM DUAL UNION ALL
SELECT 'FULL(@"INS$1" "WF_ROUTE_TRACKING_T"@"INS$1")' VN FROM DUAL UNION ALL
SELECT 'INDEX_RS_ASC(@"SEL$1" "WF_ROUTE_TRACKING_T"@"SEL$1" ("WF_ROUTE_TRACKING_T"."FORM_CODE"))' VN FROM DUAL );
   SELECT 'coe_' || DBMS_RANDOM.STRING('A',24) INTO v_new_profile_name FROM DUAL;
   DBMS_SQLTUNE.import_sql_profile (sql_text      => v_sql_text, --old sql plan
                                    PROFILE       => v_sqlprofile,
                                    NAME          => v_new_profile_name,
                                    REPLACE       => TRUE,
                                    force_match   => TRUE /* TRUE:FORCE (match even when different literals in SQL). FALSE:EXACT(similar to CURSOR_SHARING) */
                                                         );
EXCEPTION WHEN OTHERS THEN
    RAISE;
END;
/
