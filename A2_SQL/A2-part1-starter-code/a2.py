"""
Part2 of csc343 A2: Code that could be part of a ride-sharing application.
csc343, Fall 2022
University of Toronto

--------------------------------------------------------------------------------
This file is Copyright (c) 2022 Diane Horton and Marina Tawfik.
All forms of distribution, whether as given or with any changes, are
expressly prohibited.
--------------------------------------------------------------------------------
"""
import psycopg2 as pg
import psycopg2.extensions as pg_ext
from typing import Optional, List, Any
from datetime import datetime
import re


class GeoLoc:
    """A geographic location.

    === Instance Attributes ===
    longitude: the angular distance of this GeoLoc, east or west of the prime
        meridian.
    latitude: the angular distance of this GeoLoc, north or south of the
        Earth's equator.

    === Representation Invariants ===
    - longitude is in the closed interval [-180.0, 180.0]
    - latitude is in the closed interval [-90.0, 90.0]

    >>> where = GeoLoc(-25.0, 50.0)
    >>> print(where)
    '(-25.0,50.0)
    >>> where.longitude
    -25.0
    >>> where.latitude
    50.0
    """
    longitude: float
    latitude: float

    def __init__(self, longitude: float, latitude: float) -> None:
        """Initialize this geographic location with longitude <longitude> and
        latitude <latitude>.
        """
        self.longitude = longitude
        self.latitude = latitude

        assert -180.0 <= longitude <= 180.0, \
            f"Invalid value for longitude: {longitude}"
        assert -90.0 <= latitude <= 90.0, \
            f"Invalid value for latitude: {latitude}"


