Задание 1. Выведите одним запросом информацию о фильмах, у которых рейтинг “R” 
и стоимость аренды указана от 0.00 до 3.00 включительно, а также фильмы c рейтингом 
“PG-13” и стоимостью аренды больше или равной 4.00.
Ожидаемый результат запроса: https://ibb.co/Dk4PjJn

select title, rating, rental_rate
from film
where rating = 'R' and rental_rate between 0. and 3. or 
	rating = 'PG-13' and rental_rate >= 4.
	
explain analyze --77.5
select title, rating, rental_rate
from film
where (rating = 'R' and rental_rate between 0. and 3.) or 
	(rating = 'PG-13' and rental_rate >= 4.)

explain analyze --87.5
select title, rating, rental_rate
from film
where (rating::text like 'R' and rental_rate between 0. and 3.) or 
	(rating::text like 'PG-13' and rental_rate >= 4.)

Задание 2. Получите информацию о трёх фильмах с самым длинным описанием фильма.
Ожидаемый результат запроса: https://ibb.co/pfMHBs0

select title, description
from film 
order by character_length(description) desc 
limit 3

Задание 3. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных 
колонки: в первой колонке должно быть значение, указанное до @, во второй колонке должно 
быть значение, указанное после @.
Ожидаемый результат запроса: https://ibb.co/SJng6qd

select customer_id, split_part(email, '@', 1), split_part(email, '@', 2)
from customer 

select customer_id, left(email, position('@' in email) - 1), substring(email, position('@' in email))
from customer 

select customer_id, email, 
	split_part(concat(substring(email, 1, 1), 
	substring(lower(email), 2)), '@', 1) as "Email before @", 
	split_part(concat(substring(initcap(email), 1, 1), substring(email, 2)), '@', 2) as "Email after @"
from customer;

select customer_id, email, 
	split_part(concat(substring(email, 1, 1), substring(lower(email), 2)), '@', 1) as "Email before @", 
	split_part(concat(substring(upper(email), 1, 1), substring(email, 2)), '@', 2) as "Email after @",
from customer;

Задание 4. Доработайте запрос из предыдущего задания, скорректируйте значения в новых 
колонках: первая буква должна быть заглавной, остальные строчными.
Ожидаемый результат запроса: https://ibb.co/vv0k9b6

explain analyze --35.96
select customer_id,
	concat(upper(left(split_part(email, '@', 1), 1)), lower(right(split_part(email, '@', 1), -1))),
	concat(upper(left(split_part(email, '@', 2), 1)), lower(right(split_part(email, '@', 2), -1)))
from customer 

explain analyze --35.96
select customer_id,
	concat(upper(left(s1, 1)), lower(right(s1, -1))),
	concat(upper(left(s2, 1)), lower(right(s2, -1)))
from (
	select customer_id, split_part(email, '@', 1) s1, split_part(email, '@', 2) s2
	from customer) t
	
explain analyze --32.96
select customer_id,
	overlay(lower(split_part(email, '@', 1)) 
		placing upper(left(split_part(email, '@', 1), 1)) from 1 for 1),
	overlay(lower(split_part(email, '@', 2)) 
		placing upper(left(split_part(email, '@', 2), 1)) from 1 for 1)
from customer

explain analyze --35.96
select customer_id , email,
upper(left (split_part("email", '@', 1),1)) || substring (lower (split_part("email", '@', 1))from 2) as "Email before @",
upper(left (split_part("email", '@', 2),1)) || substring ((split_part("email", '@', 2)) from 2)  as "Email after @"
from customer c

Задание 1. Посчитайте для каждого фильма, сколько раз его брали в аренду, 
а также общую стоимость аренды фильма за всё время.
Ожидаемый результат запроса: https://ibb.co/BCqbGcp

select f.title, f.rating, c."name", f.release_year, l."name", count(i.film_id), sum(p.amount)
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
join "language" l on l.language_id = f.language_id
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
group by f.film_id, c.category_id, l.language_id

