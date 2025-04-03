# """
# Django command to wait for the database to be available.
# """
# import time

# from psycopg2 import OperationalError as Psycopg2OpError

# from django.db.utils import OperationalError
# from django.core.management.base import BaseCommand


# class Command(BaseCommand):
#     """Django command to wait for database."""

#     def handle(self, *args, **options):
#         """Entrypoint for command."""
#         self.stdout.write('Waiting for database...')
#         db_up = False
#         while db_up is False:
#             try:
#                 self.check(databases=['default'])
#                 db_up = True
#             except (Psycopg2OpError, OperationalError):
#                 self.stdout.write('Database unavailable, waiting 1 second...')
#                 time.sleep(1)

#         self.stdout.write(self.style.SUCCESS('Database available!'))

# wait_for_db.py
import time
import psycopg2
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    def handle(self, *args, **options):
        self.stdout.write('Waiting for database...')
        while True:
            try:
                conn = psycopg2.connect(
                    dbname="devdb",
                    user="devuser",
                    password="changeme",
                    host="db"
                )
                conn.close()
                self.stdout.write(self.style.SUCCESS('Database available!'))
                return
            except psycopg2.OperationalError as e:
                self.stdout.write(f'Database unavailable: {e}, retrying...')
                time.sleep(1)