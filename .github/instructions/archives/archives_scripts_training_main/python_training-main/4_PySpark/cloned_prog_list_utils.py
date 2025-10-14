# Databricks notebook source
# DBTITLE 1,#Executes the lineage_utils file 
# MAGIC %run ./lineage_utils

# COMMAND ----------

spark.conf.set("spark.databricks.delta.schema.autoMerge.enabled","true")

# COMMAND ----------

#Importing required libraries/packages 
from pyspark.sql.functions import regexp_replace, md5, concat_ws, array, col, lit, struct, to_json, when, to_timestamp
from pyspark.sql.types import MapType, StringType, ArrayType, TimestampType
from delta.tables import *
import re
from re import  match , compile
import functools
import operator
from datetime import datetime as dt
import pyspark.sql.functions as F
import json
from pathlib import Path
import time
load_timestamp = dt.now().isoformat()
import boto3
import requests

awsSecretKeyName = 'DATABRICKS_ENV_CONFIG'
aws_access_key = dbutils.secrets.get(scope = 'marvel', key = 'marvel_landing_zone_access_key')
aws_secret_key = dbutils.secrets.get(scope = 'marvel', key = 'marvel_landing_zone_secret_key')
aws_region = dbutils.secrets.get(scope = 'marvel', key = 'aws_region')

session = boto3.session.Session() 
secretClient = session.client(service_name='secretsmanager',aws_access_key_id=aws_access_key,
         aws_secret_access_key= aws_secret_key,region_name=aws_region)
databricks_api_token = dbutils.secrets.get(scope = 'marvel', key = 'marvel_databricks_api_token')

databricks_job_url = json.loads(secretClient.get_secret_value(SecretId=awsSecretKeyName)['SecretString'])['databricks_job_url']
databricks_instance= databricks_job_url.split("/")
databricks_instance="https://"+databricks_instance[0]

# COMMAND ----------

# Displays the input parameters widgets on the top of the notebook to get the inputs for studyId, dataEnv, lifecycle, listingName, listingType and listingTitle 

#Input parameter – dbutils.notebook (The dbutils.notebook API is a complement to %run because it lets you pass parameters to and return values from a notebook.) 

def init_prog(notebook):
    global studyId
    global dataEnv
    global lifecycle
    global listingName
    global listingType
    global listingTitle
    global devMode
    global notebookPath
    global notebookFolder
    global labelFilePath
    global cacheGoldTable

    global LISTING_TYPES
    LISTING_TYPES = ['core', 'basic', 'filtered', 'complex', 'edit check']

    print('Parsing notebook parameters')
    print()

    errors = []

    dbutils.widgets.text("studyId",'')
    studyId = dbutils.widgets.get("studyId")
    print(f'studyId = {studyId}')
    if len(studyId) == 0:
      errors.append('Parameter studyId not specified')

    dbutils.widgets.combobox('dataEnv','', ['dev', 'uat', 'prod'])
    dataEnv = dbutils.widgets.get('dataEnv')
    print(f'dataEnv = {dataEnv}')
    if len(dataEnv) == 0:
      errors.append('Parameter [dataEnv] not specified')

    dbutils.widgets.combobox('lifecycle','', ['dev', 'uat', 'prod'])
    lifecycle = dbutils.widgets.get("lifecycle")
    print(f'lifecycle = {lifecycle}')
    if len(lifecycle) == 0:
      errors.append('Parameter lifecycle not specified')

    dbutils.widgets.combobox("listingType", '', LISTING_TYPES)
    listingType = dbutils.widgets.get("listingType")
    print(f'listingType = {listingType}')
    if listingType not in LISTING_TYPES:
        errors.append(f'Invalid listing type {listingType}. Expected one of {",".join(LISTING_TYPES)}')

    dbutils.widgets.text("listingName",'')
    listingName = dbutils.widgets.get("listingName")
    print(f'listingName = {listingName}')
    if len(listingName) == 0:
      errors.append('Parameter listingName not specified')

    dbutils.widgets.text("listingTitle",'')
    listingTitle = dbutils.widgets.get("listingTitle")
    print(f'listingTitle = {listingTitle}')
    if len(listingTitle) == 0:
      errors.append('Parameter listingTitle not specified')

    dbutils.widgets.combobox("devMode",'False',['True', 'False'], 'Development Mode')
    devMode = bool(dbutils.widgets.get("devMode") == 'True')
    print(f'devMode = {devMode}')

    dbutils.widgets.text("labelFilePath",'')
    labelFilePath = dbutils.widgets.get("labelFilePath")
    print(f'labelFilePath = {labelFilePath}')
    if len(labelFilePath) == 0:
      errors.append('Parameter labelFilePath not specified, "NA" could be used when label assignment is not required')

    # Optional parameter. If not found default to true for prod lifecycle otherwise false. Can be overriden as job parameter
    try:
        cacheGoldTable = dbutils.widgets.get("cacheGoldTable")
    except:
        cacheGoldTable = (dataEnv == 'prod')
    print(f'cacheGoldTable = {cacheGoldTable}')

    notebookPath = Path(notebook.entry_point.getDbutils().notebook().getContext().notebookPath().get())
    notebookFolder = notebookPath.parent.absolute()
    print(f'Notebook Folder: {notebookFolder.absolute()}')

    if len(errors) > 0:
      print()
      errors = '\n'.join(['!!! There are missing parameters in your notebook !!!'] + errors)
      print(errors)
      raise Exception(errors)


