#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

#include "hashtable.h"

struct {
	void** data;
	size_t size;
} typedef HashTableImpl;

static int hash(char key) {
	return key % 7;//TODO
}

HashTable hashtable_init() {
	HashTableImpl* ht = (HashTableImpl*) malloc(sizeof(HashTableImpl));

	int len = 8; 
	ht->data = (void**) malloc(sizeof(void*) * len);
	ht->size = len;
	
	return (HashTable) ht;
}

int hashtable_deinit(HashTable* ht) {
	HashTableImpl* ht_impl = (HashTableImpl*) *ht;
	free(ht_impl->data);
	free(ht_impl);
	ht = NULL;
	return 0;
}

void* hashtable_get(HashTable ht, char key) {
	HashTableImpl* ht_impl = (HashTableImpl*) ht;

	int index = hash(key);

	void* res = ht_impl->data[index];

	return res;
}

int hashtable_put(HashTable ht, char key, void* val) {
	HashTableImpl* ht_impl = (HashTableImpl*) ht;

	int index = hash(key);

	ht_impl->data[index] = val;

	return 0;
}
