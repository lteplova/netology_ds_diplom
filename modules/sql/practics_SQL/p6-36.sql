============= представления =============

4. Создайте view с колонками клиент (ФИО; email) и title фильма, который он брал в прокат последним
+ Создайте представление:
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1

create view task_1 as
	with cte as (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental r)
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from cte
	join customer c on c.customer_id = cte.customer_id
	join inventory i on i.inventory_id = cte.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
	
select * 
from task_1
join customer c on concat(c.last_name, ' ', c.first_name) = concat

explain analyze --2291
select *
from task_1 
	
4.1. Создайте представление с 3-мя полями: название фильма, имя актера и количество фильмов, в которых он снимался
+ Создайте представление:
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* count - агрегатная функция подсчета значений
* Задайте окно с использованием предложений over и partition by

create view task_2 as 
	select f.title, a.last_name, count(f.film_id) over (partition by a.actor_id)
	from film f
	join film_actor fa on fa.film_id = f.film_id
	join actor a on a.actor_id = fa.actor_id

explain analyze --687
select * from task_2

============= материализованные представления =============

5. Создайте материализованное представление с колонками клиент (ФИО; email) и title фильма, 
который он брал в прокат последним
Иницилизируйте наполнение и напишите запрос к представлению.
+ Создайте материализованное представление без наполнения (with NO DATA):
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1
+ Обновите представление
+ Выберите данные

create materialized view task_3 as
	with cte as (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental r)
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from cte
	join customer c on c.customer_id = cte.customer_id
	join inventory i on i.inventory_id = cte.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
with no data

select * from task_3

refresh materialized view task_3 --2291

select 2291/13 --176

explain analyze --13
select * from task_3

explain analyze --14.49
select * from task_3
where concat = 'SMITH MARY'

create index t3_idx on task_3(concat)

explain analyze --8.29
select * from task_3
where concat = 'SMITH MARY'

5.1. Содайте наполенное материализованное представление, содержащее:
список категорий фильмов, средняя продолжительность аренды которых более 5 дней
+ Создайте материализованное представление с наполнением (with DATA)
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней
 + Выберите данные
 
create materialized view task_4 as 
	select c.name
	from film f
	join film_category fc on f.film_id = fc.film_id
	join category c on c.category_id = fc.category_id
	group by c.category_id
	having avg(rental_duration) > 5
--with data
	
explain analyze --18.5
select * from task_4

refresh materialized view task_4

drop view task_2

drop materialized view task_4

create materialized view task_4 as 
	select c.name, now() as t
	from film f
	join film_category fc on f.film_id = fc.film_id
	join category c on c.category_id = fc.category_id
	group by c.category_id
	having avg(rental_duration) > 5

название_представления | дата_обновления | ответственный_за_обновление

============ Индексы ===========

select where having on 

update / insert / delete

btree > < = null
hash = 
gist array
lag(current, 3), current, lead(current, 3)

select * 
from customer c

DROP INDEX public.idx_last_name cascade;
DROP INDEX public.idx_fk_store_id cascade;
DROP INDEX public.idx_fk_address_id cascade;

alter table customer drop constraint customer_pkey

explain analyze --16.49
select * 
from customer c
where c.customer_id = 325

alter table customer add constraint customer_pkey primary key (customer_id)

explain analyze --8.29
select * 
from customer c
where c.customer_id = 325

1-1000
1-500 501-1000
1-250 251-500 501-750 751-1000
1-125 126-250 251-375 376-500 ......

1 -> 325 | 599

explain analyze --8.29
select * 
from customer c
where c.customer_id < 100

-- 128 kb
-- 160 kb
-- 192 kb

create index title_idx on customer(last_name)

create index first_idx on customer using hash (first_name)

основная таблица + 3 таблицы с индексами.

explain analyze
select * 
from rental 
where rental_date between '2005-05-25 02:19:23' and '2005-05-25 09:47:31'

create index rent_date_idx on rental(rental_date)

explain analyze
select * 
from rental 
where rental_date::date between '2005-05-25' and '2005-05-25'

explain analyze --8.29
select * 
from customer c
where c.customer_id between 10 and 30 and c.customer_id between 20 and 40

index scan on bitmap

explain analyze
select * 
from rental 
where rental_date::date between '2005-05-25' and '2005-05-26'

create index rent_date_as_date_idx on rental(cast(rental_date as date))

create index rent_date_as_date_idx on rental(rental_date::date) --работать не будет

explain analyze
select * 
from rental 
where rental_date::date between '2005-05-25' and '2005-05-26'

explain analyze
select * 
from rental 
where rental_date between '2005-05-25' and '2005-05-26'

create index rent_date_as_dateе_idx on rental(cast(rental_date as date))

drop index rent_date_as_dateе_idx

select description from film

'A Touching Saga of a Hunter And a Butler who must Discover a Butler in A Jet Boat'

'A' -> {1, 16}
'Butler' -> {9, 14}
'Touching' -> {2}

{1, 16} -> 'A'
{9, 14} -> 'Butler'

create index a_b_c_idx on customer(last_name, first_name, cast(last_update as date))

select * from customer c

create index desc_idx on film using gin (description)

============ explain ===========

Ссылка на сервис по анализу плана запроса 
https://explain.depesz.com/
https://tatiyants.com/pev/
https://habr.com/ru/post/203320/

EXPLAIN [ ( параметр [, ...] ) ] оператор
EXPLAIN [ ANALYZE ] [ VERBOSE ] оператор

Здесь допускается параметр:

    ANALYZE [ boolean ]
    VERBOSE [ boolean ]
    COSTS [ boolean ]
    BUFFERS [ boolean ]
    TIMING [ boolean ]
    FORMAT { TEXT | XML | JSON | YAML }

