#include <stdio.h>
#include "hashtable.h"

int main(int argc, char** argv) {
	printf("Testing hashing:\n");

	HashTable ht = hashtable_init();

	char* res = (char*) hashtable_get(ht, "a");

	printf("Result: %s\n", res);

	hashtable_put(ht, "aa", (void*)"x");

	res = hashtable_get(ht, "aa");

	printf("Result: %s\n", res);

	hashtable_put(ht, "b", (void*)"1");

	printf("This should still be x\n");

	res = hashtable_get(ht, "aa");

	printf("Result: %s\n", res);

	res = hashtable_get(ht, "b");

	printf("Result: %s\n", res);

	hashtable_remove(ht, "b");

	res = hashtable_get(ht, "b");

	printf("Result: %s\n", res);

	hashtable_deinit(&ht);

	return 0;
}
