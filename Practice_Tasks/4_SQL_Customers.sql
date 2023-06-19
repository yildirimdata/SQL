-- SQL ASSIGNMENT 4

/*
Charlie's Chocolate Factory company produces chocolates. The following product information is stored: product name, 
product ID, and quantity on hand. These chocolates are made up of many components. Each component can be supplied by 
one or more suppliers. The following component information is kept: component ID, name, description, quantity on hand, 
suppliers who supply them, when and how much they supplied, and products in which they are used. On the other hand 
following supplier information is stored: supplier ID, name, and activation status.

Assumptions

A supplier can exist without providing components.
A component does not have to be associated with a supplier. It may already have been in the inventory.
A component does not have to be associated with a product. Not all components are used in products.
A product cannot exist without components. 

Do the following exercises, using the data model.

     a) Create a database named "Manufacturer"
     b) Create the tables in the database.
     c) Define table constraints.
*/
-- a) creating the database:

CREATE DATABASE Manufacturer;

-- b) creating the tables:

CREATE TABLE Product (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(255),
  quantity_on_hand INT
);

CREATE TABLE Component (
  component_id INT PRIMARY KEY,
  component_name VARCHAR(255),
  description VARCHAR(255),
  quantity_on_hand INT
);

CREATE TABLE Supplier (
  supplier_id INT PRIMARY KEY,
  supplier_name NVARCHAR(255),
  activation_status VARCHAR(255)
);

CREATE TABLE Component_supplier (
  component_id INT,
  supplier_id INT,
  supply_date DATE,
  supplied_amount INT,
  FOREIGN KEY (component_id) REFERENCES Component(component_id),
  FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

CREATE TABLE Product_component (
  product_id INT,
  component_id INT,
  FOREIGN KEY (product_id) REFERENCES Product(product_id),
  FOREIGN KEY (component_id) REFERENCES Component(component_id)
);

-- c) Define table constraints:

ALTER TABLE Component
  ADD CONSTRAINT component_quantity_on_hand CHECK (quantity_on_hand >= 0);

ALTER TABLE Supplier
  ADD CONSTRAINT supplier_status CHECK (activation_status IN ('active', 'inactive'));

ALTER TABLE Component_supplier
  ADD CONSTRAINT supplied_amount_check CHECK (supplied_amount >= 0);