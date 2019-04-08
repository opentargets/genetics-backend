PER_WINDOW = '''
SELECT
   '{CHR}' AS chromosome,
   {START} AS start,
   {END} AS end,
   uniq(gene_id) AS geneCount,
   uniq(tag_chrom,
       tag_pos,
       tag_ref,
       tag_alt) AS tagVariantCount,
   uniq(lead_chrom,
       lead_pos,
       lead_ref,
       lead_alt) AS indexVariantCount,
   uniq(study_id) AS studyCount,
   uniq(
       lead_chrom,
       lead_pos,
       lead_ref,
       lead_alt,
       tag_chrom,
       tag_pos,
       tag_ref,
       tag_alt,
       gene_id
   ) AS geneTagVariantCount,
   uniq(
        lead_chrom,
       lead_pos,
       lead_ref,
       lead_alt,
       tag_chrom,
       tag_pos,
       tag_ref,
       tag_alt, 
       study_id
   ) AS tagVariantIndexVariantStudyCount
FROM
(
       SELECT
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
       FROM ot.d2v2g_scored
       PREWHERE (tag_chrom = '{CHR}') AND 
        (((tag_pos >= {START}) AND (tag_pos <= {END})) OR 
        ((lead_pos >= {START}) AND (lead_pos <= {END})) OR 
        ((dictGetUInt32('gene', 'start', tuple(gene_id)) >= {START}) AND 
        (dictGetUInt32('gene', 'start', tuple(gene_id)) <= {END})) OR 
        ((dictGetUInt32('gene', 'end', tuple(gene_id)) >= {START}) AND 
        (dictGetUInt32('gene', 'end', tuple(gene_id)) <= {END})))
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
'''

def make_chrom_chunks(chrom_length_dict, window_size=int(2e6)):
 ''' Chunks genome into regions
 '''
 window_size = int(window_size)
 for chrom in chrom_length_dict:
     start = 1
     end = window_size
     while start < chrom_length_dict[chrom]:
         yield chrom, start, end
         start = start + window_size
         end = end + window_size

chrom_lengths = {'1': 249250621,
                '10': 135534747,
                '11': 135006516,
                '12': 133851895,
                '13': 115169878,
                '14': 107349540,
                '15': 102531392,
                '16': 90354753,
                '17': 81195210,
                '18': 78077248,
                '19': 59128983,
                '2': 243199373,
                '20': 63025520,
                '21': 48129895,
                '22': 51304566,
                '3': 198022430,
                '4': 191154276,
                '5': 180915260,
                '6': 171115067,
                '7': 159138663,
                '8': 146364022,
                '9': 141213431,
                'X': 155270560,
                'Y': 59373566}

def make_chrom_queries():
   windows = list(make_chrom_chunks(chrom_lengths, window_size=2e6))
   queries = ';'.join(PER_WINDOW.format(CHR=CHR, START=START, END=END) for (CHR, START, END) in windows)
   print(queries)