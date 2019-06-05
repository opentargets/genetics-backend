create database if not exists ot;
create table if not exists ot.studies
    engine MergeTree order by (study_id)
as select
       assumeNotNull(study_id) as study_id,
       if(length(pmid) > 0, pmid, NULL) as pmid,
       if(length(pub_date) > 0, pub_date, NULL) as pub_date,
       if(length(pub_journal) > 0, pub_journal, NULL) as pub_journal,
       if(length(pub_title) > 0, pub_title, NULL) as pub_title,
       if(length(pub_author) > 0, pub_author, NULL) as pub_author,
       has_sumstats,
       if(length(trait_reported) > 0, trait_reported, NULL) as trait_reported,
       trait_efos,
       arrayFilter(x -> length(x) > 0, ancestry_initial) as ancestry_initial,
       arrayFilter(x -> length(x) > 0, ancestry_replication) as ancestry_replication,
       n_initial,
       n_replication,
       n_cases,
       if(length(trait_category) > 0, trait_category, NULL) as trait_category,
       num_assoc_loci
   from ot.studies_log;
