CREATE TABLE IF NOT EXISTS customers (
    id int PRIMARY KEY AUTO_INCREMENT,
    full_name varchar(255) NOT NULL,
    email varchar(255) NOT NULL UNIQUE,
    gender varchar(10) NOT NULL,
    birth_date timestamp NOT NULL,
    CONSTRAINT chk_gender CHECK (gender IN ('Male', 'Female', 'Other'))
);

CREATE TABLE IF NOT EXISTS categories (
    id int PRIMARY KEY AUTO_INCREMENT,
    name varchar(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS products (
    id int PRIMARY KEY AUTO_INCREMENT,
    name varchar(255) NOT NULL UNIQUE,
    price decimal(15, 2) NOT NULL,
    category_id int NOT NULL,
    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS orders (
    id int PRIMARY KEY AUTO_INCREMENT,
    customer_id int NOT NULL,
    order_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS order_details (
    order_id int NOT NULL,
    product_id int NOT NULL,
    quantity int NOT NULL,
    price decimal(15, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);

-- 1. Categories
INSERT INTO categories (name)
VALUES
    ('Electronics'),
    ('Fashion'),
    ('Books'),
    ('Home Appliances');

-- 2. Products (Electronics có 3 sp để thỏa HAVING >= 2)
INSERT INTO products (name, price, category_id)
VALUES
    ('iPhone 15 Pro', 30000000, 1),
    ('Macbook M3', 45000000, 1),
    ('Mouse Logitech', 1200000, 1),
    ('T-Shirt Prime', 500000, 2),
    ('Jean Jacket', 1500000, 2),
    ('SQL Cookbook', 800000, 3),
    ('Air Fryer', 3200000, 4);

-- 3. Customers (Người trẻ, người già, và người chưa mua hàng)
INSERT INTO customers (full_name, email, gender, birth_date)
VALUES
    ('Nguyen Van An', 'an@gmail.com', 'Male', '2005-05-20'),
    ('Tran Thi Mai', 'mai@gmail.com', 'Female', '2004-10-15'),
    ('Le Hoang Nam', 'nam@gmail.com', 'Male', '2006-01-01'), -- Trẻ nhất
    ('Pham Thu Ha', 'ha@gmail.com', 'Female', '1990-03-12'),
    ('Ghost User', 'ghost@gmail.com', 'Other', '1995-12-12');

-- Khách chưa mua hàng
-- 4. Orders
INSERT INTO orders (customer_id, order_date)
VALUES
    (1, '2026-05-01 10:00:00'),
    (2, '2026-05-02 11:00:00'),
    (3, '2026-05-03 12:00:00'),
    (4, '2026-05-04 09:00:00');

-- 5. Order Details
INSERT INTO order_details (order_id, product_id, quantity, price)
VALUES
    (1, 1, 1, 30000000),
    (1, 3, 2, 2400000), -- Đơn 1 mua Electronics
    (2, 4, 1, 500000),
    (3, 1, 1, 30000000), -- Đơn 3 mua Electronics
    (4, 6, 1, 800000);

-- Phần 3 - Cạp nhật
-- Cập nhật giá sản phẩm
UPDATE
    products
SET
    price = 31000000
WHERE
    name = 'iPhone 15 Pro';

-- Cập nhật email khách hàng
UPDATE
    customers
SET
    email = 'an_new_2026@gmail.com'
WHERE
    full_name = 'Nguyen Van An';

-- Phần 4 - Xoá dữ liệu
DELETE FROM orders
WHERE id = 4;

-- Phần 5 - Truy vấn dữ liệu
-- Câu 1.
SELECT
    full_name AS 'Họ tên',
    email AS 'Email',
    CASE WHEN gender = 'Male' THEN
        'Nam'
    WHEN gender = 'Female' THEN
        'Nữ'
    ELSE
        'Khác'
    END AS 'Giới tính'
FROM
    customers;

-- Câu 2
SELECT
    full_name,
    email,
    (YEAR (NOW()) - YEAR (birth_date)) AS age
FROM
    customers
ORDER BY
    birth_date DESC
LIMIT 3;

-- Câu 3 ( cách 1 )
SELECT
    o.*,
    c.full_name
FROM
    orders o
    INNER JOIN customers c ON c.id = o.customer_id;

-- Câu 3 ( cách 2 )
SELECT
    o.*,
    (
        SELECT
            c.full_name
        FROM
            customers c
        WHERE
            o.customer_id = c.id) AS full_name
FROM
    orders o;

-- Câu 4 ( cách 1 )
SELECT
    c.name,
    count(p.id) AS quantity
FROM
    categories c
    INNER JOIN products p ON c.id = p.category_id
GROUP BY
    c.name
HAVING
    quantity >= 2;

-- Câu 4 ( cách 2 )
SELECT
    c.name,
    (
        SELECT
            count(p.id)
        FROM
            products p
        WHERE
            p.category_id = c.id) AS quantity
FROM
    categories c;

-- Câu 5
SELECT
    p.*
FROM
    products p
WHERE (price > (
        SELECT
            avg(price)
        FROM
            products));

-- Câu 6 ( cách 1 )
SELECT
    c.*
FROM
    customers c
WHERE
    c.id NOT IN (
        SELECT
            o.customer_id
        FROM
            orders o
        GROUP BY
            o.customer_id);

-- Câu 6 ( cách 2 )
SELECT
    c.*
FROM
    customers c
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            orders o
        WHERE
            o.customer_id = c.id);

-- Câu 7
SELECT
    c.name,
    sum(od.price) AS revenue
FROM
    order_details od
    INNER JOIN products p ON od.product_id = p.id
    INNER JOIN categories c ON p.category_id = c.id
GROUP BY
    c.name
HAVING
    revenue > ((
        SELECT
            avg(od.price)
        FROM order_details od) * 1.2);

-- Câu 8 ( cách 1 )
SELECT
    *
FROM
    products p
WHERE
    price = (
        SELECT
            max(price)
        FROM
            products
        WHERE
            category_id = p.category_id);

-- Câu 8 ( cách 2 )
SELECT
    p.*
FROM
    products p
    JOIN (
        SELECT
            category_id,
            max(price) AS max_price
        FROM
            products
        GROUP BY
            category_id) ht ON p.category_id = ht.category_id
    AND p.price = ht.max_price;

-- Phần 5 câu 9 cách 1
SELECT
    *
FROM
    customers
WHERE
    id IN (
        SELECT
            customer_id
        FROM
            orders
        WHERE
            id IN (
                SELECT
                    od.order_id
                FROM
                    order_details od
                WHERE
                    product_id IN (
                        SELECT
                            p.id
                        FROM
                            products p
                        WHERE
                            category_id IN (
                                SELECT
                                    c.id
                                FROM
                                    categories c
                                WHERE
                                    name = 'Electronics'))));

-- Phần 5 câu 9 cách 2
SELECT
    c.full_name
FROM
    customers c
    INNER JOIN orders o ON c.id = o.customer_id
    INNER JOIN order_details od ON o.id = od.order_id
    INNER JOIN products p ON od.product_id = p.id
    INNER JOIN categories cat ON p.category_id = cat.id
WHERE
    cat.name = 'Electronics'
GROUP BY
    c.full_name;