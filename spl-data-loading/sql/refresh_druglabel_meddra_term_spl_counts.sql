insert into meddra_term_spl_count
select
  llt.llt_name,
  0 assigned_by,
  counts.spl_count,
  case when llt.pt_code = llt.llt_code then 1 else 0 end is_pt
from meddra.low_level_term llt
join (
  select
    lsto.llt_code,
    count(distinct lsto.set_id) spl_count
  from spl_sec_meddra_llt_occ lsto
  where lsto.set_id in (select l.set_id from spl l)
  group by lsto.llt_code
) counts on counts.llt_code = llt.llt_code