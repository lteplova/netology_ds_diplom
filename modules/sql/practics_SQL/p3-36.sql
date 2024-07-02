============= теория =============

create table table_one (
	name_one varchar(255) not null
);

create table table_two (
	name_two varchar(255) not null
);

insert into table_one (name_one)
values ('one'), ('two'), ('three'), ('four'), ('five');

insert into table_two (name_two)
values ('four'), ('five'), ('six'), ('seven'), ('eight');

select * from table_one;

select * from table_two;

--left, right, inner, full outer, cross

select t1.name_one, t2.name_two
from table_one t1
join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
inner join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
left join table_two t2 on t1.name_one = t2.name_two

select table_one.name_one, table_two.name_two
from table_one 
left join table_two  on table_one.name_one = table_two.name_two

select count(*)
from customer c
inner join address a on a.address_id = c.address_id

select count(*)
from customer c
left join address a on a.address_id = c.address_id

select t1.name_one, t2.name_two
from table_one t1
right join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select t1.name_one, t2.name_two
from table_one t1
cross join table_two t2

select t1.name_one, t2.name_two
from table_one t1, table_two t2

select t1.name_one, t2.name_two
from table_one t1, table_two t2
where t1.name_one = t2.name_two

cross join / inner join / left/right join / full join

delete from table_one;
delete from table_two;

insert into table_one (name_one)
select unnest(array[1,1,2])

insert into table_two (name_two)
select unnest(array[1,1,3])

select * from table_one

select * from table_two

select t1.name_one, t2.name_two
from table_one t1
join table_two t2 on t1.name_one = t2.name_two

1A	1B
1a	1b
2	3

1A1B 
1A1b 
1a1B
1a1b

select t1.name_one, t2.name_two
from table_one t1
left join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
right join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select t1.name_one, t2.name_two
from table_one t1
cross join table_two t2

select count(*)
from customer c 
join rental r on r.customer_id = c.customer_id
join payment p on p.customer_id = c.customer_id and p.rental_id = r.rental_id

select count(*)
from rental 

--union / except

select 1 as x, 1 as y
union 
select 2 as x, 2 as y

select 1 as x, 1 as y
union --distinct 
select 1 as x, 1 as y

select 1 as x, 1 as y
union all
select 1 as x, 1 as y

select 1 as x, 1 as y
union 
select 2 as x, 2 as y
union all
select 1 as x, 1 as y
union --distinct 
select 1 as x, 1 as y
union
select 1 as x, 1 as y
union all
select 1 as x, 1 as y

select 1 as x, 1 as y
except 
select 2 as x, 2 as y

select 1 as x, 1 as y
except 
select 1 as x, 1 as y

select *
from (
	select 1 as x, 1 as y
	union all
	select 2 as x, 2 as y
	union all
	select 2 as x, 2 as y
	union all
	select 1 as x, 1 as y) t
except distinct
select 1 as x, 1 as y

select *
from (
	select 1 as x, 1 as y
	union all
	select 2 as x, 2 as y
	union all
	select 2 as x, 2 as y
	union all
	select 1 as x, 1 as y) t
except all
select 1 as x, 1 as y

select *
from (
	select 1 as x, 1 as y
	union all
	select 2 as x, 2 as y
	union all
	select 2 as x, 2 as y
	union all
	select 1 as x, 1 as y) t
except
select 1 as x, 1 as y

-- case
select 
	case 
		when t1.name_one is null then t2.name_two
		when t2.name_two is null then t1.name_one
		else 'Что-то пошло не так'
	end
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null


select concat(t1.name_one, t2.name_two)
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null


============= соединения =============

1. Выведите список названий всех фильмов и их языков
* Используйте таблицу film
* Соедините с language
* Выведите информацию о фильмах:
title, language."name"

select f.title, l."name"
from film f
join "language" l on l.language_id = f.language_id

1. Выведите все фильмы и их категории:
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Соедините используя оператор using

select f.title, c."name"
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id

select f.title, c."name"
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id

2. Выведите уникальный список фильмов, которые брали в аренду '24-05-2005'. 
* Используйте таблицу film
* Соедините с inventory
* Соедините с rental
* Отфильтруйте, используя where 

select f.title, r.rental_id, r.rental_date
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
where r.rental_date::date = '24-05-2005'

select f.title, r.rental_id, r.rental_date
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id and r.rental_date::date = '24-05-2005'

select f.title, r.rental_id, r.rental_date
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id and r.rental_date::date = '24-05-2005'

