FROM python:3.9.7

WORKDIR /code
ADD requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY dbConnection.py dbConnection.py

CMD ["python3", "-u", "dbConnection.py"]