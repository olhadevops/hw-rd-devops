USE SchoolDB;

CREATE TABLE IF NOT EXISTS Institutions
(
    institution_id   INT AUTO_INCREMENT PRIMARY KEY,
    institution_name VARCHAR(255)                    NOT NULL,
    institution_type ENUM ('School', 'Kindergarten') NOT NULL,
    address          VARCHAR(255)                    NOT NULL
);

CREATE TABLE IF NOT EXISTS Classes
(
    class_id       INT AUTO_INCREMENT PRIMARY KEY,
    class_name     VARCHAR(255)                                                      NOT NULL,
    institution_id INT,
    direction      ENUM ('Mathematics', 'Biology and Chemistry', 'Language Studies') NOT NULL,
    FOREIGN KEY (institution_id) REFERENCES Institutions (institution_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Children
(
    child_id       INT AUTO_INCREMENT PRIMARY KEY,
    first_name     VARCHAR(255) NOT NULL,
    last_name      VARCHAR(255) NOT NULL,
    birth_date     DATE         NOT NULL,
    year_of_entry  YEAR         NOT NULL,
    age            INT          NOT NULL,
    institution_id INT,
    class_id       INT,
    FOREIGN KEY (institution_id) REFERENCES Institutions (institution_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES Classes (class_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Parents
(
    parent_id   INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(255)   NOT NULL,
    last_name   VARCHAR(255)   NOT NULL,
    child_id    INT,
    tuition_fee DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (child_id) REFERENCES Children (child_id) ON DELETE CASCADE
);


-- Вставка записів у Institutions
INSERT INTO Institutions (institution_name, institution_type, address)
VALUES ('Kyiv School №1', 'School', 'Kyiv, Main street 10'),
       ('Sunny Kindergarten', 'Kindergarten', 'Kyiv, Flower street 5'),
       ('Lviv School №5', 'School', 'Lviv, Freedom avenue 22');

-- Вставка записів у Classes
INSERT INTO Classes (class_name, institution_id, direction)
VALUES ('1-A', 1, 'Mathematics'),
       ('Sunshine Group', 2, 'Language Studies'),
       ('5-B', 3, 'Biology and Chemistry');

-- Вставка записів у Children
INSERT INTO Children (first_name, last_name, birth_date, year_of_entry, age, institution_id, class_id)
VALUES ('Ivan', 'Petrenko', '2015-09-01', 2022, 9, 1, 1),
       ('Anna', 'Shevchenko', '2018-03-15', 2023, 6, 2, 2),
       ('Oleh', 'Kovalenko', '2013-11-20', 2020, 11, 3, 3);

-- Вставка записів у Parents
INSERT INTO Parents (first_name, last_name, child_id, tuition_fee)
VALUES ('Olena', 'Petrenko', 1, 8000.00),
       ('Mykola', 'Shevchenko', 2, 6000.00),
       ('Iryna', 'Kovalenko', 3, 10000.00);
