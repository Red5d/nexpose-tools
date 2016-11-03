set search_path to nxsilo_default; 

insert into site_synopsis (site_id) select s.site_id from sites s left join site_synopsis ss using (site_id) where ss.site_id is null and s.status is null;
