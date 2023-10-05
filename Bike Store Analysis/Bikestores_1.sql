SELECT sale.order_id,CONCAT(cust.first_name,' ',cust.last_name) AS customer_name,
cust.city,cust.state,sale.order_date,SUM(quantity) AS total_units,
SUM(ord_item.quantity * ord_item.list_price) AS revenue,
prod.product_name,cate.category_name,store.store_name,
CONCAT(staff.first_name,' ' ,staff.last_name) AS sales_rep
from sales.orders sale JOIN sales.customers cust
ON sale.customer_id = cust.customer_id
JOIN sales.order_items ord_item
ON sale .order_id= ord_item.order_id
JOIN production.products prod 
ON ord_item.product_id = prod.product_id
JOIN production.categories cate
ON prod.category_id = cate.category_id
JOIN sales.stores store 
ON sale.store_id = store.store_id
JOIN sales.staffs staff
ON sale.staff_id = staff.staff_id
GROUP BY sale.order_id,CONCAT(cust.first_name,' ',cust.last_name) ,
cust.city,cust.state,sale.order_date,prod.product_name,cate.category_name,store.store_name,
CONCAT(staff.first_name,' ' ,staff.last_name)
