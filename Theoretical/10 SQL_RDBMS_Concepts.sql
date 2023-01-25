-- SQL 10: RDBMS CONCEPTS

/*
Basic Concepts of Relational Model

Knowing the basic building blocks of the Relational model such as constraints, primary key, and foreign key, 
knowing their properties, and applying them to our data model are the prerequisites of the relational data model.

Relational Data Model Terms

The relational data model was found out by C. F. Codd in 1970. It is one of the most common data models today.

The relational data model describes the universe as “a compound of inter-related relations (or tables).

1. Relation
A relation, also known as a table or file, is a subset of the Cartesian product of a list of domains represented 
by a name. And within a table, each row represents a group of related data values. A row, or record, is also known 
as a tuple. The column in a table is a field and is also referred to as an attribute. In other words, attributes 
is used to define records and every record has a set of attributes.

2. Table

A database contains multiple tables and each table stores the data. Table Properties:

- A table has a unique name.
- There are no duplicate rows.
- Cells and attributes have to be atomic.
- Entries from columns are from the same domain and they should have same data type as following:
        - number (numeric, integer, float, smallint,…)
        - character (string)
        - date
        - logical (true or false)
- Each attribute has a distinct name.

3. Column
A relational database stores different information belonging to a domain in an organized manner.  
Being able to use and manage the database effectively requires an understanding of this organizational method.

The basic storage units are called columns or fields or attributes. These hosts the basic components of data 
into which your content can be broken down. When deciding which attributes was required, we need to think about 
the information data has. For example, drawing out the common components of the information that we will 
store in the database and avoiding the specifics that distinguish one item from another.

4. Domain
Domain refers to the original atomic values that hold the attributes a column can have. An atomic value is no longer 
divisible and expresses a structure that has a meaning on its own. For example:

The domain of Gender has a set of possibilities: Male, Female
The domain of the Month has the set of all possible months: {Jan, Feb, Mar…}.
The domain of Age is the set of all floating-point numbers greater than 0 and less than 150.

5. Relationship
Relationships are bridges that allow tables carrying information in an atomic structure to cling to each other.

6. Record
Records contain fields that are related, such as a customer or a product. As noted earlier, a tuple is another term 
used for the record.

Records and fields form the basis of all databases. A simple table gives us the clearest picture of how records 
and fields work together in a database storage project.

DATATYPES:

check the script number 2

KEY CONSTRAINTS

There are several types of keys, such as Candidate key, Composite key, Primary key (PK), Secondary key, Alternate 
key and Foreign key (FK).

1. Candidate key
A candidate key is a simple or composite key that is unique and minimal.  It is unique because no two rows in a table 
may have the same value at any time. It is minimal because every column is necessary in order to attain uniqueness.

2. Composite key
A composite key is composed of two or more attributes, but it must be minimal.

3. Primary key
The primary key (PK) is a candidate key that is selected by the database designer to be used as an identifying mechanism 
for the whole entity set. It must uniquely identify tuples in a table and not be null. The primary key is indicated 
in the ER model by underlining the attribute.

A primary key is a column or a group of columns that uniquely identifies each row in a table. You create a primary key 
for a table by using the PRIMARY KEY constraint. 

Tips:
- If primary key has two or more columns, we must use the PRIMARY KEY constraint as a table constraint.
- Each table can contain only one primary key.
- SQL Server automatically sets the NOT NULL constraint for all the primary key columns.
- SQL Server also automatically creates a unique clustered index (or a non-clustered index if specified as such) when 
we create a primary key.

4. Secondary key
A secondary key is an attribute used strictly for retrieval purposes (can be composite).

5. Alternate key
Alternate keys are all candidate keys not chosen as the primary key.

6. Foreign key
A foreign key (FK) is an attribute in a table that references the primary key in another table. FK can be null. Both 
foreign and primary keys must be of the same data type.

The FOREIGN KEY (FK) constraint defines a column, or combination of columns, whose values match the PRIMARY KEY (PK) of 
another table.

Values in an FK are automatically updated when the PK values in the associated table are updated/changed.
FK constraints must reference PK or the UNIQUE constraint of another table.
The number of columns for FK must be same as PK or UNIQUE constraint.
If the WITH NOCHECK option is used, the FK constraint will not validate existing data in a table.
No index is created on the columns that participate in an FK constraint.

For example, the field id in the employee table is a FK to the field id in the departments table:*/

CREATE TABLE employee
(
	id BIGINT NOT NULL,
	name VARCHAR(20) NULL,
  CONSTRAINT foreignkey_1 FOREIGN KEY (id) REFERENCES dbo.department(id)
);

