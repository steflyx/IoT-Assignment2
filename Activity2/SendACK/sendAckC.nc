/**
 *  Source file for implementation of module sendAckC in which
 *  the node 1 send a request to node 2 until it receives a response.
 *  The reply message contains a reading from the Fake Sensor.
 *
 *  @author Luca Pietro Borsani
 */

#include "sendAck.h"
#include "Timer.h"

module sendAckC {

  uses {
  /****** INTERFACES *****/
		interface Boot; 

	
    //interfaces for communication
	//interface for timer
	  interface Timer<TMilli> as MilliTimer;
    //other interfaces, if needed
 		interface SplitControl;
    interface Packet;
    interface AMSend;
    interface Receive;
    interface PacketAcknowledgements;
    
	
	//interface used to perform sensor reading (to get the value from a sensor)
		interface Read<uint16_t>;
  }

} implementation {

  uint8_t counter=0;
  uint8_t rec_id;
  message_t packet;
  bool ackReceived = FALSE;

  void sendReq();
  void sendResp();
  
  
  //***************** Send request function ********************//
  //Stefano
  //DONE
  void sendReq() {
		/* This function is called when we want to send a request
		 *
		 * STEPS:
		 * 1. Prepare the msg
		 * 2. Set the ACK flag for the message using the PacketAcknowledgements interface
		 *     (read the docs)
		 * 3. Send an UNICAST message to the correct node
		 * X. Use debug statements showing what's happening (i.e. message fields)
		 */
		 
		 //Preparation of the REQ message
		 my_msg_t* msg = (my_msg_t*)(call Packet.getPayload(&packet, sizeof(my_msg_t));
		 if (msg == NULL)
		 	 return;
		 	
		 msg->msg_type = REQ;
		 msg->msg_counter = counter;
		 msg->msg_value = 0;
		 
		 counter++;
		 
		 dbg("radio_req","Preparing REQ message... \n");
		 
		 //Set ACK for the message
		 if(call PacketAcknowledgements.requestAck(msg) == SUCCESS)
		 	 dbg("ACK", "Set succesfully!\n");
		 
		 //UNICAST SEND
		 if(call AMSend.send(2, &packet,sizeof(my_msg_t)) == SUCCESS){
		   dbg("radio_send", "Packet passed to lower layer successfully!\n");
		   dbg("radio_pack",">>>Pack\n \t Payload length %hhu \n", call Packet.payloadLength( &packet ) );
		   dbg_clear("radio_pack","\t Payload Sent\n" );
			 dbg_clear("radio_pack", "\t\t type: %hhu \n ", msg->msg_type);
			 dbg_clear("radio_pack", "\t\t counter: %hhu \n", msg->msg_counter); 
		 }
	 }        

  //****************** Task send response *****************//
  //DONE
  void sendResp() {
  	/* This function is called when we receive the REQ message.
  	 * Nothing to do here. 
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raise the event read one.
  	 */
		call Read.read();
  }

  //***************** Boot interface ********************//
  //Stefano
  //DONE
  event void Boot.booted() {
		dbg("boot","Application booted.\n");
	/* Fill it ... */
		call SplitControl.start();
  }

  //***************** SplitControl interface ********************//
  //Luca
  event void SplitControl.startDone(error_t err){
    /* Fill it ... */
    //Start the MilliTimer if TOS_NODE_ID == 1
		if(TOS_NODE_ID == 1){
			call MilliTimer.startPeriodic( 1000 );
			dbg("timer","Timer started.\n");
		}
  }
  
  //DONE
  event void SplitControl.stopDone(error_t err){
    /* Fill it ... */
  }

  //***************** MilliTimer interface ********************//
  //Stefano
  //DONE
  event void MilliTimer.fired() {
	/* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 * Fill this part...
	 */
	 
	 sendReq();
  }
  

  //********************* AMSend interface ****************//
  //Luca
	//Done
  event void AMSend.sendDone(message_t* buf,error_t err) {
	/* This event is triggered when a message is sent 
	 *
	 * STEPS:
	 * 1. Check if the packet is sent
	 * 2. Check if the ACK is received (read the docs)
	 * 2a. If yes, stop the timer. The program is done
	 * 2b. Otherwise, send again the request
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
   if(&packet == buf && err == SUCCESS) {
     dbg("radio_send", "Packet is sent!");	
	 	 dbg_clear("radio_send", " at time %s \n", sim_time_string()); 
	 }

	 //Checks ACK	
	 if(call PacketAcknowledgements.wasAcked(buf) == TRUE){
	 	 call MilliTimer.stop();
		 dbg("timer","Timer stopped.\n");
	 }
	 else{
	   sendReq();
   }
  }

  //***************************** Receive interface *****************//
  //Luca
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
	/* This event is triggered when a message is received 
	 *
	 * STEPS:
	 * 1. Read the content of the message
	 * 2. Check if the type is request (REQ)
	 * 3. If a request is received, send the response
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */

	//If you receive a REQ, update value of counter with msg->msg_counter
		 //Preparation of the REQ message
		 my_msg_t* msg = (my_msg_t*)(call Packet.getPayload(&packet, sizeof(my_msg_t));
		 if (msg == NULL)
		 	 return;

		 if (msg->msg_type == REQ) {
			 dbg("radio_req", "Request received!");	
	 	   dbg_clear("radio_req", " at time %s \n", sim_time_string()); 
       sendResp();
		 }
		 	
  }
  
  //************************* Read interface **********************//
  //Stefano
  //DONE
  event void Read.readDone(error_t result, uint16_t data) {
	/* This event is triggered when the fake sensor finish to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */
	 
	 my_msg_t* msg = (my_msg_t*)(call Packet.getPayload(&packet, sizeof(my_msg_t));
	 if (msg == NULL)
	 	return;
	 	
	 msg->msg_type = RESP;
	 msg->msg_counter = counter;
	 msg->msg_value = data;
	 
	 dbg("radio_pack", "Preparing message... \n");
	 
	 if(call AMSend.send(1, &packet,sizeof(my_msg_t)) == SUCCESS){
	   dbg("radio_send", "Packet passed to lower layer successfully!\n");
	   dbg("radio_pack",">>>Pack\n \t Payload length %hhu \n", call Packet.payloadLength( &packet ) );
	   dbg_clear("radio_pack","\t Payload Sent\n" );
		 dbg_clear("radio_pack", "\t\t type: %hhu \n ", msg->msg_type);
		 dbg_clear("radio_pack", "\t\t data: %hhu \n", msg->msg_value);
	 }

}

