--Practice questions from https://pgexercises.com/

-----------------------------joins------------------------------------
select bks.starttime as start, facs.name as name
from cd.facilities facs
inner join cd.bookings bks 
on bks.facid = facs.facid
where facs.name in ('Tennis Court 1','Tennis Court 2')
and bks.starttime >= '2012-09-21' and bks.starttime < '2012-09-22'
order by bks.starttime;
------------------------------------------------------------------------
select distinct recs.firstname as firstname, recs.surname as surname
	from 
		cd.members mems
		inner join cd.members recs
			on recs.memid = mems.recommendedby
order by surname, firstname; 
------------------------------------------------------------------------
select mems.firstname as memfname, mems.surname as memsname, 
recs.firstname as recfname, recs.surname as recsname
	from 
		cd.members mems
		left outer join cd.members recs
			on recs.memid = mems.recommendedby
order by memsname, memfname; 
------------------------------------------------------------------------
select distinct concat(mems.firstname, ' ', mems.surname) as member, facs.name as facility
	from 
		cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		inner join cd.members mems
			on bks.memid = mems.memid
	where 
        facs.name in ('Tennis Court 1','Tennis Court 2')
order by member, facility;
------------------------------------------------------------------------
select concat(mems.firstname,' ',mems.surname) as member, facs.name as facility,
	case 
		when mems.memid = 0 then
			bks.slots*facs.guestcost
	else 
		bks.slots*facs.membercost
	end as cost
	
	from 
		cd.bookings bks
		inner join cd.members mems
			on bks.memid = mems.memid
		inner join cd.facilities facs
			on bks.facid = facs.facid
	where 
		bks.starttime >= '2012-09-14' and bks.starttime < '2012-09-15' and (
			(mems.memid = 0 and bks.slots*facs.guestcost > 30) or
			(mems.memid != 0 and bks.slots*facs.membercost > 30)
		)
		
order by cost desc;
------------------------------------------------------------------------
select distinct concat(mems.firstname, ' ', mems.surname) as member, 
(select concat(recs.firstname, ' ', recs.surname) as recommender
	from 
		cd.members recs
		where
		recs.memid = mems.recommendedby
 	)
	from cd.members mems
order by member; 
------------------------------------------------------------------------
select member, facility, cost from (
	select 
		concat(mems.firstname,' ',mems.surname) as member,
		facs.name as facility,
		case
			when mems.memid = 0 then
				bks.slots*facs.guestcost
			else
				bks.slots*facs.membercost
		end as cost
		from
			cd.members mems
			inner join cd.bookings bks
				on mems.memid = bks.memid
			inner join cd.facilities facs
				on bks.facid = facs.facid
		where
			bks.starttime >= '2012-09-14' and
			bks.starttime < '2012-09-15'
	) as bookings
	where cost > 30
order by cost desc;
------------------------------------------------------------------------
--Modifying Data
insert into cd.facilities (facid, name, membercost, guestcost, 
						   initialoutlay, monthlymaintenance)
values (9, 'Spa', 20, 30, 100000, 800);
------------------------------------------------------------------------
insert into cd.facilities (facid, name, membercost, guestcost, 
						   initialoutlay, monthlymaintenance)
values (9, 'Spa', 20, 30, 100000, 800),(10, 'Squash Court 2', 3.5, 17.5, 5000, 80);
------------------------------------------------------------------------
insert into cd.facilities (facid, name, membercost, guestcost, 
						   initialoutlay, monthlymaintenance)
