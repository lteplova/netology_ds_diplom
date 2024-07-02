Задание 1. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 
года с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учета времени) 
с сортировкой по дате.

select staff_id, payment_date::date, sum(amount),
	sum(sum(amount)) over (partition by staff_id order by payment_date::date)
from payment 
where date_trunc('month', payment_date) = '01.08.2005'
group by staff_id, payment_date::date

Задание 2. 20.08.2005 года в магазинах проходила акция: покупатель каждого сотого платежа 
получал дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей, 
которые в день проведения акции получили скидку

select customer_id, row_number
from (
	select customer_id, row_number() over (order by payment_date)
	from payment 
	where payment_date::date = '20.08.2005') t
where row_number % 100 = 0 -- mod()

Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, 
которые попадают под условия:
· покупатель, арендовавший наибольшее количество фильмов;
· покупатель, арендовавший фильмов на самую большую сумму;
· покупатель, который последним арендовал фильм.

--explain analyze --6603
with c1 as (
	select c.customer_id, c3.country_id, count(i.film_id), sum(p.amount), max(r.rental_date)
	from customer c
	join rental r on r.customer_id = c.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join payment p on p.rental_id = r.rental_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id
	join country c3 on c3.country_id = c2.country_id
	group by c.customer_id, c3.country_id),
c2 as (
	select customer_id, country_id,
		row_number () over (partition by country_id order by count desc) cf,
		row_number () over (partition by country_id order by sum desc) sa,
		row_number () over (partition by country_id order by max desc) md
	from c1
)
select c.country, c_1.customer_id, c_2.customer_id, c_3.customer_id
from country c
left join c2 c_1 on c_1.country_id = c.country_id and c_1.cf = 1
left join c2 c_2 on c_2.country_id = c.country_id and c_2.sa = 1
left join c2 c_3 on c_3.country_id = c.country_id and c_3.md = 1
order by 1

explain analyze --4730
with c as (
	with c1 as (
		select c.customer_id, c3.country_id, count(i.film_id), sum(p.amount), max(r.rental_date),
		max(count(i.film_id)) over (partition by c3.country_id) mc, 
		max(sum(p.amount)) over (partition by c3.country_id) ma, 
		max(max(r.rental_date)) over (partition by c3.country_id) md,
		c3.country
		from customer c
		join rental r on r.customer_id = c.customer_id
		join inventory i on i.inventory_id = r.inventory_id
		join payment p on p.rental_id = r.rental_id
		join address a on a.address_id = c.address_id
		join city c2 on c2.city_id = a.city_id
		join country c3 on c3.country_id = c2.country_id
		group by c.customer_id, c3.country_id)
	select country_id, country,
		case 
			when count = mc then customer_id
		end a,
		case 
			when sum = ma then customer_id
		end b,
		case 
			when max = md then customer_id
		end c
	from c1)
select country.country, string_agg(a::text, ', '), string_agg(b::text, ', '), string_agg(c::text, ', ')
from country 
left join c on c.country_id = country.country_id
group by country.country
order by 1

explain analyze --4730
WITH AGGREGATION_TABLE AS
         (
             SELECT  CSTM.FIRST_NAME || ' ' || CSTM.LAST_NAME AS FULL_NAME
                  , CNTR.COUNTRY
                  , COUNT(INV.FILM_ID)                       AS CNT_FILM
                  , SUM(P.AMOUNT)                            AS SUM_AMOUNT
                  , MAX(R.RENTAL_DATE)                       AS LAST_RENTAL
             FROM PUBLIC.PAYMENT        P
                  JOIN PUBLIC.RENTAL    R ON P.RENTAL_ID = R.RENTAL_ID
                  JOIN PUBLIC.INVENTORY INV ON R.INVENTORY_ID = INV.INVENTORY_ID
                  JOIN PUBLIC.CUSTOMER  CSTM ON CSTM.CUSTOMER_ID = P.CUSTOMER_ID
                  JOIN PUBLIC.ADDRESS   A ON A.ADDRESS_ID = CSTM.ADDRESS_ID
                  JOIN PUBLIC.CITY      CT ON A.CITY_ID = CT.CITY_ID
                  JOIN PUBLIC.COUNTRY   CNTR ON CT.COUNTRY_ID = CNTR.COUNTRY_ID
--              WHERE CNTR.COUNTRY = 'Algeria'
             GROUP BY CSTM.LAST_NAME, CSTM.FIRST_NAME, CNTR.COUNTRY
         )
