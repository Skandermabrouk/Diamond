/*Definition de la macro variables chemin d'accès*/
%let chemin = C:/Users/skani/Desktop/ProjectDiamonds;

/*Defintion de la bibliothèque*/
libname diamonds "&chemin." ; 

/*utilisation de l'option "dsd" + "~" --> delimiteur à lintérieur des variables */
data diamonds ; 
 	infile "&chemin./diamonds.txt" firstobs=2 lrecl=1500 dsd dlm='20'x;
 	input number $ carat cut ~$11. color $  clarity $ depth table price x y z;
run ;


/*Suppression de la colonne numero et valeurs aberrantes x,y,z nuls --> aucun sens d'avoir un diamant 
	de taille,profendeur,largeur nulles 
	--> ça rend notre estimateur moins efficace ces valeurs !*/
data diamonds2; 
	set diamonds;
	drop number ;  
	if x=0 or y=0 or z=0 then delete;  
	logprix = log(price);
	logcarat = log(carat);
	
run ;



proc glmselect data=diamonds2;
	class cut color clarity / param=glm;
	model price=depth table x y z carat / showpvalues selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where cut is not missing and color is not missing and clarity is not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model price=&_GLSMOD /;
	run;
quit;





proc reg data=WORK.DIAMONDS2 alpha=0.05 ;
	model price=carat /;
	run;
quit;

proc export data=diamonds2 dbms=xlsx

outfile="C:\Users\skani\Desktop\diam.csv" dbms=csv

replace;

run;
/*extraction de la table pour sas*/
/* 
PROC EXPORT DATA = diamonds2
         OUTFILE = "C:\Users\skani\Desktop\sassss"
            DBMS = EXCEL REPLACE ;
   SHEET = "diaments" ; 
RUN ;
*/

/*Contenu de la data set*/
PROC CONTENTS DATA=diamonds2;
RUN;

/*taille de data set*/
title "TAILLE DE L ECHANTILLON";
	proc summary data=diamonds2 print;
run;

/*Methode summary efficace pour reperer le contenue et peut etre les valeurs bizarres!*/
title "Moyennes";
	proc means data=diamonds2;
run;

/*Matrice de corrélation en utilisant un test de pearson*/
ods noproctitle;
ods graphics / imagemap=on;

proc corr data=WORK.DIAMONDS2 pearson nosimple noprob 
		plots(maxpoints=none)=matrix;
	var price;
	with carat depth table x y z;
run;
/*-> Existence d'un lien fort entre le prix et le carat , x , y et z*/

/*graphique nuages de points :
	efficacité: trouvre un lien entre une VA quanti continue (carat) et une VA quanti continue (Price) */
ods graphics / reset width=6.4in height=4.8in imagemap;
/*On ajoute une droite linéaire */
proc sgplot data=WORK.DIAMONDS2;
	title "prix en fonction de carat";
	reg x=carat y=price / nomarkers;
	scatter x=carat y=price /;
	xaxis grid;
	yaxis min=0 max=20000 grid;
run;

ods graphics / reset;
/*Commentaire : 
On visualise une relation non linéaire , ça ressemble un peu à une exponentielle ?
On constate également que la variance de la relation P-C (prix,carat)[ paramètre de dispertion, l'explosion de nuages de points à droite
de la courbe ] est forte proportionnellement à l'augmentation de prix et carat.
Graçe à la droite linéaire , on remarque qu'elle ne transperce pas le nuage en deux parties equivalentes , en effet , voir le début vers (0,0),
égalemenet cette régression doit etre un peu courbé vers le centre et remonte en hauteur vers +inf à la fin.
*/

/*On utilise la technique de pairplot pour voir les relation deux à deux entre les variables
->Poids d'un diaments = f(Volume) = f(x*y*z) */

/*Var quali/quantit--> boite a moustaches 
  Var quanti/quanti --> Nuages de points 
  prix et x,y,z
  prix et cut 
  prix et clarity 
  prix et color */

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=diamonds2;
	title height=14pt "prix(en, log10) par rapport au carat";
	scatter x=carat y=price / markerattrs=(color=CX300099);
	xaxis grid;
	yaxis min=0 max=20000 grid type=log;
run;

ods graphics / reset;
title;
/*-> on, commance a avoir une droite
-> la deuxieme etape cest d'essayer de faire log10 pour les deux et ça fits*/
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=diamonds2;
	title height=14pt "prix(en, log10) par rapport au carat(log10)";
	scatter x=carat y=price / markerattrs=(color=CX990000);
	xaxis grid type=log;
	yaxis min=0 max=20000 grid type=log;
run;

ods graphics / reset;
title;
/*j'ai pensé au tri sort (a fin de visualiser mieux le point sur la courbe)*/

/*Astuce de M.Collet --> Penser au log */
proc sgplot data=diamonds2;
histogram price;
xaxis logbase=10;
yaxis logbase=10;
run; /*S'il vous plait M. je n'arrive pas à transformer ses valeurs de price en log(10) ?*/




/*d'apres diamondspro.com la clarity n'est pas une variable significatives --> mais la cut Si!!
Par ce que les imperfections microscopique d'un diament n'affecte pas la beuté d'un diaments */



/*Nous étudions ensuite le lien submergeant entre le prix(log10), carat(log10) et la clarity*/
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=WORK.DIAMONDS2;
	title height=14pt "prix(en, log10) par rapport au carat(log10) et la clarity";
	scatter x=carat y=price / group=clarity;
	xaxis grid type=log;
	yaxis min=0 max=20000 grid type=log;
run;

