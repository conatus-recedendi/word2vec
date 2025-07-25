SCRIPTS_DIR=../scripts
BIN_DIR=../bin

CC = gcc
#Using -Ofast instead of -O3 might result in faster code, but is supported only by newer GCC versions
CFLAGS = -lm -pthread -O3 -march=native -Wall -funroll-loops -Wno-unused-result

all: word2vec word2phrase distance word-analogy compute-accuracy compute-accuracy-debug word2vec-p1-exp9

word2vec : word2vec.c
	$(CC) word2vec.c -o ${BIN_DIR}/word2vec $(CFLAGS)
word2phrase : word2phrase.c
	$(CC) word2phrase.c -o ${BIN_DIR}/word2phrase $(CFLAGS)
distance : distance.c
	$(CC) distance.c -o ${BIN_DIR}/distance $(CFLAGS)
word-analogy : word-analogy.c
	$(CC) word-analogy.c -o ${BIN_DIR}/word-analogy $(CFLAGS)
compute-accuracy : compute-accuracy.c
	$(CC) compute-accuracy.c -o ${BIN_DIR}/compute-accuracy $(CFLAGS)
	chmod +x ${SCRIPTS_DIR}/*.sh
compute-accuracy-debug: compute-accuracy-debug.c
	$(CC) compute-accuracy-debug.c -o ${BIN_DIR}/compute-accuracy-debug $(CFLAGS)
	chmod +x ${SCRIPTS_DIR}/*.sh
word2vec-p1-exp9: word2vec-p1-exp9.c
	$(CC) word2vec-p1-exp9.c -o ${BIN_DIR}/word2vec-p1-exp9 $(CFLAGS)

clean:
	pushd ${BIN_DIR} && rm -rf word2vec word2phrase distance word-analogy compute-accuracy compute-accuracy-debug word2vec-p1-exp; popd 
