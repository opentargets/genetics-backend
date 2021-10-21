create database if not exists ot;
CREATE TABLE if NOT EXISTS ot.v2g_structure
engine MergeTree ORDER BY (type_id)
AS SELECT 
    type_id,
    source_id,
    groupUniqArray(feature) AS feature_set
FROM ot.v2g_scored
WHERE chr_id = '1'
GROUP BY 
    type_id,
    source_id
ORDER BY 
    type_id ASC,
    source_id ASC,
    feature_set ASC;
