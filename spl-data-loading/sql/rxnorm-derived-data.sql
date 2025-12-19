set search_path to rxnrel,rxnorig;

-- ingredients
insert into "in" (rxcui, rxaui, name, suppress)
select distinct c.rxcui, c.rxaui, c.str as name, c.suppress
from rxnconso c
where tty = 'IN' and sab='RXNORM'
;

-- multi-ingredients
insert into min (rxcui, rxaui, name, suppress)
select c.rxcui, c.rxaui, c.str name, c.suppress
from rxnconso c
where c.tty = 'MIN' and c.sab = 'RXNORM'
;

-- precise ingredients
insert into pin (rxcui, rxaui, name, in_rxcui, suppress)
select distinct
  c.rxcui,
  c.rxaui,
  c.str as name,
  (select r.rxcui1 from rxnrel r join rxnconso c1 on c1.rxcui = r.rxcui1 and c1.tty = 'IN' and c1.sab = 'RXNORM' where r.rela = 'form_of' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) incui,
  c.suppress
from rxnconso c
where tty = 'PIN' and sab='RXNORM'
;

-- brand names
insert into bn (rxcui, rxaui, name, rxn_cardinality, reformulated_to_rxcui, cur_pres, suppress)
select
  c.rxcui,
  c.rxaui,
  c.str,
  (select a.atv from rxnsat a where a.atn = 'RXN_BN_CARDINALITY' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) card,
  (select r.rxcui1
   from rxnrel r join rxnconso c1 on c1.rxcui = r.rxcui1 and c1.tty = 'BN' and c1.sab = 'RXNORM'
   where r.rela = 'reformulated_to' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) refto,
  case when c.cvf = '4096' then true else false end cur_pres,
  c.suppress
from rxnconso c
where c.tty = 'BN' and sab = 'RXNORM'
;

-- multi-ingredient ingredients
insert into min_in (min_rxcui, in_rxcui)
select c2.rxcui, c1.rxcui
from rxnrel r
join rxnconso c2 on r.rxcui2 = c2.rxcui and c2.tty = 'MIN' and c2.sab = 'RXNORM'
join rxnconso c1 on r.rxcui1 = c1.rxcui and c1.tty = 'IN' and c1.sab = 'RXNORM'
where r.rela = 'has_part' and r.sab = 'RXNORM'
;

-- multi-ingredient precise ingredients
insert into min_pin (min_rxcui, pin_rxcui)
select c2.rxcui, c1.rxcui
from rxnrel r
join rxnconso c2 on r.rxcui2 = c2.rxcui and c2.tty = 'MIN' and c2.sab = 'RXNORM'
join rxnconso c1 on r.rxcui1 = c1.rxcui and c1.tty = 'PIN' and c1.sab = 'RXNORM'
where r.rela = 'has_part' and r.sab = 'RXNORM'
;

-- brand name ingredients
insert into bn_in (bn_rxcui, in_rxcui)
select r.rxcui2, r.rxcui1
from rxnrel r
join rxnconso c2 on r.rxcui2 = c2.rxcui and c2.tty = 'BN' and c2.sab = 'RXNORM'
join rxnconso c1 on r.rxcui1 = c1.rxcui and c1.tty = 'IN' and c1.sab = 'RXNORM'
where r.rela = 'tradename_of' and r.sab = 'RXNORM'
;

-- prescribable names
insert into psn (rxcui, rxaui, name, cur_pres, suppress)
select
  c.rxcui,
  c.rxaui,
  c.str,
  case when c.cvf = '4096' then true else false end cur_pres,
  c.suppress
from rxnconso c
where c.tty = 'PSN' and sab = 'RXNORM'
;

-- dose forms
insert into df (rxcui, rxaui, name, origin, code, suppress)
select
  c.rxcui,
  c.rxaui,
  c.str,
  (select a.atv from rxnsat a where a.sab = 'RXNORM' and a.atn = 'ORIG_SOURCE' and a.rxcui = c.rxcui),
  (select a.atv from rxnsat a where a.sab = 'RXNORM' and a.atn = 'ORIG_CODE' and a.rxcui = c.rxcui),
  c.suppress
from rxnconso c
where c.tty = 'DF' and c.sab = 'RXNORM'
;

-- dose form groups
insert into dfg (rxcui, rxaui, name, suppress)
select c.rxcui, c.rxaui, c.str, c.suppress
from rxnconso c
where c.tty = 'DFG' and c.sab = 'RXNORM'
;

-- dose form group dose forms
insert into dfg_df (dfg_rxcui, df_rxcui)
select r.rxcui1, r.rxcui2
from rxnrel r
join rxnconso c2 on c2.rxcui = r.rxcui2 and c2.tty = 'DF' and c2.sab = 'RXNORM'
join rxnconso c1 on c1.rxcui = r.rxcui1 and c1.tty = 'DFG' and c1.sab = 'RXNORM'
where r.rela = 'isa' and r.sab = 'RXNORM'
;

-- semantic clinical drug and dose forms
insert into scdf (rxcui, rxaui, name, df_rxcui, cur_pres, suppress)
select
  c.rxcui,
  c.rxaui,
  c.str,
  (select r.rxcui1
   from rxnrel r join rxnconso df on r.rxcui1 = df.rxcui and df.tty = 'DF' and df.sab = 'RXNORM'
   where r.rela = 'has_dose_form' and r.sab = 'RXNORM' and c.rxcui = r.rxcui2) df,
  case when c.cvf = '4096' then true else false end cur_pres,
  c.suppress
