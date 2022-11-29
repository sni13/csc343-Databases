------ A3 Comments ------
-- 
-- Could not:
-- 1. "Every venue has at least 10 seats and there is no upper limit"
-- This constraint cannot be enforced without assertions or triggers. 
-- This is a cross-table constraint between Venue, Section, and Seat. 
-- One-line check constraints cannot check against aggregated values.
-- 2. "A venue can only have one concert at a given time"
-- This is a cross-table constraint between Venue and Concert. 
-- This constraint cannot be enforced without assertions or triggers. 

-- Did Not:
-- Extra Constraints: 
-- Assumptions: 


------ Schema Design------
drop schema if exists ticketchema cascade;
create schema ticketchema; 
set search_path to ticketchema;

-- A registered owner has a name and an unique phone number.
CREATE TABLE Owner (
  owner_id integer PRIMARY KEY,
  name varchar(30) NOT NULL,
  phone varchar(20) NOT NULL,
  unique(phone)
);

-- A venue is owned by some owner (person, organization, or company) 
-- and located in specified address and city.
-- Each venue has a single owner.
CREATE TABLE Venue (
  venue_id integer PRIMARY KEY,
  name varchar(30) NOT NULL,
  city varchar(30) NOT NULL,
  street_address varchar(50) NOT NULL,
  owner_id integer NOT NULL REFERENCES Owner
);

-- A concert is booked into some venue at some time and date.
CREATE TABLE Concert (
  concert_id integer PRIMARY KEY,
  name varchar(30) NOT NULL,
  venue_id integer NOT NULL REFERENCES Venue,
  datetime timestamp NOT NULL
);


-- A registered user has unique username.
CREATE TABLE User (
  username varchar(30) PRIMARY KEY,
  surname varchar(25) NOT NULL,
  firstname varchar(15) NOT NULL
);

-- A section belongs to some venue in the system.
-- Each section is unique to the specified venue. 
-- Sections stays the same for every concert in that venue.
CREATE TABLE Section (
  section_id integer PRIMARY KEY,
  section_name varchar(30) NOT NULL,
  venue_id integer NOT NULL REFERENCES Venue,
  UNIQUE(section_name, venue_id)
);

-- A seat belongs to one section in some venue associated to it.
-- Each seat is unique to the specified section. 
-- Seats stays the same for every concert in that section/venue.
CREATE TABLE Seat (
  seat_id integer PRIMARY KEY,
  seat_name varchar(30) NOT NULL,
  section_id integer NOT NULL REFERENCES Section,
  accessible boolean NOT NULL DEFAULT false,
  UNIQUE(seat_name, section_id)
);

-- A ticket is assigned to a seat for an associated concert.
CREATE TABLE Ticket (
  ticket_id integer PRIMARY KEY,
  username varchar(30) NOT NULL REFERENCES User,
  concert_id integer NOT NULL REFERENCES Concert,
  seat_id integer NOT NULL REFERENCES Seat,  
  datetime timestamp NOT NULL
);

-- A price is for a section in the venue that holds a concert.
CREATE TABLE Price (
  concert_id integer NOT NULL REFERENCES Concert,
  section_id integer NOT NULL REFERENCES Section,
  price real NOT NULL,
  PRIMARY KEY(concert_id, section_id)
);