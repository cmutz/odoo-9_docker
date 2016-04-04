FROM ubuntu:14.04
MAINTAINER Clement Mutz <c.mutz@whoople.fr>
ENV DEBIAN_FRONTEND noninteractive

# Install program to configure locales 
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y -q locales
RUN dpkg-reconfigure locales && \
  locale-gen fr_FR.UTF-8 && \
  /usr/sbin/update-locale LANG=fr_FR.UTF-8
# Install needed default locale for Makefly 
RUN echo 'fr_FR.UTF-8 UTF-8' >> /etc/locale.gen && \
  locale-gen
# Set default locale for the environment 
ENV LC_ALL fr_FR.UTF-8 
ENV LANG fr_FR.UTF-8 
ENV LANGUAGE fr_FR.UTF-8

RUN touch /etc/init.d/systemd-logind
RUN rm /usr/sbin/policy-rc.d
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q upgrade && apt-get -y -q dist-upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q subversion git bzr bzrtools python-pip postgresql postgresql-server-dev-9.3 python-all-dev python-dev python-setuptools libxml2-dev libxslt1-dev libevent-dev libsasl2-dev libldap2-dev pkg-config libtiff5-dev libjpeg8-dev libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev liblcms2-utils libwebp-dev tcl8.6-dev tk8.6-dev python-tk libyaml-dev sudo wget
RUN adduser --system --home=/opt/odoo --group odoo
RUN mkdir /var/log/odoo
RUN git clone https://www.github.com/odoo/odoo --depth 1 --branch 9.0 --single-branch /opt/odoo
RUN /etc/init.d/postgresql start && sudo -u postgres bash -c "psql -c \"CREATE USER odoo2222 WITH PASSWORD 'Whoople2016';\""
RUN pip install -r /opt/odoo/doc/requirements.txt
RUN pip install -r /opt/odoo/requirements.txt
RUN cd /tmp
RUN wget -qO- https://deb.nodesource.com/setup | sudo bash - && apt-get install -y  nodejs && npm install -g less less-plugin-clean-css
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q fontconfig
RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb && dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
RUN cp /usr/local/bin/wkhtmltopdf /usr/bin && cp /usr/local/bin/wkhtmltoimage /usr/bin
RUN cp /opt/odoo/debian/openerp-server.conf /etc/odoo-server.conf
COPY odoo-server.conf /etc/odoo-server.conf
COPY odoo-server /etc/init.d/odoo-server
RUN chmod 755 /etc/init.d/odoo-server
RUN chown root: /etc/init.d/odoo-server
RUN chown -R odoo: /opt/odoo/
RUN chown odoo:root /var/log/odoo
RUN touch /var/log/odoo/odoo-server.log
RUN chown odoo:root /var/log/odoo/odoo-server.log
RUN chown odoo: /etc/odoo-server.conf
RUN chmod 640 /etc/odoo-server.conf




#RUN git clone https://github.com/cmutz/postint /home/docker/postint
#RUN chmod 755 /home/docker/postint/install_postint.sh
#WORKDIR /home/docker