# COMMAND ----------

# DBTITLE 1,Fetch Last Load Date of Raw Data 
last_load_date = None
def fetchLastLoadDate():
    try: 
        global last_load_date
        if last_load_date is None: 
            raise
    except:
        try:
            if studyId is None:
                raise()
        except:
                raise Exception('Variable {studyId} is required but either null or not defined')
        try:
            if dataEnv is None:
                    raise()
        except:
                raise Exception('Variable {dataEnv} is required but either null or not defined')

        load_date_df = spark.sql(f'select job_start_datetime from `marvel`.`default`.audit_log where study_id = "{studyId}"  and environment = "{dataEnv}"')
        last_load_date = load_date_df.collect()[0][0]
        print(f'Last Load Date fetched: {last_load_date}')

    return last_load_date

# COMMAND ----------

system_cols=["D4U_RECVERDATE", "D4U_ISACTIVE", "D4U_ISDROP", "D4U_RECID", "D4U_RECVER", "D4U_DATAPROV", "RRID", "RDATASET"]
def fetchDomainTable(table : str, mandatory_columns : Optional[list] = None , optional_columns: Optional[list] = None ) : 
    '''Fetch data from the "`marvel-{dataEnv}-silver`.{studyId}.{table}" table based on the mandatory_columns & optional_columns
    Details : 
    ---------
    Returns a spark dataframe, 
    if the mandatory_columns and optional_columns are not specifed or set to None then all the columns of the table are fetched.
    if the  optional_columns is not specifed or set to None then all the mandatory_columns are fetched. 
    Parameters:
    ---------
        table (str):Name of the table to be fetched
        mandatory_columns (list): Optional = None : List of mandatory column name to be fetched  
        optional_columns (list): Optional = None : List of optional column name to be fetched
    raises: 
    ---------
        Exception: if the table doesn't exist in the Schema {studyId} of the catalog ("marvel-{dataEnv}-silver")
        Exception: if the schema {studyId} dosen't exist in the catalog("marvel-{dataEnv}-silver")
        Exception: if one of the column in the mandatory_columns parameter is not part of the table("`marvel-{dataEnv}-silver`.{studyId}.{table}")
    Returns:
    ---------
        df:pyspark.sql.DataFrame
    '''
    listing = D4UListing(table, 'silver')
    
    if listing.table.studySchemaExists() : 
        if listing.table.tableExists() : 
            latestVersion = getDeltaVersion(listing.table.fullName)
            print(f'Fetching data from {listing.table.fullName} at version {latestVersion}')
            df = spark.table(f'{listing.table.fullName}@v{latestVersion}').alias(table) #" where LOAD_DATE = '{fetchLastLoadDate()}'")
            df = df.where((col('D4U_ISACTIVE') == True) & (col('D4U_ISDROP') == False))
        else :
            raise Exception(f"Warning: Table ({listing.table.name}) is missing in  study {listing.table.studyId} in silver layer")  
    else :
        raise Exception(f"Warning: Study ({listing.table.studyId}) is missing in silver layer")  
    if mandatory_columns == None : 
        columns = [ col_ for col_ in df.columns if col_ not in system_cols]
    else : 
        missing_required_cols = [col_ for col_ in mandatory_columns if  col_ not in df.columns]
        if len(missing_required_cols) == 0  : 
            if optional_columns is None : 
                columns = mandatory_columns 
            else : 
                opt_columns = [col_ for col_ in df.columns  for regex_pattern in optional_columns if re.match(re.compile(fr"{regex_pattern}"), col_) ]
                columns = mandatory_columns + opt_columns
                #print(opt_columns)
        else :
            missing_ = '\n'.join(missing_required_cols)
            raise Exception(f"Warning: the following mondatory columns are missing in :  {listing.table}:\n {missing_}")
        
    #Appends system columns with the input columns
    df_system_cols = [x for x in system_cols if (x in df.columns and x not in columns)]
    required_cols = [col(c) for c in columns] + [col(c) for c in df_system_cols]
    df = df.select(required_cols)

    for field in df.schema.fields:
        listing.addColumn(field)

    #Updates double underscores to the system columns 
    required_cols = [col(c) for c in columns] + [col(c).alias(table + '__' + c) for c in df_system_cols]
    df = df.select(required_cols)
    sourceListings.append(listing)

    df.createOrReplaceTempView(table)

    return df

