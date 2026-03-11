
-- таблица пользователей
CREATE TABLE Users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    snils VARCHAR(14) UNIQUE NOT NULL,
    inn VARCHAR(12) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- таблица профилей пользователей
CREATE TABLE UserProfiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    birth_date DATE NOT NULL,
    sex CHAR(1),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    passport_series VARCHAR(4),
    passport_number VARCHAR(6),
    registration_address TEXT
);

-- таблица ролей
CREATE TABLE Roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- таблица связи пользователей и ролей 
CREATE TABLE UserRoles (
    user_id INTEGER REFERENCES Users(id) ON DELETE CASCADE,  
    role_id INTEGER REFERENCES Roles(id) ON DELETE CASCADE,  
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,         
    assigned_by INTEGER REFERENCES Users(id),                
    PRIMARY KEY (user_id, role_id)                           
);

-- таблица с каталогом услуг
CREATE TABLE Services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    department VARCHAR(200),
    price DECIMAL(10, 2) DEFAULT 0 CHECK (price >= 0),
    processing_days INTEGER CHECK (processing_days > 0),
    is_available BOOLEAN DEFAULT true
);

-- таблица заявлений 
CREATE TABLE Applications (
    id SERIAL PRIMARY KEY,
    application_number VARCHAR(20) UNIQUE,  -- публичный номер заявления
    user_id INTEGER NOT NULL REFERENCES Users(id),
    services_id INTEGER NOT NULL REFERENCES Services(id),
    status VARCHAR(20) DEFAULT 'pending' 
        CHECK (status IN ('pending', 'processing', 'completed', 'rejected', 'cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    form_data JSONB,  -- данные формы в свободном формате
    rejection_reason TEXT
);

-- функция генерации номера заявления
CREATE OR REPLACE FUNCTION generate_application_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.application_number = 'GSU-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(NEW.id::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- триггер, автоматически вызывает функцию при вставке
CREATE TRIGGER trg_generate_application_number
    BEFORE INSERT ON Applications
    FOR EACH ROW
    EXECUTE FUNCTION generate_application_number();

-- таблица истории статусов
CREATE TABLE ApplicationHistory (
    id SERIAL PRIMARY KEY,
    application_id INTEGER NOT NULL REFERENCES Applications(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'processing', 'completed', 'rejected', 'cancelled')),
    changed_by INTEGER REFERENCES Users(id),
    comment TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- индексы для ускорения
CREATE INDEX idx_applications_status ON Applications(status);
CREATE INDEX idx_applications_user_id ON Applications(user_id);
CREATE INDEX idx_application_history_app_id ON ApplicationHistory(application_id);

-- представление для удобного просмотра заявлений
CREATE VIEW vApplicationsDetails AS
SELECT 
    a.application_number,
    u.username AS user_login,
    up.last_name || ' ' || up.first_name AS user_name,
    s.name AS services_name,
    a.status,
    a.created_at,
    a.completed_at
FROM Applications a
JOIN Users u ON a.user_id = u.id
JOIN UserProfiles up ON u.id = up.user_id
JOIN Services s ON a.services_id = s.id;