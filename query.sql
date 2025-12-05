-- Mengambil jumlah siswa pada setiap kelas
SELECT 
    c.id AS classroom_id,        -- ID kelas
    c.name AS classroom_name,    -- Nama kelas
    COUNT(cs.student_id) AS total_students  -- Total siswa yang terdaftar
FROM classrooms c
LEFT JOIN classroom_students cs 
    ON cs.classroom_id = c.id    -- Relasi siswa-kelas
GROUP BY c.id, c.name;           -- Dikelompokkan per kelas

-- Menampilkan semua mentor yang mengajar di setiap kelas
SELECT 
    c.id AS classroom_id,        
    c.name AS classroom_name,
    u.name AS mentor_name        -- Nama mentor yang terkait kelas
FROM classroom_mentors cm
JOIN classrooms c ON c.id = cm.classroom_id
JOIN users u ON u.id = cm.mentor_id
ORDER BY c.id;                   -- Dikelompokkan berdasarkan kelas

-- Menampilkan catatan kehadiran setiap siswa untuk tiap jadwal kelas
SELECT 
    sc.classroom_id,             -- Kelas terkait jadwal
    sc.start_time,               
    sc.topic,                    -- Topik kelas
    u.name AS student_name,      
    a.status,                    -- present / absent
    a.checked_at                 -- Waktu absen dilakukan
FROM attendances a
JOIN schedules sc ON sc.id = a.schedule_id
JOIN users u ON u.id = a.user_id
ORDER BY sc.start_time, u.name;  -- Diurutkan per jadwal, lalu nama siswa

-- Menghitung kehadiran setiap minggu per siswa
SELECT 
    u.name AS student_name,
    EXTRACT(YEAR FROM sc.start_time) AS year,     -- Tahun per jadwal
    EXTRACT(WEEK FROM sc.start_time) AS week,     -- Minggu ke-
    SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) AS hadir,
    SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) AS absen
FROM attendances a
JOIN schedules sc ON sc.id = a.schedule_id
JOIN users u ON u.id = a.user_id
GROUP BY u.id, year, week;


-- Menghitung kehadiran setiap bulan per siswa
SELECT 
    u.name AS student_name,
    EXTRACT(YEAR FROM sc.start_time) AS year,     
    EXTRACT(MONTH FROM sc.start_time) AS month,   -- Bulan
    SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) AS hadir,
    SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) AS absen
FROM attendances a
JOIN schedules sc ON sc.id = a.schedule_id
JOIN users u ON u.id = a.user_id
GROUP BY u.id, year, month;


-- Materi yang dipetakan ke kelas melalui table material_classrooms
SELECT 
    c.name AS classroom_name,
    m.title AS material_title,
    m.file_url                     -- URL materi
FROM material_classrooms mc
JOIN materials m ON m.id = mc.material_id
JOIN classrooms c ON c.id = mc.classroom_id;


-- Menampilkan detail assignment beserta jumlah submission
SELECT
    c.name AS classroom_name,
    a.title AS assignment_title,
    a.deadline,                    -- Deadline tugas
    u.name AS creator_name,        -- Mentor pembuat tugas
    COUNT(s.id) AS total_submissions  -- Total pengumpulan tugas
FROM assignments a
JOIN classrooms c ON c.id = a.classroom_id
JOIN users u ON u.id = a.created_by
LEFT JOIN assignment_submissions s ON s.assignment_id = a.id
GROUP BY a.id, c.name, u.name;


-- Menampilkan semua pengumpulan tugas siswa beserta detail tugasnya
SELECT 
    u.name AS student_name,
    a.title AS assignment_title,
    s.file_url,                     -- File yang dikumpulkan
    s.created_at AS submitted_at    -- Waktu pengumpulan
FROM assignment_submissions s
JOIN users u ON u.id = s.student_id
JOIN assignments a ON a.id = s.assignment_id
ORDER BY u.id, s.created_at;

-- Menampilkan nilai siswa per assignment
SELECT
    a.title AS assignment_title,
    u.name AS student_name,
    g.grade,                        -- Nilai siswa
    g.feedback,                     -- Feedback penilaian
    g.graded_at                     -- Waktu penilaian
FROM grades g
JOIN assignments a ON a.id = g.assignment_id
JOIN users u ON u.id = g.student_id;

-- Mengambil nilai rata-rata setiap siswa berdasarkan tabel grades
SELECT
    u.name AS student_name,
    AVG(g.grade) AS avg_grade       -- Rata-rata nilai
FROM grades g
JOIN users u ON u.id = g.student_id
GROUP BY u.id;

-- Menampilkan notifikasi untuk setiap user beserta status baca
SELECT 
    u.name AS user_name,
    n.title,
    n.message,
    CASE WHEN n.is_read THEN 'read' ELSE 'unread' END AS status,
    n.created_at
FROM notifications n
JOIN users u ON u.id = n.user_id
ORDER BY u.id, n.created_at DESC;