/*
RELATIONAL INTEGRITY CONSTRAINTS

Constraints are a very important feature in a relational model. In fact, the relational model supports the well-defined 
theory of constraints on attributes or tables.

Constraints are useful because they allow a designer to specify the semantics of data in the database. Constraints 
are the rules that force DBMSs to check that data satisfies the semantics.

1. Domain Integrity

Domain restricts the values of attributes in the relation and is a constraint of the relational model. However, there 
are real-world semantics for data that cannot be specified if used only with domain constraints.

We need more specific ways to state what data values are or are not allowed and which format is suitable for an 
attribute. For example, the Employee ID (EID) must be unique or the employee Birthdate is in the 
range [Jan 1, 1950, Jan 1, 2000]. Such information is provided in logical statements called integrity constraints.

2.Referential Integrity
Referential integrity requires that a foreign key must have a matching primary key or it must be null. This constraint 
is specified between two tables (parent and child); it maintains the correspondence between rows in these tables.  
It means the reference from a row in one table to another table must be valid.

3. Entity Integrity
To ensure entity integrity, it is required that every table have a primary key. Neither the PK nor any part of it can 
contain null values.

This is because null values for the primary key mean we cannot identify some rows. For example, in the EMPLOYEE table, 
the Phone cannot be a primary key since some people may not have a telephone.

4. Enterprise Constraints
Enterprise constraints – sometimes referred to as semantic constraints – are additional rules specified by users or 
database administrators and can be based on multiple tables. Here are some examples.

- A class can have a maximum of 30 students.
- A teacher can teach a maximum of four classes per semester.
- An employee cannot take part in more than five projects.
- The salary of an employee cannot exceed the salary of the employee’s manager.

5. Business Rules
Business rules are obtained from users when gathering requirements. The requirements-gathering process is very important, 
and its results should be verified by the user before the database design is built. If the business rules are incorrect, 
the design will be incorrect, and ultimately the application built will not function as expected by the users. 
Some examples of business rules are:
- A teacher can teach many students.
- A class can have a maximum of 35 students.
- A course can be taught many times, but by only one instructor.
- Not all teachers teach classes.

TABLE or COLUMN CONSTRAINTS

The Optional Column Constraints are NULL, NOT NULL, UNIQUE, PRIMARY KEY and DEFAULT, used to initialize a value 
for a new record. The column constraint NULL indicates that null values are allowed, which means that a row 
can be created without a value for this column. The column constraint NOT NULL indicates that a value must be 
supplied when a new row is created.

To illustrate, we will use the SQL statement CREATE TABLE departments to create the departments table 
with 7 attributes or fields.*/

CREATE TABLE departments
(
	id BIGINT NOT NULL,
	name VARCHAR(20) NULL,
	dept_name VARCHAR(20) NULL,
	seniority VARCHAR(20) NULL,
	graduation VARCHAR(20) NULL,
	salary BIGINT NULL,
	hire_date DATE NULL,
        CONSTRAINT pk_1 PRIMARY KEY (id)
 ) ;

 /*
- The first field is id with a field type of BIGINT. The user cannot leave this field empty (NOT NULL).
- Similarly, the second field is name with a field type VARCHAR of length 20.
- After all the table columns are defined, a table constraint, identified by the word CONSTRAINT, is used to create 
the primary key:
CONSTRAINT pk_1 PRIMARY KEY(id)

We can use the optional column constraint IDENTITY to provide a unique, incremental value for that column. 
Identity columns are often used with the PRIMARY KEY constraints to serve as the unique row identifier for 
the table. The IDENTITY property can be assigned to a column with a tinyint, smallint, int, decimal, or numeric 
data type. This constraint:

- Generates sequential numbers.
- Does not enforce entity integrity.
- Only one column can have the IDENTITY property.
- Must be defined as an integer, numeric or decimal data type.
- Cannot update a column with the IDENTITY property.
- Cannot contain NULL values.
- Cannot bind defaults and default constraints to the column.

For IDENTITY[(seed, increment)]
- Seed – the initial value of the identity column
- Increment – the value to add to the last increment column

The UNIQUE constraint prevents duplicate values from being entered into a column.

- Both PK and UNIQUE constraints are used to enforce entity integrity.
- Multiple UNIQUE constraints can be defined for a table.
- When a UNIQUE constraint is added to an existing table, the existing data is always validated.
- A UNIQUE constraint can be placed on columns that accept nulls. Only one row can be NULL.
- A UNIQUE constraint automatically creates a unique index on the selected column.

This is an examle using the UNIQUE constraint.
 */
 CREATE TABLE employee
(
id BIGINT NOT NULL UNIQUE
name VARCHAR(20) NOT NULL
);

/*
The CHECK constraint restricts values that can be entered into a table.

- It can contain search conditions similar to a WHERE clause.
- It can reference columns in the same table.
- The data validation rule for a CHECK constraint must evaluate to a boolean expression.
- It can be defined for a column that has a rule bound to it.

This is the general syntax for the CHECK constraint:*/

[CONSTRAINT constraint_name]
CHECK [NOT FOR REPLICATION] (expression)

CREATE TABLE department
(
	id BIGINT NOT NULL,
	name VARCHAR(20) NULL,
	dept_name VARCHAR(20) NULL,
	seniority VARCHAR(20) NULL,
	graduation VARCHAR(20) NULL,
	salary BIGINT NULL,
	hire_date DATE NULL,
        CONSTRAINT pk_1 PRIMARY KEY (id),
        CHECK (salary BETWEEN 40000 AND 100000)
 ) ;

 /*
The DEFAULT constraint is used to supply a value that is automatically added for a column if the user does not supply one.

- A column can have only one DEFAULT.
- The DEFAULT constraint cannot be used on columns with a timestamp data type or identity property.
- DEFAULT constraints are automatically bound to a column when they are created.

The general syntax for the DEFAULT constraint is:*/

[CONSTRAINT constraint_name]
DEFAULT {constant_expression | niladic-function | NULL}
[FOR col_name]

ALTER TABLE departments
ADD CONSTRAINT def_dept_name DEFAULT ‘HR’ FOR dept_name;