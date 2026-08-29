# Secure Online Voting System

A premium, secure, and modern online voting system built using **React 19**, **Vite**, **Tailwind CSS v4**, **Express.js (Node.js)**, and a self-contained **SQLite local database**.

All application data is stored locally directly inside the project root folder in `database.sqlite`, making the entire system 100% portable, lightweight, and independent of external database servers or cloud dependencies.

The user interface, styles, variables, and election flows are modeled after official national electoral commission voting workflows.

---

## Dashboard Preview

![Online Voting System Dashboard](voting_system_dashboard.png)

---

## Tech Stack

| Layer       | Technology                                                    |
|-------------|---------------------------------------------------------------|
| Frontend    | React 19, Tailwind CSS v4                                     |
| Build Tool  | Vite 8                                                        |
| Backend     | Express.js (Node.js)                                          |
| Database    | Local SQLite (`database.sqlite` in project root)              |
| Persistence | Atomic SQLite Transactions + WAL Mode + Browser Local Caching |
| Manager     | npm (Node Package Manager)                                    |

---

## Technical Architecture & File Layout

```
OnlineVotingSystem/
├── database.sqlite            # Self-contained SQLite database (root level, auto-seeded)
├── server.js                  # Backend Express API server & SQLite connection layer
├── src/
│   ├── App.jsx                # Unified frontend: Context, views, and routing guards
│   ├── index.css              # Combined style sheet: Tailwind v4 + custom styles
│   └── main.jsx               # React 19 entry point
├── eslint.config.js           # ESLint configuration
├── index.html                 # Root HTML index file
├── package.json               # Dependencies, build tools, & concurrently execution scripts
└── vite.config.js             # Vite configuration with @tailwindcss/vite plugin
```

---

## SQLite Database Schema

The local SQLite database (`database.sqlite`) is automatically initialized and seeded with demo tables on server startup:

```sql
-- 1. Candidates & Parties
CREATE TABLE IF NOT EXISTS candidates (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  vote_count INTEGER NOT NULL DEFAULT 0
);

-- 2. Voter Registry
CREATE TABLE IF NOT EXISTS voters (
  voter_id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  is_used INTEGER NOT NULL DEFAULT 0,
  phone_otp TEXT NOT NULL,
  email_otp TEXT NOT NULL
);

-- 3. Authenticated Voting Users
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  password TEXT NOT NULL DEFAULT 'auto_generated',
  voter_id TEXT NOT NULL,
  has_voted INTEGER NOT NULL DEFAULT 0
);

-- 4. Cast Ballots / Votes Audit Log
CREATE TABLE IF NOT EXISTS votes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  candidate_id INTEGER NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## Demo Data & Credentials

### 1. Candidates & Political Parties (`candidates` table)

| ID | Party / Option Name                | Initial Vote Count |
|:--:|------------------------------------|:------------------:|
| 1  | **BJP (Bharatiya Janata Party)**   | `0`                |
| 2  | **AAP (Aam Aadmi Party)**          | `0`                |
| 3  | **INC (Indian National Congress)** | `0`                |
| 4  | **NOTA (None of the Above)**       | `0`                |
| 5  | **SP (Samajwadi Party)**           | `0`                |

### 2. Registered Voters Registry (`voters` table)

The following voters are pre-seeded in the local SQLite database. Use these credentials to test the authentication and voting process. Each Voter ID can only vote **once**.

| # | Voter ID       | Voter Full Name | Phone Number | Email Address              | Phone OTP  | Email OTP  | Initial Status |
|:-:|----------------|-----------------|--------------|----------------------------|:----------:|:----------:|:--------------:|
| 1 | **VUP47392**   | Aarav Sharma    | `9876543210` | `aarav.sharma@example.com` | **482910** | **736251** | `Unused (0)`   |
| 2 | **VDL81620**   | Isha Patel      | `8765432109` | `isha.patel@example.com`   | **193047** | **528374** | `Unused (0)`   |
| 3 | **VKA30517**   | Rohan Gupta     | `7654321098` | `rohan.gupta@example.com`  | **847362** | **019283** | `Unused (0)`   |
| 4 | **VTN92746**   | Meera Nair      | `9012345678` | `meera.nair@example.com`   | **571038** | **294716** | `Unused (0)`   |
| 5 | **VRJ54803**   | Vikram Singh    | `8901234567` | `vikram.singh@example.com` | **638492** | **815037** | `Unused (0)`   |
| 6 | **VWB61938**   | Ananya Das      | `7890123456` | `ananya.das@example.com`   | **420185** | **963574** | `Unused (0)`   |

---

## Step-by-Step Voting Walkthrough

1. **Voter Verification**: Enter any registered Voter ID (e.g. `VUP47392`) and click **Verify Voter ID**.
2. **Dual-Factor OTP Authentication**: 
   - Click **Send Verification Codes**.
   - Enter the corresponding **SMS OTP** (`482910`) and **Email OTP** (`736251`).
   - Click **Verify & Proceed**.
3. **Ballot Casting**: Select your preferred candidate/party and confirm your choice in the modal overlay.
4. **Receipt Generation**: View your cryptographically generated vote transaction hash receipt.
5. **Live Results**: Check the real-time election tallies, voter turnout percentage, and projected winner.

---

## Express Server Endpoints

The backend server operates on port **3001** and communicates directly with `database.sqlite`:

- **`GET /data`** — Returns the entire SQLite database snapshot (`candidates`, `voters`, `users`, `votes`).
- **`POST /data`** — Atomically commits updated records into SQLite using transactional batching.
- **`POST /api/reset`** — Resets all votes, resets voter `is_used` flags back to 0, and restores candidate vote counts to 0.

---

## Getting Started

### Prerequisites
- **Node.js** v18 or higher (uses native `node:sqlite` in Node 22+ or `better-sqlite3`)
- **npm** v9 or higher

### 1. Installation
```bash
npm install
```

### 2. Run Application
Start the SQLite backend server and Vite frontend concurrently:
```bash
npm run dev
```

- **Voter Portal**: [http://localhost:5173/](http://localhost:5173/)
- **Backend API & Database**: [http://localhost:3001/data](http://localhost:3001/data)

---

## SQLite Database Management & Inspection

### Direct SQLite CLI Inspection
You can inspect the SQLite database file directly from your terminal:
```bash
sqlite3 database.sqlite "SELECT * FROM candidates;"
sqlite3 database.sqlite "SELECT voter_id, full_name, is_used FROM voters;"
sqlite3 database.sqlite "SELECT * FROM votes;"
```

### Reset Database State
You can reset the database state anytime using either method:
- **Option 1 (API)**: Send a `POST` request to `http://localhost:3001/api/reset`.
- **Option 2 (File)**: Delete `database.sqlite` from the project root and restart the server (`npm run dev`), which will automatically recreate and seed a clean database.

