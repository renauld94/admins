# Databricks notebook source
#Defining the source listing function to save the source json file in the desired location 

sourceListings = []

def saveSourceListingsDefinition():
  sourceListingsFile = Path(notebookFolder, 'sourceListings.json')

  print(f'Writing source listings lineage json to /Workspace{sourceListingsFile.absolute()}')
  with open('/Workspace' + str(sourceListingsFile.absolute()), 'w+') as outfile:
    json.dump([listing.json() for listing in sourceListings], outfile, indent=2)


# COMMAND ----------

#Defining the target listing function to save the target json file in the desired location 

targetListing = {}

def saveTargetListingDefinition(listing):
  targetListingFile = Path(notebookFolder, 'targetListing.json')
  targetListing = listing.json()
  print(f'Writing target listing lineage json to /Workspace{targetListingFile.absolute()}')
  with open('/Workspace' + str(targetListingFile.absolute()), 'w+') as outfile:
    json.dump(targetListing, outfile, indent=2)
  return targetListing
  

# COMMAND ----------

#Dropping the source system columns which has (__)  

def dropSourceSystemColumns(df):
    columns = df.columns

    columnsToDrop = []
    for listing in sourceListings:
        for column in system_cols:
            columnsToDrop.append(listing.table.name + '__' + column)
    
    print(f'Dropping system columns: {columnsToDrop}')

    return df.drop(*columnsToDrop)

# COMMAND ----------

#Check if the system columns are available or else display "The system columns are missing in dataframe" 

def checkSystemColumns(df):

    expected_sys_cols=["D4U_RECID", "D4U_RECVER", "D4U_RECVERDATE", "D4U_DATAPROV","D4U_ISACTIVE","D4U_ISDROP"]
    columns = df.schema.fields

    for column in columns:
        if column.name in expected_sys_cols:
            expected_sys_cols.remove(column.name)

    if len(expected_sys_cols) == 0:
        # all system columns were found
        return
    else:
        raise Exception(f'The system columns [{",".join(expected_sys_cols)}] are missing in the dataframe')

# COMMAND ----------

# def addSourceDependencies(d4uTable, schema):

#   global generateLineage

#   listing = D4UListing(table, title, listingType)

#   for field in schema:
#     d4uCol = D4UColumn.fromSchema(table, field)
#     inputDependencyTree.append(d4uCol)

# COMMAND ----------

#Initializing the table name and checking if the table already exist or not 

class D4UTable:

    def __init__(self, dataEnv, dataLayer, studyId, table):
        if dataLayer not in ['silver', 'gold']:
            raise Exception(f'Data Layer value [{dataLayer}] invalid. Expected ["silver", "gold"]')
        if dataEnv not in ['dev', 'uat', 'prod']:
            raise Exception(f'Data environment value [{dataEnv}] invalid. Expected ["dev", uat", "prod"]')

        self.layer = dataLayer
        self.catalog = f'`marvel-{dataEnv}-{dataLayer}`'
        self.studyId = f'{studyId}'
        self.name = f'{table.lower()}'
        self.fullName = f'{self.catalog}.`{self.studyId}`.`{self.name}`'
        self.deltaVersion = None

    def studySchemaExists(self):
        return spark.sql(f'show schemas in {self.catalog}').selectExpr(f"any(upper(databaseName) == upper('{self.studyId}'))").collect()[0][0]
        

    def tableExists(self):
        return spark.sql(f'show tables in {self.catalog}.`{self.studyId}`').selectExpr(f"any(upper(tableName) == upper('{self.name}'))").collect()[0][0]
    
    def getLatestDeltaVersion(self):
        self.deltaVersion = getDeltaVersion(self.fullName)

    def rollback(self):
        if self.deltaVersion is not None:
            version = self.deltaVersion
            print(f'Rolling back {self.layer} table to version {self.deltaVersion}')
            restore_query = f'RESTORE TABLE {self.fullName} TO VERSION AS OF {self.deltaVersion}'
            print(f'Executing restore query: {restore_query}')
            spark.sql(restore_query)
            print(f'Restore of {self.layer} completed')
        else: 
            print(f'No {self.layer} listing or version to perform rollback with')

    def __str__(self):
        return self.fullName

# COMMAND ----------

def fetchListingConfig(table):
  pass

# COMMAND ----------

#Defining the format to create json file 

class D4UListing:
    def __init__(self, listingName, dataLayer, listingType=None,  listingTitle=None):

        if listingType is not None:
          table = f'd4u_{listingType}_{listingName}'
        else:
          table = listingName

        self.table = D4UTable(dataEnv, dataLayer, studyId, table)
        self.name = str(table)

        self.title = listingTitle
        self.listingType = listingType

        self.lineage = {}
        self.columns = []
        self.dreConfig = {}

    def json(self):
        return {
            "name": self.name,
            "title": self.title,
            "type": self.listingType,
            "lineage": self.lineage,
            "columns": list(map(lambda x: x.json(), self.columns)),
        }

    def inferColumnsFromSchema(self, schema = None):
      if schema is None:
        schema = spark.table(str(self.table)).schema

      for field in schema:
          d4uCol = D4UColumn.fromSchema(self.table, field)
          self.columns.append(d4uCol)

    def rollback(self):
        self.table.rollback()

    def __str__(self):
        return json.dumps(self.json(), indent=2)

    def addColumn(self, field):
        if devMode:
          self.columns.append(D4UColumn.fromSchema(self.table, field))

# COMMAND ----------

def getDeltaVersion(table):    
    try: 
        history_df = spark.sql(f'DESCRIBE HISTORY {table}').limit(1)
        #display(history_df)
        return  history_df.collect()[0][0]
    except Exception as p:
        print(f'Could not fetch delta version for {table}')
        print(p)
        pass

# COMMAND ----------

    
#Inserting the column information inside the json file 

class D4UColumn:

    def __init__(self):
        self.table = ''
        self.name = ''
        self.alias = ''
        self.label = ''
        self.dataType = 'string'
        self.showByDefault = True
        self.isRecIdKey = False
        self.isRecVersionKey = False
        self.isCalculated = False
        self.isCritical = False
        self.defaultWidth = 0

    @classmethod
    def fromSchema(self, table, structField):
        column = D4UColumn()
        column.table = table.name
        column.name = structField.name
        column.label = structField.metadata.get('comment')
        column.dataType = str(structField.dataType.simpleString())
        return column

    def json(self):
        return {
            'table': self.table,
            'name': self.name,
            'label': self.label,
            'dataType': self.dataType,
            'showByDefault': self.showByDefault,
            'isRecIdKey': self.isRecIdKey,
            'isRecVersionKey': self.isRecVersionKey,
            'isCalculated': self.isCalculated,
            'isCritical': self.isCritical,
            'defaultWidth': self.defaultWidth
        }

    def __str__(self):
        return json.dumps(self.json(), indent=2)
    

# COMMAND ----------

# df = spark.table('`marvel-uat-gold`.68284528mmy5207.d4u_basic_viz20021')
# listing = D4UListing()
# listing.name = 'VIZ20021'
# listing2 = D4UListing()
# listing2.name = 'VIZ200XXX'
# print(listing.json())

# COMMAND ----------

# print(D4UColumn.fromSchema('d4u_basic_viz20021', df.schema.fields[0]))
