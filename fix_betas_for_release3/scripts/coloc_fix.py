#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Ed Mountjoy
#
# Requires scipy and pandas

'''
# Set SPARK_HOME and PYTHONPATH to use 2.4.0
export PYSPARK_SUBMIT_ARGS="--driver-memory 8g pyspark-shell"
export SPARK_HOME=/Users/em21/software/spark-2.4.0-bin-hadoop2.7
export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-2.4.0-src.zip:$PYTHONPATH
'''

import sys
import os
import pyspark.sql
from pyspark.sql.types import *
from pyspark.sql import DataFrame
from pyspark.sql.functions import *

def main():

    # Args (local)
    inf = 'gs://genetics-portal-staging/coloc/190601/coloc_processed_w_betas.parquet'
    outf = 'gs://genetics-portal-staging/coloc/190612/coloc_processed_w_betas.parquet'

    # Studies to fix
    studies = [
        'GCST004131',
        'GCST004132',
        'GCST004133',
        'GCST001725',
        'GCST001728',
        'GCST001729',
        'GCST000964',
        # 'GTEX_v7'  # DEBUG
    ]

    # Make spark session
    global spark
    spark = (
        pyspark.sql.SparkSession.builder
        .getOrCreate()
    )
    print('Spark version: ', spark.version)
    
    # Load data
    df = spark.read.parquet(inf)
    # df.show()
    # sys.exit()
    
    # Get which rows to fix
    to_fix = col('right_study').isin(*studies)
    # df = df.filter(to_fix)
    # df.show()
    # df.printSchema()
    # sys.exit()

    # Fix odds ratio
    df_fixed = (
        df.withColumn('left_var_right_study_beta', when(to_fix, col('left_var_right_study_beta') * -1).otherwise(col('left_var_right_study_beta')))
    )
    # df_fixed.show()
    # sys.exit()
    
    # Save
    (
        df_fixed
        .write
        .parquet(outf, mode='overwrite')
    )

    return 0


if __name__ == '__main__':

    main()
#
