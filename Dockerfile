FROM python:2

ENV PYTHONUNBUFFERED 1

ADD . /src/
WORKDIR /src/
RUN pip install -r askbot_requirements.txt
RUN python setup.py install
RUN mkdir /site/
RUN apt-get update && apt-get -y install netcat memcached mc nginx-full less && apt-get clean
CMD ["bash","-x","/src/init-askbot.sh"]