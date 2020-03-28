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
  components new TimerMilliC() as timer;
  components new FakeSensorC() as fakeSensor;
  //components PacketAcknowledgements as pAcks;


/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  //Send and Receive interfaces
  //Radio Control
  App.SplitControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.PacketAcknowledgements -> AMSenderC.Acks;
  //App.PacketAcknowledgements -> pAcks;

  //Interfaces to access package fields
  App.Packet -> AMSenderC;

  //Timer interface
  App.MilliTimer -> timer;

  //Fake Sensor read
  App.Read -> fakeSensor.Read;

}