select (select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800;
------------------------------------------------------------------------
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE name = 'Tennis Court 2';
------------------------------------------------------------------------
UPDATE cd.facilities
SET membercost = 6, guestcost = 30
WHERE name in ('Tennis Court 1','Tennis Court 2');
------------------------------------------------------------------------
UPDATE cd.facilities
SET membercost = membercost*1.1, guestcost = guestcost*1.1
WHERE name in ('Tennis Court 2');
                        --or
update cd.facilities facs
    set
        membercost = facs2.membercost * 1.1,
        guestcost = facs2.guestcost * 1.1
    from (select * from cd.facilities where facid = 0) facs2
    where facs.facid = 1;
------------------------------------------------------------------------
delete from cd.bookings;
------------------------------------------------------------------------
delete from cd.members where memid = 37;
------------------------------------------------------------------------
delete from cd.members where memid not in (select memid from cd.bookings);
----------------------------- Aggregates-----------------------------------
select count(*) from cd.facilities;
------------------------------------------------------------------------
select count(*) from cd.facilities where guestcost >= 10;
------------------------------------------------------------------------
select recommendedby, count(*) 
	from cd.members
	where recommendedby is not null
	group by recommendedby
order by recommendedby;
------------------------------------------------------------------------
select facid, sum(slots) as "Total Slots"
	from cd.bookings
	group by facid
order by facid;
------------------------------------------------------------------------
select facid, sum(slots) as "Total Slots"
	from cd.bookings
	where 
	starttime >= '2012-09-01' and starttime <= '2012-10-01'
	group by facid
order by sum(slots);
------------------------------------------------------------------------
select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
	group by facid, month
order by facid, month;
------------------------------------------------------------------------
select count(distinct memid) from cd.bookings;
------------------------------------------------------------------------
select facid, sum(slots) as "Total Slots"
	from cd.bookings
	group by facid
	having sum(slots) > 1000
order by facid;
------------------------------------------------------------------------
select distinct facs.name, sum(slots * case 
			when memid = 0 then
				facs.guestcost
			else
				facs.membercost
		end) as revenue
	from cd.bookings bks
	inner join cd.facilities facs
		on bks.facid = facs.facid
	group by facs.name
order by revenue;
------------------------------------------------------------------------
select name, revenue from (
	select facs.name, sum(case 
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end) as revenue
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.name
	) as agg where revenue < 1000
order by revenue;  
------------------------------------------------------------------------
with sum as (select facid, sum(slots) as totalslots
	from cd.bookings
	group by facid
)
select facid, totalslots 
	from sum
	where totalslots = (select max(totalslots) from sum);
------------------------------------------------------------------------
select facid, extract(month from starttime) as month, sum(slots) as slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
	group by rollup(facid, month)
order by facid, month;  
------------------------------------------------------------------------
select facs.facid, facs.name, 
	trim(to_char(sum(bks.slots)/2.0, '9999999999999999D99')) as "Total Hours"
	
	from cd.bookings bks
	inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.facid, facs.name
order by facs.facid
------------------------------------------------------------------------
select mems.surname, mems.firstname, mems.memid, min(bks.starttime) as starttime
	from cd.members mems 
	inner join cd.bookings bks 
		on mems.memid = bks.memid
	where bks.starttime >= '2012-09-01'
		group by mems.memid
order by mems.memid;
------------------------------------------------------------------------
select count(*) over(), firstname, surname
	from cd.members
order by joindate;
------------------------------------------------------------------------
select row_number() over(order by joindate), firstname, surname
	from cd.members
order by joindate;
------------------------------------------------------------------------
select facid, total from (
	select facid, sum(slots) total, rank() over (order by sum(slots) desc) rank
        	from cd.bookings
		group by facid
	) as ranked
	where rank = 1; 
------------------------------------------------------------------------
select firstname, surname,
	((sum(bks.slots)+10)/20)*10 as hours,
	rank() over (order by ((sum(bks.slots)+10)/20)*10 desc) as rank

	from cd.bookings bks
	inner join cd.members mems
		on bks.memid = mems.memid
	group by mems.memid
order by rank, surname, firstname;    

					---or---
select firstname, surname, hours, rank() over (order by hours desc) from
	(select firstname, surname,
		((sum(bks.slots)+10)/20)*10 as hours

		from cd.bookings bks
		inner join cd.members mems
			on bks.memid = mems.memid
		group by mems.memid
	) as subq
order by rank, surname, firstname;
------------------------------------------------------------------------
select name, rank from (
	select facs.name as name, rank() over (order by sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end) desc) as rank
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.name
	) as subq
	where rank <= 3
