import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

const DB_PATH = path.join(__dirname, 'database.sqlite');

// Initialize SQLite connection (supports built-in node:sqlite or better-sqlite3)
let DatabaseSync;
try {
  const nodeSqlite = await import('node:sqlite');
  DatabaseSync = nodeSqlite.DatabaseSync;
} catch {
  const betterSqlite = (await import('better-sqlite3')).default;
  DatabaseSync = betterSqlite;
}

const db = new DatabaseSync(DB_PATH);

// Enable WAL mode for high performance and concurrency
try {
  db.exec('PRAGMA journal_mode = WAL;');
} catch {
  // Pragma optional
}

// Initial demo dataset
const INITIAL_CANDIDATES = [
  { id: 1, name: "BJP (Bharatiya Janata Party)", vote_count: 0 },
  { id: 2, name: "AAP (Aam Aadmi Party)", vote_count: 0 },
  { id: 3, name: "INC (Indian National Congress)", vote_count: 0 },
  { id: 4, name: "NOTA (None of the Above)", vote_count: 0 },
  { id: 5, name: "SP (Samajwadi Party)", vote_count: 0 }
];

const INITIAL_VOTERS = [
  { voter_id: "VUP47392", full_name: "Aarav Sharma", phone: "9876543210", email: "aarav.sharma@example.com", is_used: 0, phone_otp: "482910", email_otp: "736251" },
  { voter_id: "VDL81620", full_name: "Isha Patel", phone: "8765432109", email: "isha.patel@example.com", is_used: 0, phone_otp: "193047", email_otp: "528374" },
  { voter_id: "VKA30517", full_name: "Rohan Gupta", phone: "7654321098", email: "rohan.gupta@example.com", is_used: 0, phone_otp: "847362", email_otp: "019283" },
  { voter_id: "VTN92746", full_name: "Meera Nair", phone: "9012345678", email: "meera.nair@example.com", is_used: 0, phone_otp: "571038", email_otp: "294716" },
  { voter_id: "VRJ54803", full_name: "Vikram Singh", phone: "8901234567", email: "vikram.singh@example.com", is_used: 0, phone_otp: "638492", email_otp: "815037" },
  { voter_id: "VWB61938", full_name: "Ananya Das", phone: "7890123456", email: "ananya.das@example.com", is_used: 0, phone_otp: "420185", email_otp: "963574" }
];

// Initialize schema and seed demo data
function initDb() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS candidates (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      vote_count INTEGER NOT NULL DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS voters (
      voter_id TEXT PRIMARY KEY,
      full_name TEXT NOT NULL,
      phone TEXT NOT NULL,
      email TEXT NOT NULL,
      is_used INTEGER NOT NULL DEFAULT 0,
      phone_otp TEXT NOT NULL,
      email_otp TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL DEFAULT 'auto_generated',
      voter_id TEXT NOT NULL,
      has_voted INTEGER NOT NULL DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS votes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      candidate_id INTEGER NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);

  // Seed candidates if empty
  const candidateCount = db.prepare('SELECT COUNT(*) as count FROM candidates').get();
  if (candidateCount.count === 0) {
    const insertCandidate = db.prepare('INSERT INTO candidates (id, name, vote_count) VALUES (?, ?, ?)');
    for (const c of INITIAL_CANDIDATES) {
      insertCandidate.run(c.id, c.name, c.vote_count);
    }
  }

  // Seed voters if empty
  const voterCount = db.prepare('SELECT COUNT(*) as count FROM voters').get();
  if (voterCount.count === 0) {
    const insertVoter = db.prepare('INSERT INTO voters (voter_id, full_name, phone, email, is_used, phone_otp, email_otp) VALUES (?, ?, ?, ?, ?, ?, ?)');
    for (const v of INITIAL_VOTERS) {
      insertVoter.run(v.voter_id, v.full_name, v.phone, v.email, v.is_used, v.phone_otp, v.email_otp);
    }
  }
}

initDb();

// Helper to get all database records
function getFullData() {
  const candidates = db.prepare('SELECT id, name, vote_count FROM candidates ORDER BY id ASC').all();
  const voters = db.prepare('SELECT voter_id, full_name, phone, email, is_used, phone_otp, email_otp FROM voters ORDER BY voter_id ASC').all();
  const users = db.prepare('SELECT id, username, password, voter_id, has_voted FROM users ORDER BY id ASC').all();
  const votes = db.prepare('SELECT id, user_id, candidate_id, created_at FROM votes ORDER BY id ASC').all();
  return { candidates, voters, users, votes };
}