select f.title, r.rental_id, r.rental_date
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
where r.rental_date::date = '24-05-2005'

2.1 Выведите все магазины из города Woodridge (city_id = 576)
* Используйте таблицу store
* Соедините таблицу с address 
* Соедините таблицу с city 
* Соедините таблицу с country 
* отфильтруйте по "city_id"
* Выведите полный адрес искомых магазинов и их id:
store_id, postal_code, country, city, district, address, address2, phone

select store_id, postal_code, country, city, district, address, address2, phone
from store s
join address a on a.address_id = s.address_id 
join city c on c.city_id = a.city_id
join country c2 on c2.country_id = c.country_id
where c.city_id = 576

select store_id, postal_code, country, city, district, address, address2, phone
from store s
join address a using(address_id)
join city c using(city_id)
join country c2 using(country_id)
where c.city_id = 576

explain analyze 
select store_id, postal_code, country, city, district, address, address2, phone
from store s
join address a on a.address_id = s.address_id 
join city c on c.city_id = a.city_id
join country c2 on c2.country_id = c.country_id
where c.city_id = 576

============= агрегатные функции =============

3. Подсчитайте количество актеров в фильме Grosse Wonderful (id - 384)
* Используйте таблицу film
* Соедините с film_actor
* Отфильтруйте, используя where и "film_id" 
* Для подсчета используйте функцию count, используйте actor_id в качестве выражения внутри функции
* Примените функцильные зависимости

count 
sum 
min 
max 
avg
string_agg 
array_agg

select count(fa.actor_id)
from film f
join film_actor fa on f.film_id = fa.film_id
where f.film_id = 384

select f.title, count(fa.actor_id)
from film f
join film_actor fa on f.film_id = fa.film_id
group by f.title

select f.title, count(fa.actor_id), f.release_year, f.description
from film f
join film_actor fa on f.film_id = fa.film_id
group by f.title, f.release_year, f.description

select f.title, count(fa.actor_id), f.release_year, f.description, fa.film_id
from film f
join film_actor fa on f.film_id = fa.film_id
group by f.film_id, fa.film_id

select f.title, count(fa.actor_id), f.release_year, f.description, fa.film_id
from film f
join film_actor fa on f.film_id = fa.film_id
group by f.film_id, f.release_year

select count(1)
from customer c

select count('здесь можно написать все что угодно')
from customer c

select count(address_id)
from customer c

select count(inventory.film_id) as "Количество арендованных фильмов"
from payment 

1 payment = 1 rental = 1 film

N payment = N rental = N film

select count(distinct first_name)
from customer 

3.1 Посчитайте среднюю стоимость аренды за день по всем фильмам
* Используйте таблицу film
* Стоимость аренды за день rental_rate/rental_duration
* avg - функция, вычисляющая среднее значение
--4 агрегации

select avg(rental_rate/rental_duration),
	sum(rental_rate/rental_duration),
	min(rental_rate/rental_duration),
	max(rental_rate/rental_duration),
	count(rental_rate/rental_duration)
from film 

select count(max(rental_rate/rental_duration))
from film 

select customer_id, array_agg(rental_id)
from rental 
group by customer_id

select customer_id, string_agg(rental_id::text, ', ')
from rental 
group by customer_id

explain analyze --749
select t1.customer_id, t1.sum, t2. sum
from (
	select customer_id, sum(amount)
	from payment  
	where amount >= 5
	group by customer_id) t1
full join (
	select customer_id, sum(amount) 
	from payment  
	where date_part('month', payment_date) = 5
	group by customer_id) t2 on t1.customer_id = t2.customer_id
order by 1

explain analyze --558
select customer_id, sum(amount) filter (where amount >= 5), 
	sum(amount) filter (where date_part('month', payment_date) = 5)
from payment  
group by customer_id
order by 1

============= группировки =============

4. Выведите месяцы, в которые было сдано в аренду более чем на 10 000 у.е.

* Используйте таблицу payment
* Сгруппируйте данные по месяцу используя date_trunc
* Для каждой группы посчитайте сумму платежей
* Воспользуйтесь фильтрацией групп, для выбора месяцев с суммой продаж более чем на 10 000 у.е.

select *
from (
	select date_trunc('month', payment_date), sum(amount)
	from payment 
	group by date_trunc('month', payment_date)) t1
join (
	select date_trunc('month', rental_date), count(rental)
	from rental 
	group by date_trunc('month', rental_date)) t2 on t1.date_trunc = t2.date_trunc

select date_trunc('month', payment_date), sum(amount)
from payment 
where amount > 5
group by date_trunc('month', payment_date)
having sum(amount) > 10000

select date_part('month', payment_date), sum(amount)
from payment 
group by date_part('month', payment_date)
having date_part('month', payment_date) = 5 -- так не хорошо

select date_trunc('month', payment_date), sum(amount), sum(amount) > 10000
from payment 
where amount > 5
group by date_trunc('month', payment_date)
having sum(amount) > 10000

select customer_id, date_trunc('month', payment_date), sum(amount)
from payment 
where amount > 5
group by customer_id, date_trunc('month', payment_date)

4.1 Выведите список категорий фильмов, средняя продолжительность аренды которых более 5 дней
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней

select c."name"
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
group by c.category_id
having avg(rental_duration) > 5

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment
where customer_id < 4 
group by customer_id, staff_id, date_trunc('month', payment_date)
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment
where customer_id < 4 
group by grouping sets (customer_id, staff_id, date_trunc('month', payment_date))
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment
where customer_id < 4 
group by grouping sets (customer_id, staff_id, date_trunc('month', payment_date))
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment
where customer_id < 4 
group by cube (customer_id, staff_id, date_trunc('month', payment_date))
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment
where customer_id < 4 
group by rollup (customer_id, staff_id, date_trunc('month', payment_date))
order by 1, 2, 3

select *
from (
	select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment
where customer_id < 4 
group by grouping sets (customer_id, staff_id, date_trunc('month', payment_date))
order by 1, 2, 3) t
where date_trunc is not null

============= подзапросы =============

5. Выведите количество фильмов, со стоимостью аренды за день больше, 
чем среднее значение по всем фильмам
* Напишите подзапрос, который будет вычислять среднее значение стоимости 
аренды за день (задание 3.1)
* Используйте таблицу film
* Отфильтруйте строки в результирующей таблице, используя опретаор > (подзапрос)
* count - агрегатная функция подсчета значений

select avg(rental_rate/rental_duration) from film 

select count(1)
from film 
where rental_rate/rental_duration > (select avg(rental_rate/rental_duration) from film )

select count(1)
from film 
where rental_rate/rental_duration > 0.64937192857142856936 --(select avg(rental_rate/rental_duration) from film )

select customer_id, sum(amount) * 100 / (select sum(amount) from payment)
from payment 
group by customer_id

6. Выведите фильмы, с категорией начинающейся с буквы "C"
* Напишите подзапрос:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"
* Используйте подзапрос во from, join, where

select category_id, "name"
from category 
where "name" like 'C%'

explain analyse
select f.title, t.name
from (
	select category_id, "name"
	from category 
	where "name" like 'C%') t 
join film_category fc on fc.category_id = t.category_id
join film f on f.film_id = fc.film_id --175 / 53.54 / 0.47

explain analyse
select f.title, t.name
from (
	select category_id, "name"
	from category 
	where "name" like 'C%') t 
left join film_category fc on fc.category_id = t.category_id
left join film f on f.film_id = fc.film_id --175 / 53.54 / 0.47

explain analyse
select f.title, t.name
from film f
join film_category fc on fc.film_id = f.film_id
join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.54 / 0.47

explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id and 
	fc.category_id in --(3, 4, 5)
		(select category_id
		from category 
		where "name" like 'C%')
join category c on c.category_id = fc.category_id --175 / 47.36 / 0.45

explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c.category_id in (
	select category_id
	from category 
	where "name" like 'C%') --175 / 47.21 / 0.43

explain analyze
select f.title, t.name
from film f
right join film_category fc on fc.film_id = f.film_id
right join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.54 / 0.43

explain analyze
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c."name" like 'C%'  --175 / 53.54

explain analyze --529.21
select customer_id, sum(amount), min(amount), max(amount), avg(amount), count(amount)
from payment 
group by customer_id

--xplain analyze --738210
select distinct customer_id, 
	(select sum(amount)
	from payment p1
	where p1.customer_id = p.customer_id
	group by customer_id),
	(select min(amount)
	from payment p1
	where p1.customer_id = p.customer_id
	group by customer_id),
	(select max(amount)
	from payment p1
	where p1.customer_id = p.customer_id
	group by customer_id),
	(select avg(amount)
	from payment p1
	where p1.customer_id = p.customer_id
	group by customer_id),
	(select count(amount)
	from payment p1
	where p1.customer_id = p.customer_id
	group by customer_id)
from payment p

select 738210 / 529