explain 
select c.name
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
group by c.category_id
having avg(rental_duration) > 5

explain analyze
select c.name
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
group by c.category_id
having avg(rental_duration) > 5

explain (format json, analyze)
select c.name
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
group by c.category_id
having avg(rental_duration) > 5

cost / time

like cost min 100 time max 500
any cost min 300 time max 200

explain --135 759 574 / 20 156 906  -- 130000 / 92000
select distinct b.book_ref, bp.boarding_no
from bookings b
join tickets t on b.book_ref = t.book_ref
join ticket_flights tf on tf.ticket_no = t.ticket_no
join flights f on f.flight_id = tf.flight_id
join boarding_passes bp on bp.ticket_no = tf.ticket_no or bp.flight_id = f.flight_id

explain --1543953000565171382839672832 / 90 924 648  -- 130000 / 92000
select distinct b.book_ref, bp.boarding_no
from bookings b ,tickets t , ticket_flights tf, flights, boarding_passes bp

======================== json ========================
Создайте таблицу orders
 
CREATE TABLE orders (
     ID serial PRIMARY KEY,
     info json NOT NULL
);

INSERT INTO orders (info)
VALUES
 (
'{"items": {"product": "Beer","qty": 6,"a":345}, "customer": "John Doe"}'
 ),
 (
'{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24}}'
 ),
 (
'{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'
 ),
 (
'{ "customer": "Mary Clark", "items": {"product": "Toy Train","qty": 2}}'
 );
 
select * from orders

INSERT INTO orders (info)
VALUES
 (
'{ "a": { "a": { "a": { "a": { "a": { "c": "b"}}}}}}'
 )
 
 INSERT INTO orders (info)
VALUES
 (
'{ "a": "dddddddddddddddddddddd"}'
 )
 
|{название_товара: quantity, product_id: quantity, product_id: quantity}|общая сумма заказа|


6. Выведите общее количество заказов:
* CAST ( data AS type) преобразование типов
* SUM - агрегатная функция суммы
* -> возвращает JSON
*->> возвращает текст

select pg_typeof(info)
from orders

select pg_typeof(info->'items'->'qty')
from orders

select sum(info->'items'->'qty')
from orders

select pg_typeof(info->'items'->>'qty')
from orders

select sum((info->'items'->>'qty')::numeric)
from orders

6*  Выведите среднее количество заказов, продуктов начинающихся на "Toy"

select avg((info->'items'->>'qty')::numeric)
from orders
where info->'items'->>'product' ilike 'Toy%'

--Получить все ключи из json

select json_object_keys(info->'items')
from orders

======================== array ========================
7. Выведите сколько раз встречается специальный атрибут (special_features) у
фильма -- сколько элементов содержит атрибут special_features
* array_length(anyarray, int) - возвращает длину указанной размерности массива

text[]
int[]

select '{1, 2.}'::text[]

select '{1, 2.}'::numeric[]

wish_list [1,6,9,55]
wish_list '1,6,9,55'

2022 08 50
2022 09 30

select title, pg_typeof(special_features)
from film

select title, array_length(special_features, 1)
from film

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[], 2)

7* Выведите все фильмы содержащие специальные атрибуты: 'Trailers','Commentaries'
* Используйте операторы:
@> - содержит
<@ - содержится в
*  ARRAY[элементы] - для описания массива

https://postgrespro.ru/docs/postgresql/12/functions-subquery
https://postgrespro.ru/docs/postgrespro/12/functions-array

-- ПЛОХАЯ ПРАКТИКА --
select title, special_features
from film
where special_features[1] = 'Trailers' or special_features[1] = 'Commentaries'
	or special_features[2] = 'Trailers' or special_features[2] = 'Commentaries'
	or special_features[3] = 'Trailers' or special_features[3] = 'Commentaries'
	or special_features[4] = 'Trailers' or special_features[4] = 'Commentaries'
	
select title, special_features
from film
where special_features::text like '%Trailers%' or special_features::text like '%Commentaries%'

select title, special_features
from film
where array_position(special_features, 'Trailers') > 0 or 
	array_position(special_features, 'Commentaries') > 0
	
select * from a

insert into a(a,c)
values('{1}'::int[], 7)

update a 
set a[-5] = 3
where c = 7

{[-5:1]={3,NULL,NULL,NULL,NULL,NULL,1}}

-- ЧТО-ТО СРЕДНЕЕ ПРАКТИКА --

select title, array_agg(unnest)
from (
	select film_id, title, unnest(special_features)
	from film) t
where unnest = 'Trailers' or unnest = 'Commentaries'
group by film_id, title

-- ХОРОШАЯ ПРАКТИКА --
select title, special_features
from film
where special_features && array['Trailers'] or special_features && array['Commentaries']

select title, special_features
from film
where special_features @> array['Trailers'] or special_features @> array['Commentaries']

select title, special_features
from film
where array['Trailers'] <@ special_features or array['Commentaries'] <@ special_features

select title, special_features
from film
where special_features <@ array['Trailers'] or special_features <@ array['Commentaries']

select title, special_features
from film
where 'Trailers' = any(special_features) or 'Commentaries' = any(special_features) 

some = any

select title, special_features
from film
where 'Trailers' = all(special_features) or 'Commentaries' = all(special_features) 

select title, special_features
from film
where array_position(special_features, 'Trailers') is not null or 
	array_position(special_features, 'Commentaries') is not null
	
array_positions - которая возвращает массив со всеми индексами
	
-- НЕ СОДЕРЖИТ
select title, special_features
from film
where not 'Trailers' = any(special_features) or not 'Commentaries' = any(special_features) 