from rxnconso c
where c.tty = 'SCDF' and c.sab = 'RXNORM'
;

insert into scdf_in (scdf_rxcui, in_rxcui)
select r.rxcui2, r.rxcui1
from rxnrel r
join rxnconso c2 on c2.rxcui = r.rxcui2 and c2.tty = 'SCDF' and c2.sab = 'RXNORM'
join rxnconso c1 on c1.rxcui = r.rxcui1 and c1.tty = 'IN' and c1.sab = 'RXNORM'
where r.rela = 'has_ingredient' and r.sab = 'RXNORM'
;

-- semantic clinical drugs
insert into scd (rxcui, rxaui, name, psn_rxcui, rxterm_form, df_rxcui, scdf_rxcui, min_rxcui, strengths, qual_distinct, qty, human, vet, unquant_form_rxcui, cur_pres, suppress)
select
  c.rxcui,
  c.rxaui,
  c.str,
  (select psn.rxcui from rxnconso psn where psn.tty = 'PSN' and psn.sab = 'RXNORM' and psn.rxcui = c.rxcui) psn,
  (select a.atv from rxnsat a where a.atn = 'RXTERM_FORM' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) rxtf,
  (select r.rxcui1 from rxnrel r where r.rela = 'has_dose_form' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui)  df,
  (select r.rxcui1 from rxnrel r join rxnconso scdf on scdf.rxcui = r.rxcui1 and scdf.tty = 'SCDF' and scdf.sab = 'RXNORM' where r.rela = 'isa' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) scdf,
  (select r.rxcui1 from rxnrel r join rxnconso min on min.rxcui = r.rxcui1 and min.tty = 'MIN' and min.sab = 'RXNORM' where r.rela = 'has_ingredients' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) min,
  (select a.atv from rxnsat a where a.atn = 'RXN_AVAILABLE_STRENGTH' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) avstr,
  (select a.atv from rxnsat a where a.atn = 'RXN_QUALITATIVE_DISTINCTION' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) qual_dist,
  (select a.atv from rxnsat a where a.atn = 'RXN_QUANTITY' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) quant,
  exists (select a.atv from rxnsat a where a.atn = 'RXN_HUMAN_DRUG' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) human_drug,
  exists (select a.atv from rxnsat a where a.atn = 'RXN_VET_DRUG' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) vet_drug,
  (select r.rxcui1 from rxnrel r where r.sab = 'RXNORM' and r.rela = 'quantified_form_of' and r.rxcui2 = c.rxcui) unquant,
  case when c.cvf = '4096' then true else false end cur_pres,
  c.suppress
from rxnconso c
where c.tty = 'SCD' and c.sab='RXNORM'
;

-- semantic branded drug-and-form's
insert into sbdf (rxcui, rxaui, name, bn_rxcui, df_rxcui, scdf_rxcui, cur_pres)
select
  c.rxcui,
  c.rxaui,
  c.str,
  (select r.rxcui1 from rxnrel r join bn on bn.rxcui = r.rxcui1 where r.rela = 'has_ingredient' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) bn,
  (select r.rxcui1 from rxnrel r where r.rela = 'has_dose_form' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) df,
  (select r.rxcui1 from rxnrel r where r.rela = 'tradename_of' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) scdf,
  case when c.cvf = '4096' then true else false end cur_pres
from rxnconso c
where c.tty = 'SBDF' and c.sab = 'RXNORM'
;

-- semantic branded drug components
insert into sbdc (rxcui, rxaui, name)
select c.rxcui, c.rxaui, c.str
from rxnconso c
where c.tty = 'SBDC' and c.sab = 'RXNORM'
;

-- semantic branded drugs
insert into sbd (rxcui, rxaui, name, scd_rxcui, bn_rxcui, sbdf_rxcui, sbdc_rxcui, psn_rxcui, rxterm_form, df_rxcui, available_strengths, qual_distinct, quantity, human_drug, vet_drug, unquantified_form_rxcui, cur_pres, suppress)
select
  c.rxcui,
  c.rxaui,
  c.str,
  (select r.rxcui1 from rxnrel r where r.rela = 'tradename_of' and r.rxcui2 = c.rxcui) scd,
  (select r.rxcui1 from rxnrel r join rxnconso bn on bn.rxcui = r.rxcui1 and bn.tty = 'BN' and bn.sab = 'RXNORM' where r.rela = 'has_ingredient' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) bn,
  (select r.rxcui1 from rxnrel r join rxnconso sbdf on sbdf.rxcui = r.rxcui1 and sbdf.tty = 'SBDF' where r.rela = 'isa' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) sbdf,
  (select r.rxcui1 from rxnrel r join rxnconso sbdc on sbdc.rxcui = r.rxcui1 and sbdc.tty = 'SBDC' where r.rela = 'consists_of' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) sbdc,
  (select psn.rxcui from rxnconso psn where psn.tty = 'PSN' and psn.sab = 'RXNORM' and psn.rxcui = c.rxcui) psn,
  (select a.atv from rxnsat a where a.atn = 'RXTERM_FORM' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) rxterm_form,
  (select r.rxcui1 from rxnrel r where r.rela = 'has_dose_form' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) df,
  (select a.atv from rxnsat a where a.atn = 'RXN_AVAILABLE_STRENGTH' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) strengths,
  (select a.atv from rxnsat a where a.atn = 'RXN_QUALITATIVE_DISTINCTION' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) qual_distinct,
  (select a.atv from rxnsat a where a.atn = 'RXN_QUANTITY' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) quantity,
  exists (select a.atv from rxnsat a where a.atn = 'RXN_HUMAN_DRUG' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) human,
  exists (select a.atv from rxnsat a where a.atn = 'RXN_VET_DRUG' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) vet,
  (select r.rxcui1 from rxnrel r where r.rela = 'quantified_form_of' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) unquant,
  case when c.cvf = '4096' then true else false end cur_pres,
  c.suppress
