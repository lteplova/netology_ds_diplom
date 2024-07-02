--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1

--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:

--Пронумеруйте все платежи от 1 до N по дате - column_1
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате - column_2

--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей - column_3

--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--так, чтобы платежи с одинаковым значением имели одинаковое значение номера. - column_4

--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

select  customer_id, payment_id, payment_date, 
row_number () over (order by payment_date) as column_1,
row_number () over (partition by customer_id order by payment_date) as column_2,
sum(amount) over (partition by customer_id order by payment_date, amount) as column_3,
dense_rank() over (partition by customer_id order by amount desc) as column_4
from payment
order by customer_id, column_4
 
--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.


select  customer_id, payment_id, payment_date, amount, 
lag (amount, 1, 0.) over(partition by customer_id order by payment_date) as last_amount
from payment
order by customer_id, payment_id 

--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.

select  customer_id, payment_id, payment_date, amount, 
abs(amount - lead (amount, 1, 0.) over(partition by customer_id order by payment_date)) as difference
from payment
order by customer_id, payment_id 


--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.


select customer_id, payment_id, payment_date, amount
from (
	select customer_id, payment_id, payment_date, amount,
    row_number () over (partition by customer_id order by payment_date desc)
    from payment p 
) t
where row_number = 1
	

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.

select staff_id, payment_date::date, sum(amount),
sum(sum(amount)) over (partition by staff_id order by payment_date::date)
from payment p 
where date_trunc('month', payment_date) = '2005-08-01' 
group by staff_id, payment_date::date


--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку

select customer_id, payment_date, row_number as payment_number
from (
	select customer_id, payment_date, row_number() over(order by payment_date)
	from payment 
	where payment_date::date = '2005-08-20') t
where row_number %100 = 0


--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм






