1. Úloha IOS (2019)

Popis úlohy
Cílem úlohy je vytvorit skript pro analýzu záznamu webového serveru. Skript bude filtrovat záznamy a poskytovat statistiky podle zadání úživatele.
Specifikace chování skriptu

JMÉNO
• wana - analyzátor webových logu

POUŽITÍ
• wana [FILTR] [PRÍKAZ] [LOG [LOG2 [...]]

VOLBY
• PRÍKAZ muže být jeden z:

	– list-ip – výpis seznamu zdrojových IP adres.
	– list-hosts – výpis seznamu zdrojových doménových jmen.
	– list-uri – výpis seznamu cílových zdroju (URI).
	– hist-ip – výpis histogramu cetností dotazu podle zdrojových IP adres.
	– hist-load – výpis histogramu záteže (tj. poctu dotazu ve jednotlivých casových intervalech).

• FILTR muže být kombinace následujících:


	– -a DATETIME – after = jsou uvažovány pouze záznamy PO tomto datu (bez tohoto data). DATETIME je formátu YYYY-MM-DD HH:MM:SS.
	– -b DATETIME – before, jsou uvažovány pouze záznamy PRED tímto datem (bez tohodo data).
	– -ip IPADDR – jsou uvažovány pouze záznamy odpovídající požadavkum ze zdrojové adresy IPADDR. Formát IPADDR odpovídá IPv4 nebo IPv6.
	– -uri URI – jsou uvažovány pouze záznamy týkající se dotazu na konkrétní webovou stránku. URI je základní regulární výraz.
	
POPIS

1. Skript filtruje záznamy z webového serveru. Pokud je skriptu zadán také príkaz, nad filtrovanými záznamy daný príkaz provede.

2. Pokud skript nedostane ani filtr ani príkaz, opisuje záznamy na standardní výstup.

3. Skript umí zpracovat záznamy webového serveru komprimované pomocí nástroje gzip (v prípade, že název souboru koncí .gz).1

4. V prípade, že skript na príkazové rádce nedostane soubory se záznamy webového serveru (LOG, LOG2 . . . ), ocekává záznamy na standardním vstupu.

5. Pokud má skript vypsat seznam, každá položka je vypsána na jeden rádek a pouze jednou. Na poradí nezáleží. Položky se nesmí opakovat.

6. Vícerádkový histogram je vykreslen pomocí ASCII a je otocený doprava. Každý rádek histogramu udává kategorii (napr. IP adresu nebo casový
interval). Cetnost dané kategorie je vyobrazena posloupností znaku mrížky #. Formát je "%s (%d): %s", kde první argument identifikuje kategorii,
druhý je cetnost v císelné podobe a tretí je cetnost vykreslená pomocí mrížek.

7. Histogram podle IP adres (hist-ip) je serazen od nejcetnejších po nejméne cetné dotazy.

8. Histogram záteže (hist-load) má jednotlivé casové intervaly po celých hodinách. Do dané kategorie spadají všechny záznamy pocínající danou
hodinou. V histogramu budou pouze casové údaje s nenulovým výskytem záznamu. Formát kategorie je YYYY-MM-DD HH:00. Celkový casový rozsah
je dán casovým rozsahem vstupních nebo filtrovaných záznamu.

9. URI je identifikátor, který se v záznamu nachází za identifikátorem metody protokolu HTTP, viz RFC2616, Sec. 9.

PODROBNÉ POŽADAVKY

	1. Skript analyzuje záznamy (logy) pouze ze zadaných souboru.
	2. Skript žádný soubor nemodifikuje. Skript nepoužívá docasné soubory.
	3. IP adresa muže být IPv4 (napr. 147.229.176.19), IPv6 standardního
		(napr. 2001:67c:1220:8b0:0:0:93e5:b013) nebo IPv6 komprimovaného
		(napr. 2001:67c:1220:8b0::93e5:b013) formátu (viz RFC 1884, sekce 2.2).
	4. Skript nebere ohled na význam IP adres. IP adresy rozlišuje podle jejich textové reprezentace.
	5. Skript neuvažuje casové zóny. Predpokládá se, že všechny záznamy i filtry podle data mají casovou znacku ve stejné casové zóne.
	6. Doménové jméno podle IP adresy zjistete pomocí príkazu host. Pokud nelze doménové jméno získat, bude místo nej použita IP adresa.

NÁVRATOVÁ HODNOTA

	• Skript vrací úspech v prípade úspešné operace. Interní chyba skriptu nebo chybné argumenty budou doprovázeny chybovým hlášením a neúspešným návratovým kódem.

Implementacní detaily

	• Skript by mel mít v celém behu nastaveno POSIXLY_CORRECT=yes.
	• Skript by mel bežet na všech bežných shellech (dash, ksh, bash). Mužete použít GNU rozšírení pro sed ci awk. Jazyk Perl nebo Python povolen není.
	• Skript musí bežet na bežne dostupných OS GNU/Linux, BSD a MacOS. Studentum je k dispozici virtuální stroj s obrazem ke stažení zde: http://www.fit.vutbr.cz/~lengal/public/trusty.ova (pro VirtualBox, login: trusty / heslo: trusty), na kterém lze overit správnou funkcnost projektu.
	• Skript nesmí používat docasné soubory. Povoleny jsou docasné soubory neprímo tvorené príkazem sed (napr. argument sed -i). Príklady použití
	• Ukázky záznamu webového serveru jsou dostupné zde: https://pajda.fit.vutbr.cz/ios/ios-19-1-logs

Príklady:

	$ ./wana list-ip ios-example.com.access.log
	147.229.13.201
	198.27.69.191
	2001:67c:1220:808::93e5:8ad
	2001:67c:1220:80c:d4:985a:df2c:d717
	40.77.167.115
	66.249.66.45
	66.249.66.49
	82.202.69.253
	
	$ ./wana list-hosts ios-example.com.access.log
	hele.fit.vutbr.cz.
	ns504614.ip-198-27-69.net.
	perchta.fit.vutbr.cz.
	2001:67c:1220:80c:d4:985a:df2c:d717
	msnbot-40-77-167-115.search.msn.com.
	crawl-66-249-66-45.googlebot.com.
	crawl-66-249-66-49.googlebot.com.
	82.202.69.253

	$ ./wana -a "2019-02-22 09:00" -b "2019-02-22 09:44:54" ios-example.com.access.log
	147.229.13.201 - - [22/Feb/2019:09:24:33 +0100] "-" 408 3275 "-" "-"
	147.229.13.201 - - [22/Feb/2019:09:24:33 +0100] "-" 408 3275 "-" "-"
	198.27.69.191 - - [22/Feb/2019:09:43:13 +0100] "GET / HTTP/1.1" 200 22311 "-" "Mozilla/5.0 (
	198.27.69.191 - - [22/Feb/2019:09:43:24 +0100] "GET / HTTP/1.1" 200 22313 "-" "Mozilla/5.0 (
	198.27.69.191 - - [22/Feb/2019:09:43:42 +0100] "GET /?gf_page=upload HTTP/1.1" 200 22304 "-" 
	198.27.69.191 - - [22/Feb/2019:09:44:07 +0100] "GET / HTTP/1.1" 200 22313 "-" "Mozilla/5.0 (
	198.27.69.191 - - [22/Feb/2019:09:44:37 +0100] "GET /?up_auto_log=true HTTP/1.1" 200 22315 "-"
	
	$ ./wana -a "2019-02-22 09:00" -b "2019-02-22 09:44:54" list-uri ios-example.com.access.log
	/
	/?gf_page=upload
	/?up_auto_log=true
	
	$ ./wana hist-ip ios-example.com.access.log
	198.27.69.191 (8): ########
	2001:67c:1220:80c:d4:985a:df2c:d717 (4): ####
	82.202.69.253 (2): ##
	2001:67c:1220:808::93e5:8ad (2): ##
	147.229.13.201 (2): ##
	66.249.66.49 (1): #
	66.249.66.45 (1): #
	40.77.167.115 (1): #
	
	$ ./wana -ip 2001:67c:1220:808::93e5:8ad hist-load ios-example.com.access.log.1
	2019-02-21 08:00 (1): #
	2019-02-21 10:00 (1): #
	2019-02-21 14:00 (1): #
	2019-02-21 16:00 (1): #
	2019-02-21 19:00 (1): #
	2019-02-21 20:00 (1): #
	2019-02-21 22:00 (1): #
	2019-02-21 23:00 (1): #
	2019-02-22 02:00 (1): #
	2019-02-22 03:00 (2): ##
	2019-02-22 05:00 (1): #
	2019-02-22 07:00 (1): #
	
	$ ./wana -uri "/robots\.txt" list-hosts *log*
	msnbot-157-55-39-15.search.msn.com.
	msnbot-157-55-39-17.search.msn.com.
	msnbot-157-55-39-25.search.msn.com.
	msnbot-157-55-39-31.search.msn.com.
	msnbot-157-55-39-34.search.msn.com.
	msnbot-157-55-39-35.search.msn.com.
	msnbot-157-55-39-5.search.msn.com.
	census3.shodan.io.
	crawl3.bl.semrush.com.
	crawl7.bl.semrush.com.
	crawl8.bl.semrush.com.
	crawl12.bl.semrush.com.
	crawl14.bl.semrush.com.
	crawl22.bl.semrush.com.
	5-255-253-34.spider.yandex.com.
	5-45-207-35.spider.yandex.com.
	crawl-66-249-64-81.googlebot.com.
	crawl-66-249-66-45.googlebot.com.
	crawl-66-249-66-47.googlebot.com.
	crawl-66-249-66-49.googlebot.com.
	crawl-66-249-73-23.googlebot.com.
	crawl-66-249-75-143.googlebot.com.
	186-89-162-69.static.reverse.lstn.net.
	sky.census.shodan.io.
	
	$ ./wana -uri "/robots\.txt" hist-load *log*
	2019-02-08 09:00 (1): #
	2019-02-08 10:00 (1): #
	2019-02-10 07:00 (1): #
	2019-02-10 09:00 (1): #
	2019-02-10 20:00 (1): #
	2019-02-11 05:00 (2): ##
	2019-02-12 16:00 (1): #
	2019-02-12 19:00 (1): #
	2019-02-13 04:00 (2): ##
	2019-02-13 12:00 (1): #
	2019-02-13 15:00 (2): ##
	2019-02-14 09:00 (1): #
	2019-02-14 12:00 (1): #
	2019-02-14 22:00 (1): #
	2019-02-15 01:00 (1): #
	2019-02-15 11:00 (1): #
	2019-02-15 17:00 (1): #
	2019-02-16 01:00 (2): ##
	2019-02-16 04:00 (1): #
	2019-02-16 16:00 (2): ##
	2019-02-16 22:00 (1): #
	2019-02-17 16:00 (1): #
	2019-02-17 21:00 (1): #
	2019-02-18 03:00 (2): ##
	2019-02-18 07:00 (2): ##
	2019-02-18 18:00 (1): #
	2019-02-19 01:00 (1): #
	2019-02-19 11:00 (1): #
	2019-02-19 18:00 (1): #
	2019-02-20 13:00 (2): ##
	2019-02-20 18:00 (1): #
	2019-02-21 11:00 (1): #
	2019-02-21 23:00 (1): #
	2019-02-22 07:00 (2): ##
	2019-02-22 10:00 (1): #
