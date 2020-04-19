# AUTO-INDEX SETTING
if [ $AUTOINDEX = "off" ];
then
	echo "AUTO INDEX : OFF"
	sed -i -e "s/autoindex on/autoindex off/g" /etc/nginx/sites-available/wordpress.conf
else
	echo "AUTO INDEX : ON"
fi

# LAUNCH SERVICES
service mysql restart
service php7.3-fpm start
nginx -g 'daemon off;'

# Run with autoindex enable 	: docker run -d -e AUTOINDEX="ON" -p 80:80 -p 443:433 <image_name>
# Run with autoindex disable 	: docker run -d -e AUTOINDEX="OFF" -p 80:80 -p 443:433 <image_name>

