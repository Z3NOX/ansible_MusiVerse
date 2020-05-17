# NINGX config
NGINX läuft als Webserver auf MusiVerse und kümmert sich darum, die http Anfragen zu beantworten und entsprechend anzupassen. Das heißt im Konkreten:

- statischer Inhalt (wird nicht jedesmal von jekyll auf dem RPi erzeugt) liegt in `/srv/http/_site_static`
- dynamischer Inhalt (kann direkt über GIT geändert werden und wird vom RPi neu erzeugt) liegt in `/srv/http/_site`
