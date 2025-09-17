-- =====================================================================
-- SQL code for "Online Food Delivery System (OFDS)"
-- Student-1: 251231038
-- Student-2: 231465038
-- =====================================================================

-- ********************************************************************************
-- Section 1: DDL (Data Definition Language) - Table Creation with Constraints
-- ********************************************************************************

-- Creating "System_User" Table: Stores user account information
CREATE TABLE System_User (
    System_User_id VARCHAR2(50) CONSTRAINT pk_system_user PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    email VARCHAR2(100) NOT NULL UNIQUE,
    password VARCHAR2(100) NOT NULL,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    user_group VARCHAR2(20) CONSTRAINT chk_user_group CHECK (user_group IN ('customer', 'admin', 'restaurant')),
    reg_date DATE DEFAULT SYSDATE NOT NULL
);

-- Creating "System_User_phoneNumbers" Table (for multi-valued attribute): Stores user phone numbers
CREATE TABLE System_User_phoneNumbers (
    System_User_id VARCHAR2(50) NOT NULL,
    phone_number VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_user_phone PRIMARY KEY (System_User_id, phone_number),
    CONSTRAINT fk_user_phone_user FOREIGN KEY (System_User_id) REFERENCES System_User(System_User_id) ON DELETE CASCADE
);

-- Creating "Customer" Table: Stores information specific to customers
CREATE TABLE Customer (
    Customer_id VARCHAR2(50) CONSTRAINT pk_customer PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    System_User_id VARCHAR2(50) NOT NULL UNIQUE,
    CONSTRAINT fk_customer_system_user FOREIGN KEY (System_User_id) REFERENCES System_User(System_User_id) ON DELETE CASCADE
);

-- Creating "System_Admin" Table: Stores system administrator details
CREATE TABLE System_Admin (
    System_Admin_id VARCHAR2(50) CONSTRAINT pk_system_admin PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    admin_mail VARCHAR2(100) NOT NULL UNIQUE,
    contact01 VARCHAR2(20),
    contact02 VARCHAR2(20)
);

-- Creating "Payment_gateway" Table: Stores payment transactions
CREATE TABLE Payment_gateway (
    payment_id VARCHAR2(50) CONSTRAINT pk_payment_gateway PRIMARY KEY,
    total_amount_to_be_paid NUMBER(10,2) NOT NULL CHECK (total_amount_to_be_paid >= 0),
    payment_status VARCHAR2(20) NOT NULL CONSTRAINT chk_payment_status CHECK (payment_status IN ('Pending', 'Completed', 'Failed')),
    payment_date DATE
);

-- Creating "Payment_gateway_Methods" Table (for multi-valued attribute): Multiple payment methods
CREATE TABLE Payment_gateway_Methods (
    payment_id VARCHAR2(50) NOT NULL,
    payment_method VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_payment_methods PRIMARY KEY (payment_id, payment_method),
    CONSTRAINT fk_pm_payment FOREIGN KEY (payment_id) REFERENCES Payment_gateway(payment_id) ON DELETE CASCADE
);

