--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

--explain analyze --67.5 /0.026ms
select film_id, title, special_features 
from film
where special_features @> array['Behind the Scenes']


--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

--explain analyze --77.5/0.033
select film_id, title, special_features 
from film
where 'Behind the Scenes' = any(special_features)

--explain analyze --67.5/0.57ms
select film_id, title, special_features
from film
where array_position(special_features, 'Behind the Scenes') is not null 


--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

explain analyze  --720/26ms
with cte as (
	select film_id, title, special_features 
	from film
	where special_features @> array['Behind the Scenes']
            ) 
select c.customer_id, count(cte.special_features)
from cte
	join inventory i on i.film_id = cte.film_id
	join rental r on r.inventory_id = i.inventory_id 
	join customer c on c.customer_id = r.customer_id 
group by c.customer_id 
order by c.customer_id 

--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

explain analyze --710/30ms
select c.customer_id, count(t.special_features)
from (select film_id, title, special_features 
	from film
	where special_features @> array['Behind the Scenes']) t
join inventory i on i.film_id = t.film_id
join rental r on r.inventory_id = i.inventory_id 
join customer c on c.customer_id = r.customer_id 
group by c.customer_id 
order by c.customer_id 

--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create materialized view attrib as
	select c.customer_id, count(t.special_features)
	from (select film_id, title, special_features 
		from film
		where special_features @> array['Behind the Scenes']) t
	join inventory i on i.film_id = t.film_id
	join rental r on r.inventory_id = i.inventory_id 
	join customer c on c.customer_id = r.customer_id 
	group by c.customer_id 
	order by c.customer_id
with no data

refresh materialized view attrib 

select *
from attrib

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее

с помощью  @>

--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

с использованием подзапроса



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.

select t.staff_id, f.film_id, f.title , t.amount, t.payment_date, c.last_name as customer_last_name, c.first_name as customer_first_name
from(
select *,
row_number () over(partition by staff_id order by payment_date asc)
from payment p ) t
	join rental r on r.rental_id = t.rental_id 
	join inventory i on i.inventory_id = r.inventory_id 
	join film f on f.film_id = i.film_id
	join customer c on c.customer_id = t.customer_id
where row_number = 1

--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

select t1.store_id as "ID - магазина", t1.rental_date as "День-больше всего фильмов", t1.count as "Количество фильмов", 
t2.payment_date as "День минимальных продаж", t2.sum as "Сумма продаж в этот день"
from (
	select i.store_id, r.rental_date::date, count(i.film_id), 
		row_number() over (partition by i.store_id order by count(i.film_id) desc) r_c
	from rental r 
	join inventory i on i.inventory_id = r.inventory_id
	group by i.store_id, r.rental_date::date) t1
join (
	select s.store_id, p.payment_date::date, sum(p.amount), 
		row_number() over (partition by s.store_id order by sum(p.amount)) p_s
	from payment p 
	join staff s on s.staff_id = p.staff_id
	group by s.store_id, p.payment_date::date) t2 on t1.store_id = t2.store_id
where p_s = 1 and r_c = 1
