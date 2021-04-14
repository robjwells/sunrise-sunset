-- Set the output format for SQLite.
.headers on
.mode column

-- The localtime modifier is needed, otherwise SQLite reports the time
-- in UTC.
select
    min(time(sunrise, 'localtime')) as "Earliest sunrise",
    max(time(sunrise, 'localtime')) as "Latest sunrise",
    min(time(sunset, 'localtime')) as "Earliest sunset",
    max(time(sunset, 'localtime')) as "Latest sunset"
from
    london
;
