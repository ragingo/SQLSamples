with
    target as (
        select
            4294967295 value,
            2 as prime
        from
            dual
    ),
    prime_factorization (value, prime, success) as (
        select
            value,
            prime,
            null
        from
            target
        union all
        select
            case
                when mod(value, prime) = 0 then value/prime
                else value
            end,
            case
                when mod(value, prime) = 0 then prime
                else prime + 1
            end,
            case
                when mod(value, prime) = 0 then 1
                else 0
            end
        from
            prime_factorization
        where
            value > 1 or (value = prime)
    )
select
    ((select value from target) ||
     ' = ' ||
     listagg(prime, ' * ') within group (order by prime)
    ) as result
from
    prime_factorization
where
    success = 1
group by
    null
;