FROM netflixoss/tomcat:7.0.64

LABEL maintainer="https://github.com/Fabr1ce"

# ENV VERSION=2.0.3
ENV VERSION=1.3.1
ENV SERVER=eureka-server
ENV WARFILE=$SERVER-$VERSION.war

WORKDIR /tomcat/webapps

# RUN cd /tomcat/webapps &&\
RUN mkdir eureka

WORKDIR eureka
  # cd eureka &&\

ADD https://repo1.maven.org/maven2/com/netflix/eureka/$SERVER/$VERSION/$WARFILE .

RUN jar xf $WARFILE
RUN  rm $WARFILE

ADD config.properties /tomcat/webapps/eureka/WEB-INF/classes/config.properties
ADD eureka-client-test.properties /tomcat/webapps/eureka/WEB-INF/classes/eureka-client-test.properties
ADD eureka-server-test.properties /tomcat/webapps/eureka/WEB-INF/classes/eureka-server-test.properties

WORKDIR /

EXPOSE 8080

# ENTRYPOINT ["/tomcat/bin/catalina.sh", "run"]
ENTRYPOINT ["/tomcat/bin/catalina.sh"]

CMD ["run"]
