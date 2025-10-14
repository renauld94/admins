# Databricks notebook source
# MAGIC %md
# MAGIC # Spark SQL and DataFrames, the basics
# MAGIC
# MAGIC Spark SQL is Apache Spark’s module for working with structured data. It allows you to seamlessly mix SQL queries with Spark programs. With PySpark DataFrames you can efficiently read, write, transform, and analyze data using Python and SQL. Whether you use Python or SQL, the same underlying execution engine is used so you will always leverage the full power of Spark.
# MAGIC
# MAGIC The syntax is thought to be close to Pandas, however it's not identical. If you are familiar with Pandas and want to hit the ground running you should probably **look first** at the 'Pandas API on Spark' notebook. 
# MAGIC
# MAGIC **NOTE**: these are standalone examples, meaning you don't need to call any D4U utility functions.

# COMMAND ----------

# MAGIC %md
# MAGIC ##### Table of contents
# MAGIC 1. Create a PySpark Dataframe
# MAGIC 2. Display a PySpark dataframe
# MAGIC 3. Lazy vs Eager
# MAGIC 4. Select data in a PySpark dataframe
# MAGIC 5. Windows function
# MAGIC 6. Collect data
# MAGIC
# MAGIC ##### Useful links
# MAGIC - [Spark SQL guide](https://spark.apache.org/docs/latest/sql-programming-guide.html)
# MAGIC - [Spark by examples](https://sparkbyexamples.com/)

# COMMAND ----------


import pandas as pd
import pyspark.sql.functions as F
from datetime import date
from pyspark.sql import Row
from pyspark.sql.window import Window

devMode=True # Set to False in production pipelines

# Let's initialize the Spark session
from pyspark.sql import SparkSession
spark = SparkSession.builder.getOrCreate()
# NOTE: There's no need to add this piece of code in a D4U listing notebook, the utilities called at the top of the standard template take care of it.

# COMMAND ----------

# MAGIC %md
# MAGIC ### 1. PySpark Dataframes

# COMMAND ----------

# MAGIC %md
# MAGIC ##### Creation from scratch

# COMMAND ----------

# Let's create a PySpark dataframe from scratch, one row at a time
df = spark.createDataFrame([
    Row(SUBJID='1', AGE=25, SEX='F',  HEIGHT=150, SCREENED=date(2024, 1, 15)),
    Row(SUBJID='2', AGE=56, SEX='M',  HEIGHT=168, SCREENED=date(2024, 2, 10)),
    Row(SUBJID='3', AGE=44, SEX=None, HEIGHT=170, SCREENED=date(2024, 1, 17)),
    Row(SUBJID='4', AGE=34, SEX='M',  HEIGHT=172, SCREENED=date(2024, 5, 12))
])

# See what's under the hood
print('Type:', type(df))

# By default PySpark infers the data schema by taking a sample from the data.

# If we try to display the PySpark df, we don't get the data content like we would with a Pandas df, rather the df metadata.
df

# COMMAND ----------

# MAGIC %md
# MAGIC ##### Using a Pandas dataframe as source

# COMMAND ----------

# Let's create a Pandas df from scratch
pandas_df = pd.DataFrame({
    'SUBJID'  : [1, 2, 3, 4],
    'AGE'     : [25, 56, 44, 34],
    'SEX'     : ['F', 'M', None, 'M'],
    'HEIGHT'  : [152, 168, 170, 172],
    'SCREENED': [date(2024, 1, 15), date(2024, 2, 10), date(2024, 1, 17), date(2024, 5, 12)],
})

# Convert it as a PySpark df
df = spark.createDataFrame(pandas_df)

# Same type under the hood
print('Type:', type(df))

# Same data schema btw...
df

# COMMAND ----------

# MAGIC %md
# MAGIC ##### Import study data in D4U

# COMMAND ----------

# MAGIC %md
# MAGIC Building a listing usually requires to import some source data. Fot that, you must use the D4U standard utilities (see the Standard Template) . For example, if you need to import DRM AE from the database, use the following:
# MAGIC
# MAGIC <code>drm_ae_df = fetchDomainTable('drm_ae', mandatory_columns, optional_columns)</code>
# MAGIC
# MAGIC **NOTES**: 
# MAGIC * drm_ae_df is a PySpark dataframe
# MAGIC * Absence of any of the mandatory columns will raise an error (i.e. crash)
# MAGIC * the data comes from the *silver layer* and is filtered to keep the active non-drop records, basically the same data as in the *gold layer*.

# COMMAND ----------

# MAGIC %md
# MAGIC ### 2. Display a PySpark dataframe

# COMMAND ----------

# Very basic: show()
df.show()

# COMMAND ----------

# Better display. You can also export the data using the table's UI
df.display() 

# COMMAND ----------

# List of columns:
df.columns

# COMMAND ----------

# Descriptive summary of the data:
df.describe().display()

# COMMAND ----------

# MAGIC %md
# MAGIC ### 3. Lazy vs Eager

# COMMAND ----------

