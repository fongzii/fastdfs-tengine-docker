FROM centos:7

RUN yum -y install git gcc gcc-c++ autoconf automake zlib zlib-devel openssl openssl-devel pcre pcre-devel gd gd-devel

ENV FASTDFS_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/var/fdfs \
    PORT= \
    GROUP_NAME= \
    TRACKER_SERVER= \
    FASTDFS_MODE=tracker \
    WEB_PORT=

RUN mkdir -p ${FASTDFS_PATH}/libfastcommon \
 && mkdir -p ${FASTDFS_PATH}/fastdfs

RUN git clone --depth 1 https://github.com/happyfish100/libfastcommon.git ${FASTDFS_PATH}/libfastcommon
RUN cd ${FASTDFS_PATH}/libfastcommon chmod 777 make.sh \
 && ./make.sh && ./make.sh install

COPY git clone --depth 1 https://github.com/happyfish100/fastdfs.git ${FASTDFS_PATH}/fastdfs
RUN cd ${FASTDFS_PATH}/fastdfs \
 && ./make.sh && ./make.sh install \
 && cp conf/* /etc/fdfs/

ENV TENGINE_VERSION=tengine-2.2.3

RUN  cd /tmp \
 && wget http://tengine.taobao.org/download/${TENGINE_VERSION}.tar.gz \
 && tar -xzvf ${TENGINE_VERSION}.tar.gz \
 && git clone --depth 1 https://github.com/happyfish100/fastdfs-nginx-module.git ${TENGINE_VERSION}/fastdfs-nginx-module
 
COPY ./${TENGINE_VERSION} /tmp/${TENGINE_VERSION}
RUN cd /tmp/ && chmod -R 777 /tmp/${TENGINE_VERSION}

#./configure
RUN cd /tmp/${TENGINE_VERSION} && ./configure \
  --prefix=/opt/${TENGINE_VERSION}/ \
  --user=nginx \
  --group=nginx \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx/nginx.pid  \
  --lock-path=/var/lock/nginx.lock \
  --with-http_image_filter_module \
  --add-module=fastdfs-nginx-module/src \
  --with-http_ssl_module \
  --with-http_flv_module \
  --with-http_stub_status_module \
  --with-http_gzip_static_module &&\
  cd /tmp/${TENGINE_VERSION} && make && make install && \
  rm -rf /tmp/* && yum clean all && \
  
EXPOSE 80 443

COPY start.sh /usr/bin/
RUN chmod 755 /usr/bin/start.sh
ENTRYPOINT ["/usr/bin/start.sh"]
