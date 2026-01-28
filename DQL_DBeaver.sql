-- SQL Basic Exercises
-- 1.  Get first_name, last_name, phone & address of all customer & export as csv

select * from customer;

-- 2. List all the products with price greater than 500

select * 
from product
where unit_price > 500;

-- 3. List all the transaction that happen in month of June, 2025

select * 
from transaction
where 
	transaction_date >= '2025-06-01' and 
	transaction_date < '2025-07-01';

--or 
select * 
from transaction
where 
	transaction_date >= date '2025-06-01' and 
	transaction_date < date '2025-07-01';
	
--or 
select * 
from transaction
where 
	transaction_date >= '2025-06-01' :: timestamp
and transaction_date <  '2025-07-01' :: timestamp;

--4. List Name, Address, Email of customer from Kathmandu / Pokhara. If there is
--no email of customer, you have to display ‘-’. Sort result by name & address

select 
	concat(first_name, ' ', last_name) as customer_name,
	address,
	coalesce(email, '-') as email
from customer
where 
	address in ('Kathmandu', 'Pokhara')
order by concat(first_name, ' ', last_name), address;

--5. List HR employees who have already resigned from the mart

select * 
from employee
where department = 'HR' and is_active = false;

-- 6. List first three customer matching your lecturer's name ordered by last name

select * 
from customer
where first_name = 'Rabindra'
order by last_name
limit 3;

-- 7. Find top 5 expensive product. Exclude brands ElectroVision, BeanBrew

select * 
from product
where brand_name not in ('ElectroVision', 'BeanBrew')
order by unit_price desc
limit 5;

-- 8. List customer who uses Gmail

select * 
from customer 
where email is not null and email like '%gmail%';

-- 9. Show all the unique locations where customer reside

select distinct address from customer; 

-- 10.  Find the customer from Rasuwa who don’t have email address

select * 
from customer 
where address = 'Rasuwa' and email is null;

-- 11. Find the employee who don’t have supervisor

select * 
from employee 
where supervisor_id is null;

-- 12. Find Name, Email and Phone number of customer from Dhangadi.

select 
	concat(first_name, ' ', last_name) as customer_name,
	email,
	mobile_number
from customer 
where address = 'Dhangadi'

-- 13. Find Name, Department of top 10 highest paid employee

select 
	concat(first_name, ' ', last_name) as customer_name,
	department,
	salary
from employee
order by salary desc
limit 10;

-- 14. Get top 10 product that are low in stock excluding brand ComfortSit

select * 
from product
where brand_name <> 'ComfortSit'
order by stock
limit 10;

-- 15. Find customer whose number doesn’t start with 98

select * from customer
where mobile_number not like '98%';


-- Intermediate SQL Exercises

--1. Get the total number of customers.

select count(*) from customer;
--or
select count(id) from customer;


-- 2. Find total expenditure on salary by mart on 3 month.

select sum(salary) total_expenditure
from employee
where hire_date between '2025-03-01' and '2025-04-01';

-- 3. Total total number of customer on each city.

select count(id) total_customer, address
from customer
group by address;


-- validating total customers Using SubQuery
select sum(total_customer)
from (
select count(id) total_customer, address
from customer
group by address);

-- 4. Find the total transaction amount and monetory value handled by each
--employee for july

select 
	e.id,
	concat(e.first_name, ' ', e.last_name) employee_name,
	count(t.id) as total_txn_amount,
	sum(quantity * unit_price) monetory_value	
from transaction t
inner join product p 
on p.id = t.product_id
inner join employee e
on e.id = t.employee_id
where t.transaction_date >= '2025-07-01' and t.transaction_date < '2025-08-01'
group by e.id
order by sum(quantity * unit_price) desc;


-- 5. Calculate the average salary of employees in each department.

select 
	department,
	round(avg(salary), 2) avg_salary
from employee
group by department
order by round(avg(salary), 2) desc;

-- 6. Find employee that gets second highest salary

select *
from employee
order by salary desc
offset 1
limit 1

--

select * 
from employee
where salary = (
select distinct	salary
from employee
order by salary desc
offset 1
limit 1
)

-- 7. For each product, find total transaction, total item sold, txn amount
-- (without discount) & total discount.

