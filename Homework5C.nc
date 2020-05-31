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

module Homework5C {
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
    
    random = (call Random.rand16() % 100);
    rcm->random = random;
    rcm->topic = TOS_NODE_ID;


    if (call AMSend.send(1, &packet, sizeof(radio_toss_msg_t)) == SUCCESS) {

		locked = TRUE;

      }
      }
     }
  }


  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {

      call Timer.startPeriodic(5000);
    }
    else {

      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {

  }

  event message_t* Receive.receive(message_t* bufPtr,
				   void* payload, uint8_t len) {



		if (len != sizeof(radio_toss_msg_t)) {return bufPtr;}
		else {
		  radio_toss_msg_t* rcm = (radio_toss_msg_t*)payload;


		   printf("id: %d random: %d\n", rcm->topic, rcm->random);
       printfflush();

		  return bufPtr;
		}
    
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;

    }
  }

}