class Assignment2:
    """A class that can work with data conforming to the schema in schema.ddl.

    === Instance Attributes ===
    connection: connection to a PostgreSQL database of ride-sharing information.

    Representation invariants:
    - The database to which connection is established conforms to the schema
      in schema.ddl.
    """
    connection: Optional[pg_ext.connection]

    def __init__(self) -> None:
        """Initialize this Assignment2 instance, with no database connection
        yet.
        """
        self.connection = None

    def connect(self, dbname: str, username: str, password: str) -> bool:
        """Establish a connection to the database <dbname> using the
        username <username> and password <password>, and assign it to the
        instance attribute <connection>. In addition, set the search path to
        uber, public.

        Return True if the connection was made successfully, False otherwise.
        I.e., do NOT throw an error if making the connection fails.

        >>> a2 = Assignment2()
        >>> # This example will work for you if you change the arguments as
        >>> # appropriate for your account.
        >>> a2.connect("csc343h-zhuboyu", "zhuboyu", "")
        True
        >>> # In this example, the connection cannot be made.
        >>> a2.connect("nonsense", "silly", "junk")
        False
        """
        try:
            self.connection = pg.connect(
                dbname=dbname, user=username, password=password,
                options="-c search_path=uber,public"
            )
            # This allows psycopg2 to learn about our custom type geo_loc.
            self._register_geo_loc()
            return True
        except pg.Error:
            return False

    def disconnect(self) -> bool:
        """Close the database connection.

        Return True if closing the connection was successful, False otherwise.
        I.e., do NOT throw an error if closing the connection failed.

        >>> a2 = Assignment2()
        >>> # This example will work for you if you change the arguments as
        >>> # appropriate for your account.
        >>> a2.connect("csc343h-zhuboyu", "zhuboyu", "")
        True
        >>> a2.disconnect()
        True
        >>> a2.disconnect()
        False
        """
        try:
            if not self.connection.closed:
                self.connection.close()
            return True
        except pg.Error:
            return False

    # ======================= Driver-related methods ======================= #

    def clock_in(self, driver_id: int, when: datetime, geo_loc: GeoLoc) -> bool:
        """Record the fact that the driver with id <driver_id> has declared that
        they are available to start their shift at date time <when> and with
        starting location <geo_loc>. Do so by inserting a row in both the
        ClockedIn and the Location tables.

        If there are no rows are in the ClockedIn table, the id of the shift
        is 1. Otherwise, it is the maximum current shift id + 1.

        A driver can NOT start a new shift if they have an ongoing shift.

        Return True if clocking in was successful, False otherwise. I.e., do NOT
        throw an error if clocking in fails.

        Precondition:
            - <when> is after all dates currently recorded in the database.
        """
        try:
            # TODO: implement this method
            shift_id = 1
            cursor = self.connection.cursor()
            cursor.execute("select max(shift_id) from clockedin;")
            if cursor.rowcount == 0:
                shift_id = 1
            else:
                for i in cursor:
                    shift_id += i[0]
            s = "select driver_id from clockedIn Natural Join (select shift_id from \
                clockedIn except (select shift_id from clockedOut)) K where driver_id = {};".format(driver_id)
            cursor2 = self.connection.cursor()
            cursor2.execute(s)
            if cursor2.rowcount !=0: #if the driver has some ongoing
                return False
            else:
                cursor3 = self.connection.cursor()
                cursor3.execute("INSERT INTO ClockedIn (shift_id, driver_id, datetime)\
                     VALUES (%s, %s, %s)",(shift_id, driver_id, when))
                cursor4 = self.connection.cursor()
                cursor4.execute("INSERT INTO Location (shift_id, datetime, location) \
                    VALUES (%s, %s, %s)",(shift_id, when, geo_loc))
                self.connection.commit()
                return True
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            # raise ex
            self.connection.rollback()
            return False

    def pick_up(self, driver_id: int, client_id: int, when: datetime) -> bool:
        """Record the fact that the driver with driver id <driver_id> has
        picked up the client with client id <client_id> at date time <when>.

        If (a) the driver is currently on an ongoing shift, and
           (b) they have been dispatched to pick up the client, and
           (c) the corresponding pick-up has not been recorded
        record it by adding a row to the Pickup table, and return True.
        Otherwise, return False.

        You may not assume that the dispatch actually occurred, but you may
        assume there is no more than one outstanding dispatch entry for this
        driver and this client.

        Return True if the operation was successful, False otherwise. I.e.,
        do NOT throw an error if this pick up fails.

        Precondition:
            - <when> is after all dates currently recorded in the database.
        """
        try:
            # TODO: implement this method
            cursor = self.connection.cursor()
            s = "select driver_id, shift_id from clockedIn Natural Join (select shift_id from clockedIn \
                except (select shift_id from clockedOut)) K where driver_id ={};".format(driver_id)
            cursor.execute(s)
            cursor_ = self.connection.cursor()
            s_ = "select client_id from client where client_id = {};".format(client_id)
            cursor_.execute(s_)
            if cursor.rowcount == 0 or cursor_.rowcount == 0: #has no ongoing shift
                return False
            else:
                shift_id = -1
                request_id = -1
                for record in cursor: #exactly 1
                    shift_id = record[1]
                cursor2 = self.connection.cursor()
                cursor3 = self.connection.cursor()
                cursor2.execute("select request_id from dispatch where shift_id={};".format(shift_id))
                if cursor2.rowcount == 1:
                    for record in cursor2:
                        request_id = record[0]
                cursor3.execute("select * from pickup where request_id={};".format(request_id))        
                if cursor3.rowcount == 0:
                    cursor.execute("INSERT INTO Pickup (request_id, datetime) VALUES (%s, %s)",(request_id, when))
                    self.connection.commit()
                    return True
                else:
                    return False

        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            # raise ex
            self.connection.rollback()
            return False
  

    # ===================== Dispatcher-related methods ===================== #

    def dispatch(self, nw: GeoLoc, se: GeoLoc, when: datetime) -> None:
        """Dispatch drivers to the clients who have requested rides in the area
        bounded by <nw> and <se>, such that:
            - <nw> is the longitude and latitude in the northwest corner of this
            area
            - <se> is the longitude and latitude in the southeast corner of this
            area
        and record the dispatch time as <when>.

        Area boundaries are inclusive. For example, the point (4.0, 10.0)
        is considered within the area defined by
                    NW = (1.0, 10.0) and SE = (25.0, 2.0)
        even though it is right at the upper boundary of the area.

        NOTE: + longitude values decrease as we move further west, and
                latitude values decrease as we move further south.
              + You may find the PostgreSQL operators @> and <@> helpful.

        For all clients who have requested rides in this area (i.e., whose
        request has a source location in this area) and a driver has not
        been dispatched to them yet, dispatch drivers to them one at a time,
        from the client with the highest total billings down to the client
        with the lowest total billings, or until there are no more drivers
        available.

        Only drivers who meet all of these conditions are dispatched:
            (a) They are currently on an ongoing shift.
            (b) They are available and are NOT currently dispatched or on
            an ongoing ride.
            (c) Their most recent recorded location is in the area bounded by
            <nw> and <se>.
        When choosing a driver for a particular client, if there are several
        drivers to choose from, choose the one closest to the client's source
        location. In the case of a tie, any one of the tied drivers may be
        dispatched.

        Dispatching a driver is accomplished by adding a row to the Dispatch
        table. The dispatch car location is the driver's most recent recorded
        location. All dispatching that results from a call to this method is
        recorded to have happened at the same time, which is passed through
        parameter <when>.

        If an exception occurs during dispatch, rollback ALL changes.

        Precondition:
            - <when> is after all dates currently recorded in the database.
        """
        try:
            # find all undispatched requests in this area
            cursor = self.connection.cursor() 
            cursor.execute("DROP VIEW IF EXISTS undispatched CASCADE;")
            cursor2 = self.connection.cursor() 
            cursor2.execute("create view undispatched as\
                select request_id, client_id from request Natural Join \
                 (select request_id from request \
                 except (select request_id from dispatch)) T\
                 where source <@'(({}, {}), ({},{}))'::box;".format(nw.longitude, nw.latitude, se.longitude, se.latitude)
                 )
 
            cursor3 = self.connection.cursor()
            cursor3.execute("select * from undispatched natural join (select client_id, sum(amount) as total \
                            from billed natural join request group by client_id order by total desc) T\
                            ;")
            undispatched = [] # tuples of (request_id, client_id) pairs
            for record in cursor3:
                undispatched.append((record[0], record[1]))
            print(undispatched)
            # deal with driver
            cursor5 = self.connection.cursor()
            cursor5.execute("DROP VIEW IF EXISTS ongoingdrivers CASCADE;")
            cursor4 = self.connection.cursor()
            cursor4.execute("create view ongoingdrivers as \
                select driver_id, shift_id from clockedIn Natural Join (select shift_id from clockedIn \
                except (select shift_id from clockedOut)) K;")
            cursor6 = self.connection.cursor()
            cursor6.execute("DROP VIEW IF EXISTS availdrivers CASCADE;")
            cursor7 = self.connection.cursor()
            cursor7.execute("create view availdrivers as\
                            select shift_id from ongoingdrivers\
                            except\
                                (select shift_id from dispatch natural join \
                                (select request_id from dispatch except (select request_id from dropoff))T);")

            cursor8 = self.connection.cursor()
            cursor8.execute("select shift_id, location from location Natural join \
                             (select shift_id, max(datetime) \
                               from availdrivers natural join location\
                                group by shift_id) T\
                             where location <@'(({}, {}), ({},{}))'::box;".format(nw.longitude, nw.latitude, se.longitude, se.latitude)
                             )
            available = []
            for record in cursor8:
                available.append((record[0], record[1]))
            print(available)
            i = 0
            while len(undispatched) > 0 and len(available) > 0:
                print(i)
                cursor9 = self.connection.cursor()
                loc = '({}, {})'.format(available[i][1].longitude, available[i][1].latitude)
                cursor9.execute("INSERT INTO Dispatch(request_id, shift_id, car_location, datetime) VALUES\
                                 (%s, %s, %s, %s)", (undispatched[i][1], available[i][0], loc, when))
                undispatched.pop(i)
                available.pop(i)
                i += 1
            self.connection.commit()
            return
         
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            # raise ex
            self.connection.rollback()
            return

    # =======================     Helper methods     ======================= #

    # You do not need to understand this code. See the doctest example in
    # class GeoLoc (look for ">>>") for how to use class GeoLoc.

    def _register_geo_loc(self) -> None:
        """Register the GeoLoc type and create the GeoLoc type adapter.

        This method
            (1) informs psycopg2 that the Python class GeoLoc corresponds
                to geo_loc in PostgreSQL.
            (2) defines the logic for quoting GeoLoc objects so that you
                can use GeoLoc objects in calls to execute.
            (3) defines the logic of reading GeoLoc objects from PostgreSQL.

        DO NOT make any modifications to this method.
        """

        def adapt_geo_loc(loc: GeoLoc) -> pg_ext.AsIs:
            """Convert the given geographical location <loc> to a quoted
            SQL string.
            """
            longitude = pg_ext.adapt(loc.longitude)
            latitude = pg_ext.adapt(loc.latitude)
            return pg_ext.AsIs(f"'({longitude}, {latitude})'::geo_loc")

        def cast_geo_loc(value: Optional[str], *args: List[Any]) \
                -> Optional[GeoLoc]:
            """Convert the given value <value> to a GeoLoc object.

            Throw an InterfaceError if the given value can't be converted to
            a GeoLoc object.
            """
            if value is None:
                return None
            m = re.match(r"\(([^)]+),([^)]+)\)", value)

            if m:
                return GeoLoc(float(m.group(1)), float(m.group(2)))
            else:
                raise pg.InterfaceError(f"bad geo_loc representation: {value}")

        with self.connection, self.connection.cursor() as cursor:
            cursor.execute("SELECT NULL::geo_loc")
            geo_loc_oid = cursor.description[0][1]

            geo_loc_type = pg_ext.new_type(
                (geo_loc_oid,), "GeoLoc", cast_geo_loc
            )
            pg_ext.register_type(geo_loc_type)
            pg_ext.register_adapter(GeoLoc, adapt_geo_loc)


