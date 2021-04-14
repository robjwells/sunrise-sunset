begin;

create table successful_checks (
    date text not null references london(date),
    kind text not null,
    primary key (kind, date),
    check (kind in ('sunrise', 'sunset'))
);

commit;
