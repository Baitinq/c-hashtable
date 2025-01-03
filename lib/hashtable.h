#ifndef __HASHTABLE_H__
#define __HASHTABLE_H__

void typedef *HashTable;

HashTable hashtable_init(size_t);

int hashtable_deinit(HashTable*);

int hashtable_put(HashTable, char*, void*);

int hashtable_remove(HashTable, char*);

void* hashtable_get(HashTable, char*);

#endif
