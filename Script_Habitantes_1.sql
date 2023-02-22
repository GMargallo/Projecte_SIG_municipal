create table habitpar as
select refcad_par, ilcad_cd, i.ilcen_cd,
       s.secce_cd, distr_cd, barri_cd
from parce p, ilcen i, secce s
where p.ilcen_cd = i.ilcen_cd and
      i.secce_cd = s.secce_cd;

/*Hacemos una vista TOTALPAR (TOTALes por PARcela) donde nos quedamos con la referencia cadastral y el recuento (count) de personas que viven en ella */	  
create view totalpar as
select p.refcad_par, count(*) tpar
from parce p, adpor a, adloc l, persn n, habit h
/*En el WHERE, vinculamos las tablas de habitantes, con las personas, con los locales, con los portales y con las referencias cadastrales (habit-persn-adloc-adpor-parce)*/
where p.refcad_par = a.refcad_par
  and a.adpor_cd = l.adpor_cd
  and l.adloc_cd = n.adloc_cd
  and n.persn_nip = h.persn_nip
/*Finalmente agrupamos el recuento de habitantes por referencia cadastral*/
group by p.refcad_par;

/*Añadimos la columna TPAR (Total por PARcela) a la tabla HABITPAR.*/
alter table habitpar add tpar integer;

/*En esta columna pondremos el resultado del recuento de TOTALPAR*/
update habitpar t set tpar = (select tpar 
       from totalpar v 
	   where t.refcad_par = v.refcad_par);
	   
/* Como puede haber parcelas sin habitantes, donde sea nulo le ponemos el valor cero (0)*/
update habitpar set tpar = 0 where tpar is null;


/*Hacemos una vista TOTALHOM (TOTAL de HOMbres) donde nos quedamos con la referencia cadastral y el recuento (count) de hombres (habit_sex='1') que viven en ella */
create view totalhom as
select p.refcad_par, count(*) thom
from parce p, adpor a, adloc l, habit h, persn n
where p.refcad_par = a.refcad_par
  and a.adpor_cd = l.adpor_cd
  and l.adloc_cd = n.adloc_cd
  and n.persn_nip = h.persn_nip
  and habit_sex = '1'
group by p.refcad_par;

/*Hacemos una vista TOTALDON (TOTAL de DONcellas)donde nos quedamos con la referencia cadastral y el recuento (count) de mujeres (habit_sex='6') que viven en ella */
create view totaldon as
select p.refcad_par, count(*) tdon
from parce p, adpor a, adloc l, habit h, persn n
where p.refcad_par = a.refcad_par
  and a.adpor_cd = l.adpor_cd
  and l.adloc_cd = n.adloc_cd
  and n.persn_nip = h.persn_nip
  and habit_sex = '6'
group by p.refcad_par;

/*Añadimos las columnas THOM y TDON a la tabla HABITPAR.*/
alter table habitpar add thom integer;
alter table habitpar add tdon integer;

/*En estas columnas pondremos el resultado del recuento de TOTALHOM y TOTALDON*/
update habitpar t set thom = (select v.thom 
       from totalhom v 
	   where t.refcad_par = v.refcad_par);

update habitpar t set tdon = (select v.tdon 
       from totaldon v 
	   where t.refcad_par = v.refcad_par);

/* Como puede haber parcelas sin hombres o mujeres, donde sea nulo le ponemos el valor cero (0)*/
update habitpar set thom = 0 where thom is null;
update habitpar set tdon = 0 where tdon is null;

/*Hacemos una vista TOTAL_0_14_H (total hombres de 0 a 14) donde nos quedamos con la referencia cadastral y el recuento (count) de hombres (habit_sex='1') menores de 14 años (habit_dtnx > '01/01/2006') que viven en ella */
create view total_0_14_h as
select p.refcad_par, count(*) hpar_14_h
from parce p, adpor a, adloc l, habit h, persn n
where p.refcad_par = a.refcad_par
  and a.adpor_cd = l.adpor_cd
  and l.adloc_cd = n.adloc_cd
  and n.persn_nip = h.persn_nip
  and habit_sex = '1'
  and habit_dtnx > '01/01/2006'
group by p.refcad_par;
/* NOTA: consideramos los datos creados en 2020, así que hay unos cuantos años de decalaje. Por eso > '01/01/2006'*/ 

/*Hacemos una vista TOTAL_0_14_D (total mujeres de 0 a 14) donde nos quedamos con la referencia cadastral y el recuento (count) de mujeres (habit_sex='6') menores de 14 años (habit_dtnx > '01/01/2006') que viven en ella */
create view total_0_14_d as
select p.refcad_par, count(*) hpar_14_d
from parce p, adpor a, adloc l, habit h, persn n
where p.refcad_par = a.refcad_par
  and a.adpor_cd = l.adpor_cd
  and l.adloc_cd = n.adloc_cd
  and n.persn_nip = h.persn_nip
  and habit_sex = '6'
  and habit_dtnx > '01/01/2006'
