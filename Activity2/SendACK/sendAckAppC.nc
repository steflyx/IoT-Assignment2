/**
 *  Configuration file for wiring of sendAckC module to other common 
 *  components needed for proper functioning
 *
 *  @author Luca Pietro Borsani
 */

#include "sendAck.h"

configuration sendAckAppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, sendAckC as App;

  //add the other components here
  components new AMSenderC(AM_SEND_MSG);
  components new AMReceiverC(AM_SEND_MSG);
  components ActiveMessageC;
	components new TimerMilliC as timer;
	components new FakeSensorC as fakeSensor
	components new PacketAcknowledgements as pAcks


/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  //Send and Receive interfaces
  //Radio Control
  App.SplitControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;
  App.Receive -> AMReceiverC;

  //Interfaces to access package fields
	App.PacketAcknowledgements -> pAcks

  //Timer interface
	App.TempTimer -> temp_t;

  //Fake Sensor read
  App.SensorRead -> fakeSensor;

}

