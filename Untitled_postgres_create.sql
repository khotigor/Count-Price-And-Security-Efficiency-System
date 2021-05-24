DROP TABLE if exists "frontiers_of_objects";
DROP TABLE if exists "difficulty_of_path";
DROP TABLE if exists "difficulty";
DROP TABLE if exists "frontier";
DROP TABLE if exists "det_front";
DROP TABLE if exists "equipment";
DROP TABLE if exists "types_frontier";
DROP TABLE if exists "equipment_types";
DROP TABLE if exists "solutions";
DROP TABLE if exists "shortest_path";
DROP TABLE if exists "object_of_comp";



CREATE TABLE "object_of_comp" (
	"id_object" 	serial PRIMARY KEY,
	"name_object" 	text UNIQUE NOT NULL
);

CREATE TABLE "equipment_types" (
	"id_type" serial PRIMARY KEY,
	"name_type" text UNIQUE NOT NULL
);

CREATE TABLE "types_frontier" (
	"id_frontier_type" 		serial 	PRIMARY KEY,
	"name_frontier" 		TEXT 	UNIQUE NOT NULL
);

CREATE TABLE "difficulty" (
	"id_difficulty" 		serial 	PRIMARY KEY,
	"difficulty" 			integer	NOT NULL,
	"number_of_repeats"		integer	NOT NULL
);

CREATE TABLE "shortest_path" (
	"id_shortest_path" 		serial 	PRIMARY KEY,
	"length" 				integer	NOT NULL
);


