NAME=racer
PLATFORMS=linux macosx mingw

$(PLATFORMS): tracks/track.obj
	make -C dokidoki-support $@ NAME="../$(NAME)"

clean:
	make -C dokidoki-support $@ NAME="../$(NAME)"

%.obj: %.blend
	blender $^ -P export_track.py -- $@
