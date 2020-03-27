/**
 *  Message structure:
 *	msg_type -> either REQ or RESP (constants)
 *	msg_counter -> incremental integer
 *	value -> value from sensor
 */

#ifndef SENDACK_H
#define SENDACK_H

//payload of the msg
typedef nx_struct my_msg {
	nx_uint8_t msg_type;
    nx_uint8_t msg_counter;
    nx_uint16_t msg_value;
    
} my_msg_t;

#define REQ 1
#define RESP 2 

enum{
AM_MY_MSG = 6, REQ = 0, RESP = 1,
};

#endif