# COMMAND ----------

#Calculates and adds the general system columns based on the list of input columns 
#Input parameters - final dataframe 

def addDataProvenance(df, config = {}):
    df=df.drop("D4U_RECVERDATE", "D4U_ISACTIVE", "D4U_ISDROP", "D4U_RECID", "D4U_RECVER", "D4U_DATAPROV")
    ver_columns = []
    # Need to check Listing config for list of columns to include in RECID and RECVER
    if config.get('verKeys'):
      ver_columns = ["|"] + [column for column in config['verKeys']]
    else:
      ver_columns = ["|"] + [column for column in df.columns if '__' not in column]
    
    print('Version Columns:' + str(ver_columns))

    if  "D4U_DATAPROV" not in df.columns:
      df = df.withColumn(
          "D4U_DATAPROV",
          array(
              *[
                  struct(
                      lit(listing.table.name).alias("table"),
                      col(listing.table.name + "__D4U_RECID").alias("D4U_RECID"),
                      col(listing.table.name + "__D4U_RECVER").alias("D4U_RECVER")
                  )
                  for listing in sourceListings
              ]
          ),
      )
    df = df.withMetadata('D4U_DATAPROV', {'comment' : 'DATA4YOU Data Provenance object'})

    if config.get('recKeys'):
      df = df.withColumn(
          "D4U_RECID",
          md5(
              to_json(
                  array(*[col(recKey).cast('string')  for recKey in config['recKeys']])
              )
          )
      )
    else:
      df = df.withColumn(
          "D4U_RECID",
          md5(
              to_json(
                  array(
                      *[
                          struct(
                              lit(listing.table.name).alias("table"),
                              col(listing.table.name + "__D4U_RECID").alias("D4U_RECID"),
                          )
                          for listing in sourceListings
                      ]
                  )
              )
          )
      )
    df = df.withMetadata('D4U_RECID', {'comment' : 'DATA4YOU Unique Record Identifier'})

    df = df.withColumn("D4U_RECVER", md5(concat_ws(*ver_columns)))
    df = df.withMetadata('D4U_RECVER', {'comment' : 'DATA4YOU Record Version Identifier'})

    df = df.withColumn("D4U_RECVERDATE",to_timestamp(lit(load_timestamp)))
    df = df.withMetadata('D4U_RECVERDATE', {'comment' : 'DATA4YOU Record Version Date'})

    
    df = df.withColumn('D4U_ISDROP', functools.reduce(operator.or_, [col(listing.table.name + "__D4U_ISDROP") for listing in sourceListings]))
    df = df.withColumn('D4U_ISDROP',F.when(F.col('D4U_ISDROP').isNull(),False).otherwise(F.col('D4U_ISDROP')))
    df = df.withMetadata('D4U_ISDROP', {'comment' : 'DATA4YOU Soft Delete Flag'})

    df = df.withColumn('D4U_ISACTIVE', functools.reduce(operator.or_, [col(listing.table.name + "__D4U_ISACTIVE") for listing in sourceListings]))
    df = df.withColumn('D4U_ISACTIVE',F.when(F.col('D4U_ISACTIVE').isNull(),False).otherwise(F.col('D4U_ISACTIVE')))
    df = df.withMetadata('D4U_ISACTIVE', {'comment' : 'DATA4YOU Latest Record Version Flag'})

    #Need to add D4U_START_STUDY_DAY and D4_END_STUDY_DAY

    if "RRID" in df.columns:
        # RRID already included in DF by programmer nothing to do
        pass
    else:
        # Pick the first (ie "primary") <table>__RRID column available
        for x in [x for x in df.columns if x.endswith('__RRID')]:
            print(f'Using column [{x}] as primary RRID column')
            df = df.withColumnRenamed(x,'RRID')
            break

    if "RDATASET" in df.columns:
        # RDATASET already included in DF by programmer nothing to do
        pass
    else:
        # Pick the first (ie "primary") <table>__RDATASET column available
        for x in [x for x in df.columns if x.endswith('__RDATASET')]:
            print(f'Using column [{x}] as primary RDATASET column')
            df = df.withColumnRenamed(x,'RDATASET')
            break
    
    return df

