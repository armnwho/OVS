-- Reset script: Run this BEFORE your demo to get a clean database
-- Command: cat database.sql | /opt/homebrew/Cellar/mysql/9.6.0_2/bin/mysql -u root -pRoot@1234

DROP DATABASE IF EXISTS voting_system;
CREATE DATABASE voting_system;
USE voting_system;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50),
  password VARCHAR(50),
  voter_id VARCHAR(20) UNIQUE,
  has_voted INT DEFAULT 0
);

CREATE TABLE candidates (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  vote_count INT DEFAULT 0
);

CREATE TABLE votes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  candidate_id INT NOT NULL
);

CREATE TABLE voter_registry (
  voter_id VARCHAR(20) PRIMARY KEY,
  full_name VARCHAR(100),
  phone VARCHAR(15),
  email VARCHAR(100),
  is_used INT DEFAULT 0
);

-- Candidates
INSERT INTO candidates (name) VALUES 
('BJP (Bharatiya Janata Party)'),
('AAP (Aam Aadmi Party)'),
('INC (Indian National Congress)'),
('NOTA (None of the Above)'),
('SP (Samajwadi Party)');

-- Voters (Realistic EPIC-format Voter IDs)
INSERT INTO voter_registry (voter_id, full_name, phone, email) VALUES 
('VUP47392', 'Aarav Sharma',  '9876543210', 'aarav.sharma@example.com'),
('VDL81620', 'Isha Patel',    '8765432109', 'isha.patel@example.com'),
('VKA30517', 'Rohan Gupta',   '7654321098', 'rohan.gupta@example.com'),
('VTN92746', 'Meera Nair',    '9012345678', 'meera.nair@example.com'),
('VRJ54803', 'Vikram Singh',  '8901234567', 'vikram.singh@example.com'),
('VWB61938', 'Ananya Das',    '7890123456', 'ananya.das@example.com');