from rxnconso c
where c.tty = 'SBD' and c.sab='RXNORM'
;

-- generic drug packs
insert into gpck (rxcui, rxaui, name, psn_rxcui, df_rxcui, human_drug, cur_pres, suppress)
select
  c.rxcui,
  c.rxaui,
  c.str,
  (select psn.rxcui from rxnconso psn where psn.tty = 'PSN' and psn.sab = 'RXNORM' and psn.rxcui = c.rxcui) psn,
  (select r.rxcui1 from rxnrel r where r.sab = 'RXNORM' and r.rela = 'has_dose_form' and r.rxcui2 = c.rxcui) df,
  exists (select a.atv from rxnsat a where a.atn = 'RXN_HUMAN_DRUG' and a.sab = 'RXNORM' and a.rxcui = c.rxcui) humrx,
  case when c.cvf = '4096' then true else false end cur_pres,
  c.suppress
from rxnconso c
where c.tty = 'GPCK' and c.sab='RXNORM'
;

-- branded drug packs
insert into bpck (rxcui, rxaui, name, gpck_rxcui, psn_rxcui, df_rxcui, human_drug, cur_pres, suppress)
select
  c.rxcui,
  c.rxaui,
  c.str as name,
  (select r.rxcui1 from rxnrel r where  r.rela = 'tradename_of' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) gpck,
  (select psn.rxcui from rxnconso psn where psn.tty = 'PSN' and psn.sab = 'RXNORM' and psn.rxcui = c.rxcui) psn,
  (select r.rxcui1 from rxnrel r where r.rela = 'has_dose_form' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) df,
  exists (select a.atv from rxnsat a where a.atn = 'RXN_HUMAN_DRUG' and a.sab = 'RXNORM' and a.rxcui = c.rxcui),
  case when c.cvf = '4096' then true else false end cur_pres,
  c.suppress
from rxnconso c
where c.tty = 'BPCK' and c.sab='RXNORM'
;

-- semantic clinical drug components
insert into scdc (rxcui, rxaui, name, in_rxcui, pin_rxcui, boss_active_ingr_name, boss_active_moi_name, boss_source, rxn_in_expressed_flag, strength, boss_str_num_unit, boss_str_num_val, boss_str_denom_unit, boss_str_denom_val)
select
  c.rxcui,
  c.rxaui,
  c.str,
  (select r.rxcui1 from rxnrel r join rxnconso i on i.rxcui = r.rxcui1 and i.tty = 'IN' and i.sab = 'RXNORM' where r.rela = 'has_ingredient' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) ingr,
  (select r.rxcui1 from rxnrel r join rxnconso i on i.rxcui = r.rxcui1 and i.tty = 'PIN' and i.sab = 'RXNORM' where r.rela = 'has_precise_ingredient' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) pin,
  (select a.atv from rxnsat a where a.atn = 'RXN_BOSS_AI' and a.rxcui = c.rxcui),
  (select a.atv from rxnsat a where a.atn = 'RXN_BOSS_AM' and a.rxcui = c.rxcui),
  (select a.atv from rxnsat a where a.atn = 'RXN_BOSS_FROM' and a.rxcui = c.rxcui),
  (select a.atv from rxnsat a where a.atn = 'RXN_IN_EXPRESSED_FLAG' and a.rxcui = c.rxcui),
  (select a.atv from rxnsat a where a.atn = 'RXN_STRENGTH' and a.rxcui = c.rxcui),
  (select a.atv from rxnsat a where a.atn = 'RXN_BOSS_STRENGTH_NUM_UNIT' and a.rxcui = c.rxcui),
  (select a.atv from rxnsat a where a.atn = 'RXN_BOSS_STRENGTH_NUM_VALUE' and a.rxcui = c.rxcui),
  (select a.atv from rxnsat a where a.atn = 'RXN_BOSS_STRENGTH_DENOM_UNIT' and a.rxcui = c.rxcui),
  (select a.atv from rxnsat a where a.atn = 'RXN_BOSS_STRENGTH_DENOM_VALUE' and a.rxcui = c.rxcui)
from rxnconso c
where c.tty = 'SCDC' and c.sab = 'RXNORM'
;

-- semantic branded drug component - semantic clinical drug component associations
insert into sbdc_scdc (sbdc_rxcui, scdc_rxcui)
select sbdc.rxcui, scdc.rxcui
from rxnrel r
join rxnconso sbdc on sbdc.rxcui = r.rxcui2 and sbdc.tty = 'SBDC' and sbdc.sab = 'RXNORM'
join rxnconso scdc on scdc.rxcui = r.rxcui1 and scdc.tty = 'SCDC' and scdc.sab = 'RXNORM'
where r.rela = 'tradename_of' and r.sab = 'RXNORM'
;

