.PHONY: put parse zip doc

put:
	rsync -vrt --delete --exclude=.git \
		--exclude=.gitignore \
		--exclude=.gitmodules \
		--exclude=data \
		--exclude=doc \
		--exclude=published \
		--exclude=save \
		--exclude=tool \
		. /Volumes/Elder\ Scrolls\ Online/live/AddOns/WritLogger

get:
	cp  -f /Volumes/Elder\ Scrolls\ Online/live/SavedVariables/WritLogger.lua     data/
	-cp -f /Volumes/Elder\ Scrolls\ Online/live/SavedVariables/LibDebugLogger.lua data/


getpts:
	cp  -f /Volumes/Elder\ Scrolls\ Online/pts/SavedVariables/WritLogger.lua     data/
	-cp -f /Volumes/Elder\ Scrolls\ Online/pts/SavedVariables/LibDebugLogger.lua data/

zip:
	-rm -rf published/WritLogger published/WritLogger\ x.x.x.zip
	mkdir -p published/WritLogger
	cp -R lang published/WritLogger/lang
	cp -R Libs published/WritLogger/Libs
	cp ./WritLogger* Bindings.xml published/WritLogger/
	rm -rf published/WritLogger/Libs/LibCustomTitles/.git

	cd published; zip -r WritLogger\ x.x.x.zip WritLogger

	rm -rf published/WritLogger

explore:
	cd tools ; lua explore.lua
