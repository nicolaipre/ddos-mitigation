# Layer 7 DDoS Mitigation for Nginx

This is a simple mitigation setup for using Lua with Nginx. The way this works is by acting as a reverse TCP proxy, and performing a JavaScript check for clients that are not whitelisted. By doing this, one can easily drop clients that do not support JavaScript (i.e. bots or other unwanted types of requests). 

The implementation is quite similar to the service Blazingfast.io offers, and has been based on the public repository [ngx_lua_anticc](https://github.com/leeyiw/ngx_lua_anticc).

The current validation page is based on Blazingfast.io's implementation with minor modifications. You may adjust as you please. 

<br>

# Installation instructions

## Create a working directory for installations from source files (Optional)
```
sudo mkdir /source
sudo chown -R <user:group> /source
cd /source
```

<br>

## 1. Download and install all dependencies

```
sudo apt-get install libpcre3-dev zlib1g-dev openssl-dev gcc make automake
```

<br>

### Download and install OpenResty's LuaJIT2
```
wget https://github.com/openresty/luajit2/archive/v2.0.5.tar.gz
tar -xvf v2.0.5.tar.gz
cd luajit2-2.0.5/
make PREFIX=/usr/local/lib/lua
sudo make install
```

<br>

### Download Nginx Development Kit
```
wget https://github.com/simplresty/ngx_devel_kit/archive/v0.3.1rc1.tar.gz
tar -xvf v0.3.1rc1.tar.gz
```

<br>

### Download Nginx Lua Module
```
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.14rc3.tar.gz
tar -xvf v0.10.14rc3.tar.gz
```

<br>

### Download and install the lateset stable release of [Nginx](https://nginx.org/download/nginx-1.14.2.tar.gz).
```
wget https://nginx.org/download/nginx-1.14.2.tar.gz
tar -xvf nginx-1.14.2.tar.gz
cd nginx-1.14.2/

./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_stub_status_module --with-ld-opt=-Wl,-rpath,/usr/local/lib/lua --add-module=/source/ngx_devel_kit-0.3.1rc1 --add-module=/source/lua-nginx-module-0.10.14rc3 --with-openssl-opt=enable-ec_nistp_64_gcc_128 --with-openssl-opt=no-nextprotoneg --with-openssl-opt=no-weak-ssl-ciphers --with-openssl-opt=no-ssl3

make
sudo make install
```

<br>



## 2. Configure Nginx to use **l7_mitigation_nginx**

### Download the latest version of [l7_mitigation_nginx](https://github.com/nicolaipre/l7_mitigation_nginx/archive/master.zip)
1. Unzip the archive to the Nginx conf directory.

2. Include the line `include l7_mitigation_nginx-master/main.conf;` in the *http* section of `nginx.conf`.

<br>


## 3. Restart nginx
Once you restart Nginx, the Layer 7 DDoS Mitigation will be enabled, and you will now get a validation page prior to accessing your website where the JavaScript check will be performed. 
```
sudo killall -9 nginx
sudo ./nginx
```


<br>


# Notes
This is a simple implementation, and bugs may occur. Feel free to use this implementation for further development, but if you do remember to give credits to https://github.com/leeyiw/ngx_lua_anticc and Blazingfast.io. 