-- semantic clinical drug form groups
insert into scdg (rxcui, rxaui, name, dfg_rxcui, cur_pres, suppress)
select
  c.rxcui,
  c.rxaui,
  c.str,
  (select r.rxcui1 from rxnrel r where r.sab = 'RXNORM' and r.rela = 'has_doseformgroup' and r.rxcui2 = c.rxcui) dfg,
  case when c.cvf = '4096' then true else false end cur_pres,
  c.suppress
from rxnconso c
where c.tty = 'SCDG' and c.sab = 'RXNORM'
;

-- semantic branded drug form groups
insert into sbdg (rxcui, rxaui, name, dfg_rxcui, bn_rxcui, scdg_rxcui, cur_pres, suppress)
select
  c.rxcui,
  c.rxaui,
  c.str,
  (select r.rxcui1 from rxnrel r where r.rela = 'has_doseformgroup' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) dfg,
  (select r.rxcui1 from rxnrel r where r.rela = 'has_ingredient' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) bn,
  (select r.rxcui1 from rxnrel r where r.rela = 'tradename_of' and r.sab = 'RXNORM' and r.rxcui2 = c.rxcui) scdg,
  case when c.cvf = '4096' then true else false end cur_pres,
  c.suppress
from rxnconso c
where c.tty = 'SBDG' and c.sab = 'RXNORM'
;

-- semantic branded drug dose form - semantic branded drug dose form group associations
insert into sbdg_sbdf (sbdg_rxcui, sbdf_rxcui)
select g.rxcui, f.rxcui
from rxnrel r
join rxnconso g on g.tty = 'SBDG' and g.sab = 'RXNORM' and g.rxcui = r.rxcui1
join rxnconso f on f.tty = 'SBDF' and f.sab = 'RXNORM' and f.rxcui = r.rxcui2
where r.rela = 'isa' and r.sab = 'RXNORM'
;

-- semantic branded drug form group - semantic branded drug associations
insert into sbdg_sbd (sbdg_rxcui, sbd_rxcui)
select g.rxcui, d.rxcui
from rxnrel r
join rxnconso g on g.tty = 'SBDG' and g.sab = 'RXNORM' and g.rxcui = r.rxcui1
join rxnconso d on d.tty = 'SBD' and d.sab = 'RXNORM' and d.rxcui = r.rxcui2
where r.rela = 'isa' and r.sab = 'RXNORM'
;

-- semantic clinical drug component - semantic clinical drug associations
insert into scd_scdc (scd_rxcui, scdc_rxcui)
select d.rxcui, dc.rxcui
from rxnrel r
join rxnconso d on d.tty = 'SCD' and d.sab = 'RXNORM' and d.rxcui = r.rxcui2
join rxnconso dc on dc.tty = 'SCDC' and dc.sab = 'RXNORM' and dc.rxcui = r.rxcui1
where r.rela = 'consists_of' and r.sab = 'RXNORM'
;

-- semantic clinical dose form group - semantic clinical dose form associations
insert into scdg_scdf (scdg_rxcui, scdf_rxcui)
select g.rxcui, f.rxcui
from rxnrel r
join rxnconso f on f.tty = 'SCDF' and f.sab = 'RXNORM' and f.rxcui = r.rxcui2
join rxnconso g on g.tty = 'SCDG' and g.sab = 'RXNORM' and g.rxcui = r.rxcui1
where r.rela = 'isa' and r.sab = 'RXNORM'
;

-- semantic clinical dose form - semantic clinical dose form group associations
insert into scdg_scd (scdg_rxcui, scd_rxcui)
select g.rxcui, d.rxcui
from rxnrel r
join rxnconso d on d.tty = 'SCD' and d.sab = 'RXNORM' and d.rxcui = r.rxcui2
join rxnconso g on g.tty = 'SCDG' and g.sab = 'RXNORM' and g.rxcui = r.rxcui1
where r.rela = 'isa' and r.sab = 'RXNORM'
;

-- generic drug pack - semantic clinical drug associations
insert into gpck_scd (gpck_rxcui, scd_rxcui)
select p.rxcui, d.rxcui
from rxnrel r
join rxnconso d on d.tty = 'SCD' and d.sab = 'RXNORM' and d.rxcui = r.rxcui2
join rxnconso p on p.tty = 'GPCK' and p.sab = 'RXNORM' and p.rxcui = r.rxcui1
where r.rela = 'contained_in' and r.sab = 'RXNORM'
;

-- branded drug pack - semantic clinical drug associations
insert into bpck_scd (bpck_rxcui, scd_rxcui)
select p.rxcui, d.rxcui
from rxnrel r
join rxnconso d on d.tty = 'SCD' and d.sab = 'RXNORM' and d.rxcui = r.rxcui2
join rxnconso p on p.tty = 'BPCK' and p.sab = 'RXNORM' and p.rxcui = r.rxcui1
where r.rela = 'contained_in' and r.sab = 'RXNORM'
;

-- branded drug pack - semantic branded drug associations
insert into bpck_sbd (bpck_rxcui, sbd_rxcui)
select p.rxcui, d.rxcui
from rxnrel r
join rxnconso d on d.tty = 'SBD' and d.sab = 'RXNORM' and d.rxcui = r.rxcui2
join rxnconso p on p.tty = 'BPCK' and p.sab = 'RXNORM' and p.rxcui = r.rxcui1
where r.rela = 'contained_in' and r.sab = 'RXNORM'
;

insert into scdg_in (scdg_rxcui, in_rxcui)
select r.rxcui1, r.rxcui2
from rxnrel r
join rxnconso c2 on r.rxcui2 = c2.rxcui and c2.sab = 'RXNORM' and c2.tty = 'IN'
join rxnconso c1 on r.rxcui1 = c1.rxcui and c1.sab = 'RXNORM' and c1.tty = 'SCDG'
where r.rela = 'ingredient_of' and r.sab = 'RXNORM'
;

