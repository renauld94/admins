import dash
from dash import dcc, html, Output, Input, State
import dash_mantine_components as dmc
import plotly.express as px
from datetime import datetime, date
import pandas as pd

#-----------------------------------------------------------------------------------------------
# Useful links
#-----------------------------------------------------------------------------------------------

# Main website: https://dash.plotly.com/
# Gallery     : https://dash.gallery/Portal/

# dcc objects : https://dash.plotly.com/dash-core-components 
#               https://community.plotly.com/t/community-components-index/60098
# dbc objects : https://dash-bootstrap-components.opensource.faculty.ai/docs/components/
# dmc objects : https://www.dash-mantine-components.com/getting-started
# Iconify     : https://icon-sets.iconify.design/


#-----------------------------------------------------------------------------------------------
# Get started: 
# Refresh the git repo you already have cloned, create a virtual environment, run app and browse
#-----------------------------------------------------------------------------------------------

# 1) Open a terminal in IDAR Shiny and run these commands:
#    cd python_training
#    git pull
#    python -m venv venv
#    source venv/bin/activate
#    pip install -r requirements.txt
# 2) Open a VS code session, open this program and run it.
# 3) Look in python_training, there's a .env file. 
#    It contains a URL looking like this: /s/ef0bb3c9ab5a78e16230a/p/4b8a74fb/
# 4) Open Chrome and browse to idarshiny.jnj.com/s/ef0bb3c9ab5a78e16230a/p/4b8a74fb/  
#    Replace the URL with the the one in your .env file


#-----------------------------------------------------------------------------------------------
# Instantiate the Dash object
#-----------------------------------------------------------------------------------------------
app = dash.Dash(__name__)
app.title = "Dash basics"

#-----------------------------------------------------------------------------------------------
# Create the Dash layout
#-----------------------------------------------------------------------------------------------
app.layout = html.Div([

    dmc.Text('Hello World!'), 
    html.Hr(),                      # With Dash, no need to know HTML, this is a python object.
    
    dmc.DatePicker(                 # Not a static object. No need to know Javascript!
        id      = "date-picker",    # Object IDs are optional and must be unique
        label   = "Pick up a date", # Object properties can be customized in the layout. We'll see soon they can be changed once the app is alive, using a callback.
        minDate = date(2020, 8, 5),
        style   = {"width": 200},
        ),

    html.Br(),
    dmc.Button(
        "Click me, I don't care",  # Providing a positional argument. It's name inside the Button() function is 'children'. In that case, children is the button content, e.g. it's title. You can also pass an iterable of objects
        color = 'yellow'           # Providing a keyword argument. No need to know CSS!
    ),

    html.Div(                       # HTML divs are containers, they can be hidden.
        children = [
            dmc.Text('Hello?!')
        ],
        style = {'display': 'none'}
    )

])

#-----------------------------------------------------------------------------------------------
# Run the app
#-----------------------------------------------------------------------------------------------
app.run_server(debug=True, port=8090)


#-----------------------------------------------------------------------------------------------
# Deploy
#-----------------------------------------------------------------------------------------------

# Current process in C&SP: deploy the app in IDAR Connect.
# App Inventory manual: https://idarconnect-qa.jnj.com/connect/#/apps/51b62435-0970-4355-b3ee-2eabc3021a5e/access/23
