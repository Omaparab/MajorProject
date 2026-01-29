create schema db;

use db;

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) CHECK (role IN ('auditor', 'reviewer')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE nl_query_history (
    history_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    query_text TEXT,
    session_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE query_sessions (
    session_id VARCHAR(100) PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP
);

CREATE TABLE generated_sql (
    sql_id SERIAL PRIMARY KEY,
    history_id INT REFERENCES nl_query_history(history_id),
    sql_text TEXT,
    is_valid BOOLEAN,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    executed BOOLEAN DEFAULT FALSE
);

CREATE TABLE sql_approvals (
    approval_id SERIAL PRIMARY KEY,
    sql_id INT REFERENCES generated_sql(sql_id),
    user_id INT REFERENCES users(user_id),
    approval_status VARCHAR(20)
        CHECK (approval_status IN ('approved', 'rejected', 'pending')),
    approved_at TIMESTAMP
);

CREATE TABLE audit_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    history_id INT REFERENCES nl_query_history(history_id),
    generated_sql TEXT,
    approval_status VARCHAR(20),
    execution_status VARCHAR(20),
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE uploaded_files (
    file_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    file_name VARCHAR(255),
    file_type VARCHAR(20),   -- excel / json
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE datasets (
    dataset_id SERIAL PRIMARY KEY,
    file_id INT REFERENCES uploaded_files(file_id),
    dataset_name VARCHAR(100),
    table_name VARCHAR(100),   -- PostgreSQL table created
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dataset_schema (
    schema_id SERIAL PRIMARY KEY,
    dataset_id INT REFERENCES datasets(dataset_id),
    column_name VARCHAR(100),
    data_type VARCHAR(50)
);

CREATE TABLE feedback (
    feedback_id SERIAL PRIMARY KEY,
    history_id INT REFERENCES nl_query_history(history_id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE performance_metrics (
    metric_id SERIAL PRIMARY KEY,
    exact_match_accuracy FLOAT,
    logical_accuracy FLOAT,
    execution_accuracy FLOAT,
    precision_score FLOAT,
    recall_score FLOAT,
    f1_score FLOAT,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);