# COMMAND ----------

#Creates the table if it doesn’t exist already, if present - displays "Table already exist" 
#Input parameter – listing and schema (schema is obtained using the command df.schema and passed to the createTableIfNotExist function) 

def createTableIfNotExist(listing, schema):

    d4uTable = listing.table
    
    if d4uTable.tableExists():
        print(f'Table {d4uTable} already exist.')
    else:
        emptyDF = spark.createDataFrame([], schema)
        emptyDF \
            .write \
            .mode("overwrite") \
            .format("delta") \
            .saveAsTable(str(d4uTable))

        spark.sql(f"""COMMENT ON TABLE {str(d4uTable)} IS '{listingTitle}'""")
        
        print(f'Created new table {d4uTable}')

    return d4uTable

# COMMAND ----------

class DuplicateRecordVersions(Exception):
    pass

class DuplicateActiveRecords(Exception):
    pass



def checkForDuplicates(df):
    print('Checking df for duplicates')
    
    # Check for duplicates
    df_duplicates = df.groupBy(['D4U_RECID', 'D4U_RECVER']).count().where('count > 1')
    duplicate_count = df_duplicates.count()
    if duplicate_count > 0:
        print(f'!! Found {duplicate_count} duplicate record versions in data !!')
        display(df_duplicates)
        raise DuplicateRecordVersions("""
        Duplicate record version found. 
        Make sure no 2 records have the same values of columns [D4U_RECID, D4U_RECVER].
        """)

    df_duplicates = df.where(col('D4U_ISACTIVE') == True).groupBy(['D4U_RECID']).count().where('count > 1')
    duplicate_count = df_duplicates.count()
    if duplicate_count > 0:
        print(f'!! Found {duplicate_count} duplicate active record IDs in data !!')
        display(df_duplicates)
        raise DuplicateActiveRecords("""
        Duplicate active record ids found.
        Make sure no 2 records have the same values of columns [D4U_RECID, D4U_ISACTIVE]. 
        If receiving multiple versions of the same record ensure only the latest version is marked active.
        """)

    print('No duplicates found')

# COMMAND ----------

# Creates the table in silver layer if it doesn’t already exist or if it is already present, incremental load of data is done 
#Input parameters – (final df, listingName, listingType, listingTitle) 

