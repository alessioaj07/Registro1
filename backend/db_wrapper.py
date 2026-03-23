import pymysql
from config import DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME


class DBWrapper:
    def __init__(self):
        self.connection = pymysql.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
        )

    def query(self, sql, params=None):
        with self.connection.cursor() as cur:
            cur.execute(sql, params or ())
            return cur.fetchall()

    def execute(self, sql, params=None):
        with self.connection.cursor() as cur:
            cur.execute(sql, params or ())
            return cur.lastrowid

    def get_grades_for_student(self, student_name):
        return self.query("SELECT id, student_name, subject, grade FROM grades WHERE student_name = %s ORDER BY id DESC", (student_name,))

    def get_all_grades(self):
        return self.query("SELECT id, student_name, subject, grade FROM grades ORDER BY id DESC")

    def add_grade(self, student_name, subject, grade):
        return self.execute(
            "INSERT INTO grades (student_name, subject, grade) VALUES (%s, %s, %s)",
            (student_name, subject, grade),
        )
