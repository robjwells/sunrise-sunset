select
    time('now') >= time(sunrise) as "sun has risen"
from
    london
where
    date = date('now')
    and not exists (
        select
            date
        from
            successful_checks
        where
            kind = 'sunrise'
            and date = date('now')
    )
;
