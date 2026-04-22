# Online Voting System

A secure, framework-free online voting system built with **Java Servlets**, **JSP**, and **MySQL**. Designed as a full-stack web application that simulates a real-world digital election with voter authentication, dual-OTP verification, one-vote enforcement, and a live results dashboard.

---

## Features

- **Voter ID Verification** — Voters authenticate using a unique EPIC-format registration ID checked against a national registry database
- **Dual-OTP Authentication** — Simulated two-factor authentication via phone OTP and email OTP
- **One-Vote Enforcement** — Database-level and session-level checks prevent duplicate voting
- **Digital Ballot** — Clean candidate selection interface with confirmation modal before submission
- **Live Results Dashboard** — Real-time vote counts, turnout percentage, and projected leader with auto-refresh
- **Session Security** — Protected routes ensure only authenticated voters can access the ballot and results

---

## Tech Stack

| Layer      | Technology                          |
|------------|-------------------------------------|
| Backend    | Java Servlets (Jakarta EE 6.0)      |
| Frontend   | JSP, HTML5, CSS3, Vanilla JS        |
| Database   | MySQL 9.x                           |
| Server     | Apache Tomcat 11.0.2                |
| Connector  | MySQL Connector/J 9.6.0            |

> **Note:** No external frameworks (Spring, Hibernate, etc.) are used — the entire backend is built with pure Servlets and JDBC.

---

## Project Structure

```
OVS/
├── src/
│   └── servlets/
│       ├── DBConnection.java        # MySQL connection utility
│       ├── VoterVerifyServlet.java   # Voter ID verification
│       ├── OtpVerifyServlet.java     # Dual-OTP authentication
│       ├── VoteServlet.java          # Vote casting with transaction safety
│       └── LogoutServlet.java        # Session cleanup
├── WebContent/
│   ├── css/
│   │   └── style.css                # Complete application styling
│   ├── WEB-INF/
│   │   ├── web.xml                  # Servlet mappings
│   │   └── lib/                     # Jakarta Servlet API & MySQL Connector
│   ├── verify-voter.jsp             # Landing page — Voter ID input
│   ├── verify-otp.jsp               # OTP verification page
│   ├── vote.jsp                     # Digital ballot
│   ├── confirmed.jsp                # Vote confirmation receipt
│   └── results.jsp                  # Live results dashboard
├── lib/                             # Compile-time dependencies
├── database.sql                     # Database schema & seed data
├── Demo Sheet.md                    # Demo walkthrough & OTP reference
└── README.md
```

---

## Getting Started

### Prerequisites

- **Java JDK** 17 or higher
- **MySQL** 9.x
- **Apache Tomcat** 11.0.2 — [Download here](https://tomcat.apache.org/download-11.cgi)

### 1. Clone the Repository

```bash
git clone https://github.com/armnwho/OVS.git
cd OVS
```

### 2. Set Up the Database

Make sure MySQL is running, then execute the schema file:

```bash
cat database.sql | mysql -u root -p
```

> This creates the `voting_system` database with tables for voters, candidates, users, and votes, and seeds it with sample data.

### 3. Configure Database Credentials

Edit `src/servlets/DBConnection.java` and update the connection details if your MySQL credentials differ:

```java
private static final String URL = "jdbc:mysql://localhost:3306/voting_system";
private static final String USER = "root";
private static final String PASSWORD = "your_password";
```

### 4. Place Tomcat

Copy or extract Apache Tomcat 11.0.2 into the project root so the directory structure looks like:

```
OVS/
├── apache-tomcat-11.0.2/
├── src/
├── WebContent/
...
```

### 5. Compile & Deploy

```bash
javac -cp "lib/jakarta.servlet-api-6.0.0.jar:lib/mysql-connector-j-9.6.0.jar" \
  -d WebContent/WEB-INF/classes src/servlets/*.java

rm -rf apache-tomcat-11.0.2/webapps/voting
cp -r WebContent apache-tomcat-11.0.2/webapps/voting
```

### 6. Start Tomcat

```bash
./apache-tomcat-11.0.2/bin/startup.sh
```

### 7. Open the Application

Navigate to: **http://localhost:8080/voting/**

---

## Demo Credentials

| Voter ID       | Voter Name     | Phone OTP | Email OTP |
|----------------|----------------|-----------|-----------|
| `VUP47392`     | Aarav Sharma   | `482910`  | `736251`  |
| `VDL81620`     | Isha Patel     | `193047`  | `528374`  |
| `VKA30517`     | Rohan Gupta    | `847362`  | `019283`  |
| `VTN92746`     | Meera Nair     | `571038`  | `294716`  |
| `VRJ54803`     | Vikram Singh   | `638492`  | `815037`  |
| `VWB61938`     | Ananya Das     | `420185`  | `963574`  |

> Each Voter ID can only vote **once**. To reset, re-run `database.sql`.

---

## Application Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐     ┌──────────────────┐
│  Voter ID Page  │────▶│  OTP Verification │────▶│  Digital Ballot │────▶│  Vote Confirmed  │
│  (verify-voter) │     │  (verify-otp)     │     │  (vote)         │     │  (confirmed)     │
└─────────────────┘     └──────────────────┘     └─────────────────┘     └──────────────────┘
       │                        │                                               │
       ▼                        ▼                                               ▼
  ID not found?           Wrong OTP?                                      Live Results
  Already voted?          → Error message                                (auto-refresh)
  → Error message
```

---

## Security Features

| Feature                    | Implementation                                           |
|----------------------------|----------------------------------------------------------|
| SQL Injection Prevention   | Prepared Statements for all database queries             |
| Duplicate Vote Prevention  | Both session-level and database-level checks             |
| Transaction Safety         | Vote casting uses `setAutoCommit(false)` with rollback   |
| Session Protection         | All sensitive pages redirect unauthenticated users       |
| Input Validation           | Server-side validation on all form inputs                |

---

## Reset Database

To start fresh (clear all votes and reset voter status):

```bash
cat database.sql | mysql -u root -p
```

## Stop Tomcat

```bash
./apache-tomcat-11.0.2/bin/shutdown.sh
```

---
