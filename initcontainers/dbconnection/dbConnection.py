import psycopg2

db_name = 'postgres'
db_user = 'root'
db_pass = 'vIiRAzPan1'
db_host = "dev-db-link-greenlight.veeaplatform.net"
db_port = '5432'
db_to_check = "dev_adedge_greenlight_xir_davie"


print(f"db_name : {db_name}" )
print(f"db_user : {db_user}")
print(f"db_pass : {db_pass}")
print(f"db_host : {db_host}")
print(f"db_port : {db_port}")

# db_exists_query = "select exists(SELECT datname FROM pg_catalog.pg_database WHERE lower(datname) = lower('{}'));".format(db_to_check)
#
# # Check database connectivity.
# def checkConnectivity():
#     dbConnected=True
#     print(f"dbConnected : {dbConnected}")
#     while dbConnected:
#         try:
#             conn = psycopg2.connect(
#                 host = db_host,
#                 database = db_name,
#                 user = db_user,
#                 password = db_pass,
#                 port = db_port)
#             conn.close()
#             dbConnected = False
#             print(f"Database Connected successfully to host.")
#         except:
#             print(f"Database Connection Failure.")


# if __name__ == "__main__":
    # checkConnectivity()