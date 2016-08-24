-- List all Project IDs and Project Names
SELECT DISTINCT o.project_id,
                p.object_name
FROM   dssmdobjinfo o
       join dssmdobjinfo p
         ON o.project_id = p.object_id;

-- List objects owned by the user in all projects
SELECT (SELECT x.object_name
        FROM   dssmdobjinfo x
        WHERE  x.object_id = t1.project_id) AS project_name,
       object_type,
       object_name
FROM   dssmdobjinfo t1
WHERE  owner_id = (SELECT object_id
                   FROM   dssmdusracct
                   WHERE  Lower(login) = 'administrator')
ORDER  BY project_name,
          object_type;

-- List objects in the Profile folders in all projects (including full object path)
-- do not include folders and shortcuts
SELECT x.*,
       Substr(path, 1, Instr(path, '\\', 1, 3) - 1) AS profile_path
FROM   (SELECT DISTINCT 'Env10x'                                 AS environment,
                        'DEV'                                    AS tier,
                        p.object_name                            AS project,
                        o.object_id,
                        o.object_name,
                        o.object_type,
                        CASE o.object_type
                          WHEN 1 THEN 'Filter'
                          WHEN 2 THEN 'Template'
                          WHEN 3 THEN 'Report'
                          WHEN 4 THEN 'Metric'
                          WHEN 6 THEN 'Autostyle'
                          WHEN 10 THEN 'Prompt'
                          WHEN 12 THEN 'Attribute'
                          WHEN 13 THEN 'Fact'
                          WHEN 14 THEN 'Hierarchy'
                          WHEN 15 THEN 'Table'
                          WHEN 39 THEN 'Search'
                          WHEN 43 THEN 'Transformation'
                          WHEN 47 THEN 'Consolidation'
                          WHEN 48 THEN 'Consolidation elements'
                          WHEN 55 THEN 'Document'
                          WHEN 56 THEN 'Drill map'
                          WHEN 60 THEN 'Prompt answers'
                          ELSE 'Object ' || o.object_type
                        END                                      AS object_type_name,
                        LEVEL                                    AS path_level,
                        Sys_connect_by_path(o.object_name, '\\') AS path,
                        Lower(u.login)                           AS object_owner
        FROM   dssmdobjinfo o
               join dssmdobjinfo p
                 ON o.project_id = p.object_id
               join dssmdusracct u
                 ON o.owner_id = u.object_id
        WHERE  o.object_type NOT IN ( 8, 18 )
        START WITH o.object_id = '64DAAC900B864173907F44B75C68FD96'
        CONNECT BY PRIOR o.object_id = o.parent_id
                         AND PRIOR o.project_id = o.project_id
        ORDER  SIBLINGS BY o.object_name) x;
