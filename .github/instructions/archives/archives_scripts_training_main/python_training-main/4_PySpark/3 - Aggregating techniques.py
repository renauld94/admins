# Databricks notebook source
# MAGIC %md
# MAGIC # Partitioning vs Grouping

# COMMAND ----------

# MAGIC %md
# MAGIC Partitioning and Grouping are techniques to apply aggregate functions on subset of data rather than on the entire dataframe. There is one big difference however.
# MAGIC  1. **Grouping** will reduce the number of rows in your DataFrame.
# MAGIC  2. **Partitioning** just divides your data in subsets so you can run the aggregating function later on. This is very useful technique, not available in Pandas. Cherry on the pie: you do not lose data provenance when aggregating data.
# MAGIC
# MAGIC Let's see a concrete example for each.

# COMMAND ----------

import pyspark.sql.functions as F
from pyspark.sql import Window, Row
from datetime import date

# COMMAND ----------

# Let's create a PySpark dataframe from scratch, one row at a time
df = spark.createDataFrame([
    Row(SUBJID='1', VISIT=1, HR=80,  AGE=25, SEX='M'),
    Row(SUBJID='1', VISIT=2, HR=85,  AGE=25, SEX='M'),
    Row(SUBJID='2', VISIT=1, HR=90,  AGE=44, SEX='F'),
    Row(SUBJID='2', VISIT=2, HR=75,  AGE=44, SEX='F'),
    Row(SUBJID='3', VISIT=1, HR=105, AGE=21, SEX='M'),
    Row(SUBJID='3', VISIT=2, HR=95,  AGE=21, SEX='M'),
    Row(SUBJID='4', VISIT=1, HR=70,  AGE=36, SEX='F'),
    Row(SUBJID='4', VISIT=2, HR=65,  AGE=36, SEX='F'),
])

df.display()

# COMMAND ----------

# MAGIC %md
# MAGIC ### 1) Grouping

# COMMAND ----------

# Get the average Heart Rate for each subject:
df.groupBy('SUBJID').mean('HR').display()

# Note that the number of rows has been reduced. This is a summary.

# COMMAND ----------

# Similarly, the youngest by gender
df.groupBy('SEX').min('AGE').display()

# Here again, the number of rows has been reduced

# COMMAND ----------

# MAGIC %md
# MAGIC ### 2) Partitioning

# COMMAND ----------

# Let's partition the dataframe by SUBJID. Each partition can be processed in parallel across different nodes in a cluster, which can improve performance for large datasets.

window = Window.partitionBy('SUBJID') # Window creates the partition. Why 'Window'? Thinks about the view you get from a window: a subset of what's out there.

# We can use that window to create a new column using an aggregate function, like F.min
df2 = df.withColumn(
    "min_HR", 
    F.min("HR").over(window)
)

# We have ADDED to our df the minimal HR per SUBJID. The number of rows remained unchanged. This is nice, no need to merge anything and we kept all the columns
df2.display()

# COMMAND ----------

# We can use the same technique, and the same window object btw, to calculate 'HR Baseline' and 'Change from baseline': 

df3 = df.withColumn(
        "Baseline",
        F.first(F.when(F.col("VISIT") == 1, F.col("HR")), ignorenulls=True).over(window)    
    )\
    .withColumn(
        "Chg_from_baseline",
        F.when(
            F.col('Visit') != 1, F.col("HR") - F.col("Baseline")
        )
    )\
    .orderBy('SUBJID', 'VISIT')

df3.display()
