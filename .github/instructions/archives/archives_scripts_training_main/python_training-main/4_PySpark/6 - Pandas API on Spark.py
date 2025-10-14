# Databricks notebook source
# MAGIC %md
# MAGIC # Pandas API on Spark
# MAGIC
# MAGIC The Spark API on Pandas enables the seamless interaction between Apache Spark and Pandas, providing a high-level, flexible, and distributed data processing environment. It allows users to leverage the ease-of-use and extensive functionality of Pandas while harnessing the scalability and distributed computing capabilities of Spark. This integration enables efficient data processing and analysis on large-scale datasets using familiar Pandas syntax and operations.
# MAGIC
# MAGIC Long story short: if you're familiar with Pandas, this is for you.

# COMMAND ----------

# MAGIC %md
# MAGIC ##### Useful links
# MAGIC - [User guide](https://spark.apache.org/docs/latest/api/python/user_guide/pandas_on_spark/index.html)
# MAGIC - [Spark by examples](https://sparkbyexamples.com/pyspark/pandas-api-on-apache-spark-pyspark/)

# COMMAND ----------

# Some raw data
technologies = ({
    'Courses' :["Spark","PySpark","Hadoop","Python","Pandas","Hadoop","Spark","Python","NA"],
    'Fee'     :[22000,25000,23000,24000,26000,25000,25000,22000,1500],
    'Duration':['30days','50days','55days','40days','60days','35days','30days','50days','40days'],
    'Discount':[1000,2300,1000,1200,2500,None,1400,1600,0]
})


# COMMAND ----------

# MAGIC %md
# MAGIC ##### Using Pandas

# COMMAND ----------

import pandas as pd

# Let's create a Pandas dataframe
df = pd.DataFrame(technologies)
df

# COMMAND ----------

type(df)

# COMMAND ----------

# Quick summary by
summary = df.groupby(['Courses']).sum()
summary

# COMMAND ----------

type(summary)

# COMMAND ----------

# MAGIC %md
# MAGIC ##### Using Pandas API on Spark

# COMMAND ----------

# Let's do the same but with PySpark.
import pyspark.pandas as ps

# Only one letter changed, we just changed the package reference!
df = ps.DataFrame(technologies)
df

# COMMAND ----------

# This is not a typical Pandas df
type(df)

# COMMAND ----------

# We don't need to change any code. It yield the same results, but under the hood we're using/creating PySpark dataframes.
summary = df.groupby(['Courses']).sum()
summary

# COMMAND ----------

type(summary)

# COMMAND ----------

# MAGIC %md
# MAGIC ##### In conclusion...
# MAGIC You can take your Pandas code, replace <code>pd</code> with <code>ps</code> and it should work right away! And faster :-)
