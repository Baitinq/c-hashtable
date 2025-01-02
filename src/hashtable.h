#ifndef __HASHTABLE_H__
#define __HASHTABLE_H__

void typedef *HashTable;

HashTable hashtable_init();

int hashtable_deinit(HashTable*);

int hashtable_put(HashTable, char, void*);

void* hashtable_get(HashTable, char);

#endif