explain analyze --2904.85
select f.title, f.rating, c."name", f.release_year, l."name", count(i.film_id), sum(p.amount)
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
join "language" l on l.language_id = f.language_id
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
group by f.film_id, c.category_id, l.language_id

explain analyze --1276.94
select f.title, f.rating, c."name", f.release_year, l."name", t.count, t.sum
from film f
left join (
	select i.film_id, count(i.film_id), sum(p.amount)
	from inventory i 
	left join rental r on r.inventory_id = i.inventory_id
	left join payment p on p.rental_id = r.rental_id
	group by i.film_id) t on t.film_id = f.film_id
join "language" l on l.language_id = f.language_id
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id

1 платеж = 1 аренда = 1 инвентарный номер = 1 фильм
N платеж = N аренда = N инвентарный номер = N фильм

Задание 2. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу 
не брали в аренду.
Ожидаемый результат запроса: https://ibb.co/kyv5S9z

explain analyze --2944.98
select f.title, f.rating, c."name", f.release_year, l."name", count(i.film_id), sum(p.amount)
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
join "language" l on l.language_id = f.language_id
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
group by f.film_id, c.category_id, l.language_id
having count(i.film_id) = 0

explain analyze --593.06
select f.title, f.rating, c."name", f.release_year, l."name", count(i.film_id), sum(p.amount)
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
join "language" l on l.language_id = f.language_id
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
where i.film_id is null
group by f.film_id, c.category_id, l.language_id

select t.*, i.film_id, r.staff_id, f.rental_duration
from (
	select payment_id, rental_id, amount, staff_id, payment_date
	from payment 
	where rental_id in (
	select rental_id
	from payment
	group by rental_id
	having count(rental_id) > 1)) t 
join rental r on r.rental_id = t.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

select rental_id
from payment
where amount = 0

except
select rental_id
from rental 

Задание 3. Посчитайте количество продаж, выполненных каждым продавцом. 
Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, 
то значение в колонке будет «Да», иначе должно быть значение «Нет».
Ожидаемый результат запроса: https://ibb.co/p08qt78

select staff_id, count(payment_id),
	case 
		when count(payment_id) > 7300 then 'Yes'
		else 'No'
	end
from payment 
group by staff_id

select staff_id, count(payment_id),
	case 
		when count(payment_id) > 8000 then 'Yes'
		else 'No'
	end
from payment 
group by staff_id

Добрый день интересует способ решения такой задачи. Есть сущность и 2 аттрибута. 
нужно отфильтровать таблицу так что бы остались значения "кат" где сумма максимальна. 
Скрины изначальной таблицы и результата приложил. Очень часто в работе встречаются такие задачи. 
Какой наиболее эффективный запрос будет?
Я не буду в зуме, но запись обязательно просмотрю. Спасибо большое

select payment_id, amount
from payment 
where amount = (select max(amount) from payment)

select amount, count(1)
from payment 
group by amount

select customer_id, max(amount)
from payment 
group by customer_id

интересно как в 5 задании 3гоДЗ можно было бы убрать зеркальные пары городов

Также не победила декартово произведение в рамках одной таблицы в задании №5 основной части 3-го ДЗ. 
Если можно, давайте его разберем тоже

explain analyze --46443.96
select distinct c1.first_name, c2.first_name
from customer c1, customer c2

select (349281 - 591) / 2

select 599*599 / 2.

--Москва - Питер
Питер - Москва

> / <

explain analyze --4424
select  c1.first_name, c2.first_name
from (select distinct first_name from customer) c1, (select distinct first_name from customer) c2

select  c1.first_name, c2.first_name
from (select distinct first_name from customer) c1, (select distinct first_name from customer) c2
where c1.first_name > c2.first_name

174345

--Максим - Семен
Семен - Максим

select 'aaB' > 'aab'

numeric(10,2)
varchar(10)
99999999.99
	99.99