-- branded drug pack synonyms
insert into bpck_sy (bpck_rxcui, sy)
select distinct c.rxcui, sy.str
from rxnconso c
join rxnconso sy on sy.rxcui = c.rxcui and sy.tty = 'SY' and sy.sab = 'RXNORM'
where c.tty = 'BPCK' and c.sab = 'RXNORM'
;

-- dose form synonyms
insert into df_sy (df_rxcui, sy)
select distinct c.rxcui, sy.str
from rxnconso c
join rxnconso sy on sy.rxcui = c.rxcui and sy.tty = 'SY' and sy.sab = 'RXNORM'
where c.tty = 'DF' and c.sab = 'RXNORM'
;

-- generic drug pack synonyms
insert into gpck_sy (gpck_rxcui, sy)
select distinct c.rxcui, sy.str
from rxnconso c
join rxnconso sy on sy.rxcui = c.rxcui and sy.tty = 'SY' and sy.sab = 'RXNORM'
where c.tty = 'GPCK' and c.sab = 'RXNORM'
;

-- ingredient synonyms
insert into in_sy (in_rxcui, sy)
select distinct c.rxcui, sy.str
from rxnconso c
join rxnconso sy on sy.rxcui = c.rxcui and sy.tty = 'SY' and sy.sab = 'RXNORM'
where c.tty = 'IN' and c.sab = 'RXNORM'
;

-- multi-ingredient synonyms
insert into min_sy (min_rxcui, sy)
select distinct c.rxcui, sy.str
from rxnconso c
join rxnconso sy on sy.rxcui = c.rxcui and sy.tty = 'SY' and sy.sab = 'RXNORM'
where c.tty = 'MIN' and c.sab = 'RXNORM'
;

-- precise ingredient synonyms
insert into pin_sy (pin_rxcui, sy)
select distinct c.rxcui, sy.str
from rxnconso c
join rxnconso sy on sy.rxcui = c.rxcui and sy.tty = 'SY' and sy.sab = 'RXNORM'
where c.tty = 'PIN' and c.sab = 'RXNORM'
;

-- prescribable name synonyms
insert into psn_sy (psn_rxcui, sy)
select distinct c.rxcui, sy.str
from rxnconso c
join rxnconso sy on sy.rxcui = c.rxcui and sy.tty = 'SY' and sy.sab = 'RXNORM'
where c.tty = 'PSN' and c.sab = 'RXNORM'
;

-- semantic branded drug synonyms
insert into sbd_sy (sbd_rxcui, sy)
select distinct c.rxcui, sy.str
from rxnconso c
join rxnconso sy on sy.rxcui = c.rxcui and sy.tty = 'SY' and sy.sab = 'RXNORM'
where c.tty = 'SBD' and c.sab = 'RXNORM'
;

-- semantic clinical drug synonyms
insert into scd_sy (scd_rxcui, sy)
select distinct c.rxcui, sy.str
from rxnconso c
join rxnconso sy on sy.rxcui = c.rxcui and sy.tty = 'SY' and sy.sab = 'RXNORM'
where c.tty = 'SCD' and c.sab = 'RXNORM'
;

-- semantic clinical drug and form synonyms
insert into scdf_sy (scdf_rxcui, sy)
select distinct c.rxcui, sy.str
from rxnconso c
join rxnconso sy on sy.rxcui = c.rxcui and sy.tty = 'SY' and sy.sab = 'RXNORM'
where c.tty = 'SCDF' and c.sab = 'RXNORM'
;

-- synonym tall man synonyms
insert into sy_tmsy (sy, tmsy)
select distinct sy.str, tmsy.str
from rxnconso sy
join rxnconso tmsy on sy.rxcui = tmsy.rxcui and tmsy.tty = 'TMSY' and tmsy.sab = 'RXNORM'
where sy.tty = 'SY' and sy.sab = 'RXNORM'
;

-- ingredient source forms
insert into in_src_form (in_rxcui, src, form_tty, form_rxaui, form_rxcui, form_name, form_code, form_suppress)
select c2.rxcui, c1.sab, c1.tty, c1.rxaui, c1.rxcui, c1.str, c1.code, c1.suppress
from rxnrel r
join rxnconso c2 on r.rxcui2 = c2.rxcui and c2.tty = 'IN' and c2.sab = 'RXNORM'
join rxnconso c1 on r.rxcui1 = c1.rxcui
where r.rela = 'has_form' and r.sab = 'RXNORM'
;

-- ingredient source trade names
insert into in_src_tname (in_rxcui, src, tname_tty, tname_rxaui, tname_rxcui, tname, tname_code, tname_suppress)
select c2.rxcui, c1.sab, c1.tty, c1.rxaui, c1.rxcui, c1.str, c1.code, c1.suppress
from rxnrel r
join rxnconso c2 on r.rxcui2 = c2.rxcui and c2.tty = 'IN' and c2.sab = 'RXNORM'
join rxnconso c1 on r.rxcui1 = c1.rxcui
where r.rela = 'has_tradename' and r.sab = 'RXNORM'
;

