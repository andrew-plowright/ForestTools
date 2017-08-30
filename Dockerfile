FROM tesera/r-spatial-base:3.3.3

RUN apt-get update

RUN apt-get install -y libcairo2-dev libxt-dev

RUN R -e 'install.packages("ForestTools")'
