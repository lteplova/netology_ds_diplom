--Передавать другим студентам, выкладывать в общий доступ и так далле НЕЛЬЗЯ.

--В каких городах больше одного аэропорта?
select city, count (airport_name) 
from airports 
group by city 
having count (airport_name) > 1;

--В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
select distinct airport_name as "Аэропорты"
from airports
inner join flights on airports.airport_code = flights.arrival_airport
inner join aircrafts on flights.aircraft_code = aircrafts.aircraft_code
where aircrafts.range = (select max(range) from aircrafts);

--Вывести 10 рейсов с максимальным временем задержки вылета
select flight_id, scheduled_departure, actual_departure, (actual_departure - scheduled_departure) as time
from flights where actual_departure is not null
order by time desc
limit 10;

--Были ли брони, по которым не были получены посадочные талоны?
select count(bookings.book_ref)
from bookings
full outer join tickets on bookings.book_ref = tickets.book_ref
full outer join boarding_passes on boarding_passes.ticket_no = tickets.ticket_no
where boarding_passes.boarding_no is null;

--Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное количество вывезенных пассажиров из аэропорта за день. Т.е. в этом столбце должна отражаться сумма - 
--сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за сегодняшний день
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
where f.actual_departure is not null and bp.count_bp is not null
order by date(f.actual_departure)

--Найдите процентное соотношение перелетов по типам самолетов от общего количества.
select aircrafts.model as "Модель самолета", aircrafts.aircraft_code, 
round((count(flights.flight_id)::numeric)*100 / (select count(flights.flight_id) from flights)::numeric, 2) as "Доля перелетов"
from aircrafts
join flights on aircrafts.aircraft_code = flights.aircraft_code
group by aircrafts.aircraft_code
order by "Доля перелетов" desc;

вариант 2:
select aircrafts.model as "Модель самолета", aircrafts.aircraft_code, 
round((count(flights.flight_id)::numeric)*100 / sum(count(flights.flight_id)) over (), 2) as "Доля перелетов"
from aircrafts
join flights on aircrafts.aircraft_code = flights.aircraft_code
group by aircrafts.aircraft_code
order by "Доля перелетов" desc;

--Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?

 with econom as
	(select flight_id, max(amount)
	from ticket_flights
	where fare_conditions = 'Economy'
	group by flight_id),
business as
	(select flight_id, min(amount) as min
	from ticket_flights
	where fare_conditions = 'Business' 
	group by flight_id)
select e.flight_id, min, max, a1.city, a2.city
from econom e
join business b on e.flight_id = b.flight_id
left join flights f on e.flight_id = f.flight_id and b.flight_id = f.flight_id
left join airports a1 on a1.airport_code = f.arrival_airport
left join airports a2 on a2.airport_code = f.departure_airport
where max > min;

select fv.departure_city, fv.arrival_city
from (
	select flight_id
	from ticket_flights
	group by flight_id
	having max(amount) filter (where fare_conditions = 'Economy') > min(amount) filter (where fare_conditions = 'Business')) t 
join flights_v fv on fv.flight_id = t.flight_id

--Между какими городами нет прямых рейсов?
create view route as 
	select distinct a.city as departure_city , b.city as arrival_city, a.city||'-'||b.city as route 
	from airports as a, (select city from airports) as b
	where a.city != b.city
	--where a.city > b.city если хотим убрать зеркальные варианты
	order by route
	
create view direct_flight as 
	select distinct a.city as departure_city, aa.city as arrival_city, a.city||'-'|| aa.city as route  
	from flights as f
	inner join airports as a on f.departure_airport=a.airport_code
	inner join airports as aa on f.arrival_airport=aa.airport_code
	order by route
	
select r.* 
from route as r
except 
select df.* 
from direct_flight as df

--Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы
select departure_airport, a1.latitude as x, arrival_airport, a2.longitude as y, 
(acos(sin(radians(a1.latitude))*sin(radians(a2.latitude)) +cos(radians(a1.latitude))*
cos(radians(a2.latitude))*cos(radians(a1.longitude - a2.longitude)))*6371)::integer as "Расстояние", range
from 
	(select distinct departure_airport, arrival_airport, aircraft_code 
	from flights) as foo
join airports a1 on foo.departure_airport = a1.airport_code
join airports a2 on foo.arrival_airport = a2.airport_code
join aircrafts on aircrafts.aircraft_code = foo.aircraft_code
order by arrival_airport