#include <pthread.h>
#include <semaphore.h>
#include <stdlib.h>
#include <stdio.h>
#include<cstring>
#include <time.h>
#include<unistd.h>
#include <iostream>
#include<queue>

using namespace std;

#define MaxItems 1// Maximum items a producer can produce or a consumer can consume
#define BufferSize 5 // Size of the buffer

sem_t empty;
sem_t full;
sem_t line;

sem_t departure;
int in = 0;
int buffer[BufferSize];

pthread_mutex_t *mymutexarray,mutex;

pthread_mutex_t departMutex, serviceMutex;

int no_of_cyclists,no_of_serviceman,payment_room_capacity;

queue<int> sonali_banker_line;

queue<int> departure_list;
queue<int> service_zone;

void *producer(void *pno)
{
        sem_wait(&empty);
        pthread_mutex_lock(&mutex);
        in=*((int *)pno);
        buffer[in] =in;
        pthread_mutex_unlock(&mutex);
        sem_post(&full);

    return NULL;
}

void *consumer(void *cno)
{
    int c=*((int *)cno)+1;	//consumer number

    srand(time(0));

    pthread_mutex_lock(&mymutexarray[0]);
    while(true) {
    	pthread_mutex_lock(&departMutex);
    	if(!departure_list.empty()){
			pthread_mutex_unlock(&departMutex);
			continue;
		}
		else {
            printf("%d started taking service from serviceman 1\n",c);
            pthread_mutex_lock(&serviceMutex);
            service_zone.push(c);
            pthread_mutex_unlock(&serviceMutex);
            usleep(1000 * (rand()%500+1));
            printf("%d finished taking service from serviceman 1\n",c);

            pthread_mutex_unlock(&departMutex);
            // pthread_mutex_lock(&mymutexarray[0]);
			break;
		}
    }

    pthread_mutex_lock(&mymutexarray[1]);
    pthread_mutex_unlock(&mymutexarray[0]);
    for(int i = 1; i < no_of_serviceman; i++) {
        // if(i==0) pthread_mutex_lock(&mymutexarray[i]);
        printf("%d started taking service from serviceman %d\n",c, i+1);
        usleep(1000 * (rand()%500+1));
        printf("%d finished taking service from serviceman %d\n",c, i+1);
        if(i!=no_of_serviceman-1)
        pthread_mutex_lock(&mymutexarray[i+1]);

        pthread_mutex_unlock(&mymutexarray[i]);
    }
    pthread_mutex_lock(&serviceMutex);
    service_zone.pop();
    pthread_mutex_unlock(&serviceMutex);

    // sonali_banker_line.push(*((int *)cno)+1);
    sem_wait(&line);
    // sonali_banker_line.pop();
    printf("%d started paying the service bills\n",c);
    usleep(1000 * (rand()%500+1));
    pthread_mutex_lock(&departMutex);
    printf("%d finished paying the service bills\n",c);
    departure_list.push(c);
    pthread_mutex_unlock(&departMutex);
    sem_post(&line);

    while(true){
        pthread_mutex_lock(&serviceMutex);
        if(!service_zone.empty()){
            pthread_mutex_unlock(&serviceMutex);
            continue;
        }
        else {
            pthread_mutex_unlock(&serviceMutex);
            break;
        }
    }
    usleep(1000 * (rand()%500+1));
    pthread_mutex_lock(&departMutex);
    printf("%d has departed\n",c);

    departure_list.pop();
    pthread_mutex_unlock(&departMutex);

    return NULL;
}

int main()
{
    // printf("%d", departure_list.empty());
     no_of_cyclists=10;
     no_of_serviceman=3;
     payment_room_capacity=2;

     int a1[no_of_serviceman],a2[no_of_cyclists];

     for(int i=0;i<no_of_serviceman;i++) a1[i]=i;
     for(int i=0;i<no_of_cyclists;i++) a2[i]=i;

     mymutexarray=new pthread_mutex_t[no_of_serviceman];


    pthread_t pro[no_of_serviceman],con[no_of_cyclists];
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_init(&departMutex, NULL);
    pthread_mutex_init(&serviceMutex, NULL);
    sem_init(&empty,0,BufferSize);
    sem_init(&full,0,0);
    sem_init(&line,0,payment_room_capacity);


    for(int i = 0; i < no_of_serviceman; i++) {
        pthread_create(&pro[i], NULL, producer, (void *)&a1[i]);
    }
    for(int i = 0; i < no_of_cyclists; i++) {
        pthread_create(&con[i], NULL, consumer, (void *)&a2[i]);
    }

    for(int i = 0; i < no_of_serviceman; i++) {
        pthread_join(pro[i], NULL);
    }
    for(int i = 0; i < no_of_cyclists; i++) {
        pthread_join(con[i], NULL);
    }

  for(int i=0;i<no_of_serviceman;i++) pthread_mutex_destroy(&mymutexarray[i]);
    pthread_mutex_destroy(&mutex);
    pthread_mutex_destroy(&departMutex);
    pthread_mutex_destroy(&serviceMutex);
    sem_destroy(&empty);
    sem_destroy(&full);
    sem_destroy(&line);

    return 0;
}
