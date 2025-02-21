#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "hashtable.h"

struct {
	char* key;
	void* data;
	int deleted;
} typedef HashTableData;

struct {
	HashTableData* data;
	size_t length;
} typedef HashTableBucket;

struct {
	HashTableBucket* buckets;
	size_t capacity;
} typedef HashTableImpl;

static int hash(char* key, size_t bucket_len) {
	int sum = 0;
	while(*key != '\0') {
		sum += *key++;
	}

	return sum % bucket_len;
}

HashTable hashtable_init(size_t capacity) {
	HashTableImpl* ht = (HashTableImpl*) malloc(sizeof(HashTableImpl));

	ht->buckets = (HashTableBucket*) calloc(sizeof(HashTableBucket), capacity);
	ht->capacity = capacity;
	
	return (HashTable) ht;
}

int hashtable_deinit(HashTable* ht) {
	HashTableImpl* ht_impl = (HashTableImpl*) *ht;

	for (int i = 0; i < ht_impl->capacity; ++i) {
		HashTableBucket bucket = ht_impl->buckets[i];
		for (int j = 0; j < bucket.length; ++j) {
			HashTableData data = bucket.data[j];
			free(data.key);
			free(data.data);
		}
		free(bucket.data);
	}

	free(ht_impl->buckets);
	free(ht_impl);
	ht = NULL;
	return 0;
}

void* hashtable_get(HashTable ht, char* key) {
	HashTableImpl* ht_impl = (HashTableImpl*) ht;

	int index = hash(key, ht_impl->capacity);

	HashTableBucket bucket = ht_impl->buckets[index];

	for (int i = 0; i < bucket.length; ++i) {
		HashTableData data = bucket.data[i];
		if (!data.deleted && strcmp(data.key, key) == 0) return data.data;
	}

	return NULL;
}

int hashtable_put(HashTable ht, char* key, void* val, size_t val_size) {
	HashTableImpl* ht_impl = (HashTableImpl*) ht;

	int index = hash(key, ht_impl->capacity);
	HashTableBucket* bucket = &ht_impl->buckets[index];

	//TODO: reuse the deleted?
	for (int i = 0; i < bucket->length; ++i) {
		HashTableData* data = &bucket->data[i];
		if (strcmp(data->key, key) == 0) {
			data->data = realloc(data->data, val_size);
			memcpy(data->data, val, val_size);
			data->deleted = 0;
			return 0;
		}
	}


	//otherwise, realloc
	bucket->length++;
	bucket->data = realloc(bucket->data, sizeof(HashTableData) * bucket->length);

	HashTableData newData = {
		.key = strdup(key),
		.data = malloc(val_size),
		.deleted = 0
	};
	memcpy(newData.data, val, val_size);
	bucket->data[bucket->length - 1] = newData;

	return 0;
}

int hashtable_remove(HashTable ht, char* key) {
	HashTableImpl* ht_impl = (HashTableImpl*) ht;

	int index = hash(key, ht_impl->capacity);
	HashTableBucket* bucket = &ht_impl->buckets[index];

	for (int i = 0; i < bucket->length; ++i) {
		HashTableData* data = &bucket->data[i];
		if (!data->deleted && strcmp(data->key, key) == 0) {
			data->deleted = 1;
			return 1;
		}
	}

	return 0;
}
