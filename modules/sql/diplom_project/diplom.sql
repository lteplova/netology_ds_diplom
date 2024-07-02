SET search_path TO bookings;

-- 1. В каких городах больше одного аэропорта?

-- логика: использую агрегацию по столбцу Город, если город повторяется больше одного раза, значит аэропортов больше, чем один.

select *
from (select city, count(city)
	from airports a 
	group by city
	order by city) t
where t.count > 1


-- 2.  В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
-- Подзапрос

--логика: выбрать из таблицы с видами самолетов самолет с наибольшей дальностью (отсортировать от большего к меньшему и обрезать с помощью limit), 
--по коду судна присоединить таблицу с полетами, чтобы получить список кодов аэропортов, присоединить таблицу с аэропортами, чтобы вывести наименование аэропортов, 
--далее с помощью distinct выводим список уникальных из полученного, чтобы убрать дубли

select distinct a.airport_name from(
	select aircraft_code from aircrafts 
	order by "range" desc 
	limit 1
) t
join flights f on f.aircraft_code = t.aircraft_code
join airports a on a.airport_code = f.departure_airport or a.airport_code = f.arrival_airport 

-- 3. Вывести 10 рейсов с максимальным временем задержки вылета
-- Оператор LIMIT

--логика: вычитаем из фактического времени вылета планируемое время вылета, отсекаем NULL и сортируем в порядке убывания, отсекаем 10 первых значений

select flight_no, scheduled_departure, actual_departure, actual_departure - scheduled_departure as "время задержки вылета"
from flights
where (actual_departure - scheduled_departure) is not null
order by 4 desc 
limit 10

-- 4. Были ли брони, по которым не были получены посадочные талоны?
-- Верный тип JOIN

--логика: (вывели список уникальных броней, на которые не были получены посадочные талоны) 
--в таблице с посадочными талонами есть номера посадочных талонов и номера билетов, 
--присоединим таблицу с билетами и полетами с помощью правого соединения по номеру билету, 
--таблица с посадочными талонами будет обогащена и на местах отсутствия посадочного талона для билета появится NULL, если такие строки появились, 
--значит не было посадочного талона соответвующего билету, далее присоединяем таблицу с билетами, в которых есть номера броней, 
--чтобы получить список броней с отсутсвующими посадочными номерами.

select distinct t.book_ref 
from boarding_passes bp
right join ticket_flights tf on tf.ticket_no = bp.ticket_no 
join tickets t on t.ticket_no = tf.ticket_no
where bp.ticket_no is null

-- 5. Найдите количество свободных мест для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
--Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах в течении дня.
-- Оконная функция
-- Подзапросы или/и cte

-- логика: в первом cte находим общее количество мест в самолете определенной модели, во втором cte объединяем таблицу с полетами
-- с таблицей связей ticket_flights чтобы сопоставить билеты с полетами,  группируем по идентификатору полета (то есть рейсу) и подсчитываем количество билетов - это занятые места
-- далее высчитываем свободные места = общие места - занятые места,
-- высчитываем % соотношение свободных мест к общему кол-ву, по правилу пропорции (100% - кол-во всех мест, свободных мест - x)
-- с помощью оконной функции находим накопительную сумму, группируем по дню и по аэропорту

with cte1 as (
		select aircraft_code, count(aircraft_code)
		from seats
		group by aircraft_code
), 
cte2 as (
		select tf.flight_id, f.flight_no, f.actual_departure, f.aircraft_code, f.departure_airport, 
		count(tf.flight_id)
		from tickets t
		join ticket_flights tf on tf.ticket_no = t.ticket_no
		join flights f on f.flight_id = tf.flight_id 
		where f.actual_departure is not null
		group by tf.flight_id, f.actual_departure, f.flight_no, f.aircraft_code, f.departure_airport
	)
select  
	cte1.count - cte2.count as "количество свободных мест", 
	((cte1.count - cte2.count)*100)/cte1.count  as "% отношение св/общ",
	sum(cte2.count) over (partition by cte2.actual_departure::date, cte2.departure_airport order by cte2.actual_departure) as "накопительная сумма", 
	cte2.actual_departure, departure_airport
from cte2
join cte1 on cte1.aircraft_code = cte2.aircraft_code
where departure_airport = 'YKS'
order by 4


select f.flight_id as "id рейса", 
	f.aircraft_code as "Код самолета", 
	f.departure_airport as "Код аэропорта", 
	date(f.actual_departure) as "Дата вылета",
	(s.count_seats - bp.count_bp) as "Свободные места",
	round(((s.count_seats - bp.count_bp) * 100. / s.count_seats), 2) as "% от общего количества мест",
	sum(bp.count_bp) over (partition by date(f.actual_departure), f.departure_airport order by f.actual_departure) as "Накопительная",
	bp.count_bp as "Количество вылетевших пассажиров"
