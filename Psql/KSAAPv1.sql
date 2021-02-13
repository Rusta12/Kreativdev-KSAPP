--=======================TEST1==========================================--
-- drop function if exists trigger_on_tb1();
create or replace function trigger_on_tb1()
returns trigger language plpgsql
as $function$
begin
    UPDATE tb1 SET status = 2 WHERE id = new.id_tb1;
  	return new;
   
end; $function$;


-- drop trigger if exists trigger_on_tb1 on tb2;
create trigger trigger_on_tb1
  after insert -- or update or delete
  on tb2
  for each row
  execute procedure trigger_on_tb1();
 
--======================TEST Сьемки при создании======================================--  
drop function if exists trigger_on_shooting();

CREATE OR REPLACE FUNCTION trigger_on_shooting()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
begin
    UPDATE ksapp_shooting_do SET status_id = 1 WHERE id = new.id;
  	return new;
end; $function$
;

drop trigger if exists trigger_on_shooting on ksapp_shooting_do;

create trigger trigger_on_shooting 
after insert
on ksapp_shooting_do
for each row 
execute function trigger_on_shooting();

--===============Фото редактор тест ==================================================--
-- обновление при вставке
drop function if exists trigger_foto_redaktor();

CREATE OR REPLACE FUNCTION trigger_foto_redaktor()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
begin
    UPDATE public.ksapp_shooting_do SET status_id = 2 WHERE id = new.id_shooting_do;
  	return new;
end; $function$
;

drop trigger if exists trigger_foto_redaktor on ksapp_foto_redaktor;

create trigger trigger_foto_redaktor 
after insert
on public.ksapp_foto_redaktor
for each row 
execute function trigger_foto_redaktor();


-- обновление при удалении
drop function if exists trigger_foto_del_redaktor();

CREATE OR REPLACE FUNCTION trigger_foto_del_redaktor()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
begin
    UPDATE ksapp_shooting_do SET status_id = 1 WHERE id = old.id_shooting_do;
  	return old;
   
end; $function$
;

drop trigger if exists trigger_foto_del_redaktor on ksapp_foto_redaktor;

create trigger trigger_foto_del_redaktor after
after delete 
on ksapp_foto_redaktor
for each row 
execute function trigger_foto_del_redaktor()
;


--===============Фото редактор  добавление удаление =========================================--

drop function if exists trigger_foto_redaktor_upin();

CREATE OR REPLACE FUNCTION trigger_foto_redaktor_upin()
RETURNS trigger
LANGUAGE plpgsql
AS $function2$
begin
    if tg_op = 'DELETE' then
		UPDATE ksapp_shooting_do SET status_id = 1 WHERE id = old.id_shooting_do;
  		return old;
  	else 
  		UPDATE ksapp_shooting_do SET status_id = 2 WHERE id = new.id_shooting_do;
  		return new;
  	end if;
end; $function2$
;


drop trigger if exists trigger_foto_redaktor_upin on ksapp_foto_redaktor;

create trigger trigger_foto_redaktor_upin 
after insert or delete
on ksapp_foto_redaktor
for each row 
execute function trigger_foto_redaktor_upin()
;
--================ вставка последнего номера кадра в сводную сьемку ========================

UPDATE ksapp_shooting_do SH
SET last_frame_photo_editing = PH.last_frame_number
FROM ksapp_photo_editing PH
WHERE SH.id = PH.id_shooting_do; 


--================ вставка кол-во кадров номеров кадра в сводную сьемку ========================

CREATE OR REPLACE FUNCTION public.trigger_photo_editing_frame()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
    if tg_op = 'DELETE' then
		UPDATE ksapp_shooting_do
		SET last_frame_photo_editing = 0
		WHERE id = old.id_shooting_do; 
		return old;
  	else 
		UPDATE ksapp_shooting_do
		SET last_frame_photo_editing = new.last_frame_number
		WHERE id = new.id_shooting_do; 
  		return new;
  end if;
end; $function$
;

create trigger trigger_photo_editing_frame after
insert or delete or update
on public.ksapp_photo_editing for each row execute function trigger_photo_editing_frame();



