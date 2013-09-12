The Observatory of Global Culture
===================

### Using virtualenv

Installation

        pip install virtualenv
Initialization

        virtualenv venv
Activate

        source venv/bin/activate
Deactivate

        deactivate

### Installing Requirements

        pip install -r requirements.txt

### Deploying to new server

        virtualenv --no-site-packages --distribute .env && source .env/bin/activate && pip install -r requirements.txt