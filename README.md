# Dodaci za program Sketchup	:computer:

   Cilj projekta je bio implementacija klase dodatnih funkcionalnosti (tzv. *plugins*) koje nisu direktno podržane programom **Sketchup**, a znatno mogu olakšati i skratiti rad, dodati na estetici, pomoći pri kreiranju novih modela...
   
   
   **Sketchup** je softver za 3D modelovanje koji se prvenstveno koristi u dizajniranju arhitekture i enterijera, ali se takođe može koristiti i u pravljenju animacija, video igara, filmova, modela u raznim drugim sferama itd. Program je vrlo jednostavan za upotrebu, ima grafički korisnički interfejs i bogatu otvorenu biblioteku modela i omogućava izradu raznih funkcionalnosti. U *3D Skladište* korisnici mogu dodavati sopstvene modele, a na sajtu pod nazivom *Prošireno skladište* mogu naći postojeće *plugin*-ove.
   
   Glavni *plugin*-ovi u našem projektu se nalaze u direktorijumu [Transformations](Code/Sketchup-Plugins/Transformations), a sporedni koji nisu deo projekta su u direktorijumu ```side```.

   ![Sketchup Logo](https://github.com/matf-pp2019/safir/blob/master/logos/sketchup-icon-png-28.jpg)
   
   ## Implementacija :pencil:
   Projekat je implementiran u programskom jeziku **Ruby**, uz korišćenje **Sketchup Ruby API**-ja.
   
   ![Ruby Logo](https://github.com/matf-pp2019/safir/blob/master/logos/ruby-logo-png-6.png)
   
   ## Platforma, instalacija i pokretanje :cd:
   
   Za korišćenje dodataka, potrebno je imati instaliran sam **Sketchup**. Besplatna verzija (**Sketchup Make**) za nekomercijalne svrhe se može preuzeti sa [linka](https://www.sketchup.com/download/make). **Sketchup** je podržan na **Windows** i **Mac OS** operativnim sistemima.
   
   Dodaci u pripremljenom obliku se mogu preuzeti iz direktorijuma [Releases](Releases). Za instalaciju je neophodno otvoriti **Sketchup**, pa ući u ```Extension Manager > Manage```, pa klikom na ```Install``` će se otvoriti File explorer odakle se nađe i učita odgovarajuća .rbz datoteka. Posle instalacije, ime *plugin*-a će se pojaviti u padajućem meniju ```Extensions```(na novijim verzijama) ili ```Plugins```(starije verzije). Ukoliko imena nema u padajućem meniju, proveriti u ```Extension Manager > Home``` da li je taj dodatak *Enable*.
   
   Klikom na ime u padajucem meniju ```Extensions```(```Plugins```) se pokreće program.
   
   ## Dokumentacija :book:
   
   U direktorijumu [Instructions_and_materals](Instructions_and_materials) se nalaze uputstva i materijali.
   
   ## Članovi tima: :soccer:
   * ### Milena Stojić
   🎓 96/2016, kontakt :e-mail: : ```mi16096@alas.matf.bg.ac.rs```
   
   
   * ### Dunja Spasić
   🎓 73/2016, kontakt :e-mail: : ```mi16073@alas.matf.bg.ac.rs```
