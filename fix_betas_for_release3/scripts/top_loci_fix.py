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
    inf = 'gs://genetics-portal-staging/v2d/190530/toploci.parquet'
    outf = 'gs://genetics-portal-staging/v2d/190612/toploci.parquet'

    # Studies to fix
    studies = [
        'GCST004131',
        'GCST004132',
        'GCST004133',
        'GCST001725',
        'GCST001728',
        'GCST001729',
        'GCST000964'
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
    
    # Get which rows to fix
    to_fix = col('study_id').isin(*studies)

    # Fix odds ratio
    df_fixed = (
        df.withColumn('odds_ratio', when(to_fix, col('odds_ratio') ** -1).otherwise(col('odds_ratio')))
          .withColumn('oddsr_ci_lower', when(to_fix, col('oddsr_ci_upper') ** -1).otherwise(col('oddsr_ci_lower')))
          .withColumn('oddsr_ci_upper', when(to_fix, col('oddsr_ci_lower') ** -1).otherwise(col('oddsr_ci_upper')))
    )
    
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
