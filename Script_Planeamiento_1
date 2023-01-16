create table parce_sup as 
select refcad_par, refpar_1, ilcad_cd, ilcen_cd, f_supfinca, f_supcubierta, f_supconsbras 
from parce;

/*Añado columna para almacenar valores de SUPerficie VACante (SUPVAC)*/
alter table parce_sup add column f_supvac integer;

/*Actualizo la columna f_supvac con el resultado de la 
resta entre superficie total de parcela menos superficie construida*/
update parce_sup set f_supvac = (f_supfinca - f_supcubierta);


/*Actualizo columnas que tienen NULL con valor 0*/
update parce_sup set f_supfinca = 0 where f_supfinca is null;
update parce_sup set f_supcubierta = 0 where f_supcubierta is null;
update parce_sup set f_supconsbras = 0 where f_supconsbras is null;
update parce_sup set f_supvac = 0 where f_supvac is null;

/*Actualizo columna f_supvac covirtiendo valores negativos a 0*/
update parce_sup set f_supvac = 0 where f_supvac < 0;


/*Añado columna para almacenar valores de EDIficabilidad MATerializada por PARcela (EDIMATPAR)*/
alter table parce_sup add column f_edimatpar float;


/*Calculamos la EDIficabilidad MATerializada por PARcela, que es la división de
la superficie construida de techo (f_supconsbras) entre la superficie total de parcela (f_supfinca)*/
update parce_sup set f_edimatpar = (cast(f_supconsbras as float)/cast(f_supfinca as float)) * 100 where f_supfinca > 0;

/*Actualizo columna f_edimatpar covirtiendo valores negativos a 0*/
update parce_sup set f_edimatpar = 0 where f_edimatpar is null;
