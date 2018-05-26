### Real Estate data visualization

##### This project depends on data set available here  
foreclosure: https://data.wprdc.org/dataset/allegheny-county-mortgage-foreclosure-records/resource/859bccfd-0e12-4161-a348-313d734f25fd
Tax Liens: https://data.wprdc.org/dataset/allegheny-county-tax-liens-filed-and-satisfied/resource/65d0d259-3e58-49d3-bebb-80dc75f61245
Violations: https://data.wprdc.org/dataset/pittsburgh-pli-violations-report/resource/4e5374be-1a88-47f7-afee-6a79317019b4
Assessments: https://data.wprdc.org/dataset/property-assessments/resource/518b583f-7cc8-4f60-94d0-174cc98310dc

> It's a Electron based desktop App, using React ,Ag-grid(https://www.ag-grid.com/) and sqlite3 , Project is created for MAC . Need some minor changes to support Windows / Linux.

 - You need to download them to to your local enviornment , ~/Download folder and run `chmod u+x dbcreate.sh`  , `./dbcreate.sh` to prepare your DB. Before running the script rename the csv files as mentioned in the shell script. You need to have sqlite3 installed on your machine.

 - Once the script is successful. You need to manually move it to sudo mv ~/Downloads/realdb.db /usr/local/realdb.db

 - For developers only -> To run in local -> 1) npm install 2) npm run dev

 - For developers only -> To create the bundled application -> 1) npm run package 2) If getting error delete the `build` folder and run step 1 again 

 - This App uses `/usr/local/realdb.db` data base . DB is kept external as the users can manually change the DB when required without changing the app .

 - The bundled application can be found inside the builds folder.