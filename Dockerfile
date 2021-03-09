FROM debian:latest

MAINTAINER treadie.io

RUN apt-get update && apt-get install -y wget procps curl jq cron

WORKDIR /root/
COPY get_latest_release.sh /root/
RUN /root/get_latest_release.sh

RUN dpkg -i /root/nessus.deb && rm nessus.deb
RUN update-rc.d nessusd defaults

COPY startup.sh /root/
COPY create_nessus_user.sh /root/
# COPY nessus_clean_old_scans.sh /root/

# COPY cron_nessus_clean_old_scans /etc/cron.d/
# RUN chmod 0644 /etc/cron.d/cron_nessus_clean_old_scans
# RUN crontab /etc/cron.d/cron_nessus_clean_old_scans
# RUN touch /var/log/cron.log

WORKDIR /root/

ENTRYPOINT ["/root/startup.sh"]
