Отличие ' ' от " "

' ' -строки
" " - названия сущносетй базы данных


Зарезервированные слова

select "name"
from "language" 

select name
from language

/*select select 
from from*/ так делать не надо

логический порядок инструкции SELECT

FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE или WITH ROLLUP
HAVING
SELECT <-- объявляем алиасы (псевдонимы)
OVER
DISTINCT
ORDER by

select distinct...........
from ......... 
join ........ on ............
where 
group by 
having 


1. Получите атрибуты id фильма, название, описание, год релиза из таблицы фильмы.
Переименуйте поля так, чтобы все они начинались со слова Film (FilmTitle вместо title и тп)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- as - для задания синонимов 

select film_id, title, description, release_year
from film 

select film_id FilmFilm_id, title FilmTitle, 
	description as FilmDescription, release_year as FilmRelease_year
from film 

select film_id "FilmFilm_id", title "FilmTitle", 
	description as "FilmDescription", release_year as "Год выпуска фильма"
from film 

select 1 as "Какое-то красивое название на кириллице"

2. В одной из таблиц есть два атрибута:
rental_duration - длина периода аренды в днях  
rental_rate - стоимость аренды фильма на этот промежуток времени. 
Для каждого фильма из данной таблицы получите стоимость его аренды в день,
задайте вычисленному столбцу псевдоним cost_per_day
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- стоимость аренды в день - отношение rental_rate к rental_duration
- as - для задания синонимов 

select title, rental_rate / rental_duration as cost_per_day
from film 

select title, rental_rate / rental_duration as cost_per_day,
	rental_rate + rental_duration as cost_per_day,
	rental_rate * rental_duration as cost_per_day,
	rental_rate - rental_duration as cost_per_day
from film 

select title, power(rental_rate, rental_duration) as cost_per_day
from film 

2*
- арифметические действия
- оператор round

select title, round(rental_rate / rental_duration, 2) 
from film 

select title, rental_rate / 0 as cost_per_day
from film 

int2 - smallint 0-65535
int - int4 - integer 0-65535*65535
int8 - bigint 0-65535*65535*65535*65535

float real / double precision 

pi 3.14.............................................................
2.5 + 2.5 = 2.49999 + 2.50001

numeric(10,2)
99999999.99

serial - integer 

SELECT x,
  round(x::numeric) AS num_round,
  round(x::double precision) AS dbl_round
FROM generate_series(-3.5, 3.5, 1) as x;

select title, round(rental_rate / rental_duration, 2) 
from film 

select title, pg_typeof(rental_rate), pg_typeof(rental_duration) 
from film 

select title, round(rental_rate::float / rental_duration) 
from film 

select round(4/5, 2)

3.1 Отсортировать список фильмов по убыванию стоимости за день аренды (п.2)
- используйте order by (по умолчанию сортирует по возрастанию)
- desc - сортировка по убыванию

select title, round(rental_rate / rental_duration, 2) 
from film 
order by round(rental_rate / rental_duration, 2) desc

select title, round(rental_rate / rental_duration, 2) 
from film 
order by round(rental_rate / rental_duration, 2) --asc

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 2 desc

3.1* Отсортируйте таблицу платежей по возрастанию суммы платежа (amount)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- используйте order by 
- asc - сортировка по возрастанию 

select payment_id, amount 
from payment 
order by amount, payment_id

select payment_id, amount 
from payment 
order by amount asc, payment_id desc

3.2 Вывести топ-10 самых дорогих фильмов по стоимости за день аренды
- используйте limit

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc, title
limit 10

3.3 Вывести топ-10 самых дорогих фильмов по стоимости аренды за день, начиная с 58-ой позиции
- воспользуйтесь Limit и offset

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc, title
limit 10
offset 57

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc, title
offset 57
limit 10

-- dfhdfhfghfg
/* 
 * 
 * */

3.3* Вывести топ-15 самых низких платежей, начиная с позиции 14000
- воспользуйтесь Limit и Offset

select payment_id, amount
from payment 
order by 2 
offset 13999
limit 15
	
4. Вывести все уникальные годы выпуска фильмов
- воспользуйтесь distinct

select distinct customer_id
from customer 

select distinct release_year
from film 

4* Вывести уникальные имена покупателей
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- воспользуйтесь distinct

select distinct first_name, last_name
from customer 

select distinct on (c.first_name) c.first_name, c.last_name
from customer c
join (
	select first_name
	from customer 
	group by first_name
	having count(1) > 1) t on t.first_name = c.first_name
order by 1

5.1. Вывести весь список фильмов, имеющих рейтинг 'PG-13', в виде: "название - год выпуска"
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- "||" - оператор конкатенации, отличие от concat
- where - конструкция фильтрации
- "=" - оператор сравнения

char(12) inn
varchar(100)
text - сколько угодно символов максимум 1Гигабайт

select title, release_year
from film 
where rating = 'PG-13'

select title || ' - ' || release_year
from film 
where rating = 'PG-13'

select concat(title, ' - ', release_year), rating
from film 
where rating = 'PG-13'

select concat_ws(' - ', title, release_year, rating)
from film 
where rating = 'PG-13'

select 'Hello' || null

select concat('Hello', null)

5.2 Вывести весь список фильмов, имеющих рейтинг, начинающийся на 'PG'
- cast(название столбца as тип) - преобразование
- like - поиск по шаблону
- ilike - регистронезависимый поиск
- lower
- upper
- length

select concat(title, ' - ', release_year), rating
from film 
where rating like 'PG%'

select concat(title, ' - ', release_year), pg_typeof(rating)
from film 

select  pg_typeof(release_year)
from film 

домен - отношение - атрибут - кортеж