from flights f
left join (
	select bp.flight_id, count(bp.seat_no) as count_bp
	from boarding_passes bp
	group by bp.flight_id
	order by bp.flight_id) as bp on bp.flight_id = f.flight_id 
left join (
	select s.aircraft_code, count(*) as count_seats
	from seats s 
	group by s.aircraft_code) as s on f.aircraft_code = s.aircraft_code
where f.actual_departure is not null and bp.count_bp is not null and f.departure_airport = 'YKS'
order by date(f.actual_departure)

		
-- 6. Найдите процентное соотношение перелетов по типам самолетов от общего количества.
-- Подзапрос или окно
-- Оператор ROUND

--логика: подсчитываем количество перелетов по типу судна с помощью агрегации, умножаем найденное на 100 и делим на общее количество рейсов

select aircraft_code, 
round(((count(aircraft_code)*100)::numeric/(select count(flight_id) from flights)::numeric), 2) as "% соотношение"
from flights  
group by aircraft_code

-- 7. Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
-- CTE

--логика - делаем выборку номер рейса, стоимость, комфорт-класс, аэропорт прибытия и город данного аэропорта, 
--агрегируем по номеру рейса и высчитываем минимальную стоимость, подсчитываем сколько комфорт классов есть на рейсе (чтобы исключить рейсы с одним классом)
--выводим список по условию того, что минимальная стоимость равна равна стоимости и комфорт-класс при этом Бизнес-класс

with cte as
	(select tf.flight_id, tf.fare_conditions, tf.amount, f.arrival_airport, a.city
	from ticket_flights tf 
	join flights f on f.flight_id = tf.flight_id 
	join airports a on a.airport_code = f.arrival_airport)
select * from 
(select *,
	count (t.fare_conditions) over (partition by t.flight_id, t.city)
	from (select distinct (cte.flight_id), cte.city, cte.fare_conditions, 
	cte.amount,
	min(amount) over(partition by cte.flight_id)
	from cte) t
	) t1
where t1.count > 2
and t1.min = t1.amount 
and t1.fare_conditions like 'Business'





-- 8. Между какими городами нет прямых рейсов?
-- Декартово произведение в предложении FROM
-- Самостоятельно созданные представления (если облачное подключение, то без представления)
-- Оператор EXCEPT

--логика: создаем представление в котором с помощью декартового произведения формируем все пары городов из таблицы с аэропортами, 
-- формируем список город отправления и город прибытия на основе кодов аэропорта из таблицы полетов,
-- с помощью except вычисляем набор строк, которые присутствуют в результате левого запроса SELECT (выборка всех пар), но отсутствуют в результате правого (выборка город отправления и прибытия из таблицы полетов).

create view pairs as(
select 
	a1.city as "Город 1", 
	a2.city as "Город 2"
from airports a1
cross join airports a2
where a1.city < a2.city 
)

select * from pairs 
except 
select distinct a.city as "Город отправления", a2.city as "Город прибытия"
from flights f
join airports a on a.airport_code = f.departure_airport 
join airports a2 on a2.airport_code = f.arrival_airport 

-- 9. Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы *
-- Оператор RADIANS или использование sind/cosd
-- CASE 

--логика - соединяем таблицы с полетами, аэропортами, самолетами для того, чтобы построить маршруты рейсов и получить дальность полета конкретного судна.
-- Вычисляем расстояние между городами, сравниваем его с дальностью полета судна и  выводим результат сравнения с помощью case

select distinct f.departure_airport as "Аэропорт отправления", f.arrival_airport  as "Аэропорт прибытия", 
	round(((acos(sin(radians(a.latitude))*sin(radians(a2.latitude)) + cos(radians(a.latitude))*cos(radians(a2.latitude))*cos(radians(a.longitude) - radians(a2.longitude))))*6371)::numeric, 2) as "Расстояние между городами",
	a3.aircraft_code,
	a3.range as "Дальность полета",
	case when
	a3.range > round(((acos(sin(radians(a.latitude))*sin(radians(a2.latitude)) + cos(radians(a.latitude))*cos(radians(a2.latitude))*cos(radians(a.longitude) - radians(a2.longitude))))*6371)::numeric, 2)
	then 'Долетит'
	else 'Не долетит'
	end as "Сравнение"
from flights f
join airports a on a.airport_code = f.departure_airport 
join airports a2 on a2.airport_code = f.arrival_airport 
join aircrafts a3 on a3.aircraft_code = f.aircraft_code 
