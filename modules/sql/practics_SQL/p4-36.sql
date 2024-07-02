create database название_базы_данных

create schema lecture_4

set search_path to lecture_4

======================== Создание таблиц ========================
1. Создайте таблицу "автор" с полями:
- id 
- имя
- псевдоним (может не быть)
- дата рождения
- город рождения
- родной язык
* Используйте 
    CREATE TABLE table_name (
        column_name TYPE column_constraint,
    );
* для id подойдет serial, ограничение primary key
* Имя и дата рождения - not null
* город и язык - внешние ключи

create table author (
	author_id serial primary key,
	author_name varchar(100) not null unique,
	nick_name varchar(100),
	born_date date not null check(date_part('year', born_date) > 1600),
	city_id int not null references city(city_id), --on delete cascade,
	--language_id int not null references language(language_id),
	create_date timestamp not null default now(),
	--deleted boolean not null default false
	deleted int2 not null default 0 check(deleted in (0, 1))
)




select * 
from author
where deleted 

boolean 0/1 yes/no true/false t/f

id | название_таблицы | сгенерированный идентификатор | тип_шифрования | соль 

1*  Создайте таблицы "Язык", "Город", "Страна".
* для id подойдет serial, ограничение primary key
* названия - not null и проверка на уникальность

create table city (
	city_id serial primary key,
	city_name varchar(100) not null,
	country_id int not null references country(country_id),
	create_date timestamp not null default now(),
	deleted int2 not null default 0 check(deleted in (0, 1))
)

create table country (
	country_id serial primary key,
	country_name varchar(100) not null,
	create_date timestamp not null default now(),
	deleted int2 not null default 0 check(deleted in (0, 1))
)

create table language (
	language_id serial primary key,
	language_name varchar(100) not null,
	create_date timestamp not null default now(),
	deleted int2 not null default 0 check(deleted in (0, 1))
)

create table language (
	language_id int primary key generated always as identity,
	language_name varchar(100) not null,
	create_date timestamp not null default now(),
	deleted int2 not null default 0 check(deleted in (0, 1))
)
	
	select *
	from author
	where deleted 
	
	boolean 0/1 yes/no true/false t/f


======================== Заполнение таблицы ========================

2. Вставьте данные в таблицу с языками:
'Русский', 'Французский', 'Японский'
* Можно вставлять несколько строк одновременно:
    INSERT INTO table (column1, column2, …)
    VALUES
     (value1, value2, …),
     (value1, value2, …) ,...;

insert into language(language_name)
values ('Русский'), ('Французский'), ('Японский')

select * from language

--плохая практика
insert into language
values (4, 'Немецкий')

insert into language(language_id, language_name)
values (4, 'Немецкий')

insert into language(language_name)
values ('Монгольский')

insert into language(language_name)
values ('Немецкий')

insert into language
values (4, 'Китайский')

insert into language
values (400, 'Украинский')

-- демонстрация работы счетчика и сброс счетчика

alter sequence language_language_id_seq restart with 1000

insert into language(language_name)
values ('Голандский')

select * from language	

drop table language

2.1 Вставьте данные в таблицу со странами из таблиц country базы dvd-rental:

insert into country(country_name)
select country from public.country order by country_id

select * from country

2.2 Вставьте данные в таблицу с городами соблюдая связи из таблиц city базы dvd-rental:

insert into city(city_name, country_id)
select city, country_id from public.city order by city_id

select distinct on (city) city, country_id from public.city order by city_id

select * 
from city c 
join country c2 on c2.country_id = c.country_id

2.3 Вставьте данные в таблицу с авторами, идентификаторы языков и городов оставьте пустыми.
Жюль Верн, 08.02.1828
Михаил Лермонтов, 03.10.1814
Харуки Мураками, 12.01.1949

insert into author(author_name, nick_name, born_date, city_id)
values ('Жюль Верн', null, '08.02.1828', 1),
	('Михаил Лермонтов', 'Диарбекир', '03.10.1514', 56),
	('Харуки Мураками', null, '12.01.1949', 80)
	
insert into author(author_name, nick_name, born_date, city_id)
values ('Жюль Верн', null, '08.02.1828', 1),
	('Михаил Лермонтов', 'Диарбекир', '03.10.1814', 56),
	('Харуки Мураками', null, '12.01.1949', 80)
	
insert into author(author_name, nick_name, born_date, city_id)
values ('Жюль Верн 2', null, '08.02.1828', (select city_id from city where city_name = 'Abu Dhabi'))
	
select * from author a

======================== Модификация таблицы ========================

3. Добавьте поле "идентификатор языка" в таблицу с авторами
* ALTER TABLE table_name 
  ADD COLUMN new_column_name TYPE;

-- добавление нового столбца
alter table author add column language_id int 

-- удаление столбца
alter table author drop column language_id 

-- добавление ограничения not null
alter table author alter column language_id set not null

select * from author a

-- удаление ограничения not null
alter table author alter column language_id drop not null

-- добавление ограничения unique
alter table author add constraint lang_unique unique(language_id)

-- удаление ограничения unique
alter table author drop constraint lang_unique

-- изменение типа данных столбца
alter table author alter column language_id type text

alter table author alter column language_id type int using(language_id::int)

select pg_typeof(author_name) from author 

alter table author alter column author_name type varchar(150)

update pg_attribute set atttypmod = 154
where attrelid = 'author'::regclass and attname = 'author_name';
 
 3* В таблице с авторами измените колонку language_id - внешний ключ - ссылка на языки
 * ALTER TABLE table_name ADD CONSTRAINT constraint_name constraint_definition
 
alter table author add constraint lang_author_fkey foreign key (language_id)
	references language(language_id)

 ======================== Модификация данных ========================

4. Обновите данные, проставив корректное языки писателям:
Жюль Габриэль Верн - Французский
Михаил Юрьевич Лермонтов - Российский
Харуки Мураками - Японский
* UPDATE table
  SET column1 = value1,
   column2 = value2 ,...
  WHERE
   condition;
  
select * from author a

select * from "language" l

update author
set language_id = 2
where author_id = 3

update author
set language_id = 1
where author_id = 3

update author
set language_id = 2
where author_id in (3,6)

update author
set language_id = 3
where author_id = (select author_id from author where author_name = 'Харуки Мураками')

4*. Дополните оставшие связи по городам:

select * from author a

 ======================== Удаление данных ========================
 
5. Удалите Лермонтова

delete from author
where author_id = 4

5.1 Удалите все города

delete from city
where city_id = 1

drop table city cascade

drop table author

----------------------------------------------------------------------------

explain analyze  --320.86
select distinct customer_id 
from payment
where amount > 10

create table payment_new (like payment) partition by range (amount)

create table payment_low partition of payment_new for values from (minvalue) to (10)

create table payment_high partition of payment_new for values from (10) to (maxvalue)

insert into payment_new
select* from payment

explain analyze
select * from payment_new

select * from only payment_new

explain analyze  --3.5
select distinct customer_id 
from payment_high

select * from payment_new

select * from payment_high