-- Creating "Delivery_info" Table: Stores delivery details
CREATE TABLE Delivery_info (
    Delivery_info_id VARCHAR2(50) CONSTRAINT pk_delivery_info PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    total_quantity INT NOT NULL CHECK (total_quantity > 0),
    total_price NUMBER(10,2) NOT NULL CHECK (total_price >= 0),
    destination_address VARCHAR2(200) NOT NULL,
    delivery_agent_info VARCHAR2(100) NOT NULL,
    required_time TIMESTAMP NOT NULL,
    delivery_status VARCHAR2(50) DEFAULT 'Order Placed' CONSTRAINT chk_delivery_status CHECK (delivery_status IN ('Order Placed', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled')),
    confirmation_date TIMESTAMP,
    payment_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_delivery_payment FOREIGN KEY (payment_id) REFERENCES Payment_gateway(payment_id) ON DELETE CASCADE
);

-- Creating "Delivery_info_phoneNumbers" Table (for multi-valued attribute): Delivery contact numbers
CREATE TABLE Delivery_info_phoneNumbers (
    Delivery_info_id VARCHAR2(50) NOT NULL,
    phone_number VARCHAR2(20) NOT NULL,
    PRIMARY KEY (Delivery_info_id, phone_number),
    FOREIGN KEY (Delivery_info_id) REFERENCES Delivery_info(Delivery_info_id) ON DELETE CASCADE
);

-- Creating "Orders" Table: Represents an order header placed by a customer
CREATE TABLE Orders (
    Order_id VARCHAR2(50) CONSTRAINT pk_orders PRIMARY KEY,
    quantity INT NOT NULL CHECK (quantity > 0),
    price NUMBER(10,2) NOT NULL CHECK (price >= 0),
    Customer_id VARCHAR2(50) NOT NULL,
    Delivery_info_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_orders_customer FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_orders_delivery FOREIGN KEY (Delivery_info_id) REFERENCES Delivery_info(Delivery_info_id) ON DELETE CASCADE
);

-- Creating "Customer_message" Table: Stores customer support messages and replies from admins
CREATE TABLE Customer_message (
    Customer_message_id VARCHAR2(50) CONSTRAINT pk_customer_message PRIMARY KEY,
    sent_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    email VARCHAR2(100) NOT NULL,
    message CLOB NOT NULL,
    reply_message CLOB,
    System_Admin_id VARCHAR2(50) NOT NULL,
    Customer_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_message_admin FOREIGN KEY (System_Admin_id) REFERENCES System_Admin(System_Admin_id) ON DELETE CASCADE,
    CONSTRAINT fk_message_customer FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id) ON DELETE CASCADE
);

-- Creating "Customer_message_phoneNumbers" Table: Contact numbers associated with a customer message
CREATE TABLE Customer_message_phoneNumbers (
    Customer_message_id VARCHAR2(50) NOT NULL,
    phone_number VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_message_phone PRIMARY KEY (Customer_message_id, phone_number),
    CONSTRAINT fk_msg_phone_msg FOREIGN KEY (Customer_message_id) REFERENCES Customer_message(Customer_message_id) ON DELETE CASCADE
);

-- Creating "Food_items" Table: Stores details of individual food items
CREATE TABLE Food_items (
    Food_id VARCHAR2(50) CONSTRAINT pk_food_items PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    price NUMBER(10,2) NOT NULL CHECK (price >= 0),
    add_date DATE DEFAULT SYSDATE NOT NULL,
    description VARCHAR2(500)
);

-- Creating "Restaurants" Table: Stores restaurants information on the platform
CREATE TABLE Restaurants (
    Restaurant_id VARCHAR2(50) CONSTRAINT pk_restaurants PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    reg_date DATE DEFAULT SYSDATE NOT NULL,
    description VARCHAR2(500)
);

-- Creating "Food_Restaurants" Table: Represents the menu, linking food items to specific restaurants with a price (Restaurant-Food mapping)
CREATE TABLE Food_Restaurants (
    Food_Restaurants_id VARCHAR2(50) CONSTRAINT pk_food_restaurants PRIMARY KEY,
    food_name VARCHAR2(100) NOT NULL,
    restaurant_name VARCHAR2(100) NOT NULL,
    price NUMBER(10,2) NOT NULL CHECK (price >= 0),
    Food_id VARCHAR2(50) NOT NULL,
    Restaurant_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_fr_food FOREIGN KEY (Food_id) REFERENCES Food_items(Food_id) ON DELETE CASCADE,
    CONSTRAINT fk_fr_restaurant FOREIGN KEY (Restaurant_id) REFERENCES Restaurants(Restaurant_id) ON DELETE CASCADE
);

-- Creating "contains" Table: Junction table linking items from menus (Food_Restaurants) to a specific (Orders)
CREATE TABLE contains (
    Order_id VARCHAR2(50) NOT NULL,
    Food_Restaurants_id VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_contains PRIMARY KEY (Order_id, Food_Restaurants_id),
    CONSTRAINT fk_contains_order FOREIGN KEY (Order_id) REFERENCES Orders(Order_id) ON DELETE CASCADE,
    CONSTRAINT fk_contains_fr FOREIGN KEY (Food_Restaurants_id) REFERENCES Food_Restaurants(Food_Restaurants_id) ON DELETE CASCADE
);

-- **********************************************************
-- Section 2: Triggers for Business Rules
-- **********************************************************

-- Trigger 1: Auto-set payment_date when status changes to 'Completed'
CREATE OR REPLACE TRIGGER trg_payment_completed
BEFORE UPDATE OF payment_status ON Payment_gateway
FOR EACH ROW
WHEN (NEW.payment_status = 'Completed' AND OLD.payment_status != 'Completed')
BEGIN
    :NEW.payment_date := SYSTIMESTAMP;
END;
/

-- Trigger 2: Auto-update delivery confirmation timestamp when delivery is marked as 'Delivered'
CREATE OR REPLACE TRIGGER trg_delivery_confirmed
BEFORE UPDATE OF delivery_status ON Delivery_info
FOR EACH ROW
WHEN (NEW.delivery_status = 'Delivered' AND OLD.delivery_status != 'Delivered')
BEGIN
    :NEW.confirmation_date := SYSTIMESTAMP;
END;
/

-- ***************************************************************
-- Section 3: DML (Data Manipulation Language) - Arbitrary Data
-- ***************************************************************

-- Insert System users
INSERT INTO System_User VALUES (
    'usr_001', 'john_doe', 'john@example.com', 'securepass123', 'John', 'Doe', 'customer', SYSDATE
);
INSERT INTO System_User VALUES (
    'usr_002', 'jane_smith', 'jane@example.com', 'pass456', 'Jane', 'Smith', 'customer', SYSDATE
);

-- Insert Customers
INSERT INTO Customer VALUES (
    'cust_001', 'John Doe', 'usr_001'
);
INSERT INTO Customer VALUES (
    'cust_002', 'Jane Smith', 'usr_002'
);

-- Insert Admin
INSERT INTO System_Admin VALUES (
    'admin_001', 'Admin User', 'admin@foodapp.com', '+1234567890', '+0987654321'
);

-- Insert Payment gateway
INSERT INTO Payment_gateway VALUES (
    'pay_001', 25.99, 'Pending', NULL
);
INSERT INTO Payment_gateway VALUES (
    'pay_002', 46.54, 'Completed', SYSDATE
);

-- Insert Payment methods
INSERT INTO Payment_gateway_Methods VALUES (
    'pay_001', 'Credit Card'
);

INSERT INTO Payment_gateway_Methods VALUES (
    'pay_002', 'Cash on Delivery'
);

-- Insert Delivery info
INSERT INTO Delivery_info VALUES (
    'deliv_001', 'John Doe', 2, 25.99, '123 Maple Street, Anytown', 'Agent_007', 
    SYSTIMESTAMP + INTERVAL '1' HOUR, 'Preparing', NULL, 'pay_001'
);
INSERT INTO Delivery_info VALUES (
    'deliv_002', 'Jane Smith', 3, 46.54, '234 Main Street, Gulshan', 'Agent_007', 
    SYSTIMESTAMP + INTERVAL '1' HOUR, 'Out for Delivery', SYSDATE, 'pay_002'
);

-- Insert Orders
INSERT INTO Orders VALUES (
    'ord_001', 2, 25.99, 'cust_001', 'deliv_001'
);
INSERT INTO Orders VALUES (
    'ord_002', 3, 46.54, 'cust_002', 'deliv_002'
);

-- Insert Food items
INSERT INTO Food_items VALUES (
    'food_001', 'Margherita Pizza', 12.99, SYSDATE, 'Classic cheese pizza'
);
INSERT INTO Food_items VALUES (
    'food_002', 'Classic Beef Burger', 9.99, SYSDATE, 'Juicy beef patty with fresh vegetables'
);
INSERT INTO Food_items VALUES (
    'food_003', 'Fries', 3.99, SYSDATE, 'Crispy golden fries'
);

-- Insert Restaurants
INSERT INTO Restaurants VALUES (
    'rest_001', 'Pizza Heaven', SYSDATE, 'Best pizza in town'
);
INSERT INTO Restaurants VALUES (
    'rest_002', 'Burger Barn', SYSDATE, 'Gourmet Burgers and Fries'
);

-- Insert Food-Restaurant mapping
INSERT INTO Food_Restaurants VALUES (
    'fr_001', 'Margherita Pizza', 'Pizza Heaven', 12.99, 'food_001', 'rest_001'
);
INSERT INTO Food_Restaurants VALUES (
    'fr_002', 'Classic Beef Burger', 'Burger Barn', 9.99, 'food_002', 'rest_002'
);
INSERT INTO Food_Restaurants VALUES (
    'fr_003', 'Fries', 'Burger Barn', 3.99, 'food_003', 'rest_002'
);

-- Insert Order-food "contains" relationship
INSERT INTO contains VALUES (
    'ord_001', 'fr_001'
);
INSERT INTO contains VALUES (
    'ord_002', 'fr_002'
);

-- Update payment status to test trigger
UPDATE Payment_gateway SET payment_status = 'Completed' WHERE payment_id = 'pay_001';

-- Update delivery status to test trigger
UPDATE Delivery_info SET delivery_status = 'Delivered' WHERE Delivery_info_id = 'deliv_001';

COMMIT;

-- **********************************************************
-- Section 4: Verification Queries
-- **********************************************************

-- Verify payment_date was set by trigger
SELECT payment_id, payment_status, payment_date 
FROM Payment_gateway 
WHERE payment_id = 'pay_001';

-- Verify delivery confirmation timestamp
SELECT Delivery_info_id, delivery_status, confirmation_date 
FROM Delivery_info 
WHERE Delivery_info_id = 'deliv_001';

-- Get all Pending orders
SELECT * FROM Orders WHERE Delivery_info_id IN (
    SELECT Delivery_info_id FROM Delivery_info WHERE delivery_status = 'Preparing'
);
