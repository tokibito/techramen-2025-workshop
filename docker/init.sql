-- 初期データベース設定
-- TechRAMEN 2025 SQLワークショップ用
-- テーマ：中学校の成績管理システム

-- スキーマの作成
CREATE SCHEMA IF NOT EXISTS workshop;

-- 権限の設定
GRANT ALL PRIVILEGES ON SCHEMA workshop TO workshop;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA workshop TO workshop;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA workshop TO workshop;

-- デフォルトスキーマの設定
ALTER USER workshop SET search_path TO workshop, public;

-- サンプルテーブル: 学級
CREATE TABLE workshop.classes (
    class_id SERIAL PRIMARY KEY,
    grade INTEGER NOT NULL CHECK (grade BETWEEN 1 AND 3),
    class_number INTEGER NOT NULL CHECK (class_number BETWEEN 1 AND 9),
    class_name VARCHAR(10) NOT NULL,
    homeroom_teacher VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(grade, class_number)
);

-- サンプルテーブル: 生徒
CREATE TABLE workshop.students (
    student_id SERIAL PRIMARY KEY,
    student_number VARCHAR(10) UNIQUE NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    gender CHAR(1) CHECK (gender IN ('M', 'F')),
    birth_date DATE NOT NULL,
    class_id INTEGER REFERENCES workshop.classes(class_id),
    enrollment_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- サンプルテーブル: 教科
CREATE TABLE workshop.subjects (
    subject_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(20) NOT NULL UNIQUE,
    subject_code VARCHAR(10) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- サンプルテーブル: テスト情報
CREATE TABLE workshop.exams (
    exam_id SERIAL PRIMARY KEY,
    exam_name VARCHAR(50) NOT NULL,
    exam_date DATE NOT NULL,
    exam_number INTEGER NOT NULL CHECK (exam_number BETWEEN 1 AND 5),
    semester INTEGER NOT NULL CHECK (semester IN (1, 2, 3)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- サンプルテーブル: 成績
CREATE TABLE workshop.scores (
    score_id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES workshop.students(student_id),
    subject_id INTEGER REFERENCES workshop.subjects(subject_id),
    exam_id INTEGER REFERENCES workshop.exams(exam_id),
    score INTEGER CHECK (score BETWEEN 0 AND 100),
    is_absent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(student_id, subject_id, exam_id)
);

-- インデックスの作成
CREATE INDEX idx_scores_student_id ON workshop.scores(student_id);
CREATE INDEX idx_scores_subject_id ON workshop.scores(subject_id);
CREATE INDEX idx_scores_exam_id ON workshop.scores(exam_id);
CREATE INDEX idx_students_class_id ON workshop.students(class_id);

-- サンプルデータの挿入
-- 学級
INSERT INTO workshop.classes (grade, class_number, class_name, homeroom_teacher) VALUES
    (1, 1, '1年1組', '山田太郎'),
    (1, 2, '1年2組', '鈴木花子'),
    (2, 1, '2年1組', '佐藤次郎'),
    (2, 2, '2年2組', '田中美咲'),
    (3, 1, '3年1組', '伊藤健一'),
    (3, 2, '3年2組', '渡辺愛子');

-- 教科
INSERT INTO workshop.subjects (subject_name, subject_code) VALUES
    ('国語', 'JPN'),
    ('数学', 'MATH'),
    ('英語', 'ENG'),
    ('理科', 'SCI'),
    ('社会', 'SOC');

-- テスト情報（5回分）
INSERT INTO workshop.exams (exam_name, exam_date, exam_number, semester) VALUES
    ('1学期中間テスト', '2024-05-20', 1, 1),
    ('1学期期末テスト', '2024-07-10', 2, 1),
    ('2学期中間テスト', '2024-10-15', 3, 2),
    ('2学期期末テスト', '2024-12-05', 4, 2),
    ('3学期期末テスト', '2025-02-25', 5, 3);

-- 生徒（各クラス10人、計60人）
-- 1年1組
INSERT INTO workshop.students (student_number, last_name, first_name, gender, birth_date, class_id, enrollment_date) VALUES
    ('2024101', '青木', '陽太', 'M', '2011-04-15', 1, '2024-04-01'),
    ('2024102', '石田', 'さくら', 'F', '2011-05-20', 1, '2024-04-01'),
    ('2024103', '上田', '健太', 'M', '2011-06-10', 1, '2024-04-01'),
    ('2024104', '江口', '美優', 'F', '2011-07-25', 1, '2024-04-01'),
    ('2024105', '大野', '翔太', 'M', '2011-08-30', 1, '2024-04-01'),
    ('2024106', '加藤', '愛美', 'F', '2011-09-15', 1, '2024-04-01'),
    ('2024107', '木村', '大輝', 'M', '2011-10-20', 1, '2024-04-01'),
    ('2024108', '黒田', '結衣', 'F', '2011-11-05', 1, '2024-04-01'),
    ('2024109', '小林', '拓海', 'M', '2011-12-10', 1, '2024-04-01'),
    ('2024110', '斉藤', '莉子', 'F', '2012-01-25', 1, '2024-04-01');

-- 1年2組
INSERT INTO workshop.students (student_number, last_name, first_name, gender, birth_date, class_id, enrollment_date) VALUES
    ('2024201', '佐々木', '悠斗', 'M', '2011-04-05', 2, '2024-04-01'),
    ('2024202', '島田', '葵', 'F', '2011-05-15', 2, '2024-04-01'),
    ('2024203', '杉山', '蓮', 'M', '2011-06-20', 2, '2024-04-01'),
    ('2024204', '鈴木', '凛', 'F', '2011-07-30', 2, '2024-04-01'),
    ('2024205', '高橋', '颯太', 'M', '2011-08-25', 2, '2024-04-01'),
    ('2024206', '竹内', '芽衣', 'F', '2011-09-10', 2, '2024-04-01'),
    ('2024207', '田村', '陸', 'M', '2011-10-15', 2, '2024-04-01'),
    ('2024208', '中島', '心愛', 'F', '2011-11-20', 2, '2024-04-01'),
    ('2024209', '中村', '蒼', 'M', '2011-12-05', 2, '2024-04-01'),
    ('2024210', '西田', '杏奈', 'F', '2012-01-15', 2, '2024-04-01');

-- 2年1組
INSERT INTO workshop.students (student_number, last_name, first_name, gender, birth_date, class_id, enrollment_date) VALUES
    ('2023101', '野口', '大翔', 'M', '2010-04-10', 3, '2023-04-01'),
    ('2023102', '橋本', '彩花', 'F', '2010-05-25', 3, '2023-04-01'),
    ('2023103', '林', '悠真', 'M', '2010-06-15', 3, '2023-04-01'),
    ('2023104', '原田', '美月', 'F', '2010-07-20', 3, '2023-04-01'),
    ('2023105', '平野', '航太', 'M', '2010-08-05', 3, '2023-04-01'),
    ('2023106', '福田', '千夏', 'F', '2010-09-20', 3, '2023-04-01'),
    ('2023107', '藤田', '隼人', 'M', '2010-10-25', 3, '2023-04-01'),
    ('2023108', '前田', '楓', 'F', '2010-11-10', 3, '2023-04-01'),
    ('2023109', '松田', '大和', 'M', '2010-12-15', 3, '2023-04-01'),
    ('2023110', '三浦', '詩織', 'F', '2011-01-20', 3, '2023-04-01');

-- 2年2組
INSERT INTO workshop.students (student_number, last_name, first_name, gender, birth_date, class_id, enrollment_date) VALUES
    ('2023201', '宮崎', '翼', 'M', '2010-04-20', 4, '2023-04-01'),
    ('2023202', '村上', '琴音', 'F', '2010-05-10', 4, '2023-04-01'),
    ('2023203', '森田', '匠', 'M', '2010-06-25', 4, '2023-04-01'),
    ('2023204', '山口', '優奈', 'F', '2010-07-15', 4, '2023-04-01'),
    ('2023205', '山下', '快斗', 'M', '2010-08-20', 4, '2023-04-01'),
    ('2023206', '山本', '真央', 'F', '2010-09-05', 4, '2023-04-01'),
    ('2023207', '吉田', '涼太', 'M', '2010-10-10', 4, '2023-04-01'),
    ('2023208', '渡辺', '桜', 'F', '2010-11-25', 4, '2023-04-01'),
    ('2023209', '和田', '啓太', 'M', '2010-12-20', 4, '2023-04-01'),
    ('2023210', '安藤', '玲奈', 'F', '2011-01-05', 4, '2023-04-01');

-- 3年1組
INSERT INTO workshop.students (student_number, last_name, first_name, gender, birth_date, class_id, enrollment_date) VALUES
    ('2022101', '井上', '直樹', 'M', '2009-04-25', 5, '2022-04-01'),
    ('2022102', '岩田', '優希', 'F', '2009-05-30', 5, '2022-04-01'),
    ('2022103', '内田', '慎吾', 'M', '2009-06-05', 5, '2022-04-01'),
    ('2022104', '大塚', '彩乃', 'F', '2009-07-10', 5, '2022-04-01'),
    ('2022105', '岡田', '雄大', 'M', '2009-08-15', 5, '2022-04-01'),
    ('2022106', '小川', '真由', 'F', '2009-09-25', 5, '2022-04-01'),
    ('2022107', '金子', '拓実', 'M', '2009-10-30', 5, '2022-04-01'),
    ('2022108', '川口', '美咲', 'F', '2009-11-15', 5, '2022-04-01'),
    ('2022109', '菊地', '光', 'M', '2009-12-25', 5, '2022-04-01'),
    ('2022110', '久保', '花音', 'F', '2010-01-10', 5, '2022-04-01');

-- 3年2組
INSERT INTO workshop.students (student_number, last_name, first_name, gender, birth_date, class_id, enrollment_date) VALUES
    ('2022201', '工藤', '健斗', 'M', '2009-04-15', 6, '2022-04-01'),
    ('2022202', '栗原', '麻衣', 'F', '2009-05-05', 6, '2022-04-01'),
    ('2022203', '小島', '龍也', 'M', '2009-06-30', 6, '2022-04-01'),
    ('2022204', '後藤', '千尋', 'F', '2009-07-05', 6, '2022-04-01'),
    ('2022205', '近藤', '大輔', 'M', '2009-08-10', 6, '2022-04-01'),
    ('2022206', '坂本', '結菜', 'F', '2009-09-30', 6, '2022-04-01'),
    ('2022207', '清水', '陽向', 'M', '2009-10-05', 6, '2022-04-01'),
    ('2022208', '白石', '七海', 'F', '2009-11-30', 6, '2022-04-01'),
    ('2022209', '関口', '駿', 'M', '2009-12-30', 6, '2022-04-01'),
    ('2022210', '高木', '愛梨', 'F', '2010-01-30', 6, '2022-04-01');

-- 成績データのランダム生成
-- 各生徒、各教科、各テストに対して成績を生成
INSERT INTO workshop.scores (student_id, subject_id, exam_id, score, is_absent)
SELECT 
    s.student_id,
    sub.subject_id,
    e.exam_id,
    -- ランダムな成績を生成（50-100点の範囲で、正規分布に近い形）
    CASE 
        WHEN random() < 0.02 THEN NULL -- 2%の確率で欠席
        ELSE GREATEST(0, LEAST(100, 
            ROUND(75 + (random() - 0.5) * 40 + 
            -- 生徒による個人差
            (s.student_id % 10 - 5) * 2 + 
            -- 教科による差
            (sub.subject_id - 3) * 3 +
            -- テスト回数による成長
            (e.exam_number - 3) * 2
        )::numeric))
    END AS score,
    CASE WHEN random() < 0.02 THEN TRUE ELSE FALSE END AS is_absent
FROM workshop.students s
CROSS JOIN workshop.subjects sub
CROSS JOIN workshop.exams e
WHERE NOT (random() < 0.02); -- 欠席の場合は成績データを作成しない場合もある