CREATE OR REPLACE FUNCTION update_yangilangan_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.yangilangan_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


create table bemorlar (
	id bigserial primary key not null,
	ism varchar(90) not null,
	yosh numeric(15) not null,
	tibbiy_tarix text,
	contact_info jsonb,
	yaratilgan_at timestamp default CURRENT_TIMESTAMP,
	yangilangan_at timestamp default CURRENT_TIMESTAMP
);

CREATE TRIGGER set_yangilangan_at
BEFORE UPDATE ON bemorlar
FOR EACH ROW
EXECUTE FUNCTION update_yangilangan_at_column();

create table uchrashuvlar (
	id bigserial primary key not null,
	bemor_identifikatori bigint references bemorlar(id),
	doctor_name varchar(90) not null,
	tayinlash_sanasi date not null,
	status_uchrashuv varchar(50) default 'rejalashtirilgan',
	yaratilgan_at timestamp default CURRENT_TIMESTAMP,
	yangilangan_at timestamp default CURRENT_TIMESTAMP
);

alter table uchrashuvlar add check(status_uchrashuv = 'rejalashtirilgan' or status_uchrashuv = 'qabul qilindi' or status_uchrashuv = 'bekor qilingan');

CREATE TRIGGER set_yangilangan_at
BEFORE UPDATE ON uchrashuvlar
FOR EACH ROW
EXECUTE FUNCTION update_yangilangan_at_column();

create type tibbiy_holatlar as enum ('diabet', 'hech_narsa', 'yurak_kasalligi', 'astma', 'gipertenziya');

INSERT INTO bemorlar (ism, yosh, tibbiy_tarix, contact_info)
VALUES 
('Akmal Karimov', 30, 'Diabet va gipertenziya bilan ogʻriydi', '{"telefon": "+998901234567", "elektron_pochta": "akmal@example.com", "adres": "Toshkent, Shayxontohur"}'),

('Diyorbek Islomov', 25, 'Astma', '{"telefon": "+998907654321", "elektron_pochta": "diyorbek@example.com", "adres": "Samarqand, Bulungur"}'),

('Shahlo Alimova', 40, 'Yurak kasalligi tarixiga ega', '{"telefon": "+998937654321", "elektron_pochta": "shahlo@example.com", "adres": "Buxoro, Gʻijduvon"}'),

('Zuhra Raximova', 55, 'Diabet va boshqa surunkali kasalliklar mavjud', '{"telefon": "+998937123456", "elektron_pochta": "zuhra@example.com", "adres": "Qarshi, Chiroqchi"}'),

('Rustam Bekmurodov', 33, 'Hech qanday kasallik yoʻq', '{"telefon": "+998998765432", "elektron_pochta": "rustam@example.com", "adres": "Nukus, Amudaryo"}');

INSERT INTO uchrashuvlar (bemor_identifikatori, doctor_name, tayinlash_sanasi, status_uchrashuv)
VALUES 
(2, 'Dr. Jahongir Tursunov', '2024-11-10', 'rejalashtirilgan'),  
(4, 'Dr. Nigora Xodjaeva', '2024-11-12', 'rejalashtirilgan'),    
(5, 'Dr. Azizbek Mirzaev', '2024-11-15', 'qabul qilindi'),     
(3, 'Dr. Otabek Rustamov', '2024-11-18', 'bekor qilingan');   



-- Foydalanuvchi ma'lumotlarini yangilash
update bemorlar set tibbiy_tarix = 'kassalikdan butunlay sogaydi' where id = 2;


-- Foydalanuvchini o'chirish
delete from bemorlar where id = 1;



-- Malum bir sana oralig'idagi foydalanuvchilarni olish

select b.id, b.ism, b.yosh, b.tibbiy_tarix, u.doctor_name, u.tayinlash_sanasi from bemorlar b join uchrashuvlar u on b.id = u.bemor_identifikatori where u.tayinlash_sanasi between '2024-11-09' and '2024-11-13' ; 



-- Malum bir kasaliki bor foydalananuvchilarni olish
select * from bemorlar where tibbiy_tarix ilike '%diabet%';



--Muayyan shifokor uchun barcha uchrashuvlarni olish 

select * from uchrashuvlar where doctor_name = 'Dr. Jahongir Tursunov';

--Uchrashuvlar sonini sanab o'tayinlash_sanasi

select doctor_name, count(*) as uchrashuvlar_soni from uchrashuvlar where doctor_name = 'Dr. Jahongir Tursunov' group by doctor_name;


--Oxirgi 6 oy ichida hec qanday uchrashuv o'tkazmagan bemor
SELECT b.id, b.ism, b.yosh, b.tibbiy_tarix, b.contact_info
FROM bemorlar b
LEFT JOIN uchrashuvlar u ON b.id = u.bemor_identifikatori 
     AND u.tayinlash_sanasi >= CURRENT_DATE - INTERVAL '6 months'
WHERE u.id IS NULL;

