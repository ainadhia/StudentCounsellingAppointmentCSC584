-- Debug query to check counselor data in the database
-- This will help verify if the counselor user exists and has the correct format

SELECT 
    u.ID as USER_ID,
    u.USERNAME,
    u.FULLNAME,
    u.USERROLE,
    c.COUNSELORID,
    c.ROOMNO
FROM USERS u
JOIN COUNSELOR c ON u.ID = c.ID
WHERE u.USERROLE = 'C';

-- Also check if there are any session records for counselors
SELECT 
    s.SESSIONID,
    s.STARTTIME,
    s.ENDTIME,
    s.SESSIONSTATUS,
    s.COUNSELORID,
    u.USERNAME as COUNSELOR_NAME
FROM APP.SESSION s
JOIN USERS u ON CAST(s.COUNSELORID AS INT) = u.ID
WHERE s.SESSIONSTATUS IN ('available', 'Available')
ORDER BY s.STARTTIME;
