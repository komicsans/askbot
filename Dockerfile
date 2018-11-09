ARG SRC_DIR=.

FROM python:2

ENV PYTHONUNBUFFERED 1

ADD $SRC_DIR /src/
WORKDIR /src/
RUN cp /src/conf/supervisord.conf /etc/supervisord.conf
RUN pip install -r /src/askbot_requirements.txt
RUN python setup.py install
RUN mkdir /site/
RUN apt-get update && apt-get -y install netcat memcached mc nginx-full less psmisc && apt-get clean
CMD ["envdir","/src/env","supervisord","-n","-c","/etc/supervisord.conf"]