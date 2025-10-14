# Databricks notebook source
# MAGIC %md
# MAGIC # PySpark introduction

# COMMAND ----------

# MAGIC %md
# MAGIC ### What's Apache Spark?
# MAGIC [Apache Spark](https://spark.apache.org/) is an open-source analytics engine, developed in [Scala](https://en.wikipedia.org/wiki/Scala_(programming_language), used for large-scale data processing. Spark can run on single-node or multi-node machines, enabling parallel processing. It is also a multi-language engine, that provides APIs and libraries for several programming languages like Java, Scala, Python and R, allowing developers to work with Spark using the language they are most comfortable with.
# MAGIC
# MAGIC ### Why use PySpark?
# MAGIC While Pandas is the most popular framework for data science, data analysis and machine learning in the Python world, it only runs on a single machine and is single-threaded. Pandas is therefore less performant than Spark for large data (up to 100x times). See this [article](https://www.databricks.com/blog/2021/10/04/pandas-api-on-upcoming-apache-spark-3-2.html) about performance on Databricks.
# MAGIC
# MAGIC PySpark is a library allowing programmers to use the Apache Spark capabilities in Python. It's designed to be easy to use, with a syntax fairly close (but not identical) to Pandas. It is available in Databricks/Data4U. Although it is interesting to understand the Spark architecture, PySpark provides an easy abstraction layer for it. We'll discover this syntax in the SQL/DataFrame notebook.
# MAGIC
# MAGIC See this [article](https://sparkbyexamples.com/pyspark/pandas-vs-pyspark-dataframe-with-examples/) highlighting the differences between Pandas and PySpark.
# MAGIC
# MAGIC ### And what's PySpark Pandas API?
# MAGIC If you're already familiar with Pandas and/or have a lot of code using this library, migrating to PySpark might take time and effort. This is what the [PySpark Pandas API](https://spark.apache.org/docs/latest/api/python/reference/pyspark.pandas/index.html) tries to solve, by allowing to run your good old Pandas code on top of Spark with barely any modification. With this approach, you can work with Spark right away without any learning curve. You can have a single codebase for everything: small data and big data. A single machine and distributed machines. And you can run your Pandas code faster.
# MAGIC
# MAGIC ### Eager vs Lazy
# MAGIC In PySpark, **lazy evaluation** is an optimization technique where **transformations** on a DataFrame are not immediately executed. Instead, the operations are merely recorded in the dataframe's execution plan. The transformations are only triggered when an **action** operation, such as <code>show()</code> or <code>count()</code>, is called, resulting in a materialized computation of the transformations. **Eager evaluation** therefore refers to immediate execution of computations when an action on a dataframe is called.
# MAGIC
# MAGIC It's important to understand these 2 types of operations: transformation (> lazy and postponed) and action (> eager and immediate). Lazy evaluation offers performance benefits by avoiding unnecessary computations until required. It enables PySpark to optimize and schedule transformations efficiently. 
# MAGIC
# MAGIC ### OK, and now?
# MAGIC What about taking a look at the other notebooks in this folder? 
# MAGIC
# MAGIC ### Useful links
# MAGIC
# MAGIC - [User guide](https://spark.apache.org/docs/latest/)
# MAGIC - [Spark by examples](https://sparkbyexamples.com/)
# MAGIC - [Nice blog](https://www.cojolt.io/blog/apache-spark-sql)