select 
	p.id,
	p.name,
	p.brand_name,
	count(t.id) as total_transactions,
	sum(t.quantity) as total_item_sold,
	sum((t.quantity * p.unit_price) -t.discount_amount) as txn_amount,
	sum(t.discount_amount) as total_discount
from product p 
join transaction t
on p.id = t.product_id
group by p.id
order by p.id;


-- 8. Show customer name, product name, cashier name and quantity for
-- each transaction done by user of kathmandu after 2025.

select 
	c.id as cId,
	concat(c.first_name, ' ', c.last_name) as customer_name,
	p.name as product_name,
	concat(e.first_name, ' ', e.last_name) as cashier_name,
	t.quantity as quantity_transacted
from customer c 
inner join transaction t
on c.id = t.customer_id
inner join product p 
on p.id = t.product_id
inner join employee e 
on e.id = t.employee_id
where c.address = 'Kathmandu' and t.transaction_date >= '2025-01-01'
order by t.transaction_date;


-- 9. Find the total discount amount given per customer.

select 
	c.id as cId,
	concat(c.first_name, ' ', c.last_name) as customer_name,
	sum(t.discount_amount) total_discount_amount
from customer c 
inner join transaction t
on c.id = t.customer_id
group by c.id
order by c.id;

-- 10. Find customers who have made more than 20 transactions.

select 
	c.id,
	concat(c.first_name, ' ', c.last_name) customer_name,
	count(t.id) as total_transactions
from customer c 
inner join transaction t
on c.id = t.customer_id
group by c.id
having count(t.id) > 20
order by c.id;

-- 11. List employees who haven’t handled any transaction.

select *
from employee e 
left join transaction t
on e.id = t.employee_id
where t.id is null
order by e.id; 

-- 12. Show the employee who handled the highest number of transactions.

select 
	e.id,
	concat(e.first_name, ' ', e.last_name) customer_name,
	count(t.id) as highest_transaction
from employee e 
inner join transaction t
on e.id = t.employee_id
group by e.id
order by count(t.id) desc
limit 1;

-- 13. Find products that were never sold.

select *
from product p
left join transaction t
on p.id = t.product_id
where t.id is null
order by p.id;


-- 14. List transactions where the discount was more than 50% of the product's
-- unit price.

select 
	t.id,
	t.discount_amount,
	p.unit_price
from transaction t
inner join product p
on p.id = t.product_id
where t.discount_amount > p.unit_price * 0.50;


-- 15. Find the first transaction date for each customer.

select 
	c.id,
	concat(c.first_name, ' ', c.last_name) customer_name,
	min(t.transaction_date) first_transaction
from customer c
inner join transaction t
on c.id = t.customer_id
group by c.id
order by c.id;

-- 16. Find the top 3 customers based on total reward points.

select 
	c.id,
	concat(first_name, ' ', c.last_name) customer_name,
	sum(t.reward_point) as total_reward_points
from customer c 
inner join transaction t
on c.id = t.customer_id
group by c.id
order by sum(t.reward_point) desc
limit 3;


-- 17.  Find customers whose first transaction happened before registration.

select 
	c.id,
	concat(c.first_name, ' ', c.last_name) customer_name,
	c.created_at as registered_date,
	min(t.transaction_date)	first_transaction
from customer c 
inner join transaction t
on c.id = t.customer_id
group by c.id
having c.created_at > min(t.transaction_date)
order by c.id;

-- 18. List customers who purchased the same product more than once.

select c.id,
	concat(c.first_name, ' ', c.last_name) customer_name,
	p.name,
	p.brand_name,
	count(t.id)	as times_buyed
from customer c
inner join transaction t
on c.id = t.customer_id
inner join product p 
on p.id = t.product_id
group by c.id, p.name, p.brand_name
having count(t.id) > 1
order by c.id;

-- 19. Find average spending per customer.

select 
	c.id,
	concat(c.first_name, ' ', c.last_name) customer_name,
	round(avg((t.quantity * p.unit_price ) - t.discount_amount), 2) as avg_spending
