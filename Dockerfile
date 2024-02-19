# syntax=docker/dockerfile:1
FROM fedora:38

RUN dnf upgrade --refresh -y

# install dependencies
RUN dnf install -y onedrive syncthing

# non-root user and homedir
RUN mkdir /od_st
RUN useradd -d /od_st -u 1000 od_st
RUN chown od_st:od_st /od_st

WORKDIR /od_st

# create subdirectories
ADD bash/conf.sh ./
RUN chown od_st:od_st conf.sh
RUN chmod 755 conf.sh
RUN sudo -u od_st ./conf.sh
RUN rm conf.sh

# init st
EXPOSE 8384
ADD conf/config.xml .tmp-config/syncthing
ADD conf/key.pem .tmp-config/syncthing
ADD conf/cert.pem .tmp-config/syncthing
RUN chown od_st:od_st .tmp-config/syncthing/config.xml
RUN chown od_st:od_st .tmp-config/syncthing/key.pem
RUN chown od_st:od_st .tmp-config/syncthing/cert.pem

# init od
ADD conf/main_config .tmp-config/onedrive/config
ARG stDocs=".tmp-config/Sim Tech Documents/config"
ADD conf/sp_config ${stDocs}
ADD conf/business_shared_folders .tmp-config/onedrive
RUN chown od_st:od_st .tmp-config/onedrive/config
RUN chown od_st:od_st "${stDocs}"
RUN chown od_st:od_st .tmp-config/onedrive/business_shared_folders

# init script
ADD bash/syncer.sh bin
RUN chown od_st:od_st bin/syncer.sh
RUN chmod 755 bin/syncer.sh

# vol
VOLUME "/od_st/onedrive"
VOLUME "/od_st/sim_tech_docs"
VOLUME "/od_st/.config"

#RUN ls -lt bin
# specify user and cmd for runtime
USER od_st
ENTRYPOINT [ "./bin/syncer.sh" ]