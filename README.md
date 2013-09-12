culture-observatory
===================

Observatory of Global Culture Codebase

Using virtualenv
-------------------
Installation:
sudo easy_install virtualenv
sudo pip install virtualenv

Initialization:
cd culture-observatory
virtualenv venv

Activate:
source venv/bin/activate

Deactivate:
deactivate

Installing Requirements
-------------------
pip install -r requirements.txt

Deploying to new server
-------------------
virtualenv --no-site-packages --distribute .env && source .env/bin/activate && pip install -r requirements.txt