select concat(title, ' - ', release_year), rating
from film 
where cast(rating as text) like 'PG%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like 'PG%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like 'PG___'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like '%-%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text not like '%-%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like 'PG%' and character_length(rating::text) = 5

select concat(title, ' - ', release_year), rating
from film 
where rating::text ilike 'nc%' and character_length(rating::text) = 5

select concat(title, ' - ', release_year), rating
from film 
where rating::text ilike 'nc%ё%' escape 'ё' 

select concat(title, ' - ', release_year), rating
from film 
where upper(rating::text) like 'PG%'

select concat(title, ' - ', release_year), rating
from film 
where lower(rating::text) like 'pg%'

select concat(title, ' - ', release_year), rating
from film 
where lower(rating::text) like 'p%3'

select concat(title, ' - ', release_year), rating
from film 
where lower(rating::text) like 'p___3'

select ''''

5.2* Получить информацию по покупателям с именем содержашим подстроку'jam' (независимо от регистра написания), в виде: "имя фамилия" - одной строкой.
- "||" - оператор конкатенации
- where - конструкция фильтрации
- ilike - регистронезависимый поиск
- strpos
- character_length
- overlay
- substring
- split_part

select first_name, last_name
from customer 
where first_name ilike '%jam%'

select strpos('Hello world', 'world')

select character_length('Hello world')

select length('Hello world')

select overlay('Hello world' placing 'Max' from 
	strpos('Hello world', 'world') for character_length('world'))	
	
select overlay('Hello world' placing 'Max' from 7 for 5)	

select substring('Hello world', 3)

select split_part('Hello world and Max', ' ', 1),
	split_part('Hello world and Max', ' ', 2),
	split_part('Hello world and Max', ' ', 3),
	split_part('Hello world and Max', ' ', 4)
	
select left('Hello world and Max', 3)

select right('Hello world and Max', -1)

select initcap('hello world and.max')

6. Получить id покупателей, арендовавших фильмы в срок с 27-05-2005 по 28-05-2005 включительно
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- between - задает промежуток (аналог ... >= ... and ... <= ...)
- date_part()
- date_trunc()
- interval
- extract

date - дата без времени
timestamp - дата+время 
timestamptz - дата+время+часой пояс
time - время
interval - спец тип 

select customer_id, rental_date
from rental 
where rental_date >= '27-05-2005' and rental_date <= '28-05-2005'

select customer_id, rental_date
from rental 
where rental_date between '27-05-2005' and '28-05-2005'

'число-месяц-год' / 'год-месяц-число'
'год-месяц-число'

select customer_id, rental_date
from rental 
where rental_date between '27-05-2005'::timestamp and '28-05-2005'::timestamp 
order by 2 desc

select customer_id, rental_date
from rental 
where rental_date between '27-05-2005 00:00:00' and '28-05-2005 00:00:00'
order by 2 desc

select pg_typeof('27-05-2005')

select '27-05-2005'::timestamp

select customer_id, rental_date
from rental 
where rental_date between '27-05-2005 00:00:00' and '29-05-2005 00:00:00'
order by 2 desc

select customer_id, rental_date
from rental 
where rental_date between '27-05-2005' and '28-05-2005'::date + interval '1 day'
order by 2 desc

 + interval '100 day'
 
  + interval '3 month'

select customer_id, rental_date
from rental 
where rental_date between '27-05-2005' and '28-05-2005 24:00:00'
order by 2 desc

select customer_id, rental_date
from rental 
where rental_date::date between '27-05-2005' and '28-05-2005'
order by 2 desc

select customer_id, date(rental_date)
from rental 
where rental_date::date between '27-05-2005' and '28-05-2005'
order by 2 desc
  
6* Вывести платежи поступившие после 2005-07-08
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- > - строгое больше (< - строгое меньше)

select *
from payment
where payment_date::date > '2005-07-08'

select date_part('year', '28-05-2005'::date)

select date_part('month', '28-05-2005'::date)

select date_part('week', '28-05-2005'::date)

select date_part('minutes', '28-05-2005 18:25:14'::timestamp)

select date_trunc('year', '28-05-2005'::date)

select date_trunc('month', '28-05-2005'::date)

select date_trunc('week', '28-05-2005'::date)

select date_trunc('minutes', '28-05-2005 18:25:14'::timestamp)

select pg_typeof('28-05-2005 18:35:12'::timestamp - '26-05-2005 14:32:12'::timestamp)

select '28-05-2005 18:35:12'::timestamp - '26-05-2005 14:32:12'::timestamp

select pg_typeof('28-05-2005'::date - '26-05-2005'::date)

select '28-05-2005'::date - '26-05-2005'::date

select now()

select current_date

7 Получить количество дней с '30-04-2007' по сегодняшний день.
Получить количество месяцев с '30-04-2007' по сегодняшний день.
Получить количество лет с '30-04-2007' по сегодняшний день.

--дни:
select current_date - '30-04-2007'

select date_part('days', now() - '30-04-2007')

--Месяцы:
 select date_part('year', age(now(), '30-04-2007')) * 12 + 
 	date_part('month', age(now(), '30-04-2007'))

--Года:
select (current_date - '30-04-2007') / 365.

select date_part('year', now() - '30-04-2007')

select now() - '30-04-2007'

select date_part('year', age(now(), '30-04-2007'))

select age(now(), '30-04-2007')

select date_part('month', age(now(), '30-04-2007'))

select 14*12 + 7

select payment_id, customer_id, amount, payment_date
from payment 
where customer_id = 1 and (amount = 4.99 or amount = 2.99)

select payment_id, customer_id, amount, payment_date
from payment 
where (amount = 4.99 or amount = 2.99) and customer_id = 1

Оператор and имеет приоритет перед or 


split_part(значение, '@', 2)