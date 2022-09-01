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
    inf = 'gs://genetics-portal-dev-sumstats/filtered/pvalue_0.005/gwas/220207'
    outf = 'gs://genetics-portal-dev-sumstats/filtered/pvalue_0.005/gwas/220208'

    # Studies to fix
    studies = [
        'GCST004131',
        'GCST004132',
        'GCST004133',
        'GCST001725',
        'GCST001728',
        'GCST001729',
        'GCST000964',
        'GCST000758',
        'GCST000760',
        'GCST000755',
        'GCST000759'
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
    # df = df.filter(to_fix)
    # df.show()
    # df.printSchema()
    # sys.exit()

    # Fix odds ratio
    df_fixed = (
        df.withColumn('beta', when(to_fix, col('beta') * -1).otherwise(col('beta')))
    )
    # df_fixed.show()
    # sys.exit()
    
    # Save
    (
        df_fixed
        .repartition(5000)
        .write
        .parquet(outf, mode='overwrite')
    )

    return 0


if __name__ == '__main__':

    main()
#
