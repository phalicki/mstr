-- List all Project IDs and Project Names
select distinct o.project_id,p.object_name
from dssmdobjinfo o
join dssmdobjinfo p on o.project_id=p.object_id;

-- List objects owned by the user in all projects
select
  (select x.object_name from dssmdobjinfo x where x.object_id=t1.project_id) as project_name,
  object_type,
  object_name
from dssmdobjinfo t1
where owner_id=(
  select object_id
  from dssmdusracct
  where lower(login)='administrator'
)
order by project_name,object_type;

-- List objects in the Profile folders in all projects (including full object path)
-- do not include folders and shortcuts
select x.*,SubStr(Path,1,Instr(Path,'\\',1,3)-1) as Profile_path
from (
  select distinct 'Env10x' as environment,
  'DEV' as tier,
  p.object_name as project,
  o.object_id,
  o.object_name,
  o.object_type,
  CASE  o.object_type
        WHEN  1  THEN  'Filter'
        WHEN  2  THEN  'Template'
        WHEN  3  THEN  'Report'
        WHEN  4  THEN  'Metric'
        WHEN  6  THEN  'Autostyle'
        WHEN  10 THEN  'Prompt'
        WHEN  12 THEN  'Attribute'
        WHEN  13 THEN  'Fact'
        WHEN  14 THEN  'Hierarchy'
        WHEN  15 THEN  'Table'
        WHEN  39 THEN  'Search'
        WHEN  43 THEN  'Transformation'
        WHEN  47 THEN  'Consolidation'
        WHEN  48 THEN  'Consolidation elements'
        WHEN  55 THEN  'Document'
        WHEN  56 THEN  'Drill map'
        WHEN  60 THEN  'Prompt answers'
        ELSE           'Object ' || o.object_type
  END as object_type_name,
  LEVEL as path_level,
  SYS_CONNECT_BY_PATH(o.object_name,'\\') as path,
  lower(u.login) as object_owner

  from dssmdobjinfo o
  join dssmdobjinfo p on o.project_id=p.object_id
  join dssmdusracct u on o.owner_id=u.object_id
  where o.object_type not in (8,18)
  start with o.object_id='64DAAC900B864173907F44B75C68FD96'
  connect by prior o.object_id=o.parent_id AND prior o.project_id=o.project_id
  order siblings by o.object_name
) x;
