#include "Timer.h"
#include "Activity1.h"

module Activity1C @safe() {

	uses {
		interface Leds;
		interface Boot;
		interface Receive;
		interface AMSend;
		interface Timer<TMilli> as MilliTimer;
		interface SplitControl as AMControl;
		interface Packet;
	}

}

implementation{

	message_t packet;

	uint16_t node_id = 0;
	
	uint16_t counter = 0;
	
	bool led0 = FALSE;
	bool led1 = FALSE;
	bool led2 = FALSE;

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
			
			//According to the node id, timer has a different frequency
			if (node_id == 1)			
				call MilliTimer.startPeriodic(FREQUENCE_NODE_1);	
			
			if (node_id == 2)
				call MilliTimer.startPeriodic(FREQUENCE_NODE_2);
			
			if (node_id == 3)
				call MilliTimer.startPeriodic(FREQUENCE_NODE_3);
		}
		else {
			call AMControl.start();
		}
	}
	
	//Stop event
	event void AMControl.stopDone(error_t err){
	
	}
	
	//Timer stops and mote sends a message with its id and counter
	event void MilliTimer.fired(){
		if(locked) {
			return;
		}
		else{
		
			//Message preparation
			activity1_msg_t* a1m = (activity1_msg_t*)call Packet.getPayload(&packet, sizeof(activity1_msg_t));
			if (a1m == NULL){
				return;
			}
			
			a1m->counter = counter;
			a1m->sender_id = node_id;
			
			if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(activity1_msg_t)) == SUCCESS)
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
		if (len != sizeof(activity1_msg_t)) {return bufPtr;}
		else{	
		
			//Unpack message
			activity1_msg_t* a1m = (activity1_msg_t*)payload;
			
			//Every time a message is received, counter is increased
			counter++;
			
			//If counter is mod10 == 0, turn all led off
			if (a1m->counter % 10 == 0){
				call Leds.led0Off();
				call Leds.led1Off();
				call Leds.led2Off();
				led0 = FALSE;
				led1 = FALSE;
				led2 = FALSE;
			}
			else{
				
				//If sender is 1, turn on led 1 (same for 2 and 3)
				if(a1m->sender_id == 1){
					if(led0){
						call Leds.led0Off();
					}
					else{
						call Leds.led0On();
					}
					led0 = !led0;
				}
				if(a1m->sender_id == 2){
					if(led1){
						call Leds.led1Off();
					}
					else{
						call Leds.led1On();
					}
					led1 = !led1;
				}
				if(a1m->sender_id == 3){
					if(led2){
						call Leds.led2Off();
					}
					else{
						call Leds.led2On();
					}
					led2 = !led2;
				}
			}			
			return bufPtr;
		}
	}

}