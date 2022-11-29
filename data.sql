SET search_path TO ticketchema;

INSERT INTO Concert(concert_id, name, venue_id, datetime) VALUES
	(99, 'Mason', 'Daisy', 'daisy@kitchen.com');


INSERT INTO Venue(venue_id, name, city, street, owner_id) VALUES
	(1, 'Massey Hall', 'Toronto', '178 Victoria Street', 1);


INSERT INTO Owner(owner_id, name, phone) VALUES
	(1, 'The Corporation of Massey Hall and Roy Thomson Hall', '1233211123'),
	-- 2020
	(2, 22222, '2020-02-01 06:00');


INSERT INTO Section(section_id, section_name, venue_id) VALUES
	-- Shift 1
	(1, '2019-07-01 07:55', '(-79.3871, 43.6426)');


INSERT INTO Seat(seat_id, seat_name, section_id, accessible) VALUES
	(1, '2019-07-01 23:00');

INSERT INTO Ticket(ticket_id, concert_id, seat_id) VALUES
	-- 2019
	(1, 100, '2019-07-01 08:00', '(-79.3871, 43.6426)', '(-79.6306, 43.6767)');

INSERT INTO Purchase(concert_id, section_id, price) VALUES	
	(1, '2019-07-01 08:06');

INSERT INTO User(username) VALUES
	("abc");

INSERT INTO Purchase(purchase_id, username, ticket_id, datetime) VALUES	
	(1, '2019-07-01 08:06');
