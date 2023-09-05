Python 3.11.2 (tags/v3.11.2:878ead1, Feb  7 2023, 16:38:35) [MSC v.1934 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> 
>>> 
>>> import os
... import re
... import requests
... 
... def get_latest_version():
...     # Replace this function with the actual implementation to fetch the latest version from the product page or an API
...     latest_version = "1.0.0"  # example version
...     return latest_version
... 
... def get_installed_version():
...     installed_version = None
... 
...     # Windows
...     if os.name == 'nt':
...         try:
...             output = os.popen('wmic product where "name like \'%EPOS Connect%\'" get version').read()
...             installed_version = re.search(r'(\d+\.\d+\.\d+)', output).group(1)
...         except Exception as e:
...             print("Error: Unable to retrieve installed version on Windows. ", e)
... 
...     # macOS
...     elif os.name == 'posix':
...         try:
...             output = os.popen("system_profiler SPApplicationsDataType | grep -A 5 -i 'EPOS Connect'").read()
...             installed_version = re.search(r'(\d+\.\d+\.\d+)', output).group(1)
...         except Exception as e:
...             print("Error: Unable to retrieve installed
