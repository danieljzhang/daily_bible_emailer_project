Build instructions

From the lambda/ folder:
1. pip install -r requirements.txt -t ./package
2. cp app.py package/
3. cd package && zip -r ../daily_bible.zip .
4. The resulting daily_bible.zip will be placed in lambda/ and used by the envs example.
