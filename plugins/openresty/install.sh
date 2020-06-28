#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

curPath=`pwd`
rootPath=$(dirname "$curPath")
rootPath=$(dirname "$rootPath")
serverPath=$(dirname "$rootPath")


action=$1
type=$2

VERSION=$2
install_tmp=${rootPath}/tmp/mw_install.pl
openrestyDir=${serverPath}/source/openresty

if id www &> /dev/null ;then 
    echo "www UID is `id -u www`"
    echo "www Shell is `grep "^www:" /etc/passwd |cut -d':' -f7 `"
else
    groupadd www
	useradd -g www -s /sbin/nologin www
fi

if [ "${2}" == "" ];then
	echo '缺少安装脚本...' > $install_tmp
	exit 0
fi 

if [ ! -d $curPath/versions/$2 ];then
	echo '缺少安装脚本2...' > $install_tmp
	exit 0
fi



Install_openresty()
{
	mkdir -p ${openrestyDir}
	echo '正在安装脚本文件...' > $install_tmp

	if [ ! -f ${openrestyDir}/openresty-${VERSION}.tar.gz ];then
		wget -O ${openrestyDir}/openresty-${VERSION}.tar.gz https://openresty.org/download/openresty-${VERSION}.tar.gz
	fi


	cd ${openrestyDir} && tar -zxvf openresty-${VERSION}.tar.gz

	cd ${openrestyDir}/openresty-${VERSION} && ./configure --prefix=$serverPath/openresty \
	--with-http_v2_module \
	--with-openssl=$serverPath/source/lib/openssl-1.0.2q  \
	--with-http_stub_status_module && make && make install && \
	echo "${VERSION}" > $serverPath/openresty/version.pl
	

	echo '安装完成' > $install_tmp
}

Uninstall_openresty()
{
	rm -rf $serverPath/openresty
	echo '卸载完成' > $install_tmp
}

action=$1
if [ "${1}" == 'install' ];then
	Install_openresty
else
	Uninstall_openresty
fi
