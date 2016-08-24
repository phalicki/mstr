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
