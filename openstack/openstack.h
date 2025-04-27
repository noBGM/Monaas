/**
\brief Entry point for accessing the OpenWSN stack.

\author Thomas Watteyne <watteyne@eecs.berkeley.edu>, October 2014.
*/

#ifndef OPENWSN_OPENSTACK_H
#define OPENWSN_OPENSTACK_H

#include "opendefs.h"
#include "center_schedule.h"
//=========================== define ==========================================

//=========================== typedef =========================================

//=========================== variables =======================================

//=========================== prototypes ======================================

void openstack_init(center_role_t role, uint8_t subrole,uint8_t expectedGroup);

#endif /* OPENWSN_OPENSTACK_H */