from customer c 
inner join transaction t
on c.id = t.customer_id
inner join product p
on p.id = t.product_id
group by c.id
order by round(avg((t.quantity * p.unit_price ) - t.discount_amount), 2) desc;


-- 20. List employee name and their manager's name

select 	
	concat(e.first_name , ' ', e.last_name) employee_name,
	concat(m.first_name, ' ', m.last_name) supervisor_name
from employee e 
left join employee m
on e.supervisor_id = m.id;


-- 21. Write a query to detect duplicated if email is reused by multiple customer

select 
	email,
	count(id) as customers
from  customer
where email is not null
group by email
having count(id) > 1;


-- 22. Identify if an inactive employee has performed transactions.

select *
from employee e 
inner join transaction t
on e.id = t.employee_id
where e.is_active = false;


-- 23. Find customer who haven’t bought any Smartphone

select 
	c.id,
	concat(c.first_name, ' ', c.last_name) as customer_name
from customer c
where not exists (
select 1
from transaction t
join product p
on p.id = t.product_id
where c.id = t.customer_id
and p.name ilike '%smart%phone%'
)
order by c.id;

--

select 
	c.id,
	concat(c.first_name, ' ', c.last_name),
	p.name as product,
	p.brand_name,
	t.id
from  customer c 
inner join transaction t	
on c.id = t.customer_id
inner join product p 
on p.id = t.product_id
where t.customer_id not in (
	select 
		t.customer_id  
	from  transaction t
	inner join product p 
	on p.id = t.product_id and p.name ilike '%smart%phone%'
)
order by c.id;

-- using CTE

with customer_buying_smartphone as (
select 
	c.id,
	concat(c.first_name, ' ', c.last_name),
	p.name as product,
	p.brand_name,
	t.id as transaction_id
from  customer c 
inner join transaction t
on c.id = t.customer_id
inner join product p 
on p.id = t.product_id
where p.name ilike '%smartphone%' 
order by c.id
)
select 
	c.id,
	concat(c.first_name, ' ', c.last_name),
	p.name as product,
	p.brand_name,
	t.id as transaction_id
from  customer c 
inner join transaction t
on c.id = t.customer_id
inner join product p 
on p.id = t.product_id
where c.id not in (
select id from customer_buying_smartphone
)
order by c.id;


-- Returns customers who have at least one transaction
select *
from customer c
where exists(
select 1
from transaction t
where t.customer_id = c.id 
)


-- 24. Find top 5 most popular brand that sells Organic Apple based on qty sold

select 
	p.name,
	p.brand_name,
	sum(t.quantity) as quantity_sold
from product p
inner join transaction t
on p.id = t.product_id
where p.name ilike '%organic%apple%'
group by p.name, p.brand_name
order by sum(t.quantity) desc
limit 5;

-- 25. Find number of active employee for each department

select *
from employee
where is_active is true;

-- 26. On which day, highest discount was given by mart

select 
	date(transaction_date) discount_day,
	sum(discount_amount) total_discount
from transaction
group by date(transaction_date)
order by sum(discount_amount) desc
limit 1;

-- 27.  List name, address of employee who have never received discount

select 
	c.id,
	concat(c.first_name, ' ', c.last_name) employee_name,
	c.address
from customer c 
where not exists (
select 1
from transaction t
where c.id = t.customer_id and t.discount_amount > 0
)
order by c.id;

-- using CTE 

with customer_with_discount as (
select 
	c.id,
	concat(c.first_name, ' ', c.last_name) employee_name,
	c.address,
	t.discount_amount
from customer c 
inner join transaction t
on c.id = t.customer_id
where t.discount_amount > 0
order by c.id
)
select 
	c.id,
	concat(c.first_name, ' ', c.last_name) employee_name,
	c.address,
	t.discount_amount
from customer c 
inner join transaction t
on c.id = t.customer_id
where c.id not in (
select id from customer_with_discount
)
group by c.id, t.discount_amount
order by c.id;


-- 28. Find list of churn customer in 2025, June

select 
	c.id, 
	concat(c.first_name, ' ', c.last_name) customer_name,
	c.address
from customer c 
where not exists (
select 1
from transaction t
where c.id = t.customer_id and 
	t.transaction_date between '2025-06-01' and '2025-07-01'
)
order by c.id;

