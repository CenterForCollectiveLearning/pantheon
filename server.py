from flask import Flask
app = Flask(__name__)

# General
@app.route('/')
def index():
    return 'Index Page'

# Explore
@app.route('/explore/')
@app.route('/explore/<viz_type>/<trade_flow>/<country1>/<country2>/')
@app.route('/explore/<viz_type>/<trade_flow>/<country1>/<country2>/<int:s_date>/<int:f_date>')
@app.route('/explore/<viz_type>/<trade_flow>/<country1>/<country2>/<int:s_date>/<int:f_date>/<int:l>')
def explore(viz_type='treemap', trade_flow='export', country1='usa', country2='all', s_date=1800, f_date=1950, l=25):
    return 'Explore: %s %s %s %s %s %s %s' % (viz_type, trade_flow, country1, country2, s_date, f_date, l)

# Data
@app.route('/data')
def data():
    return 'Data!'

# People
@app.route('/people/')
def people():
    return 'People!'

# Rankings
@app.route('/rankings/')
def rankings():
    return 'Rankings!'

# About
@app.route('/about')
def about:
    return 'About!'

if __name__ == '__main__':
    app.debug = True
    app.run()