# MAGIC %md
# MAGIC PySpark uses **lazy evaluation** for transformations and **eager evaluation** for actions. Lazy evaluation means that the execution of transformations is deferred until an action is called, it's only added to the dataframe execution plan.
# MAGIC
# MAGIC For example, <code>display()</code> is an eager operation: it triggers the execution of the entire DataFrame lineage and materializes the result by printing the output to the console. This action forces Spark to execute the preceding transformations and computations within the DataFrame's execution plan. Therefore <code>display()</code> can be resource-intensive, especially for large datasets. It may cause the driver to collect and display a significant amount of data, which could impact memory usage or even crash the application if the dataset is too large to fit in memory.
# MAGIC
# MAGIC It's important to use eager evaluations judiciously and be mindful of the size of the DataFrame and available system resources. If you're working with a large dataset, consider using operations like <code>head()</code> (bring 5 records only) or aggregations to limit the amount of data retrieved and displayed.
# MAGIC
# MAGIC In a Marvel notebook, you should always use <code>display()</code> under a <code>if devMode:</code> bloc, that way it's not executed in a production pipeline.

# COMMAND ----------

# Example of an execution plan

data1    = [("Kelly", 1), ("Bob", 2), ("Cathy", 3)]
data2    = [("Kelly", "Math"), ("Bob", "Science"), ("Cathy", "History")]
columns1 = ["Name", "ID"]
columns2 = ["Name", "Subject"]
df1 = spark.createDataFrame(data1, columns1)
df2 = spark.createDataFrame(data2, columns2)

# Lazy Transformations, not executed immediately, only added to the execution plan.
my_df = df1.join(df2, "Name")               # Join operation
my_df = my_df.filter(my_df.ID > 1)          # Filter operation
my_df = my_df.select("Name", "Subject")     # Select operation

# At this point, nothing has been really executed yet.

# Eager action, triggers the execution of the above transformations.
if devMode:
    my_df.display()

# COMMAND ----------

# MAGIC %md
# MAGIC ### 4. Select data in a PySpark dataframe

# COMMAND ----------

# Keep a selection of columns. Note that the outcome is not saved, just displayed in this notebook.
df.select('SUBJID', 'AGE').display()

# That way we save the selection:
df_select = df.select('SUBJID', 'AGE')

# COMMAND ----------

# Basic filter on rows. Also not in-place!
df.filter(
    (df.SEX == 'F') &
    (df.AGE <=40  )
).display()

# Enclose multiple criterias with ( ) and use :
    # | for OR
    # & for AND
    # ~ for NOT

# COMMAND ----------

# Alternatively, you could use an SQL expression to filter the dataframe. You can also use Regex expressions.
df.filter("SEX=='F' and AGE<=40").display()

# COMMAND ----------

# Filter records out with missing values:
df.filter(df.SEX.isNull()).display()

# COMMAND ----------

# Or the other way around: filter to keep only records without missing values
df.filter(df.SEX.isNotNull()).display()

# COMMAND ----------

# We can also drop any missing values, no matter in which columns. This method is also not in-place.
df.dropna().display()

# COMMAND ----------

# Alternatively, in that easy scenario, we could use a mapping dictionnary and a User Defined Function
from pyspark.sql.types import StringType

SEXL = {'F': 'Female', 'M': 'Male'}

SEXL_udf = F.udf(lambda x: SEXL.get(x), StringType())
df = df.withColumn('SEXL', SEXL_udf(F.col('SEX')))

df.display()

# COMMAND ----------

# We can also replace Null values with a string of our choice:
df = df.fillna('MISSING', subset=['SEX'])
df.display()

# COMMAND ----------

# MAGIC %md
# MAGIC ### 5) Windows functions
# MAGIC
# MAGIC Window functions allow to perform operations across groups of data. They are a nice way to aggregate data while keeping all the columns (e.g. the data provenance columns...)

# COMMAND ----------

# Define a window specification: we want a group-by SEX. 
windowSpec = Window.partitionBy("SEX")

# AGE average across the partition
df.withColumn("Avg_Age", F.avg("AGE").over(windowSpec)).display()

# COMMAND ----------

# Window is non-deterministic, it's highly recommend to sort the partition (see the Data Provenance notebook to understand why it's useful)
windowSpec = Window.partitionBy("SEX").orderBy('SUBJID')

# Create a rank column
df.withColumn("rank", F.rank().over(windowSpec)).display()

# COMMAND ----------

# MAGIC %md
# MAGIC ### 6) collect data
# MAGIC * <code>collect()</code>: retrieve all data (including duplicates) from a DataFrame to the driver node (bringing all the data locally).
# MAGIC * <code>collect_list()</code>: aggregate values within groups in the DataFrame.
# MAGIC * <code>collect_set()</code>: aggregate unique values within groups in the DataFrame.
# MAGIC
# MAGIC **Notes:**
# MAGIC * They are non-deterministic!
# MAGIC * They are eager actions and can require a lot of memory, so be careful. 

# COMMAND ----------

# Collect all the data into an iterable object:
df.collect()

# COMMAND ----------

# Load all non missing SEX values into a list. Less elegant than Pandas syntax...
df.agg(F.collect_list("SEX")).collect()[0][0]

# COMMAND ----------

# Same but deduping values:
df.agg(F.collect_set("SEX")).collect()[0][0]
