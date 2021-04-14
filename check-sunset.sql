select
    time('now') >= time(sunset) as "sun has set"
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
            kind = 'sunset'
            and date = date('now')
    )
;