def saveToSilver(df, listingName, listingType, listingTitle):

    silverListing = D4UListing(listingName, 'silver', listingType = listingType, listingTitle  = listingTitle)

    try:       
  
        silverTable = createTableIfNotExist(
            listing = silverListing,
            schema = df.schema)

        silverListing.inferColumnsFromSchema()
        silverListing.table.getLatestDeltaVersion()

        print(f'Current silver table on version {silverListing.table.deltaVersion}')

        load_timestamp = dt.now().isoformat()
  
        spark.sql("SET spark.sql.legacy.timeParserPolicy = LEGACY")
        spark.conf.set("spark.sql.parquet.enableVectorizedReader",False)

        print(f'Received {df.count():,} records to process')

        print('Checking incoming DF for duplicates')
        checkForDuplicates(df)

        print('Computing incremental load')

        column_list = df.columns
        
        silverTable = DeltaTable \
            .forName(spark, str(silverTable)) \
            .alias('silver')
        
        silver_records = spark.table(f'{silverListing.table.fullName}@v{silverListing.table.deltaVersion}')\
            .where((col('D4U_ISACTIVE') == True) & (col('D4U_ISDROP') == False))\
            .alias('silver')

        print('Checking silver for duplicates')
        checkForDuplicates(silver_records)

        df_insert = df.alias("df").join(silver_records,on = 'D4U_RECID',how = 'leftanti').select(['df.*'])
        df_insert = df_insert.select(column_list)
        df_insert_count = df_insert.count()

        print(f'{df_insert_count:,} records to insert')
        
        df_update = silver_records.join(df.alias("df"),F.expr(f"df.D4U_RECID = silver.D4U_RECID and df.D4U_RECVER != silver.D4U_RECVER"),how = 'inner').select(['df.*'])
        df_update = df_update.select(column_list)
        df_update_count = df_update.count()
        
        print(f'{df_update_count:,} records to update')

        df_drop = silver_records.join(df.alias("df"), on = 'D4U_RECID', how = 'leftanti').select(['silver.*'])
        df_drop = df_drop\
            .withColumn("D4U_RECVERDATE", lit(load_timestamp).cast('timestamp'))\
            .withColumn("D4U_ISACTIVE", lit(True))\
            .withColumn("D4U_ISDROP", lit(True))
        df_drop_count = df_drop.count()

        print(f'{df_drop_count:,} records to drop')

        df_insert_update_drop = df_insert.union(df_update).unionByName(df_drop, allowMissingColumns=True)
        
        df_union_count_start = df_insert_update_drop.count()

        if df_union_count_start == 0:
            print('No records found to append to silver.')
            return silverListing
        
        print(f'{silver_records.count():,} records in silver before merge (active and not dropped)')
        print(f'Merging {df_union_count_start:,} records into silver')

        if df_union_count_start != (df_insert_count + df_update_count + df_drop_count):
            raise Exception("""The number of insert/drop/update records doesn't match.
                            insert.count() + update.count() + drop.count() != union(insert, update, drop).count()
                            """)

        print('Checking df_insert_update_drop for duplicates')
        checkForDuplicates(df_insert_update_drop)
        
        tic = time.perf_counter()

        print('Setting all silver records as inactive')
        #set previous records as false for updated records
        silverTable\
            .alias("silver")\
            .merge(source = df_insert_update_drop.alias("df"), condition = (col('df.D4U_RECID') == col('silver.D4U_RECID')) & (col('silver.D4U_ISACTIVE') == True))\
            .whenMatchedUpdate(set = {"silver.D4U_ISACTIVE": lit(False)})\
            .execute()
        
        active_dup_records = spark.table(f'{silverListing.table.fullName}@v{silverListing.table.deltaVersion + 1}')\
            .where(col('D4U_ISACTIVE') == True)\
            .alias("silver")\
            .join(df_insert_update_drop.alias("df"), on = 'D4U_RECID', how = 'left')\
            .where(col('df.D4U_RECID').isNotNull())\
            .select(['silver.*'])

        if active_dup_records.count() > 1:
            print(f'Found {active_dup_records.count()} active records (D4U_RECID) in silver about to be appened.')
            display(active_dup_records)
            raise Exception("""Found remaining active records in silver that about to be appened. This will cause duplicates.""")

        print(f'{silver_records.count():,} records in silver before merge (active and not dropped)')

        df_union_count_end = df_insert_update_drop.count()
        print(f'Merging {df_union_count_end:,} records into silver')

        if df_union_count_start != df_union_count_end:
            raise Exception("""The number of records for the temp table doesn't match.
                            df_union_count_start != df_union_count_end
                            """)
        
        df_insert_update_drop.write\
            .format("delta")\
            .mode("append")\
            .saveAsTable(f'{silverListing.table.fullName}')

        toc = time.perf_counter()

        final_silver_records = spark.table(f'{silverListing.table.fullName}')\
            .where((col('D4U_ISACTIVE') == True) & (col('D4U_ISDROP') == False))\
            .alias('silver')

        final_silver_records_count = final_silver_records.count()
        
        if final_silver_records_count != df.count():
            raise Exception("""The number of active non-dropped records in silver doesn't match the source dataframe.
                            final_silver_records_count != df.count()
                            """)
        
        print(f'{final_silver_records_count:,} records in silver after merge')
        print(f'Merge completed {toc - tic:0.4f} seconds')

        print(f'Silver table after merge is on version {getDeltaVersion(silverListing.table.fullName)}')

        checkForDuplicates(final_silver_records)

        print('Optimizing Table')
        spark.sql(f'OPTIMIZE {silverListing.table.fullName}')
        print('Optimization complete')

    except Exception as p:
        import traceback
        print(f'Error while merging silver records')
        print("".join(traceback.format_exception(p)))

        silverListing.rollback()

        raise p
        
    return silverListing


# COMMAND ----------

#Checks for the active silver table where IS_ACTIVE is True and merges the records to gold layer 

