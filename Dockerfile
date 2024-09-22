FROM netflixoss/tomcat:7.0.64

# LABEL maintainer="https://github.com/Fabr1ce"
LABEL maintainer="Netflix Open Source Development <talent@netflix.com>"

# ENV VERSION=2.0.3
ENV VERSION=1.10.18
ENV SERVER=eureka-server
ENV WARFILE=$SERVER-$VERSION.war

RUN cd /tomcat/webapps &&\
  mkdir eureka &&\
  cd eureka &&\
  wget -q https://repo1.maven.org/maven2/com/netflix/eureka/$SERVER/$VERSION/$WARFILE &&\
  jar xf $WARFILE &&\
  rm $WARFILE

ADD config.properties /tomcat/webapps/eureka/WEB-INF/classes/config.properties
ADD eureka-client-test.properties /tomcat/webapps/eureka/WEB-INF/classes/eureka-client-test.properties
ADD eureka-server-test.properties /tomcat/webapps/eureka/WEB-INF/classes/eureka-server-test.properties

EXPOSE 8080

ENTRYPOINT ["/tomcat/bin/catalina.sh"]

CMD ["run"]
