FROM tobix/wine:stable
MAINTAINER Tobias Gruetzmacher "tobias-docker@23.gs"

ENV WINEDEBUG -all
ENV WINEPREFIX /opt/wineprefix

COPY wine-init.sh SHA256SUMS.txt /tmp/helper/
COPY mkuserwineprefix /opt/

# Prepare environment
RUN xvfb-run sh /tmp/helper/wine-init.sh

# Install Python
ARG PYVER=3.9.4

RUN umask 0 && cd /tmp/helper && \
  curl -LOO \
    https://www.python.org/ftp/python/${PYVER}/python-${PYVER}-amd64.exe \
    https://github.com/upx/upx/releases/download/v3.96/upx-3.96-win64.zip \
  && \
  sha256sum -c SHA256SUMS.txt && \
  xvfb-run sh -c "\
    wine python-${PYVER}-amd64.exe /quiet TargetDir=C:\\Python39 \
      Include_doc=0 InstallAllUsers=1 PrependPath=1; \
    wineserver -w" && \
  unzip upx*.zip && \
  mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/ && \
  cd .. && rm -Rf helper

# Install some python software
RUN umask 0 && xvfb-run sh -c "\
  wine pip install --no-warn-script-location pyinstaller; \
  wineserver -w"

