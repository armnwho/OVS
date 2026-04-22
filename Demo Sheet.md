# Online Voting System — Demo Sheet

---

## Step 1: Start Everything (Before Demo)

Open **Terminal** and run these 3 commands one by one:

```bash
# 1. Reset database to clean state
cat "/Users/armaan/Downloads/PROGRAMMING/CODE/VSCODE/PROJECTS/JAVA/OVS/database.sql" | /opt/homebrew/Cellar/mysql/9.6.0_2/bin/mysql -u root -pRoot@1234
```

```bash
# 2. Compile & deploy
cd "/Users/armaan/Downloads/PROGRAMMING/CODE/VSCODE/PROJECTS/JAVA/OVS" && javac -cp "lib/jakarta.servlet-api-6.0.0.jar:lib/mysql-connector-j-9.6.0.jar" -d WebContent/WEB-INF/classes src/servlets/*.java && rm -rf apache-tomcat-11.0.2/webapps/voting && cp -r WebContent apache-tomcat-11.0.2/webapps/voting
```

```bash
# 3. Start Tomcat
cd "/Users/armaan/Downloads/PROGRAMMING/CODE/VSCODE/PROJECTS/JAVA/OVS" && ./apache-tomcat-11.0.2/bin/startup.sh
```

Then open in browser: **http://localhost:8080/voting/**

---

## Step 2: Voter ID & OTP Reference Card

| # | Voter ID       | Name          | Masked Phone   | Masked Email             | Phone OTP  | Email OTP  |
|---|----------------|---------------|----------------|--------------------------|------------|------------|
| 1 | **VUP47392**   | Aarav Sharma  | `987****10`    | `aa***@example.com`      | **482910** | **736251** |
| 2 | **VDL81620**   | Isha Patel    | `876****09`    | `is***@example.com`      | **193047** | **528374** |
| 3 | **VKA30517**   | Rohan Gupta   | `765****98`    | `ro***@example.com`      | **847362** | **019283** |
| 4 | **VTN92746**   | Meera Nair    | `901****78`    | `me***@example.com`      | **571038** | **294716** |
| 5 | **VRJ54803**   | Vikram Singh  | `890****67`    | `vi***@example.com`      | **638492** | **815037** |
| 6 | **VWB61938**   | Ananya Das    | `789****56`    | `an***@example.com`      | **420185** | **963574** |

---

## Stop Everything After Demo

```bash
cd "/Users/armaan/Downloads/PROGRAMMING/CODE/VSCODE/PROJECTS/JAVA/OVS" && ./apache-tomcat-11.0.2/bin/shutdown.sh
```