order by rank; 
------------------------------------------------------------------------
select 	facs.name as name,
	facs.initialoutlay/((sum(case
			when memid = 0 then slots * facs.guestcost
			else slots * membercost
		end)/3) - facs.monthlymaintenance) as months
	from cd.bookings bks
	inner join cd.facilities facs
		on bks.facid = facs.facid
	group by facs.facid
order by name; 
					---or---
select 	name, 
	initialoutlay / (monthlyrevenue - monthlymaintenance) as repaytime 
	from 
		(select facs.name as name, 
			facs.initialoutlay as initialoutlay,
			facs.monthlymaintenance as monthlymaintenance,
			sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end)/3 as monthlyrevenue
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.facid
	) as subq
order by name;
------------------------------------------------------------------------
select 	dategen.date,
	(
		-- correlated subquery that, for each day fed into it,
		-- finds the average revenue for the last 15 days
		select sum(case
			when memid = 0 then slots * facs.guestcost
			else slots * membercost
		end) as rev

		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		where bks.starttime > dategen.date - interval '14 days'
			and bks.starttime < dategen.date + interval '1 day'
	)/15 as revenue
	from
	(
		-- generates a list of days in august
		select 	cast(generate_series(timestamp '2012-08-01',
			'2012-08-31','1 day') as date) as date
	)  as dategen
order by dategen.date; 
----------------------------- Date-----------------------------------
select timestamp '2012-08-31 01:00:00';
------------------------------------------------------------------------
select timestamp '2012-08-31 01:00:00' - timestamp '2012-07-30 01:00:00' as interval;
------------------------------------------------------------------------
select cast(generate_series(timestamp '2012-10-01',
			'2012-10-31','1 day') as timestamp) as ts;
------------------------------------------------------------------------
select extract(day from timestamp '2012-08-31'); 
					---or
select date_part('day', timestamp '2012-08-31');
------------------------------------------------------------------------
select extract(epoch from (timestamp '2012-09-02 00:00:00' - '2012-08-31 01:00:00'));          
					---or (because epoch is postgres specific)---
select 	extract(day from ts.int)*60*60*24 +
	extract(hour from ts.int)*60*60 + 
	extract(minute from ts.int)*60 +
	extract(second from ts.int)
	from
		(select timestamp '2012-09-02 00:00:00' - '2012-08-31 01:00:00' as int) ts
------------------------------------------------------------------------
select 	extract(month from cal.month) as month,
	(cal.month + interval '1 month') - cal.month as length
	from
	(
		select generate_series(timestamp '2012-01-01', timestamp '2012-12-01', interval '1 month') as month
	) cal
order by month; 
------------------------------------------------------------------------
select (date_trunc('month',ts.testts) + interval '1 month') 
		- date_trunc('day', ts.testts) as remaining
	from (select timestamp '2012-02-11 01:00:00' as testts) ts;
------------------------------------------------------------------------
select starttime, starttime + slots*(interval '30 minutes') as endtime
	from cd.bookings
	order by endtime desc, starttime desc
	limit 10;
------------------------------------------------------------------------
select date_trunc('month', starttime) as month, count(*) 
	from cd.bookings
	group by month
	order by month;
------------------------------------------------------------------------
select name, month, 
	round((100*slots)/
		cast(
			25*(cast((month + interval '1 month') as date)
			- cast (month as date)) as numeric),1) as utilisation
	from  (
		select facs.name as name, date_trunc('month', starttime) as month, sum(slots) as slots
			from cd.bookings bks
			inner join cd.facilities facs
				on bks.facid = facs.facid
			group by facs.facid, month
	) as inn
order by name, month
----------------------------String--------------------------------------------
select surname || ', ' || firstname as name from cd.members;
------------------------------------------------------------------------
select * from cd.facilities where name like 'Tennis%';