ods graphics / reset;
title;
/*Gràce à ce plot : La clarity explique la variation du prix d'un diament, en effet,
les diaments qui ont une clarity faibles/pauvre sont moins chers que les diaments avec une haute clarity,
exemple : IF- Internally Flawless - intérieurement pur est désigné en rose se situe au dessus de tout diaments (dans la realité 
ça nécessite un pro experimenté de le détecter à une echelle *10 ,source i-diamonds.com) comparé au 
I1 - Included (Inclusions) , qui est visible à l'oeil nu "qualité barbes" , se situe en dessous en termes de prix*/




/*prix(log10) in function carat(log10) et cut */
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=diamonds2;
	title height=14pt "prix(log10) en fonction de carat(log10) et la cut";
	scatter x=carat y=price / group=cut;
	xaxis grid type=log;
	yaxis min=0 max=20000 grid type=log;
run;

ods graphics / reset;
title;
/*Suivant ce plot , nous constatons que la cut ne compte beaucoup pour la dispertion des prix malheureusement 
c'est contradictoire à la réalité et la logique , car en faisant les descriptives de variables au début on regarde que dans 
cette data set , le nombre total d'echantillon de cut Ideal est dominant par rapport aux nombres des autres 
cut, i.e la plupart des diaments sont ideal ,
c'est pour cela , les couleurs ne sont pas très visibles à l'oeil nu sur le plot à part la couleur 
de la cut Ideal qui est partout et explosive */


/*Ordonner les couleurs par ordre croissant d'une maniere que la meilleure couleur sera en haut 
en esperant que ça marche*/
proc sort data=diamonds2;
	by color;
run;
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=diamonds2;
	title height=14pt "prix(log10) en fonction de carat(log10) et la color";
	scatter x=carat y=price / group=color;
	xaxis grid ;
	yaxis min=0 max=20000 grid type=log;
run;

ods graphics / reset;
title;
/*c'est pareil que la clarity mais moins pire , on a du mal à l'oeil nu de constater les difference mais normalement 
suivant le jeu de données ça affecte bel et bien le prix */

/*En fait , je vais essayer de transforme la variable carat en utilisant sas a fin d'esperer de trouver une courbe meilleure 
carrée --> test boff 
inv carrée --> test booff*/
data diamonds2;
	set WORK.DIAMONDS2;
	special_carat=log10(carat);
run;

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=diamonds2;
	title height=14pt "prix(en, log10) par rapport au carat";
	scatter x=special_carat y=price / markerattrs=(color=CX300099);
	xaxis grid;
	yaxis min=0 max=20000 grid type=log;
run;

ods graphics / reset;
title;


data diamonds2;
set work.diamonds2;
special_prix = log10(price);
run;
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=WORK.DIAMONDS2;
	histogram special_prix /;
	density special_prix;
	yaxis grid;
run;

ods graphics / reset;
/*Question prof , malgre que les valeurs sont positives de data sets , 
 le log carat renvoie des valeurs negatives ???????????*/

ods noproctitle;
ods graphics / imagemap=on;

proc corr data=WORK.DIAMONDS2 pearson nosimple noprob plots=matrix(histogram 
		nvar=7 nwith=7);
	var special_prix;
	with special_carat carat depth table x y z;
run;









/*Lineaire modele
on est dans le cas continue A*B */




proc glmselect data=diamonds2;
	class cut color ;
	model special_prix = special_carat*cut*color x y z/showpvalues ;
run;


ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=WORK.DIAMONDS2 outdesign(addinputvars)=Work.reg_design;
	class cut color clarity / param=glm;
	model special_prix=x y z special_carat cut color clarity x*cut x*color 
		x*clarity / showpvalues selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where cut is not missing and color is not missing and clarity is not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model special_prix=&_GLSMOD /;
	run;
quit;

proc delete data=Work.reg_design;
run;
proc glmselect data=WORK.DIAMONDS2 outdesign(addinputvars)=Work.reg_design;
	class cut color clarity / param=glm;
	model special_prix=x*special_carat cut color clarity x*cut x*color 
		x*clarity / showpvalues selection=none;
run;

proc corr data= diamonds2 ; 
run ;
/*regarde lexp de premier price et voir si cest egale a la log 

essayeer avec quelque model pour la regression simple et deduire 
essayer avce des modeles mutliples --> deduire 

acp/cah en, r*/


proc glmselect data=WORK.DIAMONDS2 outdesign(addinputvars)=Work.reg_design;
	class cut color clarity / param=glm;
	model special_prix=special_carat x*cut x*color 
		x*clarity / showpvalues selection=none;
run;

proc glm data=diamonds2;
class cut color clarity ;
model price= cut color clarity carat x y z/ solution;
run;

ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=WORK.DIAMONDS2 outdesign(addinputvars)=Work.reg_design;
	class cut color clarity / param=effect;
	model price=carat cut*color*clarity cut clarity 
		carat*cut carat*clarity cut*clarity carat*cut*clarity / showpvalues 
		selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where cut is not missing and color is not missing and clarity is not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model price=&_GLSMOD /;
	run;
quit;

proc delete data=Work.reg_design;
run;


/*carat*cut*clarity significatives */

/*donner le modele de base et le modele avec le log */

/*regression, simple avec une seule variable sans class ni rien du tt */
/*stepwise !!!!  --> regression linear  */

proc glmselect data = diamonds2 ; 
class cut clarity color ; 
model price = carat cut color clarity x y z ;
run;

proc glmselect data = diamonds2 ; 
class cut clarity color ; 
model special_price = special_carat cut color clarity x y z ;
run;



proc glm data=diamonds2 ; 
model price = carat /solution ;
run;

proc glm data=diamonds2 ; 
model price = x /solution ;
run;

