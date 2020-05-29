/*
 * Copyright (c) 2006 Washington University in St. Louis.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */


 /**
  * Implementation of the 5th IoT challenge application.
  * The rules are given in the slides. Refering to Edoardo Longo first TinyOS
  * student activity.
  * @author Federico Dei Cas, Diego Carletti, Antoine Kryus
  * @date   May 29 2020
  */

#include "homework5.h"
#include <string.h>

module TestPrintfC {
  uses {
    interface Boot;
    interface Timer<TMilli>;
    interface Receive;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Packet;
    interface Random;
  }
}
implementation {

  message_t packet;
  bool locked;
  uint16_t random;
  radio_toss_msg_t* rcm;

  char topic[] = "static_top";

  event void Boot.booted() {
    call AMControl.start();
  }

  event void Timer.fired() {

	if(TOS_NODE_ID != 1) {

    if (locked) {
      return;
    } else {
    rcm = (radio_toss_msg_t*)call Packet.getPayload(&packet, sizeof(radio_toss_msg_t));
    if (rcm == NULL) {
		return;
    }


	  counter = (call Random.rand16() % 100);
    rcm->random = random;
    rcm-> id = TOS_NODE_ID;

    memcpy( rcm->topic, topic, sizeof(topic) );


    if (call AMSend.send(1, &packet, sizeof(radio_toss_msg_t)) == SUCCESS) {
		dbg("radio_send", "Sending packet");
		locked = TRUE;
		dbg_clear("radio_send", " at time %s \n", sim_time_string());
      }
      }
     }
  }


  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      dbg("radio","Radio on on node %d!\n", TOS_NODE_ID);
      call Timer.startPeriodic(5000);
    }
    else {
      dbgerror("radio", "Radio failed to start, retrying...\n");
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    dbg("boot", "Radio stopped!\n");
  }

  event message_t* Receive.receive(message_t* bufPtr,
				   void* payload, uint8_t len) {

   	if(TOS_NODE_ID == 1){

		if (len != sizeof(radio_toss_msg_t)) {return bufPtr;}
		else {
		  radio_toss_msg_t* rcm = (radio_toss_msg_t*)payload;

		  dbg("radio_rec", "Received packet at time %s\n", sim_time_string());
		  dbg("radio_pack",">>>Pack \n \t Payload length %hhu \n", call Packet.payloadLength( bufPtr ));

		  dbg_clear("radio_pack","\t\t Payload \n" );
		  dbg_clear("radio_pack", "\t\t msg_counter: %hhu \n", rcm->counter);



		   printf("id: %d random: %d topic: %s \n", rcm->id, rcm->counter, rcm->topic);
       printfflush();

		  return bufPtr;
		}
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
      dbg("radio_send", "Packet sent...");
      dbg_clear("radio_send", " at time %s \n", sim_time_string());
    }
  }

}