CREATE TABLE "equipment" (
	"id_equipment" 			serial 	PRIMARY KEY,
	"name_equipment" 		TEXT 	UNIQUE NOT NULL,
	"price_equipment" 		integer	NOT NULL
	CONSTRAINT positive_price CHECK ("price_equipment" > 0),
	"range_of_action" 		integer	NOT NULL
	CONSTRAINT positive_range_of_action CHECK ("range_of_action" >= 0),
	"type_equipment" 		integer	NOT NULL 
	REFERENCES equipment_types(id_type)	ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "det_front" (
	"id_equipment" 		integer NOT NULL
	REFERENCES equipment(id_equipment)	ON DELETE CASCADE ON UPDATE CASCADE,
	"id_frontier_type" 	integer NOT NULL
	REFERENCES types_frontier(id_frontier_type)	ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(id_equipment, id_frontier_type)
);

CREATE TABLE "frontier" (
	"id_frontier" 		serial 	PRIMARY KEY,
	"length" 			integer NOT NULL
	CONSTRAINT positive_length CHECK ("length" > 0),
	"width" 			integer NOT NULL
	CONSTRAINT positive_width CHECK ("width" > 0),
	"height" 			integer NOT NULL
	CONSTRAINT positive_height CHECK ("height" >= 0),
	"number_of_windows"	integer NOT NULL,
	CONSTRAINT positive_windows CHECK ("number_of_windows" >= 0),
	"number_of_doors" 	integer NOT NULL,
	CONSTRAINT positive_doors CHECK ("number_of_doors" >= 0),
	"id_frontier_type" 	integer NOT NULL
	REFERENCES types_frontier(id_frontier_type)	ON DELETE CASCADE ON UPDATE CASCADE,
	"number_of_repeats" integer NOT NULL
	CONSTRAINT positive_rep CHECK ("number_of_repeats" > 0)
);

CREATE TABLE "frontiers_of_objects"(
	"id_frontier" integer 
	REFERENCES frontier(id_frontier)	ON DELETE CASCADE ON UPDATE CASCADE,
	"id_object"	integer 
	REFERENCES object_of_comp(id_object)	ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(id_object, id_frontier)
);

CREATE TABLE "difficulty_of_path"(
	"id_difficulty" integer 
	REFERENCES difficulty(id_difficulty)	ON DELETE CASCADE ON UPDATE CASCADE,
	"id_shortest_path"	integer 
	REFERENCES shortest_path(id_shortest_path)	ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(id_difficulty, id_shortest_path)
);

CREATE TABLE "solutions" (
	"id_solution"	serial PRIMARY KEY,
	"id_object" 	integer NOT NULL
	REFERENCES object_of_comp(id_object)	ON DELETE CASCADE ON UPDATE CASCADE,
	"price" 					integer NOT NULL,
	"efficiency" 				integer,
	"intruder_professionalism" 	integer,
	"staff_professionalism" 	integer,
	"id_shortest_path" 			integer NOT NULL
	REFERENCES shortest_path(id_shortest_path)	ON DELETE CASCADE ON UPDATE CASCADE
);



INSERT INTO equipment_types(name_type) 
VALUES ('fire tempreture'), ('guarded volumetric'), ('guarded perimeter'), 
('guarded sound'), ('magnetic contact'), ('KDL'), ('controller');

INSERT INTO types_frontier(name_frontier) 
VALUES ('object territory'), ('building facilities'), ('building corridors'), 
('specific premises');

INSERT INTO equipment(name_equipment, price_equipment, range_of_action, type_equipment) 
VALUES 
('S2000-Piron-SH', 3141, 12, 3), 
('S2000-SMK', 306, 1, 5),
('S2000-ST', 816, 1, 4),
('S2000-IK', 863, 20, 2),
('DIP-34A', 1170, 1, 1),
('S2000-KDL', 2168, 0, 6),
('S2000-M', 6400, 0, 7);

INSERT INTO det_front(id_equipment, id_frontier_type)
VALUES (1, 1), (2, 2), (2, 4), (3, 2), (4, 3), (4, 4), (5, 3), (5, 4);



--Роль с полными правами на БД для админа. Все упало, зовите программиста...
CREATE ROLE it_admin WITH LOGIN PASSWORD 'amins_pass';
GRANT CONNECT, TEMPORARY ON DATABASE db_count_security_system TO it_admin;
GRANT USAGE ON SCHEMA public TO it_admin;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO it_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO it_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO it_admin;
GRANT UPDATE ON ALL TABLES IN SCHEMA public TO it_admin;
GRANT DELETE ON ALL TABLES IN SCHEMA public TO it_admin;
GRANT INSERT ON ALL TABLES IN SCHEMA public TO it_admin;

--Роль инженера
CREATE ROLE engineer WITH LOGIN PASSWORD 'engineer_pass';
GRANT all privileges on database db_count_security_system to engineer;
GRANT CONNECT ON DATABASE db_count_security_system TO engineer;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO engineer;
GRANT USAGE ON SCHEMA public TO engineer;
GRANT SELECT ON public.object_of_comp, public.frontiers_of_objects, public.frontier, 
public.det_front, public.equipment, public.equipment_types  TO engineer;
GRANT UPDATE ON public.object_of_comp, public.frontiers_of_objects, public.frontier, public.difficulty_of_path, public.difficulty, public.shortest_path	TO engineer;
GRANT DELETE ON public.object_of_comp, public.frontiers_of_objects, public.frontier, public.difficulty_of_path, public.difficulty, public.shortest_path		TO engineer;
GRANT INSERT ON public.object_of_comp, public.frontiers_of_objects, public.frontier, public.difficulty_of_path, public.difficulty, public.shortest_path	TO engineer;

--Роль представителя продавца
CREATE ROLE seller WITH LOGIN PASSWORD 'seller_pass';
GRANT CONNECT ON DATABASE db_count_security_system TO seller;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO seller;
GRANT USAGE ON SCHEMA public TO seller;
GRANT SELECT ON public.object_of_comp, public.frontiers_of_objects, public.frontier, 
public.det_front, public.equipment, public.equipment_types  TO seller;
GRANT UPDATE ON public.det_front, public.equipment, public.equipment_types  TO seller;
GRANT DELETE ON public.det_front, public.equipment, public.equipment_types  TO seller;
GRANT INSERT ON public.det_front, public.equipment, public.equipment_types  TO seller;
/*

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM it_admin;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM it_admin;
DROP ROLE IF EXISTS it_admin;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM engineer;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM engineer;
DROP ROLE IF EXISTS engineer;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM seller;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM seller;
DROP ROLE IF EXISTS seller;

*/