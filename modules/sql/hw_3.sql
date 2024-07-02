--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select 
	c.last_name || ' ' || c.first_name  as "Customer name",
	a.address, 
	c2.city,
	c3.country 
from customer c 
inner join address a on c.address_id = a.address_id 
inner join city c2 on a.city_id = c2.city_id 
inner join country c3 on c2.country_id = c3.country_id 


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select 
	c.store_id as "ID магазина",
	count(c.customer_id) as "Количество покупателей"
from customer c 
group by c.store_id


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select 
	c.store_id as "ID магазина",
    count (c.customer_id) as "Количество покупателей"
from customer c 
group by c.store_id
having count(c.customer_id) > 300

-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select 
    s.store_id as "ID магазина",
    count(c2.customer_id) as "Количество покупателей",
    c.city as "Город",
    s2.last_name || ' ' || s2.first_name  as "Имя сотрудника"
from store s 
join address a on s.address_id = a.address_id 
join city c on c.city_id = a.city_id  
join customer c2 on c2.store_id = s.store_id
join staff s2 on s2.staff_id = s.manager_staff_id 
group by s.store_id, s2.staff_id, c.city_id 
having count(c2.customer_id) > 300


--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

select 
	c.last_name || ' ' || c.first_name as "Фамилия и имя покупателя",
	count (r.rental_id) as "Количество фильмов"
from customer c 
join rental r on r.customer_id = c.customer_id 
group by c.customer_id 
order by 2 desc 
limit 5


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

select  
	c.last_name || ' ' || c.first_name as "Фамилия и имя покупателя",
	count (p.rental_id) as "Количество фильмов",
    round(sum (p.amount)) as "Общая стоимость платежей",
	min (p.amount) as "Минимальная стоимость платежа",
	max (p.amount) as "Максимальная стоимость платежей"
from  payment p 
join rental r on r.rental_id = p.rental_id 
join customer c on c.customer_id = p.customer_id 
group by c.customer_id, p.customer_id


--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.

select 
	c1.city as "Город 1", 
	c2.city as "Город 2"
from city c1
cross join city c2
where c1.city < c2.city 

select *
from city


--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 
select 
customer_id as "ID покупателя",
round(avg(return_date::date - rental_date::date), 2) as "Среднее кол-во дней на возврат"
from rental
group by customer_id 
order by 1


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.


select 
	f.title as "Название фильма", 
	f.rating as "Рейтинг", 
	c."name" as "Жанр", 
	f.release_year as "Год выпуска", 
	l."name" as "Язык", count(i.film_id) as "Количество аренд", 
	sum (p.amount) as "Общая стоимость аренды"
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
join "language" l on l.language_id = f.language_id 
join inventory i on i.film_id = f.film_id 
join rental r on r.inventory_id = i.inventory_id 
join payment p on p.rental_id = r.rental_id 
group by i.film_id, f.title, f.rating, c."name", f.release_year, l."name" 


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

select 
	f.title as "Название фильма", 
	f.rating as "Рейтинг", 
	c."name" as "Жанр", 
	concat(split_part(f.release_year::text, ',', 1), split_part(f.release_year::text, ',', 2)) as "Год выпуска", 
	l."name" as "Язык", count(i.film_id) as "Количество аренд", 
	sum (p.amount) as "Общая стоимость аренды"
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
join "language" l on l.language_id = f.language_id 
left join inventory i on i.film_id = f.film_id 
left join rental r on r.inventory_id = i.inventory_id 
left join payment p on p.rental_id = r.rental_id 
group by i.film_id, f.title, f.rating, c."name", f.release_year, l."name" 
having count(i.film_id) = 0

--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".


select staff_id, concat(split_part(count(p.staff_id)::text, ',', 1), split_part(count(p.staff_id)::text, ',', 2)) as "Количество продаж",
 case
	when count(p.staff_id) > 7300 then 'Да'
	else 'Нет'
  end as "Премия" 
from payment p 
group by p.staff_id 