import dash
from dash import dcc, html, Output, Input, State
import dash_mantine_components as dmc
import plotly.express as px
from datetime import datetime
import pandas as pd

#-----------------------------------------------------------------------------------------------
# Instantiate the Dash object
#-----------------------------------------------------------------------------------------------
app = dash.Dash(__name__)
app.title = "My Dashboard"

#-----------------------------------------------------------------------------------------------
# Dummy data
#-----------------------------------------------------------------------------------------------
iris = px.data.iris()
print(iris)

#-----------------------------------------------------------------------------------------------
# Create the Dash layout
#-----------------------------------------------------------------------------------------------
app.layout = html.Div([

    dmc.Text('Iris Dashboard', size='xl'),
    html.Hr(), 
    html.Br(), 

    dcc.Store(                 # Great way to store data in the app and exchange data between callbacks of the same webapp instance
        id   = 'iris_store',
        data = iris.to_dict()  # Accepts many python data structure (e.g lists, dicts, strings etc), as long as they can be serialized as JSON. Pandas dataframes need to be converted.
    ),

    dmc.Select (
        id          = 'iris_species_dropdown',
        label       = 'Iris species',
        placeholder = 'Select a value...',
        data        = iris.species.sort_values().unique() # Thank you Pandas!
    ),

    dcc.Graph(              # Plotly graphs and Dash are made by the same company, they interact nicely
        id = 'iris_plot'
    ), 
    
    html.Div(
        children = [
            dmc.Badge('Timestamp'),
            dmc.Text(id='plot_timestamp')
        ],
        id = 'hidden_div',
        style = {'display': 'none'}
    )

])

#-----------------------------------------------------------------------------------------------
# Define the Dash callbacks. 
#   They are triggered by a change in a property of a given object
#   They run a function, which received that changed property
#   They modify a property of a given object (possibly the same object that triggered the callback)
#-----------------------------------------------------------------------------------------------

# Callback triggered by app user
#--------------------------------------------------------------------------------
@app.callback(
    Output ('iris_plot',             'figure'), # Callback consequence
    Input  ('iris_species_dropdown', 'value' ), # That triggers the callback!
    State  ('iris_store',            'data'  ), # things we also need 
    prevent_initial_call = True
    )
def update_figure(
    picked_iris_species, # Received from iris_species_dropdown.value (INPUT: it triggered the callback)
    iris_store         , # Received from iris_store.data (STATE: it doesn't trigger a callback but just provide data)
):
    # Subset iris data
    iris = pd.DataFrame(iris_store)
    data = iris [iris ['species'] == picked_iris_species]

    # Create Plotly px figure
    fig = px.scatter(data.sepal_length, data.sepal_width)

    # Pass figure to the figure property of iris_plot
    return fig


# Callback triggered by a previous callback
#--------------------------------------------------------------------------------
@app.callback(
    Output ('plot_timestamp', 'children'),
    Output ('hidden_div',     'style'   ),
    Input  ('iris_plot'     , 'figure'  ),
    prevent_initial_call = True
)
def plot_timestamp(
    _ # we won't use the value actually, so can use an underscore
):    
    
    return (
        f"You updated the plot at {datetime.now()}.", # Pass strig to plot_timestamp.children
        {}                                            # Pass dict to hidden_div.style, ie. make the div visible
    )

#-----------------------------------------------------------------------------------------------
# Run the app
#-----------------------------------------------------------------------------------------------
app.run_server(debug=True, port=8096)


#-----------------------------------------------------------------------------------------------
# Take home message
#-----------------------------------------------------------------------------------------------
# NEVER EVER modify global variables inside callbacks. Use dcc.store to exchange data between callbacks 
# A INPUT object.property must be unique! You an use the same INPUT in two callbacks.
# A OUTPUT object.property must be unique too, unless you set allow_duplicate=True
#   Output ('iris_plot', 'figure', allow_duplicate=True),
# A callback can have more than one input. You can use ctx.triggered_id inside the function to know which INPUT fired the callback
# A callback can have more than one output. Just make sure the return contains as many values as Outputs
# Callbacks are automarically triggered at app initialization, unless you specify prevent_initial_call = True

# Important reading:
# https://dash.plotly.com/advanced-callbacks
# https://dash.plotly.com/sharing-data-between-callbacks