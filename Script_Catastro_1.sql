create table totalspar as
select refcad_par, ilcad_cd, i.ilcen_cd, s.secce_cd, distr_cd, barri_cd
from parce p, ilcen i, secce s
where p.ilcen_cd = i.ilcen_cd 
  and i.secce_cd = s.secce_cd;

/*Hacemos una vista TOTSOLPAR (TOTal Suelo por PARcela) donde nos quedamos con la referencia cadastral de cada parcela y el sumatorio (sum) de superfície de unidades de suelo (from unsol) que hay por parcela */	    
create view totsolpar as
select refcad_par, sum(unsol_sp) supsolpar
from unsol
/*Finalmente agrupamos el recuento por referencia cadastral*/
group by refcad_par;

/*Hacemos una vista TOTLOCPAR (TOTal de LOCales por PARcela) donde nos quedamos con la referencia cadastral de cada parcela y el recuento de total de locales (count) y sumatorio (sum) de superfície de locales que hay por parcela */	    
create view totlocpar as
select refcad_par, count(*) numlocpar, sum(f_suptotal) suplocpar
from ucons u, econs e, local l
/*Con el WHERE vinculamos las tablas ucons-econs-local para que se aplique el count(*) a los locales*/
where u.ucons_cd = e.ucons_cd
  and e.econs_cd = l.econs_cd
group by refcad_par;

/*Hacemos una vista TOTFISPAR (TOTal de unidades FIScales por PARcela) donde nos quedamos con la referencia cadastral de cada parcela y el recuento de numeros fiscales (count) y sumatorio (sum) de valores cadastrales que hay en ella */	
create view totfiscpar as
select refcad_par, count(*) numfiscpar, sum(e_valor) valcadpar /*Valor total*/, 
       sum(e_valorsuelo) valsolpar /*Valor suelo*/, sum(e_valorconstr) valconspar /*Valor construido*/
from ufisc
group by refcad_par;

/*Añadimos las columnas de superficies de unidades de suelo, de local y de valor cadastral a la tabla estructurlal TOTALSPAR que hemos creado al principio de la consulta.*/
alter table totalspar add supsolpar integer; /* en esta columna irá la superficie de suelo por parcela */
alter table totalspar add numlocpar integer; /* en esta columna irá numero de locales por parcela */
alter table totalspar add suplocpar integer; /* en esta columna irá la superficie de locales por parcela */
alter table totalspar add numfiscpar integer; /* en esta columna irá el numero de unidades fiscales por parcela */
/* alter table totalspar add valcadpar double precision;  OPCIONAL en esta columna iría el valor cadastral por parcela */
/* alter table totalspar add valsolpar double precision;  OPCIONAL en esta columna iría el valor de suelo por parcela */
/* alter table totalspar add valconspar double precision;  OPCIONAL en esta columna iría el valor de construccion por parcela */

/*En estas columnas pondremos el resultado de los recuentos y sumas calculados en las vistas anteriores*/
update totalspar t set supsolpar = (select supsolpar from totsolpar v where t.refcad_par = v.refcad_par);
update totalspar t set numlocpar = (select numlocpar from totlocpar v where t.refcad_par = v.refcad_par);
update totalspar t set suplocpar = (select suplocpar from totlocpar v where t.refcad_par = v.refcad_par);
update totalspar t set numfiscpar = (select numfiscpar from totfiscpar v where t.refcad_par = v.refcad_par);
/* update totalspar t set valcadpar = (select valcadpar from totfiscpar v where t.refcad_par = v.refcad_par); OPCIONAL */
/* update totalspar t set valsolpar = (select valsolpar from totfiscpar v where t.refcad_par = v.refcad_par); OPCIONAL */
/* update totalspar t set valconspar = (select valconspar from totfiscpar v where t.refcad_par = v.refcad_par); OPCIONAL */

/* Aunque conceptualmente no se lo más correcto, convertiremos los valores NULOS a CEROS*/
update totalspar set supsolpar = 0 where supsolpar is null; 
update totalspar set numlocpar = 0 where numlocpar is null;
update totalspar set suplocpar = 0 where suplocpar is null;
update totalspar set numfiscpar = 0 where numfiscpar is null;

/*OPCIONAL VALOR CADASTRAL: Debido a la privacidad de datos, no se dispone de vcifras de valor cadastral (las tablas de la BBDD estan vacías)
así que el resultado de esta parte sería nulo. No obstante, el método es lo que cuenta.*/
/* OPCIONAL: En caso de querer calcular porcentajes de valores cadastrales, creariamos nuevas columnas
alter table totalspar add vmigfiscpar double precision;
alter table totalspar add vsolm2par double precision;
alter table totalspar add vcadm2par double precision;
/* OPCIONAL: En caso de querer calcular porcentajes de valores cadastrales, calculariamos los porcentajes
update totalspar set vmigfiscpar = cast(valcadpar as double precision) / cast(numfiscpar as double precision);
update totalspar set vsolm2par = cast(valsolpar as double precision) / cast(supsolpar as double precision);
update totalspar set vcadm2par = cast(valcadpar as double precision) / cast(supsolpar as double precision);
*/

commit; /* este comando se utiliza para terminar un trabajo y confrimar los cambios en la base de datos. Se utiliza cuando se han hecho muchos cambios y se quieren consolidar. 
