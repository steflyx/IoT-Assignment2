#ifndef ACTIVITY1_H
#define ACTIVITY1_H

//Message structure
typedef nx_struct activity1_msg{
	nx_uint16_t counter;
	nx_uint16_t sender_id;
} activity1_msg_t;

//Some constants
enum {
  AM_RADIO_COUNT_MSG = 6, FREQUENCE_NODE_1 = 1000, FREQUENCE_NODE_2 = 333, FREQUENCE_NODE_3 = 200,
};

#endif