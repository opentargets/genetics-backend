create database if not exists ot;
create table if not exists ot.manhattan
  engine MergeTree order by (study, chrom, pos, ref, alt)
as SELECT study,
       chrom,
       pos,
       ref,
       alt,
       pval,
       pval_mantissa,
       pval_exponent,
       odds,
       oddsL,
       oddsU,
       direction,
       beta,
       betaL,
       betaU,
       credibleSetSize,
       ldSetSize,
       uniq_variants,
       top10_genes_raw.2   as top10_genes_raw_ids,
       top10_genes_raw.1   as top10_genes_raw_score,
       top10_genes_coloc.2 as top10_genes_coloc_ids,
       top10_genes_coloc.1 as top10_genes_coloc_score
FROM (
         SELECT study_id as study,
                lead_chrom                                                          as chrom,
                lead_pos                                                            as pos,
                lead_ref                                                            as ref,
                lead_alt                                                            as alt,
                any(pval)                                                           AS pval,
                any(pval_mantissa)                                                  AS pval_mantissa,
                any(pval_exponent)                                                  AS pval_exponent,
                any(odds_ratio)                                                     as odds,
                any(oddsr_ci_lower)                                                 as oddsL,
                any(oddsr_ci_upper)                                                 as oddsU,
                any(direction)                                                      as direction,
                any(beta)                                                           as beta,
                any(beta_ci_lower)                                                  as betaL,
                any(beta_ci_upper)                                                  as betaU,
                uniqIf((tag_chrom, tag_pos, tag_ref, tag_alt), posterior_prob > 0.) AS credibleSetSize,
                uniqIf((tag_chrom, tag_pos, tag_ref, tag_alt), overall_r2 > 0.)     AS ldSetSize,
                uniq(tag_chrom, tag_pos, tag_ref, tag_alt)                          AS uniq_variants
         FROM ot.v2d_by_stchr
         GROUP BY
              study_id,
             lead_chrom,
             lead_pos,
             lead_ref,
             lead_alt
         )
         ANY
         FULL OUTER JOIN
     (
         select study,
                chrom,
                pos,
                ref,
                alt,
                arraySort(groupUniqArray(top10_genes_with_type))                                      as top10_genes_sorted,
                if(top10_genes_sorted[1].1 = 'coloc', top10_genes_sorted[1].2,
                   [])                                                                                as top10_genes_coloc,
                if(top10_genes_sorted[1].1 = 'raw', top10_genes_sorted[1].2, top10_genes_sorted[2].2) as top10_genes_raw
         from (
               select study,
                      chrom,
                      pos,
                      ref,
                      alt,
                      (agg_type, top10_genes) as top10_genes_with_type
               from (select
                            left_study as study,
                         left_chrom as chrom,
                         left_pos as pos,
                         left_ref as ref,
                         left_alt as alt,
                         arrayReverseSort(
                                 arrayReduce('groupUniqArray',
                                             groupArray((coloc_h4, right_gene_id))))
                                    as top10_genes,
                         'coloc' as agg_type
                     from ot.v2d_coloc
                     where round(coloc_h4,2) >= 0.95 and
                             coloc_log2_h4_h3 >= log2(5) and
                             right_type <> 'gwas' and
                           left_chrom = chrom and
                           left_pos = pos and
                           left_ref = ref and
                           left_alt = alt
                     group by left_study,
                              left_chrom,
                              left_pos,
                              left_ref,
                              left_alt
                    )
               union all
               select
                      study,
                   chrom,
                   pos,
                   ref,
                   alt,
                   (agg_type, top10_genes) as top10_genes_with_type
                   from (
                         select
                                study_id as study,
                             lead_chrom as chrom,
                             lead_pos as pos,
                             lead_ref as ref,
                             lead_alt as alt,
                             arrayReverseSort(
                                     arrayReduce('groupUniqArray',
                                                 groupArray((overall_score, gene_id)))) AS top10_genes,
                             'raw' as agg_type
                         from ot.d2v2g_scored
                         where tag_chrom = chrom and
                               tag_pos = pos and
                               tag_ref = ref and
                               tag_alt = alt
                        group by study_id,
                                 lead_chrom,
                                 lead_pos,
                                 lead_ref,
                                 lead_alt
                            )
                   )
               group by study,
                    chrom,
                   pos,
                   ref,
                   alt
         ) USING (study, chrom, pos, ref, alt);

create view if not exists ot.manhattan_with_l2g as
    select study,
       chrom,
       pos,
       ref,
       alt,
       pval,
       pval_mantissa,
       pval_exponent,
       odds,
       oddsL,
       oddsU,
       direction,
       beta,
       betaL,
       betaU,
       credibleSetSize,
       ldSetSize,
       uniq_variants,
       top10_genes_raw_ids,
       top10_genes_raw_score,
       top10_genes_coloc_ids,
       top10_genes_coloc_score,
       L.top10_genes_l2g as top10_genes_l2g
    from ot.manhattan
    ANY LEFT JOIN
    (
        SELECT
            study_id,
            pos,
            ref,
            alt,
            groupUniqArray(gene_id) AS top10_genes_l2g
        FROM ot.l2g_by_slg
        PREWHERE (y_proba_full_model >= 0.5)
        GROUP BY
            study_id,
            pos,
            ref,
            alt
    ) AS L ON (study = L.study_id) AND (pos = L.pos) AND (ref = L.ref) AND (alt = L.alt);