-- using CTE

with customers_with_transaction_june as (
select 
	c.id,
	concat(c.first_name, ' ', c.last_name) customer_name,
	t.transaction_date	
from customer c
inner join transaction t
on c.id = t.customer_id
where t.transaction_date between '2025-06-01' and '2025-07-01'
order by c.id
)
select 
	c.id, 
	concat(c.first_name, ' ', c.last_name) customer_name,
	c.address
from customer c 
inner join transaction t
on c.id = t.customer_id
where c.id not in (
select id 
from customers_with_transaction_june
) 
group by c.id
order by c.id;


-- 29. Find churn customer in 2025, June for category water bottle

select 
	c.id,
	concat(c.first_name, ' ', c.last_name) customer_name
from customer c 
where not exists (
select 1
from transaction t
join product p
on p.id = t.product_id and p.name ilike '%water%bottle%' 
where c.id = t.customer_id and
	t.transaction_date between '2025-06-01' and '2025-07-01'
)
order by c.id;

-- using CTE

with customers_with_transaction_june as (
select 
	c.id,
	concat(c.first_name, ' ', c.last_name) customer_name,
	t.transaction_date,
	p.name
from customer c
inner join transaction t
on c.id = t.customer_id
inner join  product p 
on p.id = t.product_id
where 
	p.name ilike '%water%bottle%' and
	t.transaction_date between '2025-06-01' and '2025-07-01'
order by c.id
)
select *
from customer c
inner join transaction t
on c.id = t.customer_id
inner join  product p 
on p.id = t.product_id
where c.id not in (
select id
from customers_with_transaction_june 
) and p.name ilike '%water%bottle%'
order by c.id;

-- 30. Find customer who bought notebook on May & June but yet to buy on July

select 
	c.id,
	concat(c.first_name, ' ', c.last_name) customer_name
from customer c 
where exists (
select 1
from transaction t
join product p 
on p.id = t.product_id and p.name ilike '%notebook%'
where c.id = t.customer_id and 
	t.transaction_date >= '2025-05-01' and	
	t.transaction_date < '2025-06-01'
)
and exists (
select 1
from transaction t
join product p 
on p.id = t.product_id and p.name ilike '%notebook%'
where c.id = t.customer_id and 
	t.transaction_date >= '2025-06-01' and
	t.transaction_date < '2025-07-01'
)
and not exists (
select 1 
from transaction t 
join product p 
on p.id = t.product_id and p.name ilike '%notebook%'
where c.id = t.customer_id and 
	t.transaction_date >= '2025-07-01' and 
	t.transaction_date < '2025-08-01'
)
order by c.id;

--

select 
	c.id,
	concat(c.first_name, ' ', c.last_name) customer_name
from customer c 
where exists (
select 1
from transaction t
join product p 
on p.id = t.product_id and p.name ilike '%notebook%'
where c.id = t.customer_id and 
	t.transaction_date >= '2025-05-01' and	
	t.transaction_date < '2025-07-01'
)
and not exists (
select 1 
from transaction t 
join product p 
on p.id = t.product_id and p.name ilike '%notebook%'
where c.id = t.customer_id and 
	t.transaction_date >= '2025-07-01' and 
	t.transaction_date < '2025-08-01'
)
order by c.id;
	
-- using CTE

with july_notebook as (
select 
	c.id,
	concat(c.first_name, ' ', c.last_name) customer_name,
	t.transaction_date,
	p.name
from customer c 
inner join transaction t
on c.id = t.customer_id
inner join product p 
on p.id = t.product_id
where 
	p.name ilike '%notebook%' and
	t.transaction_date >= '2025-07-01' and  t.transaction_date < '2025-08-01'
order by c.id
)
select 
	c.id,
	concat(c.first_name, ' ', c.last_name) customer_name,
	t.transaction_date,
	p.name
from customer c 
inner join transaction t
on c.id = t.customer_id
inner join product p 
on p.id = t.product_id and p.name ilike '%notebook%'
where c.id not in (
select id from july_notebook
) and 
t.transaction_date >= '2025-05-01' and t.transaction_date < '2025-08-01'
order by c.id;
