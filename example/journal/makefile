.PHONY: all build install run status stop journal

all: build

build:
	dub build --build=release-debug

install:
	cp bin/example /usr/bin/example
	cp example.service /etc/systemd/system/
	systemctl daemon-reload

remove: stop
	rm /usr/bin/example
	rm /etc/systemd/system/example.service 
	systemctl daemon-reload

run:
	systemctl start example

status:
	systemctl status example

stop:
	systemctl stop example

journal:
	journalctl --no-pager -b -u example -o short