CC := clang++
FLAGS := -Wall -std=c++2a -fimplicit-modules -fimplicit-module-maps


.PHONY: modules pcm clean

.DELETE_ON_ERROR:
main: precompile
	echo "-------- Building Main ---------"; \
	pcm=""; \
	for filename in ./pcm/*.pcm; do\
		pcm="$$pcm $$filename"; \
	done; \
	echo "VARIABLE PCM = $$pcm"; \
	${CC} ${FLAGS} -fprebuilt-module-path=pcm main.cpp $$pcm -o main;


#precompile all modules
.DELETE_ON_ERROR:
precompile:
	echo "-------- Building PCMs ---------"; \
	mkdir pcm; \
	for filename in ./modules/*.cpp; do \
		${CC} ${FLAGS} -c $$filename -Xclang -emit-module-interface -o ./pcm/$$(basename $$filename .cpp).pcm; \
	done;

clean:
	rm ./**/*.o; rm ./**/*.pcm;