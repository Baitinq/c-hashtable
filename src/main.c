#include <stdio.h>
#include "hashtable.h"

int main(int argc, char** argv) {
	printf("Testing hashing:\n");

	HashTable ht = hashtable_init();

	char res = hashtable_get(ht, 'a');

	printf("Result: %c\n", res);

	hashtable_put(ht, 'a', 'x');
	
	res = hashtable_get(ht, 'a');

	printf("Result: %c\n", res);
	
	hashtable_put(ht, 'h', '1');
	
	res = hashtable_get(ht, 'a');
	
	printf("Result: %c\n", res);

	hashtable_deinit(&ht);

	return 0;
}