// Helper to sync/save full database state
function saveFullData(data) {
  const { candidates, voters, users, votes } = data;

  db.exec('BEGIN TRANSACTION;');
  try {
    if (Array.isArray(candidates)) {
      const updateCandidate = db.prepare('INSERT OR REPLACE INTO candidates (id, name, vote_count) VALUES (?, ?, ?)');
      for (const c of candidates) {
        updateCandidate.run(c.id, c.name, c.vote_count);
      }
    }

    if (Array.isArray(voters)) {
      const updateVoter = db.prepare('INSERT OR REPLACE INTO voters (voter_id, full_name, phone, email, is_used, phone_otp, email_otp) VALUES (?, ?, ?, ?, ?, ?, ?)');
      for (const v of voters) {
        updateVoter.run(v.voter_id, v.full_name, v.phone, v.email, v.is_used, v.phone_otp, v.email_otp);
      }
    }

    if (Array.isArray(users)) {
      const updateUser = db.prepare('INSERT OR REPLACE INTO users (id, username, password, voter_id, has_voted) VALUES (?, ?, ?, ?, ?)');
      for (const u of users) {
        updateUser.run(u.id, u.username, u.password || 'auto_generated', u.voter_id, u.has_voted);
      }
    }

    if (Array.isArray(votes)) {
      const updateVote = db.prepare('INSERT OR REPLACE INTO votes (id, user_id, candidate_id) VALUES (?, ?, ?)');
      for (const vote of votes) {
        updateVote.run(vote.id, vote.user_id, vote.candidate_id);
      }
    }

    db.exec('COMMIT;');
    return true;
  } catch (err) {
    db.exec('ROLLBACK;');
    console.error('Database transaction error:', err);
    return false;
  }
}

// Reset database helper
function resetDb() {
  db.exec('BEGIN TRANSACTION;');
  try {
    db.exec('DELETE FROM votes;');
    db.exec('DELETE FROM users;');
    db.exec('DELETE FROM candidates;');
    db.exec('DELETE FROM voters;');

    const insertCandidate = db.prepare('INSERT INTO candidates (id, name, vote_count) VALUES (?, ?, ?)');
    for (const c of INITIAL_CANDIDATES) {
      insertCandidate.run(c.id, c.name, c.vote_count);
    }

    const insertVoter = db.prepare('INSERT INTO voters (voter_id, full_name, phone, email, is_used, phone_otp, email_otp) VALUES (?, ?, ?, ?, ?, ?, ?)');
    for (const v of INITIAL_VOTERS) {
      insertVoter.run(v.voter_id, v.full_name, v.phone, v.email, v.is_used, v.phone_otp, v.email_otp);
    }

    db.exec('COMMIT;');
    return true;
  } catch (err) {
    db.exec('ROLLBACK;');
    console.error('Reset error:', err);
    return false;
  }
}

// API Routes
app.get('/', (req, res) => {
  res.send(`
    <h1>National Electoral Commission — Secure Voting System API</h1>
    <p>Local SQLite Database active: <code>database.sqlite</code></p>
    <ul>
      <li><a href="/data">GET /data</a> - View database state</li>
      <li>POST /data - Sync database state</li>
      <li>POST /api/reset - Reset database to initial demo state</li>
    </ul>
  `);
});

app.get('/data', (req, res) => {
  try {
    res.json(getFullData());
  } catch (err) {
    res.status(500).json({ error: 'Failed to read SQLite database', details: err.message });
  }
});

app.post('/data', (req, res) => {
  const ok = saveFullData(req.body);
  if (ok) res.json({ success: true });
  else res.status(500).json({ error: 'Failed to write data to SQLite database' });
});

app.post('/api/reset', (req, res) => {
  const ok = resetDb();
  if (ok) res.json({ success: true, message: 'Database reset to demo state' });
  else res.status(500).json({ error: 'Failed to reset database' });
});

app.listen(PORT, () => {
  console.log(`Voting System Backend Server running at http://localhost:${PORT}`);
  console.log(`SQLite database stored at: ${DB_PATH}`);
});

