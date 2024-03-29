CREATE TABLE if not exists london (
    date text primary key,
    sunrise text not null,
    sunset text not null
);
CREATE TABLE if not exists successful_checks (
    date text not null references london(date),
    kind text not null,
    primary key (kind, date),
    check (kind in ('sunrise', 'sunset'))
);
