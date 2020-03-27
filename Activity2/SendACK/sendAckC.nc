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
    //other interfaces, if needed
    
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
  bool done = FALSE;

  void sendReq();
  void sendResp();
  
  
  //***************** Send request function ********************//
  //Stefano
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
	 my_msg_t* msg = (my_msg_t*)(call Pcket.getPayload(&packet, sizeof(my_msg));
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
		 dbg_clear("radio_pack", "\t\t type: %hhu \n ", msg->type);
		 dbg_clear("radio_pack", "\t\t data: %hhu \n", msg->data);
		 
	 }
	 
	 //Checks ACK	
	 //Should we put this here or in sendDone? 
	 if(call PacketAcknowledgements.wasAcked(msg) == TRUE)
	 	done = TRUE;
	 
 }        

  //****************** Task send response *****************//
  //Luca
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
  event void Boot.booted() {
	dbg("boot","Application booted.\n");
	/* Fill it ... */
	
	
  }

  //***************** SplitControl interface ********************//
  //Luca
  event void SplitControl.startDone(error_t err){
    /* Fill it ... */
  }
  
  //Luca
  event void SplitControl.stopDone(error_t err){
    /* Fill it ... */
  }

  //***************** MilliTimer interface ********************//
  //Stefano
  event void MilliTimer.fired() {
	/* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 * Fill this part...
	 */
  }
  

  //********************* AMSend interface ****************//
  //Luca
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

  }
  
  //************************* Read interface **********************//
  //Stefano
  event void Read.readDone(error_t result, uint16_t data) {
	/* This event is triggered when the fake sensor finish to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */

}

