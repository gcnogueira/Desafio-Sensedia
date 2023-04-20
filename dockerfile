FROM ubuntu:20.04
RUN apt-get update
COPY ./script-desafio.sh /home
COPY challenge-sre-2023 /home/challenge-sre-2023/
WORKDIR /home
CMD ["bash",  "./script-desafio.sh"]