-- ingredient source ingredient ofs
insert into in_src_in_of (in_rxcui, src, in_of_tty, in_of_rxaui, in_of_rxcui, in_of, in_of_code, in_of_suppress)
select c2.rxcui, c1.sab, c1.tty, c1.rxaui, c1.rxcui, c1.str, c1.code, c1.suppress
from rxnrel r
join rxnconso c2 on r.rxcui2 = c2.rxcui and c2.tty = 'IN' and c2.sab = 'RXNORM'
join rxnconso c1 on r.rxcui1 = c1.rxcui
where r.rela = 'ingredient_of' and r.sab = 'RXNORM'
;

-- ingredient src part ofs
insert into in_src_part_of (in_rxcui, src, part_of_tty, part_of_rxaui, part_of_rxcui, part_of, part_of_code, part_of_suppress)
select c2.rxcui, c1.sab, c1.tty, c1.rxaui, c1.rxcui, c1.str, c1.code, c1.suppress
from rxnrel r
join rxnconso c2 on r.rxcui2 = c2.rxcui and c2.tty = 'IN' and c2.sab = 'RXNORM'
join rxnconso c1 on r.rxcui1 = c1.rxcui
where r.rela = 'part_of' and r.sab = 'RXNORM'
;

-- ingredient rxnorm reactivation dates
insert into in_rxn_action (in_rxcui, action, date, rxaui)
select a.rxcui, 'reactivated', a.atv::date, a.rxaui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.sab = 'RXNORM' and c.tty = 'IN'
where a.atn = 'RXN_ACTIVATED'
;

-- ingredient rxnorm obsoleted dates
insert into in_rxn_action (in_rxcui, action, date, rxaui)
select a.rxcui, 'obsoleted', a.atv::date, a.rxaui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.sab = 'RXNORM' and c.tty = 'IN'
where a.atn = 'RXN_OBSOLETED'
;

-- ATC ingredient levels
insert into atc_in_level (rxaui, level, code, in_rxcui)
select a.rxaui, a.atv::smallint, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.sab = 'RXNORM' and c.tty = 'IN'
where a.atn = 'ATC_LEVEL'
;

-- ingredient DCSAs
insert into src_in_dcsa (rxaui, designation, sab, src_code, in_rxcui)
select a.rxaui, a.atv, a.sab, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'DCSA'
;

-- ingredient pregnancy hazard classifications
insert into src_in_dpc (rxaui, dpc, sab, src_code, in_rxcui)
select a.rxaui, a.atv, a.sab, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'DPC'
;

-- ingredient scope statements
insert into src_in_scope_stmt (rxaui, scope_statement, sab, src_code, in_rxcui)
select a.rxaui, a.atv, a.sab, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'SOS'
;