, NUMBERING_TABLE AS
    (
        SELECT  COUNTRY
             , FULL_NAME
             , ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY CNT_FILM DESC )    AS RN_CNT_FILM
             , ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY SUM_AMOUNT DESC )  AS RN_SUM_AMOUNT
             , ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY LAST_RENTAL DESC ) AS RN_LAST_RENTAL
        FROM AGGREGATION_TABLE
    )
SELECT DISTINCT
       COUNTRY                                                                            AS "Страна"
    , max (CASE WHEN RN_CNT_FILM = 1 THEN FULL_NAME END ) OVER (PARTITION BY COUNTRY)     AS "Покупател, арендовавший наибольнее кол-во фильмов"
    , max (CASE WHEN RN_SUM_AMOUNT = 1 THEN FULL_NAME END ) OVER (PARTITION BY COUNTRY)   AS "Покупател, арендовавший фильмов на самую большую сумму"
    , max (CASE WHEN RN_LAST_RENTAL = 1 THEN FULL_NAME END ) OVER (PARTITION BY COUNTRY)  AS "Покупател, который последним арендовал фильм"
FROM NUMBERING_TABLE
ORDER BY COUNTRY;

explain analyze --1271
WITH t1 as(
SELECT cr.country
		,ag.customer_id
		,ag.customer_name
		,ag.pcount
		,ag.psum
		,ag.maxp_date
		,ag.maxpid
		,ag.maxr_date
		,ag.maxrid
FROM (
SELECT 
		c.customer_id,
		c.address_id 
		,concat(c.last_name,  ' ', c.first_name ) AS customer_name
		,count(r.rental_id) AS pcount
		,sum(p.amount) AS psum
		,MAX(p.payment_date) AS maxp_date
		,MAX(p.payment_id)  AS maxpid
		,MAX(r.rental_id)  AS maxrid
		,MAX(r.rental_date)  AS maxr_date
FROM customer c 
LEFT JOIN payment p ON c.customer_id = p.customer_id 
LEFT JOIN rental r ON r.customer_id = c.customer_id  AND r.rental_id = p.rental_id 
group BY c.customer_id 
) AS ag
JOIN address a ON ag.address_id = a.address_id 
JOIN city ct ON ct.city_id = a.city_id 
LEFT JOIN country cr ON cr.country_id = ct.country_id
),
t2 AS 
(SELECT t1.country
		,t1.customer_name
		,t1.pcount
		,max(t1.pcount) OVER(PARTITION BY t1.country) AS max_count 
		,t1.psum
		,max(t1.psum) OVER(PARTITION BY t1.country) AS max_sum 
--		,t1.maxp_date
--		,MAX(t1.maxp_date) OVER(PARTITION BY t1.country) AS max_payment_date
--		,t1.maxpid
--		,MAX(t1.maxpid) OVER(PARTITION BY t1.country) AS max_payment_id
		,t1.maxr_date
		,MAX(t1.maxr_date) OVER(PARTITION BY t1.country) AS max_rental_date
		,t1.maxrid
		,MAX(t1.maxrid) OVER(PARTITION BY t1.country) AS max_rental_id
FROM t1
 )
SELECT  * FROM 	
(SELECT t2.country, t2.customer_name AS "наибольшее количество фильмов" FROM t2 WHERE t2.pcount = t2.max_count )AS ct
JOIN 
(SELECT t2.country, t2.customer_name AS "на самую большую сумму" FROM t2 WHERE t2.psum = t2.max_sum )AS sm USING(country)
JOIN 
(SELECT t2.country, t2.customer_name AS "последним арендовал фильм" FROM t2 WHERE t2.maxrid = t2.max_rental_id)AS pd USING(country)
ORDER BY country 

Задание 1. Откройте по ссылке SQL-запрос.
· Сделайте explain analyze этого запроса.
· Основываясь на описании запроса, найдите узкие места и опишите их.
· Сравните с вашим запросом из основной части (если ваш запрос изначально укладывается в 15мс — отлично!).
· Сделайте построчное описание explain analyze на русском языке оптимизированного запроса. 
Описание строк в explain можно посмотреть по ссылке.

explain analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc

explain analyze
select  cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) 
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
group by cu.customer_id
order by 2 desc

Задание 2. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.

select *
from (
	select *, row_number() over (partition by staff_id order by payment_date)
	from payment) t 
where row_number = 1

