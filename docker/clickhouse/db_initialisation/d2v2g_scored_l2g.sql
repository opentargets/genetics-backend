create database if not exists ot;
create table if not exists ot.d2l2g_raw_scores
  engine MergeTree partition by (lead_chrom) order by (lead_pos)
AS SELECT
    study_id,
    lead_chrom,
    lead_pos,
    lead_ref,
    lead_alt,
    gene_id,
    any(v2g_source_list) as v2g_source_list,
    any(v2g_source_score_list) as v2g_source_score_list,
    any(v2g_overall_score) as v2g_overall_score,
    sum(l2g_raw) as l2g_raw
FROM
(
    SELECT
        study_id,
        lead_chrom,
        lead_pos,
        lead_ref,
        lead_alt,
        gene_id,
        any(posterior_prob) AS posterior_prob,
        any(overall_r2) AS overall_r2,
        any(source_list) as v2g_source_list,
        any(source_score_list) as v2g_source_score_list,
        any(overall_score) AS v2g_overall_score,
        if(isNull(posterior_prob), overall_r2 * v2g_overall_score, posterior_prob * v2g_overall_score) AS l2g_raw
    FROM ot.d2v2g_scored
    GROUP BY
        study_id,
        lead_chrom,
        lead_pos,
        lead_ref,
        lead_alt,
        tag_chrom,
        tag_pos,
        tag_ref,
        tag_alt,
        gene_id
)
GROUP BY
    study_id,
    lead_chrom,
    lead_pos,
    lead_ref,
    lead_alt,
    gene_id;


create database if not exists ot;
create table if not exists ot.d2l2g_norm_scores
  engine MergeTree partition by (lead_chrom) order by (lead_pos)
AS SELECT
    study_id,
    lead_chrom,
    lead_pos,
    lead_ref,
    lead_alt,
    gene_id,
    v2g_source_list,
    v2g_source_score_list,
    v2g_overall_score,
    l2g_raw,
    (l2g_raw /sum_l2) as l2g_norm
FROM (
        SELECT
          *
        FROM ot.d2l2g_raw_scores
    )
  ALL INNER JOIN
    (
       SELECT
          study_id,
          lead_chrom,
          lead_pos,
          lead_ref,
          lead_alt,
          sum(l2g_raw) as sum_l2
       FROM ot.d2l2g_raw_scores
      group by study_id,
          lead_chrom,
          lead_pos,
          lead_ref,
          lead_alt
    ) USING (study_id, lead_chrom, lead_pos, lead_ref, lead_alt);