insert into drugbank_in_unii (rxaui, unii, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.sab = 'RXNORM' and c.tty = 'IN'
where a.atn = 'FDA_UNII_CODE'
;

insert into drugbank_in_sec_go_id (rxaui, sec_go_id, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.sab = 'RXNORM' and c.tty = 'IN'
where a.atn = 'SID'
;

-- VANDF ingredient exclude in drug interaction checks
insert into vandf_in_exclude_di (rxaui, exclude_check, code, in_rxcui)
select a.rxaui, a.atv = 'YES', a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'EXCLUDE_DI_CHECK'
order by rxcui
;

-- VANDF ingredient formulary indicator
insert into vandf_in_nf_ind (rxaui, nf_ind, code, in_rxcui)
select a.rxaui, a.atv = 'YES', a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'NFI'
order by rxcui
;

-- VANDF ingredient national formulary inactivation dates
insert into vandf_in_nf_inact (rxaui, inactivated, code, in_rxcui)
select a.rxaui, a.atv::date, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'NF_INACTIVATE'
order by rxcui
;

-- VANDF ingredient national formulary names
insert into vandf_in_nf_name (rxaui, name, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'NF_NAME'
order by rxcui
;

-- VANDF ingredient product source multiplicities
insert into vandf_in_prod_src_mult (rxaui, src_mult, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'SNGL_OR_MULT_SRC_PRD'
order by rxcui
;

-- VANDF ingredient NDF/HT classes
insert into vandf_in_ndfht_class (rxaui, ndfht_class, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'VAC'
order by rxcui
;

-- VANDF ingredient VA classes
insert into vandf_in_va_class (rxaui, va_class, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'VA_CLASS_NAME'
order by rxcui
;

-- VANDF ingredient VA dispense units
insert into vandf_in_va_dspun (rxaui, dispense_unit, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'VA_DISPENSE_UNIT'
order by rxcui
;

-- VANDF ingredient generic names
insert into vandf_in_gname (rxaui, generic_name, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'VA_GENERIC_NAME'
order by rxcui
;

-- VANDF ingredient CMOP IDs
insert into vandf_in_cmopid (rxaui, cmop_id, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'VMO'
order by rxcui
;

-- MeSH online notes for MEDLINE searchers
insert into msh_in_ml_note (rxaui, note, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'OL'
order by rxcui
;

-- Mesh ingredient allowed qualifiers
insert into msh_in_aql (rxaui, qualifier, code, in_rxcui)
select a.rxaui, qualifier, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
cross join lateral regexp_split_to_table(a.atv, ' ') qualifier
where a.atn = 'AQL'
order by rxcui
;

-- Mesh ingredient hierarchical numbers
insert into msh_in_hnum (rxaui, hnum, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'MN'
order by rxcui
;

-- Mesh ingredient classes
insert into msh_in_dc (rxaui, msh_class, code, in_rxcui)
select a.rxaui, a.atv::smallint, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'DC'
;

-- Mesh ingredient established dates
insert into msh_in_est_date (rxaui, established, code, in_rxcui)
select a.rxaui, a.atv::date, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'DX'
;

-- Mesh ingredient entry dates
insert into msh_in_ent_date (rxaui, entered, code, in_rxcui)
select a.rxaui, a.atv::date, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'MDA'
;

-- Mesh ingredient revision dates
insert into msh_in_rev_date (rxaui, revised, code, in_rxcui)
select a.rxaui, a.atv::date, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'MMR'
;

-- Mesh ingredient headings
insert into msh_in_hdg (rxaui, main_hdg, code, in_rxcui)
select a.rxcui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'EC'
;

-- Mesh ingredient annotations
insert into msh_in_ann (rxaui, annotation, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'AN'
;

-- Mesh ingredient frequencies
insert into msh_in_freq (rxaui, freq, code, in_rxcui)
select a.rxaui, a.atv::smallint, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'FR'
;

-- Mesh ingredient see headings
insert into msh_in_see_hdg (rxaui, hdg, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'FR'
;

-- Mesh ingredient is-tradenames
insert into msh_in_is_tname (rxaui, is_tradename, code, in_rxcui)
select a.rxaui, a.atv = 'TRD', a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'LT'
;

-- Mesh ingredient heading mapped-to's
insert into msh_in_hdg_mapped_to (rxaui, hdg_mapped_to, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'HM'
;

-- Mesh ingredient histories
insert into msh_in_hist (rxaui, note, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'HN'
;

-- Mesh ingredient related headings
insert into msh_in_rel_hdg (rxaui, rel_hdg, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'II'
;

-- Mesh ingredient heading dates
insert into msh_in_hdg_dates (rxaui, hdg_dates, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'PI'
;

-- Mesh ingredient public notes
insert into msh_in_pub_note (rxaui, note, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'PM'
;

-- Mesh ingredient registration numbers
insert into msh_in_reg_num (rxaui, reg_num, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'RN'
;

-- Mesh ingredient CA registration numbers
insert into msh_in_ca_reg_num (rxaui, ca_reg_num, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'RR'
;

-- Mesh ingredient supplemental record classes
insert into msh_in_sup_class (rxaui, sup_class, code, in_rxcui)
select a.rxaui, a.atv::smallint, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'SC'
;

-- Mesh ingredient literature sources
insert into msh_in_lit_src (rxaui, lit_src, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'SRC'
;

-- Mesh ingredient term unique identifiers
insert into msh_in_term_ui (rxaui, term_ui, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'TERMUI'
;

-- Mesh ingredient thesaurus ids
insert into msh_in_thes_id (rxaui, thesaurus_id, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'TH'
;

-- USP monograph official dates
insert into usp_in_monog_date (rxaui, official_date, code, in_rxcui)
select a.rxaui, a.atv::date, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'MONOGRAPH_OFFICIAL_DATE'
;

-- USP monograph statuses
insert into usp_in_monog_stat (rxaui, status, code, in_rxcui)
select a.rxaui, a.atv, a.code, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'MONOGRAPH_STATUS'
;

-- MMSL ingredient supply categories
insert into mmsl_in_sup_cat (rxaui, sup_cat, in_rxcui)
select a.rxaui, a.atv, a.rxcui
from rxnsat a
join rxnconso c on c.rxcui = a.rxcui and c.tty = 'IN' and c.sab = 'RXNORM'
where a.atn = 'TYPE'
;

-- PIN source form-ofs
insert into pin_src_form_of
select c2.rxcui, c1.sab, c1.tty, c1.rxaui, c1.rxcui, c1.str, c1.code, c1.suppress
from rxnrel r
join rxnconso c2 on r.rxcui2 = c2.rxcui and c2.tty = 'PIN' and c2.sab = 'RXNORM'
join rxnconso c1 on r.rxcui1 = c1.rxcui
where r.rela = 'form_of' and r.sab = 'RXNORM'
;

-- PIN source part-ofs
insert into pin_src_part_of
select c2.rxcui, c1.sab, c1.tty, c1.rxaui, c1.rxcui, c1.str, c1.code, c1.suppress
from rxnrel r
join rxnconso c2 on r.rxcui2 = c2.rxcui and c2.tty = 'PIN' and c2.sab = 'RXNORM'
join rxnconso c1 on r.rxcui1 = c1.rxcui
where r.rela = 'part_of' and r.sab = 'RXNORM'
;

-- PIN source PIN-ofs
insert into pin_src_pin_of
select c2.rxcui, c1.sab, c1.tty, c1.rxaui, c1.rxcui, c1.str, c1.code, c1.suppress
from rxnrel r
join rxnconso c2 on r.rxcui2 = c2.rxcui and c2.tty = 'PIN' and c2.sab = 'RXNORM'
join rxnconso c1 on r.rxcui1 = c1.rxcui
where r.rela = 'precise_ingredient_of' and r.sab = 'RXNORM'
;

--
-- TODO: Examine from here: Use only rxnorig tables, avoid using inverse relationships, "larger" entity first in intersection tables.
--


-- Load tables derived from sab=MTHSPL subset of RxNorm.

-- spl substances
insert into mthspl_sub (rxaui, rxcui, unii, biologic_code, name, in_rxcui, pin_rxcui, suppress)
select
  c.rxaui,
  c.rxcui,
  case when length(c.code) = 10 then c.code end unii,
  case when length(c.code) >= 17 then c.code end biologic_code,
  c.str name,
  (select i.rxcui from "in" i where i.rxcui = c.rxcui) in_rxcui,
  (select i.rxcui from pin i where i.rxcui = c.rxcui) pin_rxcui,
  c.suppress
from rxnconso c
where c.tty = 'SU' and c.sab = 'MTHSPL'
;

-- spl products
insert into mthspl_prod (rxaui, rxcui, code, rxnorm_created, name, scd_rxcui, sbd_rxcui, gpck_rxcui, bpck_rxcui, suppress, ambiguity_flag)
select
  c.rxaui,
  c.rxcui,
  case when c.code <> 'NOCODE' then c.code end,
  c.tty = 'MTH_RXN_DP',
  c.str as name,
  (select d.rxcui from scd d where d.rxcui = c.rxcui) scd_rxcui,
  (select d.rxcui from sbd d where d.rxcui = c.rxcui) sbd_rxcui,
  (select d.rxcui from gpck d where d.rxcui = c.rxcui) gpck_rxcui,
  (select d.rxcui from bpck d where d.rxcui = c.rxcui) bpck_rxcui,
  c.suppress,
  (select a.atv from rxnsat a where a.rxaui = c.rxaui and a.atn = 'AMBIGUITY_FLAG') ambiguity_flag
from rxnconso c
where c.tty in ('DP','MTH_RXN_DP') and c.sab='MTHSPL'
;

-- spl substance set ids
insert into mthspl_sub_setid (sub_rxaui, set_id, suppress)
select a.rxaui, a.atv, a.suppress
from mthspl_sub s
join rxnsat a on a.rxaui = s.rxaui and a.atn = 'SPL_SET_ID'
;

-- spl ingredient types
insert into mthspl_ingr_type (ingr_type, description) values
  ('I', 'inactive ingredient'),
  ('A', 'active ingredient'),
  ('M', 'active moiety')
;

-- spl product substances
insert into mthspl_prod_sub (prod_rxaui, ingr_type, sub_rxaui)
select
  r.rxaui2 prod_rxaui,
  case when r.rela='has_active_ingredient' then 'A'
       when r.rela='has_active_moiety' then 'M'
       else 'I' end ingr_type,
  r.rxaui1 sub_rxaui
from rxnrel r
where
  r.rela IN ('has_active_ingredient','has_inactive_ingredient','has_active_moiety')
  and r.sab='MTHSPL'
;

-- spl product dailymed spl ids
insert into mthspl_prod_dmspl
select distinct p.rxaui, a.atv dm_spl_id
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'DM_SPL_ID'
;

-- spl product set ids
insert into mthspl_prod_setid
select distinct p.rxaui, a.atv dm_spl_id
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'SPL_SET_ID'
;

-- spl product ndcs
insert into mthspl_prod_ndc
select p.rxaui, a.atv full_ndc, regexp_replace(a.atv , '-[0-9]+$', '') two_part_ndc
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'NDC'
;

-- spl product labelers
insert into mthspl_prod_labeler
select p.rxaui, a.atv
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'LABELER'
;

-- spl product labeling types
insert into mthspl_prod_labeltype
select p.rxaui, a.atv
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'LABEL_TYPE'
;

-- spl market categories
insert into mthspl_mktcat (name)
select distinct a.atv
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'MARKETING_CATEGORY'
;

-- spl product market categories
insert into mthspl_prod_mktcat (prod_rxaui, mkt_cat)
select p.rxaui, a.atv
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'MARKETING_CATEGORY'
;

-- spl product market category codes
insert into mthspl_prod_mktcat_code (prod_rxaui, mkt_cat, code, num)
select pa.rxaui, mc.name, pa.atv, regexp_replace(pa.atv, '^[A-Za-z]+', '')
from (
  select p.rxaui, a.atn, a.atv
  from mthspl_prod p
  join rxnsat a on a.rxaui = p.rxaui
) pa
join mthspl_mktcat mc on mc.name = pa.atn
;

-- spl product marketing statuses
insert into mthspl_prod_mktstat
select p.rxaui, a.atv
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'MARKETING_STATUS'
;

-- spl product marketing effective time highs
insert into mthspl_prod_mkteffth
select p.rxaui, a.atv
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'MARKETING_EFFECTIVE_TIME_HIGH'
;

-- spl product marketing effective time lows
insert into mthspl_prod_mktefftl
select p.rxaui, a.atv
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'MARKETING_EFFECTIVE_TIME_LOW'
;

-- spl product dcsa's
insert into mthspl_prod_dcsa
select p.rxaui, a.atv
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'DCSA'
;

-- spl product nhric's
insert into mthspl_prod_nhric
select p.rxaui, a.atv
from mthspl_prod p
join rxnsat a on a.rxaui = p.rxaui and a.atn = 'NHRIC'
;

-- spl pill attributes
insert into mthspl_pillattr (attr) values
  ('IMPRINT_CODE'),
  ('COATING'),
  ('COLOR'),
  ('COLORTEXT'),
  ('SCORE'),
  ('SHAPE'),
  ('SHAPETEXT'),
  ('SIZE'),
  ('SYMBOL')
;

-- spl product pill attributes
insert into mthspl_prod_pillattr (prod_rxaui, attr, attr_val)
select pa.rxaui, a.attr, pa.atv
from (
  select p.rxaui, a.atn, a.atv
  from mthspl_prod p
  join rxnsat a on a.rxaui = p.rxaui
) pa
join mthspl_pillattr a on a.attr = pa.atn
;
