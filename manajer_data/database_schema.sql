-- Database Schema for Academic System

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE, -- NIM or NIP
    password VARCHAR(255) NOT NULL, -- Hash: password_hash(pass, PASSWORD_BCRYPT)
    name VARCHAR(100) NOT NULL,
    role ENUM('mahasiswa', 'dosen', 'admin', 'keuangan') NOT NULL,
    photo_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    sks INT NOT NULL,
    semester INT NOT NULL
);

CREATE TABLE classes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    dosen_id INT NOT NULL,
    section VARCHAR(10) NOT NULL, -- e.g., 'Kelas A'
    day VARCHAR(10) NOT NULL,
    time_start TIME NOT NULL,
    time_end TIME NOT NULL,
    room VARCHAR(50) NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id),
    FOREIGN KEY (dosen_id) REFERENCES users(id)
);

CREATE TABLE enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    class_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (class_id) REFERENCES classes(id)
);

CREATE TABLE materials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    type ENUM('materi', 'tugas', 'ujian') NOT NULL,
    file_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id)
);

CREATE TABLE submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    material_id INT NOT NULL,
    student_id INT NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    grade INT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (material_id) REFERENCES materials(id),
    FOREIGN KEY (student_id) REFERENCES users(id)
);

-- Dummy Data for Testing

-- Users (Password: 123456 -> $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi)
INSERT INTO users (username, password, name, role) VALUES 
('2023001', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ahmad Siswa', 'mahasiswa'),
('D001', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Budi Santoso, M.Kom', 'dosen'),
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin Akademik', 'admin');

-- Courses
INSERT INTO courses (code, name, sks, semester) VALUES 
('IF101', 'Algoritma Pemrograman', 3, 1),
('IF102', 'Struktur Data', 4, 2);

-- Classes
INSERT INTO classes (course_id, dosen_id, section, day, time_start, time_end, room) VALUES 
(1, 2, 'Kelas A', 'Senin', '08:00:00', '10:00:00', 'R.101'),
(2, 2, 'Kelas A', 'Selasa', '10:00:00', '12:00:00', 'Lab.1');

-- Enrollments
INSERT INTO enrollments (student_id, class_id) VALUES 
(1, 1),
(1, 2);
