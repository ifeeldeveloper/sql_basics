DROP TABLE IF EXISTS employee cascade;
DROP TABLE IF EXISTS customer cascade;
DROP TABLE IF EXISTS product cascade;
DROP TABLE IF EXISTS transaction cascade;


CREATE TABLE employee (	
    id SERIAL PRIMARY KEY,  -- Auto-increment ID for employee
    first_name VARCHAR(50) NOT NULL,  -- First name is required
    last_name VARCHAR(50) NOT NULL,   -- Last name is required
    email VARCHAR(100),  -- Email address (optional)
    department VARCHAR(20) CHECK (department IN ('HR', 'Cashier', 'Cleansing', 'Security', 'Inventory')), -- Pre-defined values
    supervisor_id INT REFERENCES employee(id),  -- Refer back to same employee table
    mobile_number VARCHAR(10) CHECK (LENGTH(mobile_number) = 10), -- Exactly 10 digits
    is_active BOOLEAN,
    hire_date DATE DEFAULT NOW(),  -- DEFAULT to current value if not given
    salary DECIMAL(10,2) CHECK (salary >= 0)
);


CREATE TABLE customer (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    mobile_number VARCHAR(10) UNIQUE CHECK (LENGTH(mobile_number) = 10),
    address VARCHAR(200),
    created_at DATE DEFAULT NOW(),
	is_staff BOOLEAN
);


CREATE TABLE product (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) CHECK (unit_price >= 0),
    stock INT CHECK (stock >= 0),
	brand_name VARCHAR(100) NOT NULL
);

CREATE TABLE transaction (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer(id),
    employee_id INT REFERENCES employee(id),
    product_id INT REFERENCES product(id),
    transaction_date TIMESTAMP DEFAULT NOW(),
    quantity INT CHECK (quantity > 0),
    discount_amount DECIMAL(10,2),
	reward_point DECIMAL(10,2) DEFAULT 0
);