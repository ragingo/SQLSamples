--wevtutil qe Application > f:\app.xml
--wevtutil qe Security > f:\sec.xml
-- 文字コードはUTF-8じゃないとだめ

use Sample;

/* -- データ取り込み
drop table EventLogXml;

select
	convert(xml, BulkColumn) as Doc
into
	EventLogXml
from
	openrowset(bulk N'f:\sec.xml', SINGLE_BLOB) as x
;

*/

declare @doc xml

set @doc = (select Doc from EventLogXml)

;

declare @doc2 xml

set @doc2 = 
	@doc.query('
		declare namespace e="http://schemas.microsoft.com/win/2004/08/events/event";
		for $Event in /Events/e:Event
			let $EventID   := xs:int(($Event/e:System/e:EventID)[1])
			let $Computer  := string(($Event/e:System/e:Computer)[1])
			let $Timestamp := string(($Event/e:System/e:TimeCreated/@SystemTime)[1])
			let $LogonType :=
				xs:int(
					if ( $EventID = 4624 or $EventID = 4634 ) then
						($Event/e:EventData/e:Data[@Name=''LogonType''])[1]
					else
						null[1]
				)
		return
			element rec { 
					attribute EventID {
						$EventID
					},
					attribute Computer {
						$Computer
					},
					attribute Timestamp {
						$Timestamp
					},
					attribute LogonType {
						$LogonType
					}
				}
	')
;

select
	evt.c.value('@EventID', 'int') as EventID,
	evt.c.value('@Computer', 'varchar(256)') as Computer,
	evt.c.value('@Timestamp', 'varchar(256)') as Timestamp,
	evt.c.value('@LogonType', 'int') as LogonType
from
	@doc2.nodes('/rec') as evt(c)
where
	evt.c.value('@EventID', 'int') in (4624, 4634)