def sample_test_function() -> None:
    """A sample test function."""
    a2 = Assignment2()
    try:
        # TODO: Change this to connect to your own database:
        connected = a2.connect("csc343h-nisailin", "nisailin", "")
        print(f"[Connected] Expected True | Got {connected}.")

        # TODO: Test one or more methods here, or better yet, make more testing
        #   functions, with each testing a different aspect of the code.

        # ------------------- Testing Clocked In -----------------------------#

        # These tests assume that you have already loaded the sample data we
        # provided into your database.

        # # This driver doesn't exist in db
        # clocked_in = a2.clock_in(
        #     989898, datetime.now(), GeoLoc(-79.233, 43.712)
        # )
        # print(f"[ClockIn] Expected False | Got {clocked_in}.")

        # # This drive does exist in the db
        # clocked_in = a2.clock_in(
        #     22222, datetime.now(), GeoLoc(-79.233, 43.712)
        # )
        # print(f"[ClockIn] Expected True | Got {clocked_in}.")

        # # Same driver clocks in again
        # clocked_in = a2.clock_in(
        #     22222, datetime.now(), GeoLoc(-79.233, 43.712)
        # )
        # print(f"[ClockIn] Expected False | Got {clocked_in}.")

        # # markus sample test
        # clocked_in = a2.clock_in(
        #     12345, datetime.now(), GeoLoc(-25.0, 50.0)
        # )
        # print(f"[ClockIn] Expected True | Got {clocked_in}.")

        # # pick_up(self, driver_id: int, client_id: int, when: datetime) 
        # # Q2 simple test - Driver and client are not in database - False
        # pickup = a2.pick_up(
        #     32432, 323, datetime(2022, 10, 31, 8, 15)
        # )
        # print(f"[ClockIn] Expected False | Got {pickup}.")

        # # Q2 simple test - driver on shift, dispatched, no pick-up recorded - True
        # pickup = a2.pick_up(
        #     12345, 100, datetime(2022, 10, 31, 8, 15)
        # )
        # print(f"[ClockIn] Expected True | Got {pickup}.")

        # q3
        nw = GeoLoc(-79.233, 10)
        se = GeoLoc(90, 90)
        dis = a2.dispatch(
            nw, se, datetime(2022, 10, 31, 11, 00)
        )
        print(f"[nw] Expected True | Got {dis}.")

    finally:
        a2.disconnect()


if __name__ == "__main__":
    # Un comment-out the next two lines if you would like all the doctest
    # examples (see ">>>" in the method and class docstrings) to be run
    # and checked.
    # import doctest
    # doctest.testmod()

    # TODO: Put your testing code here, or call testing functions such as
    #   this one:
    sample_test_function()