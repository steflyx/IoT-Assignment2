#ifndef ACTIVITY5_H
#define ACTIVITY5_H

//Message structure
typedef nx_struct activity5_msg{
	nx_uint16_t value;
	nx_uint16_t sender_id;
} activity5_msg_t;

//Constants
enum {
  AM_RADIO_COUNT_MSG = 6, FREQUENCY = 5000
};

#endif