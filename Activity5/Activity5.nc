#include "Timer.h"
#include "Activity5.h"
#include "printf.h"

module Activity5C @safe() {

	uses {
		interface Boot;
		interface Receive;
		interface AMSend;
		interface Timer<TMilli> as MilliTimer;
		interface SplitControl as AMControl;
		interface Packet;
		interface Random;
	}

}

implementation{

	message_t packet;

	uint16_t node_id = 0;	
	uint16_t value = 0;
	
	bool locked = FALSE;

	//Boot event
	event void Boot.booted(){
		call AMControl.start();
	}
	
	//Start event
	event void AMControl.startDone(error_t err){
		if (err == SUCCESS){
		
			//Node is initialized by Cooja
			node_id = TOS_NODE_ID;
			
			//If node id is 2 or 3, we start a timer		
			if (node_id == 2 || node_id == 3)
				call MilliTimer.startPeriodic(FREQUENCY);
			
		}
		else {
			call AMControl.start();
		}
	}
	
	//Stop event
	event void AMControl.stopDone(error_t err){
	
	}
	
	//Timer stops and mote sends a message with a random value between 0 and 100
	event void MilliTimer.fired(){
		if(locked) {
			return;
		}
		else{
		
			//Message preparation
			activity5_msg_t* a5m = (activity5_msg_t*)call Packet.getPayload(&packet, sizeof(activity5_msg_t));
			if (a5m == NULL){
				return;
			}
			
			a5m->value = call Random.rand16()%101;
			a5m->sender_id = node_id;
			
			if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(activity5_msg_t)) == SUCCESS)
				locked = TRUE;
					
		}
	}
	
	//Message sent
	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
   		if (&packet == bufPtr)
      		locked = FALSE;
  	}
	
	//A message is received
	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len){
		if (len != sizeof(activity5_msg_t)) {return bufPtr;}
		else{	
				
			//Only node 1 needs to print the value	
			if(node_id == 1){
			
				//Unpack message
				activity5_msg_t* a5m = (activity5_msg_t*)payload;
				
				//Checks if value is greater than 70 and prints it
				if(a5m->value > 70){
					printf("{\"id\": %u, \"value\": %u}\n",a5m->sender_id,a5m->value);
					printfflush();
				}
			}		
			return bufPtr;
		}
	}

}