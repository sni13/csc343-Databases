drop schema if exists ticketchema cascade;
create schema ticketchema; 
set search_path to ticketchema;

CREATE TABLE Venue (
 
);



---- Example from A2
CREATE TABLE Client (
  client_id integer PRIMARY KEY,
  surname varchar(25) NOT NULL,
  firstname varchar(15) NOT NULL,
  email varchar(30) DEFAULT NULL
);