def saveToGold(silverListing, listingName, listingType, listingTitle):

    goldListing = D4UListing(listingName, 'gold', listingType = listingType, listingTitle = listingTitle)

    try:
        
        silverInitialVersion = silverListing.table.deltaVersion
        silverCurrentVersion = getDeltaVersion(silverListing.table.fullName)

        #Fetches only the active records and the ones which are not dropped from the silver table and creates the gold table 
        silverTable = spark.table(str(silverListing.table)).where((col('D4U_ISACTIVE') == True) & (col('D4U_ISDROP') == False)).alias('silver')
        
        goldColumns = list(filter(lambda x : x.name not in ["D4U_ISACTIVE","D4U_ISDROP"], silverTable.schema.fields))
        #Creates the gold table if it doesn’t already exist 
        createTableIfNotExist(
            goldListing,
            schema = StructType(goldColumns))
        
        if silverCurrentVersion == silverInitialVersion:
            print('No records found to append to gold.')
            return
        
        silver_record_count = silverTable.count()

        goldListing.table.getLatestDeltaVersion()
        print(f'Current gold table on version {goldListing.table.deltaVersion}')
        
        goldTable = DeltaTable.forName(spark, goldListing.table.fullName).alias('gold')

        print(f'{goldTable.toDF().count():,} records in gold before merge')

        checkForDuplicates(silverTable)

        tic = time.perf_counter()

        silverTable.write\
            .mode("overwrite")\
            .format("delta")\
            .option("overwriteSchema", "true")\
            .saveAsTable(goldListing.table.fullName)

        toc = time.perf_counter()

        # Refetching Delta Table object in case of schema changes
        goldTable = DeltaTable.forName(spark, goldListing.table.fullName).alias('gold')
        gold_record_count = goldTable.toDF().count()

        print(f'{gold_record_count:,} records in gold after merge')

        if silver_record_count != gold_record_count:
            raise Exception("""The number of records in silver and gold doesn't match.
                            silver_record_count != gold_record_count
                            """)

        print(f'Merge completed {toc - tic:0.4f} seconds')

        print('Optimizing Table')
        spark.sql(f'OPTIMIZE {goldListing.table.fullName}')
        print('Optimization complete')

        if cacheGoldTable == True:
            loadTableinSQLWarehouse(goldListing)
        
    except Exception as p:
        import traceback
        print(f'Error while merging silver records')
        print("".join(traceback.format_exception(p)))
        
        silverListing.rollback()
        goldListing.rollback()

        raise p

# COMMAND ----------

def loadTableinSQLWarehouse(listing):
    
    warehouse_id = getSQLWarehouse()

    if warehouse_id is not None:
        print(f'Loading table {listing.table.fullName} into SQL Warehouse cache')
        runSelectQuery(warehouse_id, listing)

def runSelectQuery(warehouse_id, listing):

    api_url = f'{databricks_instance}/api/2.0/sql/statements'
    
    auth_header = f"Bearer {databricks_api_token}"
    headers = {
        'Authorization': auth_header,
        'Content-Type': 'application/json'
    }

    request_body = {
        'warehouse_id': warehouse_id,
        'statement': f'SELECT * FROM {listing.table.fullName}',
        'row_limit': 10,
        'wait_timeout': '50s'
    }

    response = requests.post(api_url, headers=headers, json=request_body)
    response_json = response.json()
    print(f"API Response: {json.dumps(response_json, indent=2)}") 

    
def getSQLWarehouse(name = 'Data Query Warehouse'):

    api_url = f'{databricks_instance}/api/2.0/sql/warehouses'
    
    auth_header = f"Bearer {databricks_api_token}"
    headers = {
        'Authorization': auth_header,
        'Content-Type': 'application/json'
    }
    
    request_body = {}

    response = requests.get(api_url, headers=headers, json=request_body)
    response_json = response.json()
    print(f"API Response: {json.dumps(response_json, indent=2)}") 
    
    if response.status_code == 200:

        warehouse = next(iter([w for w in response_json['warehouses'] if w['name'] == name]))
        if warehouse is not None:
            print(f"Found SQL Warehouse ID: {warehouse}")
            return warehouse['id']
    
    raise Exception(f"Cannot find SQL Warehouse [{name}]")

# COMMAND ----------

# Get catalog name
def get_marvel_catalog_name(dataEnv, layer):
    return f'`marvel-{dataEnv.lower()}-{layer.lower()}`'

# COMMAND ----------

# Get Table name
def get_study_table_name(catalog, studyId, tableName):
    return f"{catalog}.`{studyId.lower()}`.`{tableName.lower()}`"

# COMMAND ----------

def setOrder(df,col_list):
  col_seq = [x for x in col_list if x in df.columns] + [x for x in df.columns if 'D4U_' in x.upper()]
  df = df.select(col_seq)
  return df
