-- EPL や他の クエリに置き換えやすくするため、極力 方言や with は使わないよう気をつける

with
    browsers as (
        select
            log.*,
            (case
                when ua is null then ''
                when ua = 'null' then ''
                -- Bot
                when instr(lower(ua), 'googlebot')            > 0 then 'Google Bot'
                when instr(lower(ua), 'linespider')           > 0 then 'LINE Search Bot'
                when instr(lower(ua), 'msnbot')               > 0 then 'MSN Bot'
                when instr(lower(ua), 'moatbot')              > 0 then 'Moat Bot'
                -- ^Mozilla/
                when regexp_like(ua, '^Mozilla/') then
                    (case
                        -- iPhone or iPad
                        when regexp_like(lower(ua), 'iphone|ipad') then
                            (case
                                when instr(lower(ua), 'sleipnir')   > 0 then 'Sleipnir'
                                when instr(lower(ua), 'chrome')     > 0 then 'Chrome'
                                when instr(lower(ua), 'safari')     > 0 then 'Safari'
                                else 'Unknown (iOS)'
                            end)
                        -- Android Browser
                        when instr(lower(ua), 'android') > 0 then
                            (case
                                when instr(lower(ua), 'chrome')     > 0 then 'Chrome (Android)'
                                when instr(lower(ua), 'firefox')    > 0 then 'Firefox (Android)'
                                else 'Unknown (Android)'
                            end)
                        -- Browser
                        when instr(lower(ua), 'msie')               > 0 then 'IE'
                        when instr(lower(ua), 'trident')            > 0 then 'IE 11'
                        when instr(lower(ua), 'edge')               > 0 then 'Edge'
                        when instr(lower(ua), 'vivaldi')            > 0 then 'Vivaldi'
                        when instr(lower(ua), 'sleipnir')           > 0 then 'Sleipnir'
                        when instr(lower(ua), 'puffin')             > 0 then 'Puffin'
                        when instr(lower(ua), 'silk')               > 0 then 'Silk'
                        when instr(lower(ua), 'oculusbrowser')      > 0 then 'OculusBrowser'
                        when instr(lower(ua), 'samsungbrowser')     > 0 then 'SamsungBrowser'
                        when instr(lower(ua), 'qtwebengine')        > 0 then 'QtWebEngine'
                        when instr(lower(ua), 'chromium')           > 0 then 'Chromium'
                        when instr(lower(ua), 'headlesschrome')     > 0 then 'HeadlessChrome'
                        when instr(lower(ua), 'chrome')             > 0 then 'Chrome'
                        when instr(lower(ua), 'safari')             > 0 then 'Safari'
                        when instr(lower(ua), 'firefox')            > 0 then 'Firefox'
                        when instr(lower(ua), 'opera')              > 0 then 'Opera'
                        when instr(lower(ua), 'palemoon')           > 0 then 'PaleMoon'
                        when instr(lower(ua), 'playstation 3')      > 0 then 'PS3'
                        when instr(lower(ua), 'playstation 4')      > 0 then 'PS4'
                        when instr(lower(ua), 'playstation vita')   > 0 then 'PS Vita'
                        when instr(lower(ua), 'nintendo wiiu')      > 0 then 'Wii U'
                        else 'Unknown'
                    end)
                else 'Invalid UA'
            end) as browser
        from
            access_log as log
    )
select
    b.*
from
    browsers as b