Задание 3. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
· день, в который арендовали больше всего фильмов (в формате год-месяц-день);
· количество фильмов, взятых в аренду в этот день;
· день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
· сумму продажи в этот день.

store_id - кто прав?

select *
from (
	select i.store_id, r.rental_date::date, count(i.film_id), 
		row_number() over (partition by i.store_id order by count(i.film_id) desc) r_c
	from rental r 
	join inventory i on i.inventory_id = r.inventory_id
	group by i.store_id, r.rental_date::date) t
where r_c = 1

select *
from (
	select i.store_id, p.payment_date::date, sum(p.amount), 
		row_number() over (partition by i.store_id order by sum(p.amount)) p_s
	from rental r 
	join inventory i on i.inventory_id = r.inventory_id
	join payment p on p.rental_id = r.rental_id
	group by i.store_id, p.payment_date::date) t
where p_s = 1

from payment p
join staff s on s.staff_id = p.staff_id

--explain analyze
select *
from (
	select i.store_id, r.rental_date::date, count(i.film_id), 
		row_number() over (partition by i.store_id order by count(i.film_id) desc) r_c
	from rental r 
	join inventory i on i.inventory_id = r.inventory_id
	group by i.store_id, r.rental_date::date) t1
join (
	select i.store_id, p.payment_date::date, sum(p.amount), 
		row_number() over (partition by i.store_id order by sum(p.amount)) p_s
	from rental r 
	join inventory i on i.inventory_id = r.inventory_id
	join payment p on p.rental_id = r.rental_id
	group by i.store_id, p.payment_date::date) t2 on t1.store_id = t2.store_id
where p_s = 1 and r_c = 1

--explain analyze
select *
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

explain analyze
select *
from (
	select s.store_id, r.rental_date::date, count(r.rental_id), 
		row_number() over (partition by s.store_id order by count(r.rental_id) desc) r_c
	from rental r 
	join payment p on p.rental_id = r.rental_id
	join staff s on s.staff_id = p.staff_id
	group by s.store_id, r.rental_date::date) t1
join (
	select s.store_id, p.payment_date::date, sum(p.amount), 
		row_number() over (partition by s.store_id order by sum(p.amount)) p_s
	from payment p 
	join staff s on s.staff_id = p.staff_id
	group by s.store_id, p.payment_date::date) t2 on t1.store_id = t2.store_id
where p_s = 1 and r_c = 1

select customer_id, payment_date,
	row_number() over (partition by customer_id order by payment_date),
	sum(amount) over (partition by customer_id order by payment_date),
	min(amount) over (partition by customer_id order by payment_date),
	max(amount) over (partition by customer_id order by payment_date),
	avg(amount) over (partition by customer_id order by payment_date)
from payment 

select customer_id, payment_date,
	row_number() over w,
	sum(amount) over w,
	min(amount) over w,
	max(amount) over w,
	avg(amount) over w
from payment 
window w as (partition by customer_id order by payment_date)

create materialized view zoom_task as
	select t1.store_id, rental_date, count, payment_date, sum 
	from (
		select i.store_id, r.rental_date::date, count(i.film_id), 
			row_number() over (partition by i.store_id order by count(i.film_id) desc) r_c
		from rental r 
		join inventory i on i.inventory_id = r.inventory_id
		group by i.store_id, r.rental_date::date) t1
	join (
		select i.store_id, p.payment_date::date, sum(p.amount), 
			row_number() over (partition by i.store_id order by sum(p.amount)) p_s
		from rental r 
		join inventory i on i.inventory_id = r.inventory_id
		join payment p on p.rental_id = r.rental_id
		group by i.store_id, p.payment_date::date) t2 on t1.store_id = t2.store_id
	where p_s = 1 and r_c = 1
	
create table mat_aud (
	id serial primary key,
	mat_name varchar(50) not null,
	refresh_time timestamp default now()
)

create or replace function mat_foo() returns text as $$
begin
	refresh materialized view zoom_task;
	insert into mat_aud(mat_name) values ('zoom_task');
	return null;
end;
$$ language plpgsql

select mat_foo()

select * from mat_aud

drop все cascade * 2


SET PGPASSWORD=123
"c:\program files\postgresql\10\bin\psql.exe"
-h localhost -p 5433 -U postgres -d postgres
-c "select mat_foo();"

-c "set search_path to ""название_схемы"";"

explain analyze
with cte1 as (select first_name || ' ' || last_name as full_name
 		from actor_info ai 
 		where ai.film_info like '%Animation:%')
 select full_name
 from cte1;
