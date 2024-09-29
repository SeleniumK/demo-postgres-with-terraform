DROP TABLE IF EXISTS pgcon.cities;
DROP TABLE IF EXISTS pgcon.states;
DROP TABLE IF EXISTS pgcon.secret_cities;
DROP TABLE IF EXISTS pgcon.secret_states;

CREATE TABLE IF NOT EXISTS pgcon.cities as select id, legal_name from 
          (SELECT generate_series(1,10) AS id,md5(random()::text) AS legal_name)s;

CREATE TABLE IF NOT EXISTS pgcon.states as select id, legal_name from 
          (SELECT generate_series(1,10) AS id,md5(random()::text) AS legal_name)s;

CREATE TABLE IF NOT EXISTS pgcon.secret_cities as select id, legal_name from 
          (SELECT generate_series(1,10) AS id,md5(random()::text) AS legal_name)s;

CREATE TABLE IF NOT EXISTS pgcon.secret_states as select id, legal_name from 
          (SELECT generate_series(1,10) AS id,md5(random()::text) AS legal_name)s;