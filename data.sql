SET search_path TO ticketchema;

INSERT INTO Owner(owner_id, name, phone) VALUES
	(1, 'The Corporation of Massey Hall and Roy Thomson Hall', '1233211123'),
    (2, 'Maple Leaf Sports & Entertainment', '1416416416');

INSERT INTO Venue(venue_id, name, city, street_address, owner_id) VALUES
	(1, 'Massey Hall', 'Toronto', '178 Victoria Street', 1),
    (2, 'Roy Thomson Hall', 'Toronto', '60 Simcoe St', 1),
    (3, 'ScotiaBank Arena', 'Toronto', '40 Bay St', 2);
 
INSERT INTO Concert(concert_id, name, venue_id, datetime) VALUES
	(1, 'Ron Sexsmith', 1, '2022-12-03 19:30'),
    (2, 'Women''s Blues Review', 1, '2022-11-25 20:00'),
    (3, 'Mariah Carey - Merry Christmas to all', 3, '2022-12-09 20:00'),
    (4, 'Mariah Carey - Merry Christmas to all', 3, '2022-12-11 20:00'),
    (5, 'TSO - Elf in', 2, '2022-12-09 19:30'),
    (6, 'TSO - Elf in', 2, '2022-12-10 14:30'),
    (7, 'TSO - Elf in', 2, '2022-12-10 19:30');

INSERT INTO Section(section_id, section_name, venue_id) VALUES
    -- Insert sections for 'Massey Hall'
    (1, 'floor', 1),
    (2, 'balcony', 1),
    -- Insert sections for 'Roy Thomson Hall'
    (3, 'main hall', 2),
    -- Insert sections for 'ScotiaBank Arena'
    (4, '100', 3),
    (5, '200', 3),
    (6, '300', 3);


INSERT INTO Seat(seat_id, seat_name, section_id, accessible) VALUES
    -- Insert seats for 'Massey Hall' 
    -- 'floor' section
	(1, 'A1', 1, true),
    (2, 'A2', 1, true),
    (3, 'A3', 1, true),
    (4, 'A4', 1, false),
    (5, 'A5', 1, false),
    (6, 'A6', 1, false),
    (7, 'A7', 1, false),
    (8, 'A8', 1, true),
    (9, 'A9', 1, true),
    (10, 'A10', 1, true),
    (11, 'B1', 1, false),
    (12, 'B2', 1, false),
    (13, 'B3', 1, false),
    (14, 'B4', 1, false),
    (15, 'B5', 1, false),
    (16, 'B6', 1, false),
    (17, 'B7', 1, false),
    (18, 'B8', 1, false),
    (19, 'B9', 1, false),
    (20, 'B10', 1, false),
    -- 'balcony' section
	(21, 'C1', 2, false),
    (22, 'C2', 2, false),
    (23, 'C3', 2, false),
    (24, 'C4', 2, false),
    (25, 'C5', 2, false),
    -- Insert seats for 'Roy Thomson Hall' 
    -- 'main hall' section
    (26, 'AA1', 3, false),
    (27, 'AA2', 3, false),
    (28, 'AA3', 3, false),
    (29, 'BB1', 3, false),
    (30, 'BB2', 3, false),
    (31, 'BB3', 3, false),
    (32, 'BB4', 3, false),
    (33, 'BB5', 3, false),
    (34, 'BB6', 3, false),
    (35, 'BB7', 3, false),
    (36, 'BB8', 3, false),
    (37, 'CC1', 3, false),
    (38, 'CC2', 3, false),
    (39, 'CC3', 3, false),
    (40, 'CC4', 3, false),
    (41, 'CC5', 3, false),
    (42, 'CC6', 3, false),
    (43, 'CC7', 3, false),
    (44, 'CC8', 3, false),
    (45, 'CC9', 3, false),
    (46, 'CC10', 3, false),
    -- Insert seats for 'ScotiaBank Arena' 
    -- '100' section
    (47, 'row 1, seat 1', 4, true),
    (48, 'row 1, seat 2', 4, true),
    (49, 'row 1, seat 3', 4, true),
    (50, 'row 1, seat 4', 4, true),
    (51, 'row 1, seat 5', 4, true),
    (52, 'row 2, seat 1', 4, true),
    (53, 'row 2, seat 2', 4, true),
    (54, 'row 2, seat 3', 4, true),
    (55, 'row 2, seat 4', 4, true),
    (56, 'row 2, seat 5', 4, true),
    -- '200' section
    (57, 'row 1, seat 1', 5, false),
    (58, 'row 1, seat 2', 5, false),
    (59, 'row 1, seat 3', 5, false),
    (60, 'row 1, seat 4', 5, false),
    (61, 'row 1, seat 5', 5, false),
    (62, 'row 2, seat 1', 5, false),
    (63, 'row 2, seat 2', 5, false),
    (64, 'row 2, seat 3', 5, false),
    (65, 'row 2, seat 4', 5, false),
    (66, 'row 2, seat 5', 5, false),
    -- '300' section
    (67, 'row 1, seat 1', 6, false),
    (68, 'row 1, seat 2', 6, false),
    (69, 'row 1, seat 3', 6, false),
    (70, 'row 1, seat 4', 6, false),
    (71, 'row 1, seat 5', 6, false),
    (72, 'row 2, seat 1', 6, false),
    (73, 'row 2, seat 2', 6, false),
    (74, 'row 2, seat 3', 6, false),
    (75, 'row 2, seat 4', 6, false),
    (76, 'row 2, seat 5', 6, false);

INSERT INTO Price(concert_id, section_id, price) VALUES
    -- for concert_id: 1, massey hall has 'floor' 'balcony'
    (1, 1, 130),
    (1, 2, 99),
    -- for concert_id: 2, massey hall has 'floor' 'balcony'
    (2, 1, 150),
    (2, 2, 125),
    -- for concert_id: 3, ScotiaBank Arena has '100' '200' '300'
    (3, 4, 986),
    (3, 5, 244),
    (3, 6, 176),
    -- for concert_id: 4, ScotiaBank Arena has '100' '200' '300'
    (4, 4, 936),
    (4, 5, 194),
    (4, 6, 126),
    -- for concert_id: 5, 6, 7, Roy Thompson Hall has 'main hall'
    (5, 3, 159),
    (6, 3, 159),
    (7, 3, 159);

INSERT INTO UserInfo(username, surname, firstname) VALUES
    ('ahightower', 'Hightower', 'Alicent'),
    ('d_targaryen', 'Targaryen', 'Daemon'),
    ('cristonc', 'Cole', 'Criston');

INSERT INTO Ticket(ticket_id, username, concert_id, seat_id, datetime) VALUES
    (1, 'ahightower', 2, 5, '2022-09-03 19:30'),
    (2, 'ahightower', 2, 22, '2022-09-06 09:30'),
    (3, 'd_targaryen', 1, 13, '2022-09-08 19:30'),
    (4, 'd_targaryen', 7, 35, '2022-09-10 09:30'),
    (5, 'cristonc', 3, 49, '2022-09-10 20:30'), 
    (6, 'cristonc', 4, 64, '2022-09-11 20:30'),
    (7, 'cristonc', 4, 65, '2022-09-11 20:30');