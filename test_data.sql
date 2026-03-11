-- ТЕСТОВЫЕ ДАННЫЕ
-- все данные вымышленные, совпадения случайны

-- 1. Пользователи (Users)
INSERT INTO Users (username, password_hash, snils, inn) VALUES
('ivanov', 'hash123', '123-456-789 01', '123456789012'),
('petrov', 'hash456', '234-567-890 12', '234567890123'),
('sidorov', 'hash789', '345-678-901 23', NULL);

-- 2. Профили пользователей (UserProfiles)
INSERT INTO UserProfiles (
    user_id, first_name, last_name, middle_name, birth_date, sex, email, phone, 
    passport_series, passport_number, registration_address
) VALUES 
(1, 'Иван', 'Иванов', 'Иванович', '1990-01-15', 'M', 'ivan.ivanov@email.com', '+79011234567', 
 '1234', '567890', 'г. Москва, ул. Ленина, д. 1, кв. 1'),
(2, 'Петр', 'Петров', 'Петрович', '1985-05-20', 'M', 'petr.petrov@email.com', '+79021234567', 
 '2345', '678901', 'г. Москва, ул. Гагарина, д. 2, кв. 2'),
(3, 'Сидор', 'Сидоров', 'Сидорович', '1995-10-10', 'M', 'sidor.sidorov@email.com', '+79031234567', 
 '3456', '789012', 'г. Москва, ул. Пушкина, д. 3, кв. 3');

-- 3. Роли (Roles)
INSERT INTO Roles (name, description) VALUES
('Гражданин', 'Обычный пользователь портала, может подавать заявления'),
('Сотрудник', 'Сотрудник ведомства, может обрабатывать заявления'),
('Администратор', 'Администратор системы, управляет пользователями и услугами');

-- 4. Назначение ролей пользователям (UserRoles)
INSERT INTO UserRoles (user_id, role_id, assigned_by) VALUES
(1, 1, 1),  -- Иванов (id=1) получает роль Гражданин (id=1), назначил сам себя
(2, 2, 1),  -- Петров (id=2) получает роль Сотрудник (id=2), назначил Иванов (id=1)
(3, 3, 1);  -- Сидоров (id=3) получает роль Администратор (id=3), назначил Иванов (id=1)

-- Проверочные запросы (закомментированы)
-- SELECT * FROM Users;
-- SELECT * FROM UserProfiles;
-- SELECT * FROM Roles;
-- SELECT * FROM UserRoles;