group by p.refcad_par;
/* NOTA: consideramos los datos creados en 2020, así que hay unos cuantos años de decalaje. Por eso > '01/01/2006'*/ 


/*Hacemos una vista TOTAL_15_64_H donde nos quedamos con la referencia cadastral y el recuento (count) de hombres entre 15 y 64 años que viven en ella */
create view total_15_64_h as
select p.refcad_par, count(*) hpar_64_h
from parce p, adpor a, adloc l, habit h, persn n
where p.refcad_par = a.refcad_par
  and a.adpor_cd = l.adpor_cd
  and l.adloc_cd = n.adloc_cd
  and n.persn_nip = h.persn_nip
  and habit_sex = '1'
  and habit_dtnx between '01/01/1956' and '01/01/2006'
group by p.refcad_par;

/*Hacemos una vista TOTAL_15_64_D donde nos quedamos con la referencia cadastral y el recuento (count) de mujeres entre 15 y 64 años que viven en ella */
create view total_15_64_d as
select p.refcad_par, count(*) hpar_64_d
from parce p, adpor a, adloc l, habit h, persn n
where p.refcad_par = a.refcad_par
  and a.adpor_cd = l.adpor_cd
  and l.adloc_cd = n.adloc_cd
  and n.persn_nip = h.persn_nip
  and habit_sex = '6'
  and habit_dtnx between '01/01/1956' and '01/01/2006'
group by p.refcad_par;

/*Hacemos una vista TOTAL_65_H donde nos quedamos con la referencia cadastral y el recuento (count) de hombres mayores de 65 años que viven en ella */
create view total_65_h as
select p.refcad_par, count(*) hpar_65_h
from parce p, adpor a, adloc l, habit h, persn n
where p.refcad_par = a.refcad_par
  and a.adpor_cd = l.adpor_cd
  and l.adloc_cd = n.adloc_cd
  and n.persn_nip = h.persn_nip
  and habit_sex = '1'
  and habit_dtnx <= '31/12/1955'
group by p.refcad_par;

/*Hacemos una vista TOTAL_65_D donde nos quedamos con la referencia cadastral y el recuento (count) de mujeres mayores de 65 años que viven en ella */
create view total_65_d as
select p.refcad_par, count(*) hpar_65_d
from parce p, adpor a, adloc l, habit h, persn n
where p.refcad_par = a.refcad_par
  and a.adpor_cd = l.adpor_cd
  and l.adloc_cd = n.adloc_cd
  and n.persn_nip = h.persn_nip
  and habit_sex = '6'
  and habit_dtnx <= '31/12/1955'
group by p.refcad_par;

/*Como hay hombres que no tienen fecha de nacimiento en la base de datos (habit_dtnx is null), hacemos una vista TOTAL_NOED_H*/
create view total_noed_h as
select p.refcad_par, count(*) hpar_noed_h
from parce p, adpor a, adloc l, habit h, persn n
where p.refcad_par = a.refcad_par
  and a.adpor_cd = l.adpor_cd
  and l.adloc_cd = n.adloc_cd
  and n.persn_nip = h.persn_nip
  and habit_sex = '1'
  and habit_dtnx is null
group by p.refcad_par;

/*Como hay mujeres que no tienen fecha de nacimiento en la base de datos (habit_dtnx is null), hacemos una vista TOTAL_NOED_D*/
create view total_noed_d as
select p.refcad_par, count(*) hpar_noed_d
from parce p, adpor a, adloc l, habit h, persn n
where p.refcad_par = a.refcad_par
  and a.adpor_cd = l.adpor_cd
  and l.adloc_cd = n.adloc_cd
  and n.persn_nip = h.persn_nip
  and habit_sex = '6'
  and habit_dtnx is null
group by p.refcad_par;


/*Añadimos las columnas de intervalos de edad y sexo a la tabla HABITPAR.*/
alter table habitpar add hpar_14_h integer;
alter table habitpar add hpar_14_d integer;
alter table habitpar add hpar_64_h integer;
alter table habitpar add hpar_64_d integer;
alter table habitpar add hpar_65_h integer;
alter table habitpar add hpar_65_d integer;
alter table habitpar add hpar_noed_h integer;
alter table habitpar add hpar_noed_d integer;

/*Actualizamos las columnas de intervalo de edad y sexo con los datos de las vistas que hemos ido creando con los recuentos*/
update habitpar t set hpar_14_h = (select v.hpar_14_h 
       from total_0_14_h v 
	   where t.refcad_par = v.refcad_par);

update habitpar t set hpar_14_d = (select v.hpar_14_d 
       from total_0_14_d v 
	   where t.refcad_par = v.refcad_par);

update habitpar t set hpar_64_h = (select v.hpar_64_h 
       from total_15_64_h v 
	   where t.refcad_par = v.refcad_par);

update habitpar t set hpar_64_d = (select v.hpar_64_d 
       from total_15_64_d v 
	   where t.refcad_par = v.refcad_par);

update habitpar t set hpar_65_h = (select v.hpar_65_h 
       from total_65_h v 
	   where t.refcad_par = v.refcad_par);

update habitpar t set hpar_65_d = (select v.hpar_65_d 
       from total_65_d v 
	   where t.refcad_par = v.refcad_par);

update habitpar t set hpar_noed_h = (select v.hpar_noed_h 
       from total_noed_h v 
	   where t.refcad_par = v.refcad_par);
	
update habitpar t set hpar_noed_d = (select v.hpar_noed_d 
       from total_noed_d v 
	   where t.refcad_par = v.refcad_par);
	   
/*Actualizamos los valores nulos con valores cero (0)*/
update habitpar set hpar_14_h = 0 where hpar_14_h is null;
update habitpar set hpar_14_d = 0 where hpar_14_d is null;
update habitpar set hpar_64_h = 0 where hpar_64_h is null;
update habitpar set hpar_64_d = 0 where hpar_64_d is null;
update habitpar set hpar_65_h = 0 where hpar_65_h is null;
update habitpar set hpar_65_d = 0 where hpar_65_d is null;
update habitpar set hpar_noed_h = 0 where hpar_noed_h is null;
update habitpar set hpar_noed_d = 0 where hpar_noed_d is null;

/*Añadimos las columnas de intervalos de edad sin diferenciar por sexo a la tabla HABITPAR.*/
alter table habitpar add hpar_14 integer;
alter table habitpar add hpar_64 integer;
alter table habitpar add hpar_65 integer;
alter table habitpar add hpar_noed integer;

/*Actualizamos las columnas de grupos de edad sin diferenciar por sexo con la suma de recuentos por sexo*/
update habitpar set hpar_14 = hpar_14_h + hpar_14_d;
update habitpar set hpar_64 = hpar_64_h + hpar_64_d;
update habitpar set hpar_65 = hpar_65_h + hpar_65_d;
update habitpar set hpar_noed = hpar_noed_h + hpar_noed_d;

/*CALCULO DE PORCENTAJES DE GRUPOS DE EDAD Y SEXO SOBRE EL TOTAL DE HABITANTES POR PARCELA*/
/*Primero añadimos las columnas de porcentajes por intervalos de edad y sexo a la tabla HABITPAR. Tipo double precision porque se rellenarán con resultados de divisiones*/
alter table habitpar add phom double precision;
alter table habitpar add pdon double precision;
alter table habitpar add ppar_14_h double precision;
alter table habitpar add ppar_14_d double precision;
alter table habitpar add ppar_14 double precision;
alter table habitpar add ppar_64_h double precision;
alter table habitpar add ppar_64_d double precision;
alter table habitpar add ppar_64 double precision;
alter table habitpar add ppar_65_h double precision;
alter table habitpar add ppar_65_d double precision;
alter table habitpar add ppar_65 double precision;
alter table habitpar add ppar_noed_h double precision;
alter table habitpar add ppar_noed_d double precision;
alter table habitpar add ppar_noed double precision;

/*Luego actualizamos las columnas con el resultado de la division de cada intervalo entre el total de población de cada parcela.
Hacemos "cast" porque los intervalos son en INTEGER y si no lo hicieramos el resultado nos saldria sin decimales aunque hayamos declarad los campos como DOUBLE PRECISION*/
update habitpar set phom = ( cast(thom as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set phom = 0 where tpar = 0;

update habitpar set pdon = ( cast(tdon as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set pdon = 0 where tpar = 0;

/*Calcualmos los porcentajes de menores de 14 años respecto el total de habitantes en cada parcela*/
update habitpar set ppar_14_h = ( cast(hpar_14_h as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_14_h = 0 where tpar = 0;

update habitpar set ppar_14_d = ( cast(hpar_14_d as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_14_d = 0 where tpar = 0;

update habitpar set ppar_14 = ( cast(hpar_14 as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_14 = 0 where tpar = 0;

/* Ahora calculamos porcentaje de adultos*/

update habitpar set ppar_64_h = ( cast(hpar_64_h as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_64_h = 0 where tpar = 0;

update habitpar set ppar_64_d = ( cast(hpar_64_d as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_64_d = 0 where tpar = 0;

update habitpar set ppar_64 = ( cast(hpar_64 as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_64 = 0 where tpar = 0;

/* Calculamos los porcentajes de viejos*/

update habitpar set ppar_65_h = ( cast(hpar_65_h as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_65_h = 0 where tpar = 0;

update habitpar set ppar_65_d = ( cast(hpar_65_d as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_65_d = 0 where tpar = 0;

update habitpar set ppar_65 = ( cast(hpar_65 as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_65 = 0 where tpar = 0;

/* Calculamos los porcenajes de la gente sin edad*/

update habitpar set ppar_noed_h = ( cast(hpar_noed_h as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_noed_h = 0 where tpar = 0;

update habitpar set ppar_noed_d = ( cast(hpar_noed_d as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_noed_d = 0 where tpar = 0;

update habitpar set ppar_noed = ( cast(hpar_noed as double precision) / cast(tpar as double precision) ) * 100
	where tpar > 0;
update habitpar set ppar_noed = 0 where tpar = 0;
