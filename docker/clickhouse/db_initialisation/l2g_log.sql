create database if not exists ot;
create table if not exists ot.l2g_log(
  study_id String,
  chrom String,
  pos UInt32,
  ref String,
  alt String,
  gene_id String,
  training_clf String,
  training_gs String,
  training_fold String,
  y_proba_dist_foot Float64,
  y_proba_dist_tss Float64,
  y_proba_full_model Float64,
  y_proba_logi_distance Float64,
  y_proba_logi_interaction Float64,
  y_proba_logi_molecularQTL Float64,
  y_proba_logi_pathogenicity Float64,
  y_proba_logo_distance Float64,
  y_proba_logo_interaction Float64,
  y_proba_logo_molecularQTL Float64,
  y_proba_logo_pathogenicity Float64)
engine = Log;

