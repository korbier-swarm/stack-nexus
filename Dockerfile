FROM debian:buster-slim

EXPOSE 8081
VOLUME /opt/sonatype/sonatype-work/nexus3

RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1 \
	&& echo 'deb http://ftp.us.debian.org/debian sid main' >> /etc/apt/sources.list \
	&& apt-get update -y \
	&& apt-get install openjdk-8-jdk-headless wget curl gnupg systemctl -y \
	&& wget https://nx-staging.sonatype.com/repository/community-apt-hosted/pool/n/nexus-repository-manager/nexus-repository-manager_3.22.102-2_all.deb \
	&& apt install ./nexus-repository-manager_3.22.102-2_all.deb -y \
	&& sed -i 's/-Xmx2703m/-Xmx1200M/g' /opt/sonatype/nexus3/bin/nexus.vmoptions \
	&& sed -i 's/-Xms2703m/-Xms1200M/g' /opt/sonatype/nexus3/bin/nexus.vmoptions \
	&& echo '-XX:MaxDirectMemorySize=2G' >> /opt/sonatype/nexus3/bin/nexus.vmoptions \
	&& sed -i 's;-Djava.endorsed.dirs=lib/endorsed;-Djava.endorsed.dirs=lib/endorsed:/opt/sonatype/jna;g' /opt/sonatype/nexus3/bin/nexus.vmoptions \
	&& chmod -R 777 /opt/sonatype/sonatype-work/nexus3 \
	&& mkdir /opt/sonatype/jna \
	&& cd /opt/sonatype/jna \
	&& wget https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.5.0/jna-5.5.0.jar \
	&& wget https://repo1.maven.org/maven2/net/java/dev/jna/jna-platform/5.5.0/jna-platform-5.5.0.jar \
	&& chmod +x /opt/sonatype/jna/* \
	&& rm -f /nexus-repository-manager_3.22.102-2_all.deb

CMD systemctl start nexus-repository-manager && tail -F /opt/sonatype/sonatype-work/nexus3/log/nexus.log