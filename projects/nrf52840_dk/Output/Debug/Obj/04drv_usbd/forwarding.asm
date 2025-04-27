	.cpu cortex-m4
	.arch armv7e-m
	.fpu fpv4-sp-d16
	.eabi_attribute 27, 1
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 38, 1
	.eabi_attribute 18, 4
	.file	"forwarding.c"
	.text
.Ltext0:
	.section	.rodata.rreg_uriquery,"a"
	.align	2
	.type	rreg_uriquery, %object
	.size	rreg_uriquery, 6
rreg_uriquery:
	.ascii	"h=ucb\000"
	.section	.rodata.infoBoardname,"a"
	.align	2
	.type	infoBoardname, %object
	.size	infoBoardname, 9
infoBoardname:
	.ascii	"nRF52840\000"
	.section	.rodata.infouCName,"a"
	.align	2
	.type	infouCName, %object
	.size	infouCName, 9
infouCName:
	.ascii	"nRF52840\000"
	.section	.rodata.infoRadioName,"a"
	.align	2
	.type	infoRadioName, %object
	.size	infoRadioName, 13
infoRadioName:
	.ascii	"nRF52840 SoC\000"
	.section	.rodata.infoStackName,"a"
	.align	2
	.type	infoStackName, %object
	.size	infoStackName, 9
infoStackName:
	.ascii	"OpenWSN \000"
	.section	.rodata.linklocalprefix,"a"
	.align	2
	.type	linklocalprefix, %object
	.size	linklocalprefix, 8
linklocalprefix:
	.ascii	"\376\200\000\000\000\000\000\000"
	.section	.rodata.all_routers_multicast,"a"
	.align	2
	.type	all_routers_multicast, %object
	.size	all_routers_multicast, 16
all_routers_multicast:
	.ascii	"\377\002\000\000\000\000\000\000\000\000\000\000\000"
	.ascii	"\000\000\032"
	.section	.text.forwarding_init,"ax",%progbits
	.align	1
	.global	forwarding_init
	.syntax unified
	.thumb
	.thumb_func
	.type	forwarding_init, %function
forwarding_init:
.LFB115:
	.file 1 "C:\\Users\\16603\\Desktop\\HKUSTGZ\\IOTA5109-WSN\\openwsnProj\\mywsn\\openstack\\03b-IPv6\\forwarding.c"
	.loc 1 54 28
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 55 1
	nop
	bx	lr
.LFE115:
	.size	forwarding_init, .-forwarding_init
	.section	.text.forwarding_send,"ax",%progbits
	.align	1
	.global	forwarding_send
	.syntax unified
	.thumb
	.thumb_func
	.type	forwarding_send, %function
forwarding_send:
.LFB116:
	.loc 1 65 50
	@ args = 0, pretend = 0, frame = 264
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, lr}
.LCFI0:
	sub	sp, sp, #316
.LCFI1:
	add	r3, sp, #312
	sub	r3, r3, #260
	str	r0, [r3]
	.loc 1 74 14
	movs	r3, #0
	str	r3, [sp, #140]
	.loc 1 90 8
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 90 16
	movs	r2, #20
	strb	r2, [r3, #1]
	.loc 1 92 7
	movs	r3, #0
	strb	r3, [sp, #297]
	.loc 1 95 15
	movs	r0, #2
	bl	idmanager_getMyID
	str	r0, [sp, #288]
	.loc 1 98 8
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 98 28
	movs	r2, #3
	strb	r2, [r3, #42]
	.loc 1 100 41
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 100 5
	adds	r3, r3, #25
	add	r2, sp, #100
	add	r1, sp, #120
	mov	r0, r3
	bl	packetfunctions_ip128bToMac64b
	.loc 1 105 41
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 105 9
	adds	r3, r3, #25
	mov	r0, r3
	bl	packetfunctions_isLinkLocal
	mov	r3, r0
	.loc 1 105 8
	cmp	r3, #0
	bne	.L3
	.loc 1 106 51 discriminator 1
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 106 9 discriminator 1
	adds	r3, r3, #25
	mov	r0, r3
	bl	packetfunctions_isAllRoutersMulticast
	mov	r3, r0
	.loc 1 105 62 discriminator 1
	cmp	r3, #0
	bne	.L3
	.loc 1 107 49
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 107 9
	adds	r3, r3, #25
	mov	r0, r3
	bl	packetfunctions_isAllHostsMulticast
	mov	r3, r0
	.loc 1 106 72
	cmp	r3, #0
	beq	.L4
.L3:
	.loc 1 108 9
	add	r3, sp, #80
	movs	r2, #17
	movs	r1, #0
	mov	r0, r3
	bl	memset
	.loc 1 109 30
	movs	r3, #5
	strb	r3, [sp, #80]
	.loc 1 110 35
	movs	r3, #254
	strb	r3, [sp, #81]
	.loc 1 111 35
	movs	r3, #128
	strb	r3, [sp, #82]
	.loc 1 112 18
	add	r3, sp, #80
	str	r3, [sp, #308]
	.loc 1 113 13
	movs	r3, #0
	strb	r3, [sp, #299]
	.loc 1 114 13
	movs	r3, #0
	strb	r3, [sp, #296]
	b	.L5
.L4:
	.loc 1 115 16
	movs	r0, #5
	bl	idmanager_getMyID
	mov	r2, r0
	add	r3, sp, #120
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_sameAddress
	mov	r3, r0
	.loc 1 115 15
	cmp	r3, #0
	bne	.L6
	.loc 1 116 58 discriminator 1
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 116 16 discriminator 1
	adds	r3, r3, #25
	mov	r0, r3
	bl	packetfunctions_isBroadcastMulticast
	mov	r3, r0
	.loc 1 115 104 discriminator 1
	cmp	r3, #0
	bne	.L6
	.loc 1 117 20
	movs	r0, #5
	bl	idmanager_getMyID
	str	r0, [sp, #308]
	.loc 1 118 13
	movs	r3, #0
	strb	r3, [sp, #299]
	.loc 1 119 13
	movs	r3, #0
	strb	r3, [sp, #296]
	b	.L5
.L6:
	.loc 1 121 20
	movs	r0, #5
	bl	idmanager_getMyID
	str	r0, [sp, #308]
	.loc 1 122 13
	movs	r3, #1
	strb	r3, [sp, #299]
	.loc 1 123 13
	movs	r3, #1
	strb	r3, [sp, #296]
.L5:
	.loc 1 126 17
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 126 12
	add	r0, r3, #43
	.loc 1 126 55
	ldr	r3, [sp, #308]
	adds	r3, r3, #1
	.loc 1 126 5
	movs	r2, #8
	mov	r1, r3
	bl	memcpy
	.loc 1 127 17
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 127 12
	add	r0, r3, #51
	.loc 1 127 54
	ldr	r3, [sp, #288]
	adds	r3, r3, #1
	.loc 1 127 5
	movs	r2, #8
	mov	r1, r3
	bl	memcpy
	.loc 1 130 5
	add	r3, sp, #220
	movs	r2, #68
	movs	r1, #0
	mov	r0, r3
	bl	memset
	.loc 1 131 5
	add	r3, sp, #152
	movs	r2, #68
	movs	r1, #0
	mov	r0, r3
	bl	memset
	.loc 1 137 33
	movs	r3, #65
	strb	r3, [sp, #180]
	.loc 1 141 5
	add	r3, sp, #144
	movs	r1, #0
	mov	r0, r3
	bl	forwarding_createRplOption
	.loc 1 152 9
	add	r3, sp, #120
	ldr	r1, [sp, #308]
	mov	r0, r3
	bl	packetfunctions_sameAddress
	mov	r3, r0
	.loc 1 152 8
	cmp	r3, #0
	beq	.L7
	.loc 1 154 13
	movs	r3, #1
	strb	r3, [sp, #298]
	.loc 1 155 13
	movs	r3, #1
	strb	r3, [sp, #295]
	.loc 1 156 16
	add	r3, sp, #100
	str	r3, [sp, #304]
	.loc 1 157 15
	add	r3, sp, #60
	str	r3, [sp, #300]
	b	.L8
.L7:
	.loc 1 161 55
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 161 13
	adds	r3, r3, #25
	mov	r0, r3
	bl	packetfunctions_isBroadcastMulticast
	mov	r3, r0
	.loc 1 161 12
	cmp	r3, #0
	bne	.L9
	.loc 1 162 17
	movs	r3, #0
	strb	r3, [sp, #298]
	.loc 1 163 17
	movs	r3, #0
	strb	r3, [sp, #295]
	.loc 1 164 27
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 164 20
	adds	r3, r3, #25
	str	r3, [sp, #304]
	.loc 1 165 26
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 165 19
	adds	r3, r3, #42
	str	r3, [sp, #300]
	.loc 1 167 40
	movs	r3, #3
	strb	r3, [sp, #250]
	.loc 1 168 13
	ldr	r2, [sp, #300]
	add	r3, sp, #250
	ldr	r5, [r2]	@ unaligned
	ldr	r4, [r2, #4]	@ unaligned
	ldr	r0, [r2, #8]	@ unaligned
	ldr	r1, [r2, #12]	@ unaligned
	str	r5, [r3]	@ unaligned
	str	r4, [r3, #4]	@ unaligned
	str	r0, [r3, #8]	@ unaligned
	str	r1, [r3, #12]	@ unaligned
	ldrb	r2, [r2, #16]
	strb	r2, [r3, #16]
	.loc 1 169 41
	movs	r3, #65
	strb	r3, [sp, #248]
	b	.L8
.L9:
	.loc 1 172 17
	movs	r3, #3
	strb	r3, [sp, #298]
	.loc 1 173 15
	movs	r3, #1
	strb	r3, [sp, #297]
	.loc 1 174 17
	movs	r3, #3
	strb	r3, [sp, #295]
	.loc 1 175 27
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 175 20
	adds	r3, r3, #25
	str	r3, [sp, #304]
	.loc 1 176 26
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 176 19
	adds	r3, r3, #42
	str	r3, [sp, #300]
.L8:
	.loc 1 181 12
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	ldrb	r3, [r3, #12]	@ zero_extendqisi2
	.loc 1 181 8
	cmp	r3, #0
	beq	.L10
	.loc 1 182 21
	movs	r3, #1
	strb	r3, [sp, #294]
	b	.L11
.L10:
	.loc 1 184 21
	movs	r3, #0
	strb	r3, [sp, #294]
.L11:
	.loc 1 187 9
	ldr	r4, [sp, #140]
	.loc 1 191 31
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r3, [r3]
	.loc 1 187 9
	ldrb	r3, [r3, #11]	@ zero_extendqisi2
	ldrb	r2, [sp, #248]	@ zero_extendqisi2
	ldrb	r5, [sp, #294]	@ zero_extendqisi2
	add	r0, sp, #52
	movs	r1, #2
	str	r1, [sp, #44]
	ldr	r1, [sp, #300]
	str	r1, [sp, #40]
	ldr	r1, [sp, #304]
	str	r1, [sp, #36]
	ldrb	r1, [sp, #295]	@ zero_extendqisi2
	str	r1, [sp, #32]
	ldrb	r1, [sp, #296]	@ zero_extendqisi2
	str	r1, [sp, #28]
	ldrb	r1, [sp, #297]	@ zero_extendqisi2
	str	r1, [sp, #24]
	ldrb	r1, [sp, #298]	@ zero_extendqisi2
	str	r1, [sp, #20]
	ldrb	r1, [sp, #299]	@ zero_extendqisi2
	str	r1, [sp, #16]
	movs	r1, #0
	str	r1, [sp, #12]
	str	r2, [sp, #8]
	movs	r2, #2
	str	r2, [sp, #4]
	str	r3, [sp]
	mov	r3, r5
	mov	r2, r4
	movs	r1, #3
	bl	iphc_prependIPv6Header
	mov	r3, r0
	.loc 1 187 8
	cmp	r3, #1
	bne	.L12
	.loc 1 204 16
	movs	r3, #1
	b	.L14
.L12:
	.loc 1 208 46
	movs	r3, #1
	strb	r3, [sp, #228]
	.loc 1 210 12
	add	r3, sp, #312
	sub	r3, r3, #260
	ldr	r0, [r3]
	add	r4, sp, #144
	add	r2, sp, #152
	add	r1, sp, #220
	movs	r3, #2
	str	r3, [sp, #4]
	add	r3, sp, #140
	str	r3, [sp]
	mov	r3, r4
	bl	forwarding_send_internal_RoutingTable
	mov	r3, r0
.L14:
	.loc 1 221 1 discriminator 1
	mov	r0, r3
	add	sp, sp, #316
.LCFI2:
	@ sp needed
	pop	{r4, r5, pc}
.LFE116:
	.size	forwarding_send, .-forwarding_send
	.section	.text.forwarding_sendDone,"ax",%progbits
	.align	1
	.global	forwarding_sendDone
	.syntax unified
	.thumb
	.thumb_func
	.type	forwarding_sendDone, %function
forwarding_sendDone:
.LFB117:
	.loc 1 229 66
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{lr}
.LCFI3:
	sub	sp, sp, #20
.LCFI4:
	str	r0, [sp, #12]
	mov	r3, r1
	strb	r3, [sp, #11]
	.loc 1 232 16
	ldr	r3, [sp, #12]
	movs	r2, #20
	strb	r2, [r3, #1]
	.loc 1 234 12
	ldr	r3, [sp, #12]
	ldrb	r3, [r3]	@ zero_extendqisi2
	.loc 1 234 8
	cmp	r3, #7
	beq	.L16
	.loc 1 234 47 discriminator 1
	ldr	r3, [sp, #12]
	ldrb	r3, [r3]	@ zero_extendqisi2
	.loc 1 234 41 discriminator 1
	cmp	r3, #20
	bne	.L17
.L16:
	.loc 1 237 12
	ldrb	r3, [sp, #11]	@ zero_extendqisi2
	cmp	r3, #1
	bne	.L18
	.loc 1 238 13
	movs	r3, #0
	str	r3, [sp]
	movs	r3, #1
	movs	r2, #80
	movs	r1, #20
	movs	r0, #2
	bl	openserial_printLog
.L18:
	.loc 1 242 9
	ldr	r0, [sp, #12]
	bl	openqueue_freePacketBuffer
	b	.L19
.L17:
	.loc 1 247 20
	ldr	r3, [sp, #12]
	ldrb	r3, [r3, #11]	@ zero_extendqisi2
	.loc 1 247 9
	cmp	r3, #17
	beq	.L20
	cmp	r3, #58
	beq	.L21
	b	.L23
.L20:
	.loc 1 250 17
	ldrb	r3, [sp, #11]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r0, [sp, #12]
	bl	udp_sendDone
	.loc 1 251 17
	b	.L19
.L21:
	.loc 1 254 17
	ldrb	r3, [sp, #11]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r0, [sp, #12]
	bl	icmpv6_sendDone
	.loc 1 255 17
	b	.L19
.L23:
	.loc 1 258 17
	ldr	r3, [sp, #12]
	ldrb	r3, [r3, #11]	@ zero_extendqisi2
	uxth	r3, r3
	movs	r2, #0
	str	r2, [sp]
	movs	r2, #7
	movs	r1, #20
	movs	r0, #1
	bl	openserial_printLog
	.loc 1 263 17
	ldr	r0, [sp, #12]
	bl	openqueue_freePacketBuffer
	.loc 1 266 1
	nop
.L19:
	nop
	add	sp, sp, #20
.LCFI5:
	@ sp needed
	ldr	pc, [sp], #4
.LFE117:
	.size	forwarding_sendDone, .-forwarding_sendDone
	.section	.text.forwarding_receive,"ax",%progbits
	.align	1
	.global	forwarding_receive
	.syntax unified
	.thumb
	.thumb_func
	.type	forwarding_receive, %function
forwarding_receive:
.LFB118:
	.loc 1 284 3
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{lr}
.LCFI6:
	sub	sp, sp, #36
.LCFI7:
	str	r0, [sp, #20]
	str	r1, [sp, #16]
	str	r2, [sp, #12]
	str	r3, [sp, #8]
	.loc 1 289 8
	ldr	r3, [sp, #20]
	.loc 1 289 16
	movs	r2, #20
	strb	r2, [r3, #1]
	.loc 1 294 8
	ldr	r3, [sp, #20]
	.loc 1 294 41
	ldr	r2, [sp, #12]
	ldrb	r2, [r2, #9]	@ zero_extendqisi2
	.loc 1 294 22
	strb	r2, [r3, #11]
	.loc 1 295 8
	ldr	r3, [sp, #20]
	.loc 1 295 52
	ldr	r2, [sp, #12]
	ldrb	r2, [r2, #8]	@ zero_extendqisi2
	.loc 1 295 33
	strb	r2, [r3, #12]
	.loc 1 298 17
	ldr	r3, [sp, #20]
	.loc 1 298 12
	add	r0, r3, #25
	.loc 1 298 39
	ldr	r3, [sp, #12]
	adds	r3, r3, #47
	.loc 1 298 5
	movs	r2, #17
	mov	r1, r3
	bl	memcpy
	.loc 1 299 17
	ldr	r3, [sp, #20]
	.loc 1 299 12
	add	r0, r3, #42
	.loc 1 299 34
	ldr	r3, [sp, #12]
	adds	r3, r3, #30
	.loc 1 299 5
	movs	r2, #17
	mov	r1, r3
	bl	memcpy
	.loc 1 303 48
	ldr	r3, [sp, #20]
	.loc 1 303 21
	adds	r3, r3, #25
	mov	r0, r3
	bl	idmanager_isMyAddress
	mov	r3, r0
	.loc 1 301 8
	cmp	r3, #0
	bne	.L25
	.loc 1 305 63
	ldr	r3, [sp, #20]
	.loc 1 305 21
	adds	r3, r3, #25
	mov	r0, r3
	bl	packetfunctions_isBroadcastMulticast
	mov	r3, r0
	.loc 1 304 21
	cmp	r3, #0
	beq	.L26
.L25:
	.loc 1 308 30
	ldr	r3, [sp, #16]
	ldrb	r3, [r3, #9]	@ zero_extendqisi2
	.loc 1 307 13
	cmp	r3, #43
	beq	.L26
	.loc 1 310 35
	ldr	r3, [sp, #16]
	ldrb	r3, [r3, #30]	@ zero_extendqisi2
	.loc 1 310 12
	cmp	r3, #0
	bne	.L27
	.loc 1 310 74 discriminator 1
	ldr	r3, [sp, #16]
	ldrb	r3, [r3, #29]	@ zero_extendqisi2
	.loc 1 310 54 discriminator 1
	cmp	r3, #0
	beq	.L28
.L27:
	.loc 1 311 63
	ldr	r3, [sp, #16]
	ldrb	r3, [r3, #64]	@ zero_extendqisi2
	uxth	r2, r3
	.loc 1 311 98
	ldr	r3, [sp, #16]
	ldrb	r3, [r3, #29]	@ zero_extendqisi2
	uxth	r3, r3
	.loc 1 311 13
	add	r3, r3, r2
	uxth	r2, r3
	add	r3, sp, #20
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_tossHeader
.L28:
	.loc 1 314 59
	ldr	r3, [sp, #12]
	ldrb	r3, [r3, #64]	@ zero_extendqisi2
	.loc 1 314 9
	uxth	r2, r3
	add	r3, sp, #20
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_tossHeader
	.loc 1 316 20
	ldr	r3, [sp, #20]
	ldrb	r3, [r3, #11]	@ zero_extendqisi2
	.loc 1 316 9
	cmp	r3, #17
	beq	.L29
	cmp	r3, #58
	beq	.L30
	b	.L38
.L29:
	.loc 1 319 17
	ldr	r3, [sp, #20]
	mov	r0, r3
	bl	udp_receive
	.loc 1 320 17
	b	.L32
.L30:
	.loc 1 323 17
	ldr	r3, [sp, #20]
	mov	r0, r3
	bl	icmpv6_receive
	.loc 1 324 17
	b	.L32
.L38:
	.loc 1 327 17
	ldr	r3, [sp, #20]
	ldrb	r3, [r3, #11]	@ zero_extendqisi2
	uxth	r3, r3
	movs	r2, #1
	str	r2, [sp]
	movs	r2, #7
	movs	r1, #20
	movs	r0, #2
	bl	openserial_printLog
	.loc 1 332 17
	ldr	r3, [sp, #20]
	mov	r0, r3
	bl	openqueue_freePacketBuffer
	.loc 1 316 9
	b	.L24
.L32:
	b	.L24
.L26:
	.loc 1 338 12
	ldr	r3, [sp, #20]
	.loc 1 338 22
	movs	r2, #20
	strb	r2, [r3]
	.loc 1 353 13
	bl	openqueue_isHighPriorityEntryEnough
	mov	r3, r0
	.loc 1 353 12
	cmp	r3, #0
	bne	.L34
	.loc 1 356 13
	movs	r3, #0
	str	r3, [sp]
	movs	r3, #0
	movs	r2, #23
	movs	r1, #20
	movs	r0, #4
	bl	openserial_printLog
	.loc 1 358 13
	ldr	r3, [sp, #20]
	mov	r0, r3
	bl	openqueue_freePacketBuffer
	.loc 1 359 13
	b	.L24
.L34:
	.loc 1 362 30
	ldr	r3, [sp, #16]
	ldrb	r3, [r3, #9]	@ zero_extendqisi2
	.loc 1 362 12
	cmp	r3, #43
	beq	.L35
	.loc 1 363 19
	ldr	r3, [sp, #8]
	ldrb	r3, [r3, #1]
	strb	r3, [sp, #31]
	.loc 1 364 24
	ldr	r3, [sp, #8]
	ldrb	r2, [r3, #3]	@ zero_extendqisi2
	ldrb	r3, [r3, #4]	@ zero_extendqisi2
	lsls	r3, r3, #8
	orrs	r3, r3, r2
	strh	r3, [sp, #28]	@ movhi
	.loc 1 365 24
	ldrb	r3, [sp, #31]	@ zero_extendqisi2
	and	r3, r3, #16
	.loc 1 365 16
	cmp	r3, #0
	beq	.L36
	.loc 1 367 17
	ldrb	r3, [sp, #31]	@ zero_extendqisi2
	uxth	r2, r3
	ldrh	r3, [sp, #28]
	str	r3, [sp]
	mov	r3, r2
	movs	r2, #22
	movs	r1, #20
	movs	r0, #2
	bl	openserial_printLog
.L36:
	.loc 1 371 30
	bl	icmpv6rpl_getMyDAGrank
	mov	r3, r0
	mov	r2, r3
	.loc 1 371 16
	ldrh	r3, [sp, #28]
	cmp	r3, r2
	bcs	.L37
	.loc 1 374 35
	ldr	r3, [sp, #8]
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	orr	r3, r3, #8
	uxtb	r2, r3
	ldr	r3, [sp, #8]
	strb	r2, [r3, #1]
	.loc 1 376 17
	bl	icmpv6rpl_getMyDAGrank
	mov	r3, r0
	mov	r2, r3
	ldrh	r3, [sp, #28]
	str	r2, [sp]
	movs	r2, #21
	movs	r1, #20
	movs	r0, #2
	bl	openserial_printLog
.L37:
	.loc 1 380 13
	ldr	r3, [sp, #8]
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r0, [sp, #8]
	bl	forwarding_createRplOption
	.loc 1 389 21
	ldr	r0, [sp, #20]
	ldr	r3, [sp, #16]
	adds	r3, r3, #4
	movs	r2, #1
	str	r2, [sp, #4]
	str	r3, [sp]
	ldr	r3, [sp, #8]
	ldr	r2, [sp, #12]
	ldr	r1, [sp, #16]
	bl	forwarding_send_internal_RoutingTable
	mov	r3, r0
	.loc 1 388 16
	cmp	r3, #1
	bne	.L24
	.loc 1 401 17
	ldr	r3, [sp, #20]
	mov	r0, r3
	bl	openqueue_freePacketBuffer
	b	.L24
.L35:
	.loc 1 405 17
	ldr	r0, [sp, #20]
	ldr	r3, [sp, #8]
	ldr	r2, [sp, #12]
	ldr	r1, [sp, #16]
	bl	forwarding_send_internal_SourceRouting
	mov	r3, r0
	.loc 1 405 16
	cmp	r3, #1
	bne	.L24
	.loc 1 411 17
	movs	r3, #0
	str	r3, [sp]
	movs	r3, #0
	movs	r2, #18
	movs	r1, #20
	movs	r0, #2
	bl	openserial_printLog
.L24:
	.loc 1 415 1
	add	sp, sp, #36
.LCFI8:
	@ sp needed
	ldr	pc, [sp], #4
.LFE118:
	.size	forwarding_receive, .-forwarding_receive
	.section	.text.forwarding_getNextHop,"ax",%progbits
	.align	1
	.global	forwarding_getNextHop
	.syntax unified
	.thumb
	.thumb_func
	.type	forwarding_getNextHop, %function
forwarding_getNextHop:
.LFB119:
	.loc 1 425 90
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{lr}
.LCFI9:
	sub	sp, sp, #20
.LCFI10:
	str	r0, [sp, #4]
	str	r1, [sp]
	.loc 1 428 9
	ldr	r0, [sp, #4]
	bl	packetfunctions_isBroadcastMulticast
	mov	r3, r0
	.loc 1 428 8
	cmp	r3, #0
	beq	.L40
	.loc 1 430 33
	ldr	r3, [sp]
	movs	r2, #2
	strb	r2, [r3]
	.loc 1 431 16
	movs	r3, #0
	strb	r3, [sp, #15]
	.loc 1 431 9
	b	.L41
.L42:
	.loc 1 432 40 discriminator 3
	ldrb	r3, [sp, #15]	@ zero_extendqisi2
	.loc 1 432 44 discriminator 3
	ldr	r2, [sp]
	add	r3, r3, r2
	movs	r2, #255
	strb	r2, [r3, #1]
	.loc 1 431 29 discriminator 3
	ldrb	r3, [sp, #15]	@ zero_extendqisi2
	adds	r3, r3, #1
	strb	r3, [sp, #15]
.L41:
	.loc 1 431 23 discriminator 1
	ldrb	r3, [sp, #15]	@ zero_extendqisi2
	cmp	r3, #7
	bls	.L42
	.loc 1 438 1
	b	.L44
.L40:
	.loc 1 436 9
	ldr	r0, [sp]
	bl	icmpv6rpl_getPreferredParentEui64
.L44:
	.loc 1 438 1
	nop
	add	sp, sp, #20
.LCFI11:
	@ sp needed
	ldr	pc, [sp], #4
.LFE119:
	.size	forwarding_getNextHop, .-forwarding_getNextHop
	.section	.text.forwarding_send_internal_RoutingTable,"ax",%progbits
	.align	1
	.global	forwarding_send_internal_RoutingTable
	.syntax unified
	.thumb
	.thumb_func
	.type	forwarding_send_internal_RoutingTable, %function
forwarding_send_internal_RoutingTable:
.LFB120:
	.loc 1 461 3
	@ args = 8, pretend = 0, frame = 40
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{lr}
.LCFI12:
	sub	sp, sp, #60
.LCFI13:
	str	r0, [sp, #28]
	str	r1, [sp, #24]
	str	r2, [sp, #20]
	str	r3, [sp, #16]
	.loc 1 466 41
	ldr	r3, [sp, #28]
	.loc 1 466 9
	adds	r3, r3, #25
	mov	r0, r3
	bl	packetfunctions_isLinkLocal
	mov	r3, r0
	.loc 1 466 8
	cmp	r3, #0
	beq	.L46
	.loc 1 467 45
	ldr	r3, [sp, #28]
	.loc 1 467 13
	adds	r3, r3, #25
	mov	r0, r3
	bl	neighbors_isStableNeighbor
	mov	r3, r0
	.loc 1 467 12
	cmp	r3, #0
	bne	.L47
	.loc 1 467 73 discriminator 1
	ldr	r3, [sp, #28]
	ldrb	r3, [r3, #10]	@ zero_extendqisi2
	.loc 1 467 67 discriminator 1
	cmp	r3, #0
	beq	.L48
.L47:
	.loc 1 469 49
	ldr	r3, [sp, #28]
	.loc 1 469 13
	add	r0, r3, #25
	.loc 1 470 49
	ldr	r3, [sp, #28]
	.loc 1 469 13
	add	r2, r3, #61
	add	r3, sp, #36
	mov	r1, r3
	bl	packetfunctions_ip128bToMac64b
	b	.L48
.L46:
	.loc 1 473 36
	ldr	r3, [sp, #28]
	.loc 1 473 9
	add	r2, r3, #25
	.loc 1 473 63
	ldr	r3, [sp, #28]
	.loc 1 473 9
	adds	r3, r3, #61
	mov	r1, r3
	mov	r0, r2
	bl	forwarding_getNextHop
.L48:
	.loc 1 476 12
	ldr	r3, [sp, #28]
	.loc 1 476 34
	ldrb	r3, [r3, #61]	@ zero_extendqisi2
	.loc 1 476 8
	cmp	r3, #0
	bne	.L49
	.loc 1 477 9
	ldr	r3, [sp, #28]
	ldrb	r3, [r3, #40]	@ zero_extendqisi2
	uxth	r2, r3
	ldr	r3, [sp, #28]
	ldrb	r3, [r3, #41]	@ zero_extendqisi2
	uxth	r3, r3
	str	r3, [sp]
	mov	r3, r2
	movs	r2, #17
	movs	r1, #20
	movs	r0, #2
	bl	openserial_printLog
	.loc 1 481 16
	movs	r3, #1
	b	.L52
.L49:
	.loc 1 484 31
	ldr	r3, [sp, #24]
	ldrb	r3, [r3, #30]	@ zero_extendqisi2
	.loc 1 484 8
	cmp	r3, #0
	beq	.L51
	.loc 1 485 59
	ldr	r3, [sp, #24]
	ldrb	r3, [r3, #64]	@ zero_extendqisi2
	.loc 1 485 9
	uxth	r2, r3
	add	r3, sp, #28
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_tossHeader
.L51:
	.loc 1 489 12
	ldr	r0, [sp, #28]
	ldrb	r3, [sp, #68]	@ zero_extendqisi2
	str	r3, [sp, #12]
	movs	r3, #0
	str	r3, [sp, #8]
	movs	r3, #0
	str	r3, [sp, #4]
	ldr	r3, [sp, #64]
	str	r3, [sp]
	ldr	r3, [sp, #16]
	ldr	r2, [sp, #20]
	ldr	r1, [sp, #24]
	bl	iphc_sendFromForwarding
	mov	r3, r0
.L52:
	.loc 1 502 1 discriminator 1
	mov	r0, r3
	add	sp, sp, #60
.LCFI14:
	@ sp needed
	ldr	pc, [sp], #4
.LFE120:
	.size	forwarding_send_internal_RoutingTable, .-forwarding_send_internal_RoutingTable
	.section	.text.forwarding_send_internal_SourceRouting,"ax",%progbits
	.align	1
	.global	forwarding_send_internal_SourceRouting
	.syntax unified
	.thumb
	.thumb_func
	.type	forwarding_send_internal_SourceRouting, %function
forwarding_send_internal_SourceRouting:
.LFB121:
	.loc 1 525 3
	@ args = 0, pretend = 0, frame = 240
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, lr}
.LCFI15:
	sub	sp, sp, #260
.LCFI16:
	str	r0, [sp, #28]
	str	r1, [sp, #24]
	str	r2, [sp, #20]
	str	r3, [sp, #16]
	.loc 1 546 13
	movs	r3, #0
	strb	r3, [sp, #251]
	.loc 1 548 5
	add	r3, sp, #36
	movs	r2, #127
	movs	r1, #0
	mov	r0, r3
	bl	memset
	.loc 1 549 16
	movs	r3, #0
	strb	r3, [sp, #250]
	.loc 1 550 15
	movs	r3, #0
	strb	r3, [sp, #252]
	.loc 1 551 16
	ldr	r3, [sp, #28]
	.loc 1 551 12
	add	r0, r3, #25
	.loc 1 551 37
	ldr	r3, [sp, #20]
	adds	r3, r3, #47
	.loc 1 551 5
	movs	r2, #17
	mov	r1, r3
	bl	memcpy
	.loc 1 552 16
	ldr	r3, [sp, #28]
	.loc 1 552 12
	add	r0, r3, #42
	.loc 1 552 32
	ldr	r3, [sp, #20]
	adds	r3, r3, #30
	.loc 1 552 5
	movs	r2, #17
	mov	r1, r3
	bl	memcpy
	.loc 1 555 20
	movs	r3, #3
	strb	r3, [sp, #224]
	.loc 1 556 31
	ldr	r3, [sp, #24]
	ldrb	r3, [r3, #30]	@ zero_extendqisi2
	.loc 1 556 8
	cmp	r3, #0
	beq	.L54
	.loc 1 557 23
	ldr	r3, [sp, #16]
	ldrb	r3, [r3, #2]	@ zero_extendqisi2
	.loc 1 557 12
	cmp	r3, #0
	bne	.L55
	.loc 1 558 13
	add	r3, sp, #224
	adds	r3, r3, #1
	mov	r0, r3
	bl	icmpv6rpl_getRPLDODAGid
	b	.L55
.L54:
	.loc 1 561 28
	ldr	r3, [sp, #20]
	adds	r3, r3, #30
	.loc 1 561 9
	add	r4, sp, #224
	mov	r5, r3
	ldr	r0, [r5]	@ unaligned
	ldr	r1, [r5, #4]	@ unaligned
	ldr	r2, [r5, #8]	@ unaligned
	ldr	r3, [r5, #12]	@ unaligned
	stmia	r4!, {r0, r1, r2, r3}
	ldrb	r3, [r5, #16]
	strb	r3, [r4]
.L55:
	.loc 1 564 10
	movs	r3, #0
	strb	r3, [sp, #253]
	.loc 1 566 33
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 566 44
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	add	r3, r3, r2
	.loc 1 566 13
	ldrb	r3, [r3]
	strb	r3, [sp, #255]
	.loc 1 567 30
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 567 48
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	adds	r3, r3, #1
	add	r3, r3, r2
	.loc 1 567 10
	ldrb	r3, [r3]
	strb	r3, [sp, #254]
	.loc 1 570 11
	b	.L56
.L57:
	.loc 1 571 16
	ldrb	r3, [sp, #255]
	and	r3, r3, #31
	strb	r3, [sp, #251]
	.loc 1 572 24
	ldrb	r3, [sp, #252]	@ zero_extendqisi2
	.loc 1 572 16
	add	r2, sp, #36
	adds	r0, r2, r3
	.loc 1 572 40
	ldr	r3, [sp, #28]
	ldr	r1, [r3, #4]
	.loc 1 572 58
	ldrb	r3, [sp, #251]	@ zero_extendqisi2
	adds	r3, r3, #2
	.loc 1 572 9
	mov	r2, r3
	bl	memcpy
	.loc 1 573 9
	ldrb	r3, [sp, #251]	@ zero_extendqisi2
	uxth	r3, r3
	adds	r3, r3, #2
	uxth	r2, r3
	add	r3, sp, #28
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_tossHeader
	.loc 1 574 19
	ldrb	r2, [sp, #251]
	ldrb	r3, [sp, #252]
	add	r3, r3, r2
	uxtb	r3, r3
	adds	r3, r3, #2
	strb	r3, [sp, #252]
	.loc 1 575 37
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 575 48
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	add	r3, r3, r2
	.loc 1 575 17
	ldrb	r3, [r3]
	strb	r3, [sp, #255]
	.loc 1 576 34
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 576 52
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	adds	r3, r3, #1
	add	r3, r3, r2
	.loc 1 576 14
	ldrb	r3, [r3]
	strb	r3, [sp, #254]
.L56:
	.loc 1 570 21
	ldrb	r3, [sp, #255]	@ zero_extendqisi2
	and	r3, r3, #224
	.loc 1 570 42
	cmp	r3, #160
	beq	.L57
	.loc 1 579 10
	ldrb	r3, [sp, #253]
	adds	r3, r3, #2
	strb	r3, [sp, #253]
	.loc 1 582 5
	ldrb	r3, [sp, #254]	@ zero_extendqisi2
	cmp	r3, #4
	bhi	.L58
	adr	r2, .L60
	ldr	pc, [r2, r3, lsl #2]
	.p2align 2
.L60:
	.word	.L64+1
	.word	.L63+1
	.word	.L62+1
	.word	.L61+1
	.word	.L59+1
	.p2align 1
.L64:
	.loc 1 584 49
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 584 13
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	.loc 1 584 59
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	.loc 1 584 13
	strb	r3, [sp, #240]
	.loc 1 585 18
	ldrb	r3, [sp, #253]
	adds	r3, r3, #1
	strb	r3, [sp, #253]
	.loc 1 586 13
	b	.L58
.L63:
	.loc 1 588 49
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 588 13
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	.loc 1 588 59
	add	r3, r3, r2
	ldrh	r3, [r3]	@ unaligned
	uxth	r3, r3
	.loc 1 588 13
	strh	r3, [sp, #239]	@ unaligned
	.loc 1 589 18
	ldrb	r3, [sp, #253]
	adds	r3, r3, #2
	strb	r3, [sp, #253]
	.loc 1 590 13
	b	.L58
.L62:
	.loc 1 592 49
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 592 13
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	.loc 1 592 59
	add	r3, r3, r2
	ldr	r3, [r3]	@ unaligned
	.loc 1 592 13
	str	r3, [sp, #237]	@ unaligned
	.loc 1 593 18
	ldrb	r3, [sp, #253]
	adds	r3, r3, #4
	strb	r3, [sp, #253]
	.loc 1 594 13
	b	.L58
.L61:
	.loc 1 596 48
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 596 13
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	.loc 1 596 58
	adds	r1, r2, r3
	.loc 1 596 13
	add	r3, sp, #224
	adds	r3, r3, #9
	movs	r2, #8
	mov	r0, r3
	bl	memcpy
	.loc 1 597 18
	ldrb	r3, [sp, #253]
	adds	r3, r3, #8
	strb	r3, [sp, #253]
	.loc 1 598 13
	b	.L58
.L59:
	.loc 1 600 48
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 600 13
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	.loc 1 600 58
	adds	r1, r2, r3
	.loc 1 600 13
	add	r3, sp, #224
	adds	r3, r3, #1
	movs	r2, #16
	mov	r0, r3
	bl	memcpy
	.loc 1 601 18
	ldrb	r3, [sp, #253]
	adds	r3, r3, #16
	strb	r3, [sp, #253]
	.loc 1 602 13
	nop
.L58:
	.loc 1 605 5
	add	r2, sp, #164
	add	r1, sp, #184
	add	r3, sp, #224
	mov	r0, r3
	bl	packetfunctions_ip128bToMac64b
	.loc 1 607 13
	movs	r0, #5
	bl	idmanager_getMyID
	mov	r2, r0
	add	r3, sp, #184
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_sameAddress
	mov	r3, r0
	.loc 1 606 8
	cmp	r3, #0
	beq	.L65
	.loc 1 608 13
	movs	r0, #2
	bl	idmanager_getMyID
	mov	r2, r0
	add	r3, sp, #164
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_sameAddress
	mov	r3, r0
	.loc 1 607 87
	cmp	r3, #0
	beq	.L65
	.loc 1 610 14
	ldrb	r3, [sp, #255]
	and	r3, r3, #31
	strb	r3, [sp, #249]
	.loc 1 611 12
	ldrb	r3, [sp, #249]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L66
	.loc 1 614 18
	ldrb	r3, [sp, #249]
	subs	r3, r3, #1
	strb	r3, [sp, #249]
	.loc 1 615 13
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	uxth	r2, r3
	add	r3, sp, #28
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_tossHeader
	.loc 1 616 17
	add	r3, sp, #28
	movs	r1, #2
	mov	r0, r3
	bl	packetfunctions_reserveHeader
	mov	r3, r0
	.loc 1 616 16
	cmp	r3, #1
	bne	.L67
	.loc 1 617 24
	movs	r3, #1
	b	.L113
.L67:
	.loc 1 619 16
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 619 29
	ldrb	r2, [sp, #249]
	orn	r2, r2, #127
	uxtb	r2, r2
	strb	r2, [r3]
	.loc 1 620 16
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 620 25
	adds	r3, r3, #1
	.loc 1 620 29
	ldrb	r2, [sp, #254]
	strb	r2, [r3]
	.loc 1 623 13
	add	r4, sp, #204
	add	r5, sp, #224
	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}
	ldr	r3, [r5]
	strb	r3, [r4]
	.loc 1 624 13
	ldrb	r3, [sp, #254]	@ zero_extendqisi2
	cmp	r3, #4
	bhi	.L69
	adr	r2, .L71
	ldr	pc, [r2, r3, lsl #2]
	.p2align 2
.L71:
	.word	.L75+1
	.word	.L74+1
	.word	.L73+1
	.word	.L72+1
	.word	.L70+1
	.p2align 1
.L75:
	.loc 1 626 56
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 626 66
	adds	r3, r3, #2
	ldrb	r3, [r3]	@ zero_extendqisi2
	.loc 1 626 21
	strb	r3, [sp, #220]
	.loc 1 627 21
	b	.L69
.L74:
	.loc 1 629 56
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 629 66
	adds	r3, r3, #2
	ldrh	r3, [r3]	@ unaligned
	uxth	r3, r3
	.loc 1 629 21
	strh	r3, [sp, #219]	@ unaligned
	.loc 1 630 21
	b	.L69
.L73:
	.loc 1 632 56
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 632 66
	adds	r3, r3, #2
	ldr	r3, [r3]	@ unaligned
	.loc 1 632 21
	str	r3, [sp, #217]	@ unaligned
	.loc 1 633 21
	b	.L69
.L72:
	.loc 1 635 55
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 635 65
	adds	r1, r3, #2
	.loc 1 635 21
	add	r3, sp, #204
	adds	r3, r3, #9
	movs	r2, #8
	mov	r0, r3
	bl	memcpy
	.loc 1 636 21
	b	.L69
.L70:
	.loc 1 638 55
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 638 65
	adds	r1, r3, #2
	.loc 1 638 21
	add	r3, sp, #204
	adds	r3, r3, #1
	movs	r2, #16
	mov	r0, r3
	bl	memcpy
	.loc 1 639 21
	nop
.L69:
	.loc 1 641 73
	ldr	r3, [sp, #28]
	.loc 1 641 13
	add	r2, r3, #61
	add	r1, sp, #184
	add	r3, sp, #204
	mov	r0, r3
	bl	packetfunctions_ip128bToMac64b
	.loc 1 611 12
	b	.L108
.L66:
	.loc 1 643 41
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 643 52
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	add	r3, r3, r2
	.loc 1 643 21
	ldrb	r3, [r3]
	strb	r3, [sp, #255]
	.loc 1 644 43
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 644 61
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	adds	r3, r3, #1
	add	r3, r3, r2
	.loc 1 644 23
	ldrb	r3, [r3]
	strb	r3, [sp, #248]
	.loc 1 646 30
	ldrb	r3, [sp, #255]	@ zero_extendqisi2
	and	r3, r3, #224
	.loc 1 645 16
	cmp	r3, #128
	bne	.L77
	.loc 1 646 69
	ldrb	r3, [sp, #248]	@ zero_extendqisi2
	cmp	r3, #4
	bhi	.L77
	.loc 1 650 20
	ldrb	r2, [sp, #248]	@ zero_extendqisi2
	ldrb	r3, [sp, #254]	@ zero_extendqisi2
	cmp	r2, r3
	bcc	.L78
	.loc 1 651 21
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	uxth	r2, r3
	add	r3, sp, #28
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_tossHeader
	.loc 1 653 21
	add	r4, sp, #204
	add	r5, sp, #224
	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}
	ldr	r3, [r5]
	strb	r3, [r4]
	.loc 1 654 21
	ldrb	r3, [sp, #248]	@ zero_extendqisi2
	cmp	r3, #4
	bhi	.L79
	adr	r2, .L81
	ldr	pc, [r2, r3, lsl #2]
	.p2align 2
.L81:
	.word	.L85+1
	.word	.L84+1
	.word	.L83+1
	.word	.L82+1
	.word	.L80+1
	.p2align 1
.L85:
	.loc 1 656 64
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 656 74
	adds	r3, r3, #2
	ldrb	r3, [r3]	@ zero_extendqisi2
	.loc 1 656 29
	strb	r3, [sp, #220]
	.loc 1 657 29
	b	.L79
.L84:
	.loc 1 659 64
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 659 74
	adds	r3, r3, #2
	ldrh	r3, [r3]	@ unaligned
	uxth	r3, r3
	.loc 1 659 29
	strh	r3, [sp, #219]	@ unaligned
	.loc 1 660 29
	b	.L79
.L83:
	.loc 1 662 64
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 662 74
	adds	r3, r3, #2
	ldr	r3, [r3]	@ unaligned
	.loc 1 662 29
	str	r3, [sp, #217]	@ unaligned
	.loc 1 663 29
	b	.L79
.L82:
	.loc 1 665 63
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 665 73
	adds	r1, r3, #2
	.loc 1 665 29
	add	r3, sp, #204
	adds	r3, r3, #9
	movs	r2, #8
	mov	r0, r3
	bl	memcpy
	.loc 1 666 29
	b	.L79
.L80:
	.loc 1 668 63
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 668 73
	adds	r1, r3, #2
	.loc 1 668 29
	add	r3, sp, #204
	adds	r3, r3, #1
	movs	r2, #16
	mov	r0, r3
	bl	memcpy
	.loc 1 669 29
	nop
.L79:
	.loc 1 671 81
	ldr	r3, [sp, #28]
	.loc 1 671 21
	add	r2, r3, #61
	add	r1, sp, #184
	add	r3, sp, #204
	mov	r0, r3
	bl	packetfunctions_ip128bToMac64b
	.loc 1 650 20
	b	.L76
.L78:
	.loc 1 673 26
	ldrb	r3, [sp, #253]
	adds	r3, r3, #2
	strb	r3, [sp, #253]
	.loc 1 674 21
	ldrb	r3, [sp, #248]	@ zero_extendqisi2
	cmp	r3, #3
	bhi	.L87
	adr	r2, .L89
	ldr	pc, [r2, r3, lsl #2]
	.p2align 2
.L89:
	.word	.L92+1
	.word	.L91+1
	.word	.L90+1
	.word	.L88+1
	.p2align 1
.L92:
	.loc 1 676 65
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 676 29
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	.loc 1 676 75
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	.loc 1 676 29
	strb	r3, [sp, #240]
	.loc 1 677 34
	ldrb	r3, [sp, #253]
	adds	r3, r3, #1
	strb	r3, [sp, #253]
	.loc 1 678 29
	b	.L87
.L91:
	.loc 1 680 65
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 680 29
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	.loc 1 680 75
	add	r3, r3, r2
	ldrh	r3, [r3]	@ unaligned
	uxth	r3, r3
	.loc 1 680 29
	strh	r3, [sp, #239]	@ unaligned
	.loc 1 681 34
	ldrb	r3, [sp, #253]
	adds	r3, r3, #2
	strb	r3, [sp, #253]
	.loc 1 682 29
	b	.L87
.L90:
	.loc 1 684 65
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 684 29
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	.loc 1 684 75
	add	r3, r3, r2
	ldr	r3, [r3]	@ unaligned
	.loc 1 684 29
	str	r3, [sp, #237]	@ unaligned
	.loc 1 685 34
	ldrb	r3, [sp, #253]
	adds	r3, r3, #4
	strb	r3, [sp, #253]
	.loc 1 686 29
	b	.L87
.L88:
	.loc 1 688 64
	ldr	r3, [sp, #28]
	ldr	r2, [r3, #4]
	.loc 1 688 29
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	.loc 1 688 74
	adds	r1, r2, r3
	.loc 1 688 29
	add	r3, sp, #224
	adds	r3, r3, #9
	movs	r2, #8
	mov	r0, r3
	bl	memcpy
	.loc 1 689 34
	ldrb	r3, [sp, #253]
	adds	r3, r3, #8
	strb	r3, [sp, #253]
	.loc 1 690 29
	nop
.L87:
	.loc 1 692 31
	ldrb	r3, [sp, #255]
	and	r3, r3, #31
	strb	r3, [sp, #247]
	.loc 1 693 21
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	uxth	r2, r3
	add	r3, sp, #28
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_tossHeader
	.loc 1 694 24
	ldrb	r3, [sp, #247]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L93
	.loc 1 695 35
	ldrb	r3, [sp, #247]
	subs	r3, r3, #1
	strb	r3, [sp, #247]
	.loc 1 696 29
	add	r3, sp, #28
	movs	r1, #2
	mov	r0, r3
	bl	packetfunctions_reserveHeader
	mov	r3, r0
	.loc 1 696 28
	cmp	r3, #1
	bne	.L94
	.loc 1 697 36
	movs	r3, #1
	b	.L113
.L94:
	.loc 1 699 28
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 699 41
	ldrb	r2, [sp, #247]
	orn	r2, r2, #127
	uxtb	r2, r2
	strb	r2, [r3]
	.loc 1 700 28
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 700 37
	adds	r3, r3, #1
	.loc 1 700 41
	ldrb	r2, [sp, #248]
	strb	r2, [r3]
.L93:
	.loc 1 703 21
	ldrb	r3, [sp, #254]	@ zero_extendqisi2
	cmp	r3, #4
	bhi	.L95
	adr	r2, .L97
	ldr	pc, [r2, r3, lsl #2]
	.p2align 2
.L97:
	.word	.L101+1
	.word	.L100+1
	.word	.L99+1
	.word	.L98+1
	.word	.L96+1
	.p2align 1
.L101:
	.loc 1 705 33
	add	r3, sp, #28
	movs	r1, #1
	mov	r0, r3
	bl	packetfunctions_reserveHeader
	mov	r3, r0
	.loc 1 705 32
	cmp	r3, #1
	bne	.L102
	.loc 1 706 40
	movs	r3, #1
	b	.L113
.L102:
	.loc 1 708 32
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 708 66
	ldrb	r2, [sp, #240]	@ zero_extendqisi2
	.loc 1 708 45
	strb	r2, [r3]
	.loc 1 709 29
	b	.L95
.L100:
	.loc 1 711 33
	add	r3, sp, #28
	movs	r1, #2
	mov	r0, r3
	bl	packetfunctions_reserveHeader
	mov	r3, r0
	.loc 1 711 32
	cmp	r3, #1
	bne	.L103
	.loc 1 712 40
	movs	r3, #1
	b	.L113
.L103:
	.loc 1 714 40
	ldr	r3, [sp, #28]
	.loc 1 714 36
	ldr	r3, [r3, #4]
	ldrh	r2, [sp, #239]	@ unaligned
	uxth	r2, r2
	.loc 1 714 29
	strh	r2, [r3]	@ unaligned
	.loc 1 715 29
	b	.L95
.L99:
	.loc 1 717 33
	add	r3, sp, #28
	movs	r1, #4
	mov	r0, r3
	bl	packetfunctions_reserveHeader
	mov	r3, r0
	.loc 1 717 32
	cmp	r3, #1
	bne	.L104
	.loc 1 718 40
	movs	r3, #1
	b	.L113
.L104:
	.loc 1 720 40
	ldr	r3, [sp, #28]
	.loc 1 720 36
	ldr	r3, [r3, #4]
	ldr	r2, [sp, #237]	@ unaligned
	.loc 1 720 29
	str	r2, [r3]	@ unaligned
	.loc 1 721 29
	b	.L95
.L98:
	.loc 1 723 33
	add	r3, sp, #28
	movs	r1, #8
	mov	r0, r3
	bl	packetfunctions_reserveHeader
	mov	r3, r0
	.loc 1 723 32
	cmp	r3, #1
	bne	.L105
	.loc 1 724 40
	movs	r3, #1
	b	.L113
.L105:
	.loc 1 726 40
	ldr	r3, [sp, #28]
	.loc 1 726 36
	ldr	r0, [r3, #4]
	.loc 1 726 29
	add	r3, sp, #224
	adds	r3, r3, #9
	movs	r2, #8
	mov	r1, r3
	bl	memcpy
	.loc 1 727 29
	b	.L95
.L96:
	.loc 1 729 33
	add	r3, sp, #28
	movs	r1, #16
	mov	r0, r3
	bl	packetfunctions_reserveHeader
	mov	r3, r0
	.loc 1 729 32
	cmp	r3, #1
	bne	.L106
	.loc 1 730 40
	movs	r3, #1
	b	.L113
.L106:
	.loc 1 732 40
	ldr	r3, [sp, #28]
	.loc 1 732 36
	ldr	r0, [r3, #4]
	.loc 1 732 29
	add	r3, sp, #224
	adds	r3, r3, #1
	movs	r2, #16
	mov	r1, r3
	bl	memcpy
	.loc 1 733 29
	nop
.L95:
	.loc 1 735 25
	add	r3, sp, #28
	movs	r1, #2
	mov	r0, r3
	bl	packetfunctions_reserveHeader
	mov	r3, r0
	.loc 1 735 24
	cmp	r3, #1
	bne	.L107
	.loc 1 736 32
	movs	r3, #1
	b	.L113
.L107:
	.loc 1 738 24
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 738 37
	movs	r2, #128
	strb	r2, [r3]
	.loc 1 739 24
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 739 33
	adds	r3, r3, #1
	.loc 1 739 37
	ldrb	r2, [sp, #254]
	strb	r2, [r3]
	.loc 1 740 82
	ldr	r3, [sp, #28]
	.loc 1 740 21
	add	r2, r3, #61
	add	r1, sp, #184
	add	r3, sp, #224
	mov	r0, r3
	bl	packetfunctions_ip128bToMac64b
	.loc 1 650 20
	b	.L76
.L77:
	.loc 1 744 17
	ldrb	r3, [sp, #253]	@ zero_extendqisi2
	uxth	r2, r3
	add	r3, sp, #28
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_tossHeader
	.loc 1 745 52
	ldr	r3, [sp, #28]
	.loc 1 745 17
	add	r0, r3, #25
	.loc 1 745 91
	ldr	r3, [sp, #28]
	.loc 1 745 17
	add	r2, r3, #61
	add	r3, sp, #184
	mov	r1, r3
	bl	packetfunctions_ip128bToMac64b
	.loc 1 611 12
	b	.L108
.L76:
	.loc 1 611 12 is_stmt 0 discriminator 1
	b	.L108
.L65:
	.loc 1 750 9 is_stmt 1
	ldrb	r3, [sp, #172]	@ zero_extendqisi2
	uxth	r3, r3
	str	r3, [sp]
	movs	r3, #16
	movs	r2, #16
	movs	r1, #20
	movs	r0, #2
	bl	openserial_printLog
.L108:
	.loc 1 755 31
	ldr	r3, [sp, #24]
	ldrb	r3, [r3, #30]	@ zero_extendqisi2
	.loc 1 755 8
	cmp	r3, #0
	beq	.L109
	.loc 1 755 70 discriminator 1
	ldr	r3, [sp, #24]
	ldr	r3, [r3, #24]
	.loc 1 755 50 discriminator 1
	cmp	r3, #0
	beq	.L109
	.loc 1 757 40
	ldr	r3, [sp, #24]
	ldr	r2, [r3, #24]
	.loc 1 757 63
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 757 58
	subs	r3, r2, r3
	.loc 1 757 20
	uxtb	r2, r3
	ldrb	r3, [sp, #250]
	add	r3, r3, r2
	strb	r3, [sp, #250]
	.loc 1 758 24
	ldrb	r3, [sp, #252]	@ zero_extendqisi2
	.loc 1 758 16
	add	r2, sp, #36
	adds	r0, r2, r3
	.loc 1 758 40
	ldr	r3, [sp, #28]
	ldr	r3, [r3, #4]
	.loc 1 758 9
	ldrb	r2, [sp, #250]	@ zero_extendqisi2
	mov	r1, r3
	bl	memcpy
	.loc 1 759 9
	ldrb	r3, [sp, #250]	@ zero_extendqisi2
	uxth	r2, r3
	add	r3, sp, #28
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_tossHeader
	.loc 1 760 19
	ldrb	r2, [sp, #252]
	ldrb	r3, [sp, #250]
	add	r3, r3, r2
	strb	r3, [sp, #252]
	.loc 1 763 22
	ldr	r3, [sp, #28]
	ldr	r1, [sp, #16]
	mov	r0, r3
	bl	iphc_retrieveIPv6HopByHopHeader
	mov	r3, r0
	strb	r3, [sp, #246]
	.loc 1 766 9
	ldrb	r3, [sp, #246]	@ zero_extendqisi2
	uxth	r2, r3
	add	r3, sp, #28
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_tossHeader
	.loc 1 768 15
	ldr	r3, [sp, #16]
	ldrb	r3, [r3, #1]
	strb	r3, [sp, #245]
	.loc 1 769 20
	ldr	r3, [sp, #16]
	ldrb	r2, [r3, #3]	@ zero_extendqisi2
	ldrb	r3, [r3, #4]	@ zero_extendqisi2
	lsls	r3, r3, #8
	orrs	r3, r3, r2
	strh	r3, [sp, #242]	@ movhi
	.loc 1 770 20
	ldrb	r3, [sp, #245]	@ zero_extendqisi2
	and	r3, r3, #16
	.loc 1 770 12
	cmp	r3, #0
	bne	.L110
	.loc 1 773 13
	ldrb	r3, [sp, #245]	@ zero_extendqisi2
	uxth	r2, r3
	ldrh	r3, [sp, #242]
	str	r3, [sp]
	mov	r3, r2
	movs	r2, #22
	movs	r1, #20
	movs	r0, #2
	bl	openserial_printLog
.L110:
	.loc 1 777 26
	bl	icmpv6rpl_getMyDAGrank
	mov	r3, r0
	mov	r2, r3
	.loc 1 777 12
	ldrh	r3, [sp, #242]
	cmp	r3, r2
	bls	.L111
	.loc 1 780 31
	ldr	r3, [sp, #16]
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	orr	r3, r3, #8
	uxtb	r2, r3
	ldr	r3, [sp, #16]
	strb	r2, [r3, #1]
	.loc 1 782 13
	bl	icmpv6rpl_getMyDAGrank
	mov	r3, r0
	mov	r2, r3
	ldrh	r3, [sp, #242]
	str	r2, [sp]
	movs	r2, #21
	movs	r1, #20
	movs	r0, #2
	bl	openserial_printLog
.L111:
	.loc 1 786 9
	ldr	r3, [sp, #16]
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r0, [sp, #16]
	bl	forwarding_createRplOption
	.loc 1 794 59
	ldr	r3, [sp, #24]
	ldrb	r3, [r3, #64]	@ zero_extendqisi2
	.loc 1 794 9
	uxth	r2, r3
	add	r3, sp, #28
	mov	r1, r2
	mov	r0, r3
	bl	packetfunctions_tossHeader
	b	.L112
.L109:
	.loc 1 796 20
	movs	r3, #0
	strb	r3, [sp, #250]
.L112:
	.loc 1 799 8
	ldr	r3, [sp, #28]
	.loc 1 799 30
	movs	r2, #1
	strb	r2, [r3, #59]
	.loc 1 802 12
	ldr	r0, [sp, #28]
	ldr	r3, [sp, #24]
	adds	r3, r3, #4
	movs	r2, #1
	str	r2, [sp, #12]
	ldrb	r2, [sp, #252]	@ zero_extendqisi2
	str	r2, [sp, #8]
	add	r2, sp, #36
	str	r2, [sp, #4]
	str	r3, [sp]
	ldr	r3, [sp, #16]
	ldr	r2, [sp, #20]
	ldr	r1, [sp, #24]
	bl	iphc_sendFromForwarding
	mov	r3, r0
.L113:
	.loc 1 815 1 discriminator 2
	mov	r0, r3
	add	sp, sp, #260
.LCFI17:
	@ sp needed
	pop	{r4, r5, pc}
.LFE121:
	.size	forwarding_send_internal_SourceRouting, .-forwarding_send_internal_SourceRouting
	.section	.text.forwarding_createRplOption,"ax",%progbits
	.align	1
	.global	forwarding_createRplOption
	.syntax unified
	.thumb
	.thumb_func
	.type	forwarding_createRplOption, %function
forwarding_createRplOption:
.LFB122:
	.loc 1 824 75
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{lr}
.LCFI18:
	sub	sp, sp, #20
.LCFI19:
	str	r0, [sp, #4]
	mov	r3, r1
	strb	r3, [sp, #3]
	.loc 1 826 28
	ldr	r3, [sp, #4]
	movs	r2, #99
	strb	r2, [r3]
	.loc 1 827 33
	bl	icmpv6rpl_getRPLIntanceID
	mov	r3, r0
	mov	r2, r3
	.loc 1 827 31
	ldr	r3, [sp, #4]
	strb	r2, [r3, #2]
	.loc 1 828 30
	bl	icmpv6rpl_getMyDAGrank
	mov	r3, r0
	mov	r2, r3
	.loc 1 828 28
	ldr	r3, [sp, #4]
	strh	r2, [r3, #3]	@ unaligned
	.loc 1 830 19
	ldr	r3, [sp, #4]
	ldrb	r3, [r3, #2]	@ zero_extendqisi2
	.loc 1 830 8
	cmp	r3, #0
	bne	.L120
	.loc 1 831 11
	movs	r3, #1
	strb	r3, [sp, #15]
	b	.L121
.L120:
	.loc 1 833 11
	movs	r3, #0
	strb	r3, [sp, #15]
.L121:
	.loc 1 836 20
	ldr	r3, [sp, #4]
	ldrh	r3, [r3, #3]	@ unaligned
	uxth	r3, r3
	.loc 1 836 33
	uxtb	r3, r3
	.loc 1 836 8
	cmp	r3, #0
	bne	.L122
	.loc 1 837 11
	movs	r3, #1
	strb	r3, [sp, #14]
	b	.L123
.L122:
	.loc 1 839 11
	movs	r3, #0
	strb	r3, [sp, #14]
.L123:
	.loc 1 842 42
	ldrsb	r3, [sp, #3]
	bic	r3, r3, #3
	sxtb	r2, r3
	.loc 1 842 58
	ldrb	r3, [sp, #15]	@ zero_extendqisi2
	lsls	r3, r3, #1
	.loc 1 842 53
	sxtb	r3, r3
	orrs	r3, r3, r2
	sxtb	r2, r3
	.loc 1 842 64
	ldrsb	r3, [sp, #14]
	orrs	r3, r3, r2
	sxtb	r3, r3
	uxtb	r2, r3
	.loc 1 842 23
	ldr	r3, [sp, #4]
	strb	r2, [r3, #1]
	.loc 1 843 1
	nop
	add	sp, sp, #20
.LCFI20:
	@ sp needed
	ldr	pc, [sp], #4
.LFE122:
	.size	forwarding_createRplOption, .-forwarding_createRplOption
	.section	.debug_frame,"",%progbits
.Lframe0:
	.4byte	.LECIE0-.LSCIE0
.LSCIE0:
	.4byte	0xffffffff
	.byte	0x3
	.ascii	"\000"
	.uleb128 0x1
	.sleb128 -4
	.uleb128 0xe
	.byte	0xc
	.uleb128 0xd
	.uleb128 0
	.align	2
.LECIE0:
.LSFDE0:
	.4byte	.LEFDE0-.LASFDE0
.LASFDE0:
	.4byte	.Lframe0
	.4byte	.LFB115
	.4byte	.LFE115-.LFB115
	.align	2
.LEFDE0:
.LSFDE2:
	.4byte	.LEFDE2-.LASFDE2
.LASFDE2:
	.4byte	.Lframe0
	.4byte	.LFB116
	.4byte	.LFE116-.LFB116
	.byte	0x4
	.4byte	.LCFI0-.LFB116
	.byte	0xe
	.uleb128 0xc
	.byte	0x84
	.uleb128 0x3
	.byte	0x85
	.uleb128 0x2
	.byte	0x8e
	.uleb128 0x1
	.byte	0x4
	.4byte	.LCFI1-.LCFI0
	.byte	0xe
	.uleb128 0x148
	.byte	0x4
	.4byte	.LCFI2-.LCFI1
	.byte	0xe
	.uleb128 0xc
	.align	2
.LEFDE2:
.LSFDE4:
	.4byte	.LEFDE4-.LASFDE4
.LASFDE4:
	.4byte	.Lframe0
	.4byte	.LFB117
	.4byte	.LFE117-.LFB117
	.byte	0x4
	.4byte	.LCFI3-.LFB117
	.byte	0xe
	.uleb128 0x4
	.byte	0x8e
	.uleb128 0x1
	.byte	0x4
	.4byte	.LCFI4-.LCFI3
	.byte	0xe
	.uleb128 0x18
	.byte	0x4
	.4byte	.LCFI5-.LCFI4
	.byte	0xe
	.uleb128 0x4
	.align	2
.LEFDE4:
.LSFDE6:
	.4byte	.LEFDE6-.LASFDE6
.LASFDE6:
	.4byte	.Lframe0
	.4byte	.LFB118
	.4byte	.LFE118-.LFB118
	.byte	0x4
	.4byte	.LCFI6-.LFB118
	.byte	0xe
	.uleb128 0x4
	.byte	0x8e
	.uleb128 0x1
	.byte	0x4
	.4byte	.LCFI7-.LCFI6
	.byte	0xe
	.uleb128 0x28
	.byte	0x4
	.4byte	.LCFI8-.LCFI7
	.byte	0xe
	.uleb128 0x4
	.align	2
.LEFDE6:
.LSFDE8:
	.4byte	.LEFDE8-.LASFDE8
.LASFDE8:
	.4byte	.Lframe0
	.4byte	.LFB119
	.4byte	.LFE119-.LFB119
	.byte	0x4
	.4byte	.LCFI9-.LFB119
	.byte	0xe
	.uleb128 0x4
	.byte	0x8e
	.uleb128 0x1
	.byte	0x4
	.4byte	.LCFI10-.LCFI9
	.byte	0xe
	.uleb128 0x18
	.byte	0x4
	.4byte	.LCFI11-.LCFI10
	.byte	0xe
	.uleb128 0x4
	.align	2
.LEFDE8:
.LSFDE10:
	.4byte	.LEFDE10-.LASFDE10
.LASFDE10:
	.4byte	.Lframe0
	.4byte	.LFB120
	.4byte	.LFE120-.LFB120
	.byte	0x4
	.4byte	.LCFI12-.LFB120
	.byte	0xe
	.uleb128 0x4
	.byte	0x8e
	.uleb128 0x1
	.byte	0x4
	.4byte	.LCFI13-.LCFI12
	.byte	0xe
	.uleb128 0x40
	.byte	0x4
	.4byte	.LCFI14-.LCFI13
	.byte	0xe
	.uleb128 0x4
	.align	2
.LEFDE10:
.LSFDE12:
	.4byte	.LEFDE12-.LASFDE12
.LASFDE12:
	.4byte	.Lframe0
	.4byte	.LFB121
	.4byte	.LFE121-.LFB121
	.byte	0x4
	.4byte	.LCFI15-.LFB121
	.byte	0xe
	.uleb128 0xc
	.byte	0x84
	.uleb128 0x3
	.byte	0x85
	.uleb128 0x2
	.byte	0x8e
	.uleb128 0x1
	.byte	0x4
	.4byte	.LCFI16-.LCFI15
	.byte	0xe
	.uleb128 0x110
	.byte	0x4
	.4byte	.LCFI17-.LCFI16
	.byte	0xe
	.uleb128 0xc
	.align	2
.LEFDE12:
.LSFDE14:
	.4byte	.LEFDE14-.LASFDE14
.LASFDE14:
	.4byte	.Lframe0
	.4byte	.LFB122
	.4byte	.LFE122-.LFB122
	.byte	0x4
	.4byte	.LCFI18-.LFB122
	.byte	0xe
	.uleb128 0x4
	.byte	0x8e
	.uleb128 0x1
	.byte	0x4
	.4byte	.LCFI19-.LCFI18
	.byte	0xe
	.uleb128 0x18
	.byte	0x4
	.4byte	.LCFI20-.LCFI19
	.byte	0xe
	.uleb128 0x4
	.align	2
.LEFDE14:
	.text
.Letext0:
	.file 2 "C:/Program Files/SEGGER/SEGGER Embedded Studio for ARM 6.30/include/stdint.h"
	.file 3 "C:/Program Files/SEGGER/SEGGER Embedded Studio for ARM 6.30/include/string.h"
	.file 4 "../../bsp/boards/nrf52840_dk/board_info.h"
	.file 5 "../../inc/opendefs.h"
	.file 6 "../../openstack/03a-IPHC/iphc.h"
	.file 7 "C:\\Users\\16603\\Desktop\\HKUSTGZ\\IOTA5109-WSN\\openwsnProj\\mywsn\\openstack\\03b-IPv6\\forwarding.h"
	.file 8 "../../drivers/common/openserial.h"
	.file 9 "../../openstack/cross-layers/idmanager.h"
	.file 10 "../../openstack/03b-IPv6/icmpv6rpl.h"
	.file 11 "../../openstack/cross-layers/packetfunctions.h"
	.file 12 "../../openstack/02b-MAChigh/neighbors.h"
	.file 13 "../../openstack/cross-layers/openqueue.h"
	.file 14 "C:\\Users\\16603\\Desktop\\HKUSTGZ\\IOTA5109-WSN\\openwsnProj\\mywsn\\openstack\\03b-IPv6\\icmpv6.h"
	.file 15 "../../openstack/04-TRAN/udp.h"
	.section	.debug_info,"",%progbits
.Ldebug_info0:
	.4byte	0x14e6
	.2byte	0x4
	.4byte	.Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.4byte	.LASF1359
	.byte	0xc
	.4byte	.LASF1360
	.4byte	.LASF1361
	.4byte	.Ldebug_ranges0+0
	.4byte	0
	.4byte	.Ldebug_line0
	.4byte	.Ldebug_macro0
	.uleb128 0x2
	.byte	0x4
	.byte	0x5
	.ascii	"int\000"
	.uleb128 0x3
	.byte	0x1
	.byte	0x8
	.4byte	.LASF968
	.uleb128 0x3
	.byte	0x4
	.byte	0x7
	.4byte	.LASF969
	.uleb128 0x4
	.4byte	.LASF971
	.byte	0x2
	.byte	0xd5
	.byte	0x1c
	.4byte	0x4a
	.uleb128 0x3
	.byte	0x1
	.byte	0x6
	.4byte	.LASF970
	.uleb128 0x4
	.4byte	.LASF972
	.byte	0x2
	.byte	0xd6
	.byte	0x1c
	.4byte	0x62
	.uleb128 0x5
	.4byte	0x51
	.uleb128 0x3
	.byte	0x1
	.byte	0x8
	.4byte	.LASF973
	.uleb128 0x4
	.4byte	.LASF974
	.byte	0x2
	.byte	0xd8
	.byte	0x1c
	.4byte	0x75
	.uleb128 0x3
	.byte	0x2
	.byte	0x5
	.4byte	.LASF975
	.uleb128 0x4
	.4byte	.LASF976
	.byte	0x2
	.byte	0xd9
	.byte	0x1c
	.4byte	0x88
	.uleb128 0x3
	.byte	0x2
	.byte	0x7
	.4byte	.LASF977
	.uleb128 0x4
	.4byte	.LASF978
	.byte	0x2
	.byte	0xdb
	.byte	0x1c
	.4byte	0x37
	.uleb128 0x3
	.byte	0x8
	.byte	0x5
	.4byte	.LASF979
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.4byte	.LASF980
	.uleb128 0x4
	.4byte	.LASF981
	.byte	0x3
	.byte	0x2e
	.byte	0x1d
	.4byte	0x37
	.uleb128 0x6
	.4byte	0x5d
	.4byte	0xc5
	.uleb128 0x7
	.4byte	0x37
	.byte	0x5
	.byte	0
	.uleb128 0x5
	.4byte	0xb5
	.uleb128 0x8
	.4byte	.LASF982
	.byte	0x4
	.byte	0x9a
	.byte	0x16
	.4byte	0xc5
	.uleb128 0x5
	.byte	0x3
	.4byte	rreg_uriquery
	.uleb128 0x6
	.4byte	0x5d
	.4byte	0xec
	.uleb128 0x7
	.4byte	0x37
	.byte	0x8
	.byte	0
	.uleb128 0x5
	.4byte	0xdc
	.uleb128 0x8
	.4byte	.LASF983
	.byte	0x4
	.byte	0x9b
	.byte	0x16
	.4byte	0xec
	.uleb128 0x5
	.byte	0x3
	.4byte	infoBoardname
	.uleb128 0x8
	.4byte	.LASF984
	.byte	0x4
	.byte	0x9c
	.byte	0x16
	.4byte	0xec
	.uleb128 0x5
	.byte	0x3
	.4byte	infouCName
	.uleb128 0x6
	.4byte	0x5d
	.4byte	0x125
	.uleb128 0x7
	.4byte	0x37
	.byte	0xc
	.byte	0
	.uleb128 0x5
	.4byte	0x115
	.uleb128 0x8
	.4byte	.LASF985
	.byte	0x4
	.byte	0x9d
	.byte	0x16
	.4byte	0x125
	.uleb128 0x5
	.byte	0x3
	.4byte	infoRadioName
	.uleb128 0x8
	.4byte	.LASF986
	.byte	0x5
	.byte	0x19
	.byte	0x16
	.4byte	0xec
	.uleb128 0x5
	.byte	0x3
	.4byte	infoStackName
	.uleb128 0x9
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x5
	.byte	0x38
	.byte	0x6
	.4byte	0x169
	.uleb128 0xa
	.4byte	.LASF987
	.byte	0
	.uleb128 0xa
	.4byte	.LASF988
	.byte	0x1
	.byte	0
	.uleb128 0x9
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x5
	.byte	0x3e
	.byte	0x6
	.4byte	0x1a2
	.uleb128 0xa
	.4byte	.LASF989
	.byte	0
	.uleb128 0xa
	.4byte	.LASF990
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF991
	.byte	0x2
	.uleb128 0xa
	.4byte	.LASF992
	.byte	0x3
	.uleb128 0xa
	.4byte	.LASF993
	.byte	0x4
	.uleb128 0xa
	.4byte	.LASF994
	.byte	0x5
	.uleb128 0xa
	.4byte	.LASF995
	.byte	0x6
	.byte	0
	.uleb128 0x9
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x5
	.byte	0x4e
	.byte	0x6
	.4byte	0x211
	.uleb128 0xa
	.4byte	.LASF996
	.byte	0
	.uleb128 0xa
	.4byte	.LASF997
	.byte	0x11
	.uleb128 0xa
	.4byte	.LASF998
	.byte	0x3
	.uleb128 0xa
	.4byte	.LASF999
	.byte	0x2b
	.uleb128 0xa
	.4byte	.LASF1000
	.byte	0x3a
	.uleb128 0xa
	.4byte	.LASF1001
	.byte	0x80
	.uleb128 0xa
	.4byte	.LASF1002
	.byte	0x81
	.uleb128 0xa
	.4byte	.LASF1003
	.byte	0x85
	.uleb128 0xa
	.4byte	.LASF1004
	.byte	0x86
	.uleb128 0xa
	.4byte	.LASF1005
	.byte	0x3
	.uleb128 0xa
	.4byte	.LASF1006
	.byte	0x9b
	.uleb128 0xa
	.4byte	.LASF1007
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1008
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF1009
	.byte	0x2
	.uleb128 0xa
	.4byte	.LASF1010
	.byte	0x2e
	.uleb128 0xa
	.4byte	.LASF1011
	.byte	0xfa
	.byte	0
	.uleb128 0x9
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x5
	.byte	0x81
	.byte	0x6
	.4byte	0x334
	.uleb128 0xa
	.4byte	.LASF1012
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1013
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF1014
	.byte	0x2
	.uleb128 0xa
	.4byte	.LASF1015
	.byte	0x3
	.uleb128 0xa
	.4byte	.LASF1016
	.byte	0x4
	.uleb128 0xa
	.4byte	.LASF1017
	.byte	0x5
	.uleb128 0xa
	.4byte	.LASF1018
	.byte	0x6
	.uleb128 0xa
	.4byte	.LASF1019
	.byte	0x7
	.uleb128 0xa
	.4byte	.LASF1020
	.byte	0x8
	.uleb128 0xa
	.4byte	.LASF1021
	.byte	0x9
	.uleb128 0xa
	.4byte	.LASF1022
	.byte	0xa
	.uleb128 0xa
	.4byte	.LASF1023
	.byte	0xb
	.uleb128 0xa
	.4byte	.LASF1024
	.byte	0xc
	.uleb128 0xa
	.4byte	.LASF1025
	.byte	0xd
	.uleb128 0xa
	.4byte	.LASF1026
	.byte	0xe
	.uleb128 0xa
	.4byte	.LASF1027
	.byte	0xf
	.uleb128 0xa
	.4byte	.LASF1028
	.byte	0x10
	.uleb128 0xa
	.4byte	.LASF1029
	.byte	0x11
	.uleb128 0xa
	.4byte	.LASF1030
	.byte	0x12
	.uleb128 0xa
	.4byte	.LASF1031
	.byte	0x13
	.uleb128 0xa
	.4byte	.LASF1032
	.byte	0x14
	.uleb128 0xa
	.4byte	.LASF1033
	.byte	0x15
	.uleb128 0xa
	.4byte	.LASF1034
	.byte	0x16
	.uleb128 0xa
	.4byte	.LASF1035
	.byte	0x17
	.uleb128 0xa
	.4byte	.LASF1036
	.byte	0x18
	.uleb128 0xa
	.4byte	.LASF1037
	.byte	0x19
	.uleb128 0xa
	.4byte	.LASF1038
	.byte	0x1a
	.uleb128 0xa
	.4byte	.LASF1039
	.byte	0x1b
	.uleb128 0xa
	.4byte	.LASF1040
	.byte	0x1c
	.uleb128 0xa
	.4byte	.LASF1041
	.byte	0x1d
	.uleb128 0xa
	.4byte	.LASF1042
	.byte	0x1e
	.uleb128 0xa
	.4byte	.LASF1043
	.byte	0x1f
	.uleb128 0xa
	.4byte	.LASF1044
	.byte	0x20
	.uleb128 0xa
	.4byte	.LASF1045
	.byte	0x21
	.uleb128 0xa
	.4byte	.LASF1046
	.byte	0x22
	.uleb128 0xa
	.4byte	.LASF1047
	.byte	0x23
	.uleb128 0xa
	.4byte	.LASF1048
	.byte	0x24
	.uleb128 0xa
	.4byte	.LASF1049
	.byte	0x25
	.uleb128 0xa
	.4byte	.LASF1050
	.byte	0x26
	.uleb128 0xa
	.4byte	.LASF1051
	.byte	0x27
	.uleb128 0xa
	.4byte	.LASF1052
	.byte	0x28
	.uleb128 0xa
	.4byte	.LASF1053
	.byte	0x29
	.uleb128 0xa
	.4byte	.LASF1054
	.byte	0x2a
	.uleb128 0xa
	.4byte	.LASF1055
	.byte	0x2b
	.uleb128 0xa
	.4byte	.LASF1056
	.byte	0x2c
	.uleb128 0xa
	.4byte	.LASF1057
	.byte	0x2d
	.byte	0
	.uleb128 0x9
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x5
	.byte	0xc8
	.byte	0x6
	.4byte	0x53b
	.uleb128 0xa
	.4byte	.LASF1058
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF1059
	.byte	0x2
	.uleb128 0xa
	.4byte	.LASF1060
	.byte	0x3
	.uleb128 0xa
	.4byte	.LASF1061
	.byte	0x4
	.uleb128 0xa
	.4byte	.LASF1062
	.byte	0x5
	.uleb128 0xa
	.4byte	.LASF1063
	.byte	0x6
	.uleb128 0xa
	.4byte	.LASF1064
	.byte	0x7
	.uleb128 0xa
	.4byte	.LASF1065
	.byte	0x8
	.uleb128 0xa
	.4byte	.LASF1066
	.byte	0x9
	.uleb128 0xa
	.4byte	.LASF1067
	.byte	0xa
	.uleb128 0xa
	.4byte	.LASF1068
	.byte	0xb
	.uleb128 0xa
	.4byte	.LASF1069
	.byte	0xc
	.uleb128 0xa
	.4byte	.LASF1070
	.byte	0xd
	.uleb128 0xa
	.4byte	.LASF1071
	.byte	0xe
	.uleb128 0xa
	.4byte	.LASF1072
	.byte	0xf
	.uleb128 0xa
	.4byte	.LASF1073
	.byte	0x10
	.uleb128 0xa
	.4byte	.LASF1074
	.byte	0x11
	.uleb128 0xa
	.4byte	.LASF1075
	.byte	0x12
	.uleb128 0xa
	.4byte	.LASF1076
	.byte	0x13
	.uleb128 0xa
	.4byte	.LASF1077
	.byte	0x14
	.uleb128 0xa
	.4byte	.LASF1078
	.byte	0x15
	.uleb128 0xa
	.4byte	.LASF1079
	.byte	0x16
	.uleb128 0xa
	.4byte	.LASF1080
	.byte	0x17
	.uleb128 0xa
	.4byte	.LASF1081
	.byte	0x19
	.uleb128 0xa
	.4byte	.LASF1082
	.byte	0x1a
	.uleb128 0xa
	.4byte	.LASF1083
	.byte	0x1b
	.uleb128 0xa
	.4byte	.LASF1084
	.byte	0x1c
	.uleb128 0xa
	.4byte	.LASF1085
	.byte	0x1d
	.uleb128 0xa
	.4byte	.LASF1086
	.byte	0x1e
	.uleb128 0xa
	.4byte	.LASF1087
	.byte	0x1f
	.uleb128 0xa
	.4byte	.LASF1088
	.byte	0x20
	.uleb128 0xa
	.4byte	.LASF1089
	.byte	0x21
	.uleb128 0xa
	.4byte	.LASF1090
	.byte	0x22
	.uleb128 0xa
	.4byte	.LASF1091
	.byte	0x23
	.uleb128 0xa
	.4byte	.LASF1092
	.byte	0x24
	.uleb128 0xa
	.4byte	.LASF1093
	.byte	0x25
	.uleb128 0xa
	.4byte	.LASF1094
	.byte	0x26
	.uleb128 0xa
	.4byte	.LASF1095
	.byte	0x27
	.uleb128 0xa
	.4byte	.LASF1096
	.byte	0x28
	.uleb128 0xa
	.4byte	.LASF1097
	.byte	0x29
	.uleb128 0xa
	.4byte	.LASF1098
	.byte	0x2a
	.uleb128 0xa
	.4byte	.LASF1099
	.byte	0x2b
	.uleb128 0xa
	.4byte	.LASF1100
	.byte	0x2c
	.uleb128 0xa
	.4byte	.LASF1101
	.byte	0x2d
	.uleb128 0xa
	.4byte	.LASF1102
	.byte	0x2e
	.uleb128 0xa
	.4byte	.LASF1103
	.byte	0x2f
	.uleb128 0xa
	.4byte	.LASF1104
	.byte	0x30
	.uleb128 0xa
	.4byte	.LASF1105
	.byte	0x31
	.uleb128 0xa
	.4byte	.LASF1106
	.byte	0x32
	.uleb128 0xa
	.4byte	.LASF1107
	.byte	0x33
	.uleb128 0xa
	.4byte	.LASF1108
	.byte	0x34
	.uleb128 0xa
	.4byte	.LASF1109
	.byte	0x35
	.uleb128 0xa
	.4byte	.LASF1110
	.byte	0x36
	.uleb128 0xa
	.4byte	.LASF1111
	.byte	0x37
	.uleb128 0xa
	.4byte	.LASF1112
	.byte	0x38
	.uleb128 0xa
	.4byte	.LASF1113
	.byte	0x39
	.uleb128 0xa
	.4byte	.LASF1114
	.byte	0x3a
	.uleb128 0xa
	.4byte	.LASF1115
	.byte	0x3b
	.uleb128 0xa
	.4byte	.LASF1116
	.byte	0x3c
	.uleb128 0xa
	.4byte	.LASF1117
	.byte	0x3d
	.uleb128 0xa
	.4byte	.LASF1118
	.byte	0x3e
	.uleb128 0xa
	.4byte	.LASF1119
	.byte	0x3f
	.uleb128 0xa
	.4byte	.LASF1120
	.byte	0x40
	.uleb128 0xa
	.4byte	.LASF1121
	.byte	0x41
	.uleb128 0xa
	.4byte	.LASF1122
	.byte	0x42
	.uleb128 0xa
	.4byte	.LASF1123
	.byte	0x43
	.uleb128 0xa
	.4byte	.LASF1124
	.byte	0x44
	.uleb128 0xa
	.4byte	.LASF1125
	.byte	0x45
	.uleb128 0xa
	.4byte	.LASF1126
	.byte	0x46
	.uleb128 0xa
	.4byte	.LASF1127
	.byte	0x47
	.uleb128 0xa
	.4byte	.LASF1128
	.byte	0x48
	.uleb128 0xa
	.4byte	.LASF1129
	.byte	0x49
	.uleb128 0xa
	.4byte	.LASF1130
	.byte	0x4a
	.uleb128 0xa
	.4byte	.LASF1131
	.byte	0x4b
	.uleb128 0xa
	.4byte	.LASF1132
	.byte	0x4c
	.uleb128 0xa
	.4byte	.LASF1133
	.byte	0x4d
	.uleb128 0xa
	.4byte	.LASF1134
	.byte	0x4e
	.uleb128 0xa
	.4byte	.LASF1135
	.byte	0x4f
	.uleb128 0xa
	.4byte	.LASF1136
	.byte	0x50
	.uleb128 0xa
	.4byte	.LASF1137
	.byte	0x51
	.uleb128 0xa
	.4byte	.LASF1138
	.byte	0x52
	.uleb128 0xa
	.4byte	.LASF1139
	.byte	0x53
	.uleb128 0xa
	.4byte	.LASF1140
	.byte	0x54
	.uleb128 0xa
	.4byte	.LASF1141
	.byte	0x55
	.byte	0
	.uleb128 0xb
	.4byte	.LASF1142
	.byte	0x5
	.2byte	0x129
	.byte	0x12
	.4byte	0x7c
	.uleb128 0xb
	.4byte	.LASF1143
	.byte	0x5
	.2byte	0x12a
	.byte	0x12
	.4byte	0x7c
	.uleb128 0xb
	.4byte	.LASF1144
	.byte	0x5
	.2byte	0x12b
	.byte	0x11
	.4byte	0x51
	.uleb128 0xc
	.byte	0x5
	.byte	0x5
	.2byte	0x12e
	.byte	0x9
	.4byte	0x597
	.uleb128 0xd
	.4byte	.LASF1145
	.byte	0x5
	.2byte	0x12f
	.byte	0xd
	.4byte	0x51
	.byte	0
	.uleb128 0xd
	.4byte	.LASF1146
	.byte	0x5
	.2byte	0x130
	.byte	0xe
	.4byte	0x7c
	.byte	0x1
	.uleb128 0xd
	.4byte	.LASF1147
	.byte	0x5
	.2byte	0x131
	.byte	0xe
	.4byte	0x7c
	.byte	0x3
	.byte	0
	.uleb128 0xb
	.4byte	.LASF1148
	.byte	0x5
	.2byte	0x132
	.byte	0x3
	.4byte	0x562
	.uleb128 0xc
	.byte	0x5
	.byte	0x5
	.2byte	0x13a
	.byte	0x9
	.4byte	0x5d9
	.uleb128 0xd
	.4byte	.LASF1149
	.byte	0x5
	.2byte	0x13b
	.byte	0xa
	.4byte	0x51
	.byte	0
	.uleb128 0xd
	.4byte	.LASF1150
	.byte	0x5
	.2byte	0x13c
	.byte	0xe
	.4byte	0x7c
	.byte	0x1
	.uleb128 0xd
	.4byte	.LASF1151
	.byte	0x5
	.2byte	0x13d
	.byte	0xe
	.4byte	0x7c
	.byte	0x3
	.byte	0
	.uleb128 0xb
	.4byte	.LASF1152
	.byte	0x5
	.2byte	0x13e
	.byte	0x3
	.4byte	0x5a4
	.uleb128 0xe
	.byte	0x10
	.byte	0x5
	.2byte	0x142
	.byte	0x5
	.4byte	0x632
	.uleb128 0xf
	.4byte	.LASF1153
	.byte	0x5
	.2byte	0x143
	.byte	0x11
	.4byte	0x632
	.uleb128 0xf
	.4byte	.LASF1154
	.byte	0x5
	.2byte	0x144
	.byte	0x11
	.4byte	0x642
	.uleb128 0xf
	.4byte	.LASF1155
	.byte	0x5
	.2byte	0x145
	.byte	0x11
	.4byte	0x652
	.uleb128 0xf
	.4byte	.LASF1156
	.byte	0x5
	.2byte	0x146
	.byte	0x11
	.4byte	0x632
	.uleb128 0xf
	.4byte	.LASF1157
	.byte	0x5
	.2byte	0x147
	.byte	0x11
	.4byte	0x642
	.byte	0
	.uleb128 0x6
	.4byte	0x51
	.4byte	0x642
	.uleb128 0x7
	.4byte	0x37
	.byte	0x1
	.byte	0
	.uleb128 0x6
	.4byte	0x51
	.4byte	0x652
	.uleb128 0x7
	.4byte	0x37
	.byte	0x7
	.byte	0
	.uleb128 0x6
	.4byte	0x51
	.4byte	0x662
	.uleb128 0x7
	.4byte	0x37
	.byte	0xf
	.byte	0
	.uleb128 0xc
	.byte	0x11
	.byte	0x5
	.2byte	0x140
	.byte	0x9
	.4byte	0x681
	.uleb128 0xd
	.4byte	.LASF1158
	.byte	0x5
	.2byte	0x141
	.byte	0xd
	.4byte	0x51
	.byte	0
	.uleb128 0x10
	.4byte	0x5e6
	.byte	0x1
	.byte	0
	.uleb128 0xb
	.4byte	.LASF1159
	.byte	0x5
	.2byte	0x149
	.byte	0x3
	.4byte	0x662
	.uleb128 0x11
	.2byte	0x148
	.byte	0x5
	.2byte	0x14c
	.byte	0x9
	.4byte	0x956
	.uleb128 0xd
	.4byte	.LASF1160
	.byte	0x5
	.2byte	0x14e
	.byte	0x12
	.4byte	0x51
	.byte	0
	.uleb128 0xd
	.4byte	.LASF1161
	.byte	0x5
	.2byte	0x14f
	.byte	0x12
	.4byte	0x51
	.byte	0x1
	.uleb128 0xd
	.4byte	.LASF1162
	.byte	0x5
	.2byte	0x150
	.byte	0x12
	.4byte	0x956
	.byte	0x4
	.uleb128 0xd
	.4byte	.LASF1163
	.byte	0x5
	.2byte	0x151
	.byte	0x12
	.4byte	0x69
	.byte	0x8
	.uleb128 0xd
	.4byte	.LASF1164
	.byte	0x5
	.2byte	0x158
	.byte	0x12
	.4byte	0x51
	.byte	0xa
	.uleb128 0xd
	.4byte	.LASF1165
	.byte	0x5
	.2byte	0x15e
	.byte	0x12
	.4byte	0x51
	.byte	0xb
	.uleb128 0xd
	.4byte	.LASF1166
	.byte	0x5
	.2byte	0x15f
	.byte	0x12
	.4byte	0x51
	.byte	0xc
	.uleb128 0xd
	.4byte	.LASF1167
	.byte	0x5
	.2byte	0x160
	.byte	0x12
	.4byte	0x7c
	.byte	0xe
	.uleb128 0xd
	.4byte	.LASF1168
	.byte	0x5
	.2byte	0x161
	.byte	0x12
	.4byte	0x7c
	.byte	0x10
	.uleb128 0xd
	.4byte	.LASF1169
	.byte	0x5
	.2byte	0x162
	.byte	0x12
	.4byte	0x956
	.byte	0x14
	.uleb128 0xd
	.4byte	.LASF1170
	.byte	0x5
	.2byte	0x163
	.byte	0x12
	.4byte	0x51
	.byte	0x18
	.uleb128 0xd
	.4byte	.LASF1171
	.byte	0x5
	.2byte	0x166
	.byte	0x12
	.4byte	0x681
	.byte	0x19
	.uleb128 0xd
	.4byte	.LASF1172
	.byte	0x5
	.2byte	0x167
	.byte	0x12
	.4byte	0x681
	.byte	0x2a
	.uleb128 0xd
	.4byte	.LASF1173
	.byte	0x5
	.2byte	0x168
	.byte	0x12
	.4byte	0x51
	.byte	0x3b
	.uleb128 0xd
	.4byte	.LASF1174
	.byte	0x5
	.2byte	0x16e
	.byte	0xf
	.4byte	0x555
	.byte	0x3c
	.uleb128 0xd
	.4byte	.LASF1175
	.byte	0x5
	.2byte	0x16f
	.byte	0x11
	.4byte	0x681
	.byte	0x3d
	.uleb128 0xd
	.4byte	.LASF1176
	.byte	0x5
	.2byte	0x170
	.byte	0xd
	.4byte	0x51
	.byte	0x4e
	.uleb128 0xd
	.4byte	.LASF1177
	.byte	0x5
	.2byte	0x171
	.byte	0xd
	.4byte	0x51
	.byte	0x4f
	.uleb128 0xd
	.4byte	.LASF1178
	.byte	0x5
	.2byte	0x172
	.byte	0xd
	.4byte	0x51
	.byte	0x50
	.uleb128 0xd
	.4byte	.LASF1179
	.byte	0x5
	.2byte	0x173
	.byte	0xd
	.4byte	0x51
	.byte	0x51
	.uleb128 0xd
	.4byte	.LASF1180
	.byte	0x5
	.2byte	0x174
	.byte	0xb
	.4byte	0x597
	.byte	0x52
	.uleb128 0xd
	.4byte	.LASF1181
	.byte	0x5
	.2byte	0x175
	.byte	0xe
	.4byte	0x956
	.byte	0x58
	.uleb128 0xd
	.4byte	.LASF1182
	.byte	0x5
	.2byte	0x176
	.byte	0x11
	.4byte	0x95c
	.byte	0x5c
	.uleb128 0xd
	.4byte	.LASF1183
	.byte	0x5
	.2byte	0x177
	.byte	0x11
	.4byte	0x95c
	.byte	0x75
	.uleb128 0xd
	.4byte	.LASF1184
	.byte	0x5
	.2byte	0x178
	.byte	0xe
	.4byte	0x7c
	.byte	0x8e
	.uleb128 0xd
	.4byte	.LASF1185
	.byte	0x5
	.2byte	0x179
	.byte	0xd
	.4byte	0x51
	.byte	0x90
	.uleb128 0xd
	.4byte	.LASF1186
	.byte	0x5
	.2byte	0x17a
	.byte	0xd
	.4byte	0x51
	.byte	0x91
	.uleb128 0xd
	.4byte	.LASF1187
	.byte	0x5
	.2byte	0x17b
	.byte	0xd
	.4byte	0x51
	.byte	0x92
	.uleb128 0xd
	.4byte	.LASF1188
	.byte	0x5
	.2byte	0x17c
	.byte	0xd
	.4byte	0x51
	.byte	0x93
	.uleb128 0xd
	.4byte	.LASF1189
	.byte	0x5
	.2byte	0x17d
	.byte	0xe
	.4byte	0x956
	.byte	0x94
	.uleb128 0xd
	.4byte	.LASF1190
	.byte	0x5
	.2byte	0x17e
	.byte	0xe
	.4byte	0x956
	.byte	0x98
	.uleb128 0xd
	.4byte	.LASF1191
	.byte	0x5
	.2byte	0x17f
	.byte	0xd
	.4byte	0x51
	.byte	0x9c
	.uleb128 0xd
	.4byte	.LASF1192
	.byte	0x5
	.2byte	0x180
	.byte	0xa
	.4byte	0x51
	.byte	0x9d
	.uleb128 0xd
	.4byte	.LASF1193
	.byte	0x5
	.2byte	0x181
	.byte	0xa
	.4byte	0x51
	.byte	0x9e
	.uleb128 0xd
	.4byte	.LASF1194
	.byte	0x5
	.2byte	0x182
	.byte	0xa
	.4byte	0x51
	.byte	0x9f
	.uleb128 0xd
	.4byte	.LASF1195
	.byte	0x5
	.2byte	0x183
	.byte	0xa
	.4byte	0x51
	.byte	0xa0
	.uleb128 0xd
	.4byte	.LASF1196
	.byte	0x5
	.2byte	0x184
	.byte	0xd
	.4byte	0x69
	.byte	0xa2
	.uleb128 0xd
	.4byte	.LASF1197
	.byte	0x5
	.2byte	0x185
	.byte	0xa
	.4byte	0x51
	.byte	0xa4
	.uleb128 0xd
	.4byte	.LASF1198
	.byte	0x5
	.2byte	0x187
	.byte	0xd
	.4byte	0x51
	.byte	0xa5
	.uleb128 0xd
	.4byte	.LASF1199
	.byte	0x5
	.2byte	0x188
	.byte	0xd
	.4byte	0x51
	.byte	0xa6
	.uleb128 0xd
	.4byte	.LASF1200
	.byte	0x5
	.2byte	0x189
	.byte	0xd
	.4byte	0x51
	.byte	0xa7
	.uleb128 0xd
	.4byte	.LASF1201
	.byte	0x5
	.2byte	0x18a
	.byte	0x11
	.4byte	0x681
	.byte	0xa8
	.uleb128 0xd
	.4byte	.LASF1202
	.byte	0x5
	.2byte	0x18b
	.byte	0xd
	.4byte	0x51
	.byte	0xb9
	.uleb128 0xd
	.4byte	.LASF1203
	.byte	0x5
	.2byte	0x18c
	.byte	0xd
	.4byte	0x51
	.byte	0xba
	.uleb128 0xd
	.4byte	.LASF1204
	.byte	0x5
	.2byte	0x18d
	.byte	0xe
	.4byte	0x956
	.byte	0xbc
	.uleb128 0xd
	.4byte	.LASF1205
	.byte	0x5
	.2byte	0x18f
	.byte	0xd
	.4byte	0x51
	.byte	0xc0
	.uleb128 0xd
	.4byte	.LASF1206
	.byte	0x5
	.2byte	0x190
	.byte	0xc
	.4byte	0x3e
	.byte	0xc1
	.uleb128 0xd
	.4byte	.LASF1207
	.byte	0x5
	.2byte	0x191
	.byte	0xd
	.4byte	0x51
	.byte	0xc2
	.uleb128 0xd
	.4byte	.LASF1208
	.byte	0x5
	.2byte	0x192
	.byte	0xa
	.4byte	0x51
	.byte	0xc3
	.uleb128 0xd
	.4byte	.LASF1209
	.byte	0x5
	.2byte	0x194
	.byte	0xd
	.4byte	0x96c
	.byte	0xc4
	.byte	0
	.uleb128 0x12
	.byte	0x4
	.4byte	0x51
	.uleb128 0x6
	.4byte	0x5d9
	.4byte	0x96c
	.uleb128 0x7
	.4byte	0x37
	.byte	0x4
	.byte	0
	.uleb128 0x6
	.4byte	0x51
	.4byte	0x97c
	.uleb128 0x7
	.4byte	0x37
	.byte	0x81
	.byte	0
	.uleb128 0xb
	.4byte	.LASF1210
	.byte	0x5
	.2byte	0x195
	.byte	0x3
	.4byte	0x68e
	.uleb128 0x13
	.4byte	.LASF1215
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x24
	.byte	0x6
	.4byte	0x9b4
	.uleb128 0xa
	.4byte	.LASF1211
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1212
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF1213
	.byte	0x2
	.uleb128 0xa
	.4byte	.LASF1214
	.byte	0x3
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1216
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x2b
	.byte	0x6
	.4byte	0x9d3
	.uleb128 0xa
	.4byte	.LASF1217
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1218
	.byte	0x1
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1219
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x52
	.byte	0x6
	.4byte	0x9fe
	.uleb128 0xa
	.4byte	.LASF1220
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1221
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF1222
	.byte	0x2
	.uleb128 0xa
	.4byte	.LASF1223
	.byte	0x3
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1224
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x59
	.byte	0x6
	.4byte	0xa1d
	.uleb128 0xa
	.4byte	.LASF1225
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1226
	.byte	0x1
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1227
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x5e
	.byte	0x6
	.4byte	0xa3c
	.uleb128 0xa
	.4byte	.LASF1228
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1229
	.byte	0x1
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1230
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x63
	.byte	0x6
	.4byte	0xa67
	.uleb128 0xa
	.4byte	.LASF1231
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1232
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF1233
	.byte	0x2
	.uleb128 0xa
	.4byte	.LASF1234
	.byte	0x3
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1235
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x6a
	.byte	0x6
	.4byte	0xa86
	.uleb128 0xa
	.4byte	.LASF1236
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1237
	.byte	0x1
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1238
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x6f
	.byte	0x6
	.4byte	0xaa5
	.uleb128 0xa
	.4byte	.LASF1239
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1240
	.byte	0x1
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1241
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x74
	.byte	0x6
	.4byte	0xad0
	.uleb128 0xa
	.4byte	.LASF1242
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1243
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF1244
	.byte	0x2
	.uleb128 0xa
	.4byte	.LASF1245
	.byte	0x3
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1246
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x80
	.byte	0x6
	.4byte	0xaf5
	.uleb128 0xa
	.4byte	.LASF1247
	.byte	0xe0
	.uleb128 0xa
	.4byte	.LASF1248
	.byte	0x80
	.uleb128 0xa
	.4byte	.LASF1249
	.byte	0xa0
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1250
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x86
	.byte	0x6
	.4byte	0xb14
	.uleb128 0xa
	.4byte	.LASF1251
	.byte	0x1f
	.uleb128 0xa
	.4byte	.LASF1252
	.byte	0x6
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1253
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x8b
	.byte	0x6
	.4byte	0xb51
	.uleb128 0xa
	.4byte	.LASF1254
	.byte	0
	.uleb128 0xa
	.4byte	.LASF1255
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF1256
	.byte	0x2
	.uleb128 0xa
	.4byte	.LASF1257
	.byte	0x3
	.uleb128 0xa
	.4byte	.LASF1258
	.byte	0x4
	.uleb128 0xa
	.4byte	.LASF1259
	.byte	0x5
	.uleb128 0xa
	.4byte	.LASF1260
	.byte	0x6
	.byte	0
	.uleb128 0x13
	.4byte	.LASF1261
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x6
	.byte	0x98
	.byte	0x6
	.4byte	0xb6a
	.uleb128 0xa
	.4byte	.LASF1262
	.byte	0x1f
	.byte	0
	.uleb128 0x14
	.byte	0x44
	.byte	0x6
	.byte	0xa4
	.byte	0x9
	.4byte	0xc03
	.uleb128 0x15
	.4byte	.LASF1263
	.byte	0x6
	.byte	0xa5
	.byte	0xd
	.4byte	0x51
	.byte	0
	.uleb128 0x15
	.4byte	.LASF1264
	.byte	0x6
	.byte	0xa6
	.byte	0xe
	.4byte	0x8f
	.byte	0x4
	.uleb128 0x15
	.4byte	.LASF1265
	.byte	0x6
	.byte	0xa7
	.byte	0xa
	.4byte	0x51
	.byte	0x8
	.uleb128 0x15
	.4byte	.LASF1266
	.byte	0x6
	.byte	0xa8
	.byte	0xd
	.4byte	0x51
	.byte	0x9
	.uleb128 0x15
	.4byte	.LASF1267
	.byte	0x6
	.byte	0xa9
	.byte	0xe
	.4byte	0xc03
	.byte	0xc
	.uleb128 0x15
	.4byte	.LASF1268
	.byte	0x6
	.byte	0xaa
	.byte	0xe
	.4byte	0x956
	.byte	0x18
	.uleb128 0x15
	.4byte	.LASF1269
	.byte	0x6
	.byte	0xae
	.byte	0xd
	.4byte	0x51
	.byte	0x1c
	.uleb128 0x15
	.4byte	.LASF1270
	.byte	0x6
	.byte	0xaf
	.byte	0xd
	.4byte	0x51
	.byte	0x1d
	.uleb128 0x16
	.ascii	"src\000"
	.byte	0x6
	.byte	0xb0
	.byte	0x11
	.4byte	0x681
	.byte	0x1e
	.uleb128 0x15
	.4byte	.LASF1271
	.byte	0x6
	.byte	0xb1
	.byte	0x11
	.4byte	0x681
	.byte	0x2f
	.uleb128 0x15
	.4byte	.LASF1272
	.byte	0x6
	.byte	0xb2
	.byte	0xd
	.4byte	0x51
	.byte	0x40
	.byte	0
	.uleb128 0x6
	.4byte	0x956
	.4byte	0xc13
	.uleb128 0x7
	.4byte	0x37
	.byte	0x2
	.byte	0
	.uleb128 0x4
	.4byte	.LASF1273
	.byte	0x6
	.byte	0xb3
	.byte	0x3
	.4byte	0xb6a
	.uleb128 0x14
	.byte	0x5
	.byte	0x6
	.byte	0xd7
	.byte	0x9
	.4byte	0xc5d
	.uleb128 0x15
	.4byte	.LASF1274
	.byte	0x6
	.byte	0xd8
	.byte	0xd
	.4byte	0x51
	.byte	0
	.uleb128 0x15
	.4byte	.LASF1275
	.byte	0x6
	.byte	0xd9
	.byte	0xd
	.4byte	0x51
	.byte	0x1
	.uleb128 0x15
	.4byte	.LASF1276
	.byte	0x6
	.byte	0xda
	.byte	0xd
	.4byte	0x51
	.byte	0x2
	.uleb128 0x15
	.4byte	.LASF1277
	.byte	0x6
	.byte	0xdb
	.byte	0xe
	.4byte	0x7c
	.byte	0x3
	.byte	0
	.uleb128 0x4
	.4byte	.LASF1278
	.byte	0x6
	.byte	0xdc
	.byte	0x3
	.4byte	0xc1f
	.uleb128 0x9
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x7
	.byte	0x15
	.byte	0x6
	.4byte	0xc84
	.uleb128 0xa
	.4byte	.LASF1279
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF1280
	.byte	0x2
	.byte	0
	.uleb128 0x9
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x7
	.byte	0x1a
	.byte	0x6
	.4byte	0xcb7
	.uleb128 0xa
	.4byte	.LASF1281
	.byte	0x10
	.uleb128 0xa
	.4byte	.LASF1282
	.byte	0x8
	.uleb128 0xa
	.4byte	.LASF1283
	.byte	0x4
	.uleb128 0xa
	.4byte	.LASF1284
	.byte	0x2
	.uleb128 0xa
	.4byte	.LASF1285
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF1286
	.byte	0x1f
	.byte	0
	.uleb128 0x9
	.byte	0x7
	.byte	0x1
	.4byte	0x62
	.byte	0x8
	.byte	0x65
	.byte	0x6
	.4byte	0xcea
	.uleb128 0xa
	.4byte	.LASF1287
	.byte	0x1
	.uleb128 0xa
	.4byte	.LASF1288
	.byte	0x2
	.uleb128 0xa
	.4byte	.LASF1289
	.byte	0x3
	.uleb128 0xa
	.4byte	.LASF1290
	.byte	0x4
	.uleb128 0xa
	.4byte	.LASF1291
	.byte	0x5
	.uleb128 0xa
	.4byte	.LASF1292
	.byte	0x6
	.byte	0
	.uleb128 0x6
	.4byte	0x5d
	.4byte	0xcfa
	.uleb128 0x7
	.4byte	0x37
	.byte	0x7
	.byte	0
	.uleb128 0x5
	.4byte	0xcea
	.uleb128 0x8
	.4byte	.LASF1293
	.byte	0x9
	.byte	0x13
	.byte	0x16
	.4byte	0xcfa
	.uleb128 0x5
	.byte	0x3
	.4byte	linklocalprefix
	.uleb128 0x6
	.4byte	0x5d
	.4byte	0xd21
	.uleb128 0x7
	.4byte	0x37
	.byte	0xf
	.byte	0
	.uleb128 0x5
	.4byte	0xd11
	.uleb128 0x8
	.4byte	.LASF1294
	.byte	0xa
	.byte	0x4c
	.byte	0x16
	.4byte	0xd21
	.uleb128 0x5
	.byte	0x3
	.4byte	all_routers_multicast
	.uleb128 0x17
	.byte	0x4
	.uleb128 0x18
	.4byte	.LASF1301
	.byte	0xa
	.byte	0xdd
	.byte	0x9
	.4byte	0x51
	.uleb128 0x19
	.4byte	.LASF1295
	.byte	0x6
	.2byte	0x128
	.byte	0x9
	.4byte	0x51
	.4byte	0xd62
	.uleb128 0x1a
	.4byte	0xd62
	.uleb128 0x1a
	.4byte	0xd68
	.byte	0
	.uleb128 0x12
	.byte	0x4
	.4byte	0x97c
	.uleb128 0x12
	.byte	0x4
	.4byte	0xc5d
	.uleb128 0x1b
	.4byte	.LASF1296
	.byte	0xb
	.byte	0x2f
	.byte	0xb
	.4byte	0x555
	.4byte	0xd89
	.uleb128 0x1a
	.4byte	0xd89
	.uleb128 0x1a
	.4byte	0x7c
	.byte	0
	.uleb128 0x12
	.byte	0x4
	.4byte	0xd62
	.uleb128 0x1b
	.4byte	.LASF1297
	.byte	0xa
	.byte	0xdf
	.byte	0xb
	.4byte	0x555
	.4byte	0xda5
	.uleb128 0x1a
	.4byte	0x956
	.byte	0
	.uleb128 0x1b
	.4byte	.LASF1298
	.byte	0x6
	.byte	0xfc
	.byte	0xb
	.4byte	0x555
	.4byte	0xdde
	.uleb128 0x1a
	.4byte	0xd62
	.uleb128 0x1a
	.4byte	0xdde
	.uleb128 0x1a
	.4byte	0xdde
	.uleb128 0x1a
	.4byte	0xd68
	.uleb128 0x1a
	.4byte	0xde4
	.uleb128 0x1a
	.4byte	0x956
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.byte	0
	.uleb128 0x12
	.byte	0x4
	.4byte	0xc13
	.uleb128 0x12
	.byte	0x4
	.4byte	0x8f
	.uleb128 0x1b
	.4byte	.LASF1299
	.byte	0xc
	.byte	0x5f
	.byte	0x6
	.4byte	0x51
	.4byte	0xe00
	.uleb128 0x1a
	.4byte	0xe00
	.byte	0
	.uleb128 0x12
	.byte	0x4
	.4byte	0x681
	.uleb128 0x1b
	.4byte	.LASF1300
	.byte	0xa
	.byte	0xe3
	.byte	0x6
	.4byte	0x51
	.4byte	0xe1c
	.uleb128 0x1a
	.4byte	0xe00
	.byte	0
	.uleb128 0x18
	.4byte	.LASF1302
	.byte	0xa
	.byte	0xe9
	.byte	0xb
	.4byte	0x548
	.uleb128 0x18
	.4byte	.LASF1303
	.byte	0xd
	.byte	0x3f
	.byte	0x6
	.4byte	0x51
	.uleb128 0x1c
	.4byte	.LASF1304
	.byte	0xe
	.byte	0x39
	.byte	0x6
	.4byte	0xe46
	.uleb128 0x1a
	.4byte	0xd62
	.byte	0
	.uleb128 0x1c
	.4byte	.LASF1305
	.byte	0xf
	.byte	0x15
	.byte	0x6
	.4byte	0xe58
	.uleb128 0x1a
	.4byte	0xd62
	.byte	0
	.uleb128 0x1c
	.4byte	.LASF1306
	.byte	0xb
	.byte	0x31
	.byte	0x6
	.4byte	0xe6f
	.uleb128 0x1a
	.4byte	0xd89
	.uleb128 0x1a
	.4byte	0x7c
	.byte	0
	.uleb128 0x1b
	.4byte	.LASF1307
	.byte	0x9
	.byte	0x40
	.byte	0x6
	.4byte	0x51
	.4byte	0xe85
	.uleb128 0x1a
	.4byte	0xe00
	.byte	0
	.uleb128 0x1c
	.4byte	.LASF1308
	.byte	0xe
	.byte	0x37
	.byte	0x6
	.4byte	0xe9c
	.uleb128 0x1a
	.4byte	0xd62
	.uleb128 0x1a
	.4byte	0x555
	.byte	0
	.uleb128 0x1c
	.4byte	.LASF1309
	.byte	0xf
	.byte	0x13
	.byte	0x6
	.4byte	0xeb3
	.uleb128 0x1a
	.4byte	0xd62
	.uleb128 0x1a
	.4byte	0x555
	.byte	0
	.uleb128 0x1b
	.4byte	.LASF1310
	.byte	0xd
	.byte	0x3b
	.byte	0xb
	.4byte	0x555
	.4byte	0xec9
	.uleb128 0x1a
	.4byte	0xd62
	.byte	0
	.uleb128 0x1b
	.4byte	.LASF1311
	.byte	0x8
	.byte	0x92
	.byte	0xb
	.4byte	0x555
	.4byte	0xef3
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x53b
	.uleb128 0x1a
	.4byte	0x53b
	.byte	0
	.uleb128 0x19
	.4byte	.LASF1312
	.byte	0x6
	.2byte	0x115
	.byte	0xb
	.4byte	0x555
	.4byte	0xf55
	.uleb128 0x1a
	.4byte	0xd89
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x8f
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0x51
	.uleb128 0x1a
	.4byte	0xe00
	.uleb128 0x1a
	.4byte	0xe00
	.uleb128 0x1a
	.4byte	0x51
	.byte	0
	.uleb128 0x1b
	.4byte	.LASF1313
	.byte	0x3
	.byte	0x38
	.byte	0xb
	.4byte	0xd38
	.4byte	0xf75
	.uleb128 0x1a
	.4byte	0xd38
	.uleb128 0x1a
	.4byte	0xf75
	.uleb128 0x1a
	.4byte	0xa9
	.byte	0
	.uleb128 0x12
	.byte	0x4
	.4byte	0xf7b
	.uleb128 0x1d
	.uleb128 0x1b
	.4byte	.LASF1314
	.byte	0xb
	.byte	0x1f
	.byte	0x6
	.4byte	0x51
	.4byte	0xf92
	.uleb128 0x1a
	.4byte	0xe00
	.byte	0
	.uleb128 0x1b
	.4byte	.LASF1315
	.byte	0xb
	.byte	0x25
	.byte	0x6
	.4byte	0x51
	.4byte	0xfad
	.uleb128 0x1a
	.4byte	0xe00
	.uleb128 0x1a
	.4byte	0xe00
	.byte	0
	.uleb128 0x1b
	.4byte	.LASF1316
	.byte	0x3
	.byte	0x41
	.byte	0xb
	.4byte	0xd38
	.4byte	0xfcd
	.uleb128 0x1a
	.4byte	0xd38
	.uleb128 0x1a
	.4byte	0x29
	.uleb128 0x1a
	.4byte	0xa9
	.byte	0
	.uleb128 0x1b
	.4byte	.LASF1317
	.byte	0xb
	.byte	0x23
	.byte	0x6
	.4byte	0x51
	.4byte	0xfe3
	.uleb128 0x1a
	.4byte	0xe00
	.byte	0
	.uleb128 0x1b
	.4byte	.LASF1318
	.byte	0xb
	.byte	0x21
	.byte	0x6
	.4byte	0x51
	.4byte	0xff9
	.uleb128 0x1a
	.4byte	0xe00
	.byte	0
	.uleb128 0x1b
	.4byte	.LASF1319
	.byte	0xb
	.byte	0x27
	.byte	0x6
	.4byte	0x51
	.4byte	0x100f
	.uleb128 0x1a
	.4byte	0xe00
	.byte	0
	.uleb128 0x1c
	.4byte	.LASF1320
	.byte	0xb
	.byte	0x16
	.byte	0x6
	.4byte	0x102b
	.uleb128 0x1a
	.4byte	0xe00
	.uleb128 0x1a
	.4byte	0xe00
	.uleb128 0x1a
	.4byte	0xe00
	.byte	0
	.uleb128 0x1b
	.4byte	.LASF1321
	.byte	0x9
	.byte	0x3c
	.byte	0xe
	.4byte	0xe00
	.4byte	0x1041
	.uleb128 0x1a
	.4byte	0x51
	.byte	0
	.uleb128 0x1e
	.4byte	.LASF1343
	.byte	0x1
	.2byte	0x338
	.byte	0x6
	.4byte	.LFB122
	.4byte	.LFE122-.LFB122
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x1095
	.uleb128 0x1f
	.4byte	.LASF1322
	.byte	0x1
	.2byte	0x338
	.byte	0x30
	.4byte	0xd68
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x1f
	.4byte	.LASF1275
	.byte	0x1
	.2byte	0x338
	.byte	0x44
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -21
	.uleb128 0x20
	.ascii	"I\000"
	.byte	0x1
	.2byte	0x339
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -9
	.uleb128 0x20
	.ascii	"K\000"
	.byte	0x1
	.2byte	0x339
	.byte	0x10
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -10
	.byte	0
	.uleb128 0x21
	.4byte	.LASF1339
	.byte	0x1
	.2byte	0x205
	.byte	0xb
	.4byte	0x555
	.4byte	.LFB121
	.4byte	.LFE121-.LFB121
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x1209
	.uleb128 0x22
	.ascii	"msg\000"
	.byte	0x1
	.2byte	0x206
	.byte	0x1b
	.4byte	0xd62
	.uleb128 0x3
	.byte	0x91
	.sleb128 -244
	.uleb128 0x1f
	.4byte	.LASF1323
	.byte	0x1
	.2byte	0x207
	.byte	0x1a
	.4byte	0xdde
	.uleb128 0x3
	.byte	0x91
	.sleb128 -248
	.uleb128 0x1f
	.4byte	.LASF1324
	.byte	0x1
	.2byte	0x208
	.byte	0x1a
	.4byte	0xdde
	.uleb128 0x3
	.byte	0x91
	.sleb128 -252
	.uleb128 0x1f
	.4byte	.LASF1322
	.byte	0x1
	.2byte	0x20c
	.byte	0x18
	.4byte	0xd68
	.uleb128 0x3
	.byte	0x91
	.sleb128 -256
	.uleb128 0x23
	.4byte	.LASF1325
	.byte	0x1
	.2byte	0x20e
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -17
	.uleb128 0x23
	.4byte	.LASF1158
	.byte	0x1
	.2byte	0x20f
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -18
	.uleb128 0x23
	.4byte	.LASF1326
	.byte	0x1
	.2byte	0x210
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x23
	.4byte	.LASF1327
	.byte	0x1
	.2byte	0x211
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -23
	.uleb128 0x23
	.4byte	.LASF1328
	.byte	0x1
	.2byte	0x212
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -25
	.uleb128 0x23
	.4byte	.LASF1329
	.byte	0x1
	.2byte	0x213
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -19
	.uleb128 0x23
	.4byte	.LASF1330
	.byte	0x1
	.2byte	0x214
	.byte	0x11
	.4byte	0x681
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0x23
	.4byte	.LASF1331
	.byte	0x1
	.2byte	0x215
	.byte	0x11
	.4byte	0x681
	.uleb128 0x3
	.byte	0x91
	.sleb128 -68
	.uleb128 0x23
	.4byte	.LASF1332
	.byte	0x1
	.2byte	0x216
	.byte	0x11
	.4byte	0x681
	.uleb128 0x3
	.byte	0x91
	.sleb128 -88
	.uleb128 0x23
	.4byte	.LASF1333
	.byte	0x1
	.2byte	0x217
	.byte	0x11
	.4byte	0x681
	.uleb128 0x3
	.byte	0x91
	.sleb128 -108
	.uleb128 0x23
	.4byte	.LASF1334
	.byte	0x1
	.2byte	0x219
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -26
	.uleb128 0x23
	.4byte	.LASF1275
	.byte	0x1
	.2byte	0x21a
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -27
	.uleb128 0x23
	.4byte	.LASF1277
	.byte	0x1
	.2byte	0x21b
	.byte	0xe
	.4byte	0x7c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -30
	.uleb128 0x23
	.4byte	.LASF1335
	.byte	0x1
	.2byte	0x21d
	.byte	0xd
	.4byte	0x1209
	.uleb128 0x3
	.byte	0x91
	.sleb128 -236
	.uleb128 0x23
	.4byte	.LASF1336
	.byte	0x1
	.2byte	0x21e
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x23
	.4byte	.LASF1337
	.byte	0x1
	.2byte	0x220
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -22
	.uleb128 0x23
	.4byte	.LASF1338
	.byte	0x1
	.2byte	0x222
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -21
	.byte	0
	.uleb128 0x6
	.4byte	0x51
	.4byte	0x1219
	.uleb128 0x7
	.4byte	0x37
	.byte	0x7e
	.byte	0
	.uleb128 0x21
	.4byte	.LASF1340
	.byte	0x1
	.2byte	0x1c3
	.byte	0xb
	.4byte	0x555
	.4byte	.LFB120
	.4byte	.LFE120-.LFB120
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x12a5
	.uleb128 0x22
	.ascii	"msg\000"
	.byte	0x1
	.2byte	0x1c4
	.byte	0x1b
	.4byte	0xd62
	.uleb128 0x2
	.byte	0x91
	.sleb128 -36
	.uleb128 0x1f
	.4byte	.LASF1323
	.byte	0x1
	.2byte	0x1c5
	.byte	0x1a
	.4byte	0xdde
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x1f
	.4byte	.LASF1324
	.byte	0x1
	.2byte	0x1c6
	.byte	0x1a
	.4byte	0xdde
	.uleb128 0x2
	.byte	0x91
	.sleb128 -44
	.uleb128 0x1f
	.4byte	.LASF1322
	.byte	0x1
	.2byte	0x1c7
	.byte	0x18
	.4byte	0xd68
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0x1f
	.4byte	.LASF1264
	.byte	0x1
	.2byte	0x1cb
	.byte	0x13
	.4byte	0xde4
	.uleb128 0x2
	.byte	0x91
	.sleb128 0
	.uleb128 0x1f
	.4byte	.LASF1341
	.byte	0x1
	.2byte	0x1cc
	.byte	0x11
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 4
	.uleb128 0x23
	.4byte	.LASF1342
	.byte	0x1
	.2byte	0x1cf
	.byte	0x11
	.4byte	0x681
	.uleb128 0x2
	.byte	0x91
	.sleb128 -28
	.byte	0
	.uleb128 0x1e
	.4byte	.LASF1344
	.byte	0x1
	.2byte	0x1a9
	.byte	0x6
	.4byte	.LFB119
	.4byte	.LFE119-.LFB119
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x12eb
	.uleb128 0x1f
	.4byte	.LASF1345
	.byte	0x1
	.2byte	0x1a9
	.byte	0x29
	.4byte	0xe00
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x1f
	.4byte	.LASF1346
	.byte	0x1
	.2byte	0x1a9
	.byte	0x47
	.4byte	0xe00
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x20
	.ascii	"i\000"
	.byte	0x1
	.2byte	0x1aa
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -9
	.byte	0
	.uleb128 0x1e
	.4byte	.LASF1347
	.byte	0x1
	.2byte	0x114
	.byte	0x6
	.4byte	.LFB118
	.4byte	.LFE118-.LFB118
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x1363
	.uleb128 0x22
	.ascii	"msg\000"
	.byte	0x1
	.2byte	0x115
	.byte	0x1b
	.4byte	0xd62
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x1f
	.4byte	.LASF1323
	.byte	0x1
	.2byte	0x116
	.byte	0x1a
	.4byte	0xdde
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x1f
	.4byte	.LASF1324
	.byte	0x1
	.2byte	0x117
	.byte	0x1a
	.4byte	0xdde
	.uleb128 0x2
	.byte	0x91
	.sleb128 -28
	.uleb128 0x1f
	.4byte	.LASF1322
	.byte	0x1
	.2byte	0x11b
	.byte	0x18
	.4byte	0xd68
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x23
	.4byte	.LASF1275
	.byte	0x1
	.2byte	0x11d
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -9
	.uleb128 0x23
	.4byte	.LASF1277
	.byte	0x1
	.2byte	0x11e
	.byte	0xe
	.4byte	0x7c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -12
	.byte	0
	.uleb128 0x24
	.4byte	.LASF1348
	.byte	0x1
	.byte	0xe5
	.byte	0x6
	.4byte	.LFB117
	.4byte	.LFE117-.LFB117
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x1398
	.uleb128 0x25
	.ascii	"msg\000"
	.byte	0x1
	.byte	0xe5
	.byte	0x2c
	.4byte	0xd62
	.uleb128 0x2
	.byte	0x91
	.sleb128 -12
	.uleb128 0x26
	.4byte	.LASF1349
	.byte	0x1
	.byte	0xe5
	.byte	0x3b
	.4byte	0x555
	.uleb128 0x2
	.byte	0x91
	.sleb128 -13
	.byte	0
	.uleb128 0x27
	.4byte	.LASF1350
	.byte	0x1
	.byte	0x41
	.byte	0xb
	.4byte	0x555
	.4byte	.LFB116
	.4byte	.LFE116-.LFB116
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x14d7
	.uleb128 0x25
	.ascii	"msg\000"
	.byte	0x1
	.byte	0x41
	.byte	0x2d
	.4byte	0xd62
	.uleb128 0x3
	.byte	0x91
	.sleb128 -276
	.uleb128 0x8
	.4byte	.LASF1323
	.byte	0x1
	.byte	0x42
	.byte	0x15
	.4byte	0xc13
	.uleb128 0x3
	.byte	0x91
	.sleb128 -108
	.uleb128 0x8
	.4byte	.LASF1324
	.byte	0x1
	.byte	0x43
	.byte	0x15
	.4byte	0xc13
	.uleb128 0x3
	.byte	0x91
	.sleb128 -176
	.uleb128 0x8
	.4byte	.LASF1322
	.byte	0x1
	.byte	0x44
	.byte	0x13
	.4byte	0xc5d
	.uleb128 0x3
	.byte	0x91
	.sleb128 -184
	.uleb128 0x8
	.4byte	.LASF1351
	.byte	0x1
	.byte	0x48
	.byte	0x12
	.4byte	0xe00
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x8
	.4byte	.LASF1352
	.byte	0x1
	.byte	0x49
	.byte	0x12
	.4byte	0xe00
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x8
	.4byte	.LASF1264
	.byte	0x1
	.byte	0x4a
	.byte	0xe
	.4byte	0x8f
	.uleb128 0x3
	.byte	0x91
	.sleb128 -188
	.uleb128 0x8
	.4byte	.LASF1353
	.byte	0x1
	.byte	0x4c
	.byte	0x11
	.4byte	0x681
	.uleb128 0x3
	.byte	0x91
	.sleb128 -208
	.uleb128 0x8
	.4byte	.LASF1354
	.byte	0x1
	.byte	0x4d
	.byte	0x11
	.4byte	0x681
	.uleb128 0x3
	.byte	0x91
	.sleb128 -228
	.uleb128 0x8
	.4byte	.LASF1355
	.byte	0x1
	.byte	0x4e
	.byte	0x12
	.4byte	0xe00
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x8
	.4byte	.LASF1356
	.byte	0x1
	.byte	0x4f
	.byte	0x12
	.4byte	0xe00
	.uleb128 0x2
	.byte	0x91
	.sleb128 -28
	.uleb128 0x8
	.4byte	.LASF1357
	.byte	0x1
	.byte	0x50
	.byte	0x11
	.4byte	0x681
	.uleb128 0x3
	.byte	0x91
	.sleb128 -248
	.uleb128 0x8
	.4byte	.LASF1358
	.byte	0x1
	.byte	0x51
	.byte	0x11
	.4byte	0x681
	.uleb128 0x3
	.byte	0x91
	.sleb128 -268
	.uleb128 0x28
	.ascii	"sac\000"
	.byte	0x1
	.byte	0x52
	.byte	0xa
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -29
	.uleb128 0x28
	.ascii	"sam\000"
	.byte	0x1
	.byte	0x53
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -30
	.uleb128 0x28
	.ascii	"m\000"
	.byte	0x1
	.byte	0x54
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -31
	.uleb128 0x28
	.ascii	"dac\000"
	.byte	0x1
	.byte	0x55
	.byte	0xa
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x28
	.ascii	"dam\000"
	.byte	0x1
	.byte	0x56
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -33
	.uleb128 0x8
	.4byte	.LASF1266
	.byte	0x1
	.byte	0x57
	.byte	0xd
	.4byte	0x51
	.uleb128 0x2
	.byte	0x91
	.sleb128 -34
	.byte	0
	.uleb128 0x29
	.4byte	.LASF1362
	.byte	0x1
	.byte	0x36
	.byte	0x6
	.4byte	.LFB115
	.4byte	.LFE115-.LFB115
	.uleb128 0x1
	.byte	0x9c
	.byte	0
	.section	.debug_abbrev,"",%progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x2134
	.uleb128 0x19
	.uleb128 0x55
	.uleb128 0x17
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x10
	.uleb128 0x17
	.uleb128 0x2119
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0x4
	.byte	0x1
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x13
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0x17
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x10
	.uleb128 0xd
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x13
	.byte	0x1
	.uleb128 0xb
	.uleb128 0x5
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x13
	.uleb128 0x4
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x14
	.uleb128 0x13
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x15
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x16
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x17
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x18
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x19
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3c
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1a
	.uleb128 0x5
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1b
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3c
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1c
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x3c
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1d
	.uleb128 0x26
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x1e
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1f
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x20
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x21
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x22
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x23
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x24
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x25
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x26
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x27
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x28
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x29
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_pubnames,"",%progbits
	.4byte	0x16e7
	.2byte	0x2
	.4byte	.Ldebug_info0
	.4byte	0x14ea
	.4byte	0xca
	.ascii	"rreg_uriquery\000"
	.4byte	0xf1
	.ascii	"infoBoardname\000"
	.4byte	0x103
	.ascii	"infouCName\000"
	.4byte	0x12a
	.ascii	"infoRadioName\000"
	.4byte	0x13c
	.ascii	"infoStackName\000"
	.4byte	0x15c
	.ascii	"E_SUCCESS\000"
	.4byte	0x162
	.ascii	"E_FAIL\000"
	.4byte	0x177
	.ascii	"ADDR_NONE\000"
	.4byte	0x17d
	.ascii	"ADDR_16B\000"
	.4byte	0x183
	.ascii	"ADDR_64B\000"
	.4byte	0x189
	.ascii	"ADDR_128B\000"
	.4byte	0x18f
	.ascii	"ADDR_PANID\000"
	.4byte	0x195
	.ascii	"ADDR_PREFIX\000"
	.4byte	0x19b
	.ascii	"ADDR_ANYCAST\000"
	.4byte	0x1b0
	.ascii	"IANA_IPv6HOPOPT\000"
	.4byte	0x1b6
	.ascii	"IANA_UDP\000"
	.4byte	0x1bc
	.ascii	"IANA_IPv6ROUTING\000"
	.4byte	0x1c2
	.ascii	"IANA_IPv6ROUTE\000"
	.4byte	0x1c8
	.ascii	"IANA_ICMPv6\000"
	.4byte	0x1ce
	.ascii	"IANA_ICMPv6_ECHO_REQUEST\000"
	.4byte	0x1d4
	.ascii	"IANA_ICMPv6_ECHO_REPLY\000"
	.4byte	0x1da
	.ascii	"IANA_ICMPv6_RS\000"
	.4byte	0x1e0
	.ascii	"IANA_ICMPv6_RA\000"
	.4byte	0x1e6
	.ascii	"IANA_ICMPv6_RA_PREFIX_INFORMATION\000"
	.4byte	0x1ec
	.ascii	"IANA_ICMPv6_RPL\000"
	.4byte	0x1f2
	.ascii	"IANA_ICMPv6_RPL_DIS\000"
	.4byte	0x1f8
	.ascii	"IANA_ICMPv6_RPL_DIO\000"
	.4byte	0x1fe
	.ascii	"IANA_ICMPv6_RPL_DAO\000"
	.4byte	0x204
	.ascii	"IANA_RSVP\000"
	.4byte	0x20a
	.ascii	"IANA_UNDEFINED\000"
	.4byte	0x21f
	.ascii	"COMPONENT_NULL\000"
	.4byte	0x225
	.ascii	"COMPONENT_OPENWSN\000"
	.4byte	0x22b
	.ascii	"COMPONENT_IDMANAGER\000"
	.4byte	0x231
	.ascii	"COMPONENT_OPENQUEUE\000"
	.4byte	0x237
	.ascii	"COMPONENT_OPENSERIAL\000"
	.4byte	0x23d
	.ascii	"COMPONENT_PACKETFUNCTIONS\000"
	.4byte	0x243
	.ascii	"COMPONENT_RANDOM\000"
	.4byte	0x249
	.ascii	"COMPONENT_RADIO\000"
	.4byte	0x24f
	.ascii	"COMPONENT_IEEE802154\000"
	.4byte	0x255
	.ascii	"COMPONENT_IEEE802154E\000"
	.4byte	0x25b
	.ascii	"COMPONENT_SIXTOP_TO_IEEE802154E\000"
	.4byte	0x261
	.ascii	"COMPONENT_IEEE802154E_TO_SIXTOP\000"
	.4byte	0x267
	.ascii	"COMPONENT_SIXTOP\000"
	.4byte	0x26d
	.ascii	"COMPONENT_NEIGHBORS\000"
	.4byte	0x273
	.ascii	"COMPONENT_SCHEDULE\000"
	.4byte	0x279
	.ascii	"COMPONENT_SIXTOP_RES\000"
	.4byte	0x27f
	.ascii	"COMPONENT_MSF\000"
	.4byte	0x285
	.ascii	"COMPONENT_OPENBRIDGE\000"
	.4byte	0x28b
	.ascii	"COMPONENT_IPHC\000"
	.4byte	0x291
	.ascii	"COMPONENT_FRAG\000"
	.4byte	0x297
	.ascii	"COMPONENT_FORWARDING\000"
	.4byte	0x29d
	.ascii	"COMPONENT_ICMPv6\000"
	.4byte	0x2a3
	.ascii	"COMPONENT_ICMPv6ECHO\000"
	.4byte	0x2a9
	.ascii	"COMPONENT_ICMPv6ROUTER\000"
	.4byte	0x2af
	.ascii	"COMPONENT_ICMPv6RPL\000"
	.4byte	0x2b5
	.ascii	"COMPONENT_UDP\000"
	.4byte	0x2bb
	.ascii	"COMPONENT_SOCK_TO_UDP\000"
	.4byte	0x2c1
	.ascii	"COMPONENT_UDP_TO_SOCK\000"
	.4byte	0x2c7
	.ascii	"COMPONENT_OPENCOAP\000"
	.4byte	0x2cd
	.ascii	"COMPONENT_CJOIN\000"
	.4byte	0x2d3
	.ascii	"COMPONENT_OSCORE\000"
	.4byte	0x2d9
	.ascii	"COMPONENT_C6T\000"
	.4byte	0x2df
	.ascii	"COMPONENT_CEXAMPLE\000"
	.4byte	0x2e5
	.ascii	"COMPONENT_CINFO\000"
	.4byte	0x2eb
	.ascii	"COMPONENT_CLEDS\000"
	.4byte	0x2f1
	.ascii	"COMPONENT_CSENSORS\000"
	.4byte	0x2f7
	.ascii	"COMPONENT_CSTORM\000"
	.4byte	0x2fd
	.ascii	"COMPONENT_CWELLKNOWN\000"
	.4byte	0x303
	.ascii	"COMPONENT_UECHO\000"
	.4byte	0x309
	.ascii	"COMPONENT_UINJECT\000"
	.4byte	0x30f
	.ascii	"COMPONENT_RRT\000"
	.4byte	0x315
	.ascii	"COMPONENT_SECURITY\000"
	.4byte	0x31b
	.ascii	"COMPONENT_USERIALBRIDGE\000"
	.4byte	0x321
	.ascii	"COMPONENT_UEXPIRATION\000"
	.4byte	0x327
	.ascii	"COMPONENT_UMONITOR\000"
	.4byte	0x32d
	.ascii	"COMPONENT_CINFRARED\000"
	.4byte	0x342
	.ascii	"ERR_JOINED\000"
	.4byte	0x348
	.ascii	"ERR_JOIN_REQUEST\000"
	.4byte	0x34e
	.ascii	"ERR_SEQUENCE_NUMBER_OVERFLOW\000"
	.4byte	0x354
	.ascii	"ERR_REPLAY_FAILED\000"
	.4byte	0x35a
	.ascii	"ERR_DECRYPTION_FAILED\000"
	.4byte	0x360
	.ascii	"ERR_ABORT_JOIN_PROCESS\000"
	.4byte	0x366
	.ascii	"ERR_WRONG_TRAN_PROTOCOL\000"
	.4byte	0x36c
	.ascii	"ERR_UNSUPPORTED_PORT_NUMBER\000"
	.4byte	0x372
	.ascii	"ERR_INVALID_CHECKSUM\000"
	.4byte	0x378
	.ascii	"ERR_RCVD_ECHO_REQUEST\000"
	.4byte	0x37e
	.ascii	"ERR_RCVD_ECHO_REPLY\000"
	.4byte	0x384
	.ascii	"ERR_6LORH_DEADLINE_EXPIRED\000"
	.4byte	0x38a
	.ascii	"ERR_6LORH_DEADLINE_DROPPED\000"
	.4byte	0x390
	.ascii	"ERR_UNEXPECTED_DAO\000"
	.4byte	0x396
	.ascii	"ERR_UNSUPPORTED_ICMPV6_TYPE\000"
	.4byte	0x39c
	.ascii	"ERR_6LOWPAN_UNSUPPORTED\000"
	.4byte	0x3a2
	.ascii	"ERR_NO_NEXTHOP\000"
	.4byte	0x3a8
	.ascii	"ERR_INVALID_FWDMODE\000"
	.4byte	0x3ae
	.ascii	"ERR_LARGE_DAGRANK\000"
	.4byte	0x3b4
	.ascii	"ERR_HOP_LIMIT_REACHED\000"
	.4byte	0x3ba
	.ascii	"ERR_LOOP_DETECTED\000"
	.4byte	0x3c0
	.ascii	"ERR_WRONG_DIRECTION\000"
	.4byte	0x3c6
	.ascii	"ERR_FORWARDING_PACKET_DROPPED\000"
	.4byte	0x3cc
	.ascii	"ERR_FRAG_INVALID_SIZE\000"
	.4byte	0x3d2
	.ascii	"ERR_FRAG_REASSEMBLED\000"
	.4byte	0x3d8
	.ascii	"ERR_FRAG_FAST_FORWARD\000"
	.4byte	0x3de
	.ascii	"ERR_FRAG_STORED\000"
	.4byte	0x3e4
	.ascii	"ERR_FRAG_REASSEMBLY_OR_VRB_TIMEOUT\000"
	.4byte	0x3ea
	.ascii	"ERR_FRAG_FRAGMENTING\000"
	.4byte	0x3f0
	.ascii	"ERR_BRIDGE_MISMATCH\000"
	.4byte	0x3f6
	.ascii	"ERR_SCHEDULE_ADD_DUPLICATE_SLOT\000"
	.4byte	0x3fc
	.ascii	"ERR_NEIGHBORS_FULL\000"
	.4byte	0x402
	.ascii	"ERR_NO_SENT_PACKET\000"
	.4byte	0x408
	.ascii	"ERR_NO_RECEIVED_PACKET\000"
	.4byte	0x40e
	.ascii	"ERR_SCHEDULE_OVERFLOWN\000"
	.4byte	0x414
	.ascii	"ERR_SIXTOP_RETURNCODE\000"
	.4byte	0x41a
	.ascii	"ERR_SIXTOP_REQUEST\000"
	.4byte	0x420
	.ascii	"ERR_SIXTOP_COUNT\000"
	.4byte	0x426
	.ascii	"ERR_SIXTOP_LIST\000"
	.4byte	0x42c
	.ascii	"ERR_UNSUPPORTED_FORMAT\000"
	.4byte	0x432
	.ascii	"ERR_UNSUPPORTED_METADATA\000"
	.4byte	0x438
	.ascii	"ERR_TX_CELL_USAGE\000"
	.4byte	0x43e
	.ascii	"ERR_RX_CELL_USAGE\000"
	.4byte	0x444
	.ascii	"ERR_WRONG_CELLTYPE\000"
	.4byte	0x44a
	.ascii	"ERR_IEEE154_UNSUPPORTED\000"
	.4byte	0x450
	.ascii	"ERR_DESYNCHRONIZED\000"
	.4byte	0x456
	.ascii	"ERR_SYNCHRONIZED\000"
	.4byte	0x45c
	.ascii	"ERR_LARGE_TIMECORRECTION\000"
	.4byte	0x462
	.ascii	"ERR_WRONG_STATE_IN_ENDFRAME_SYNC\000"
	.4byte	0x468
	.ascii	"ERR_WRONG_STATE_IN_STARTSLOT\000"
	.4byte	0x46e
	.ascii	"ERR_WRONG_STATE_IN_TIMERFIRES\000"
	.4byte	0x474
	.ascii	"ERR_WRONG_STATE_IN_NEWSLOT\000"
	.4byte	0x47a
	.ascii	"ERR_WRONG_STATE_IN_ENDOFFRAME\000"
	.4byte	0x480
	.ascii	"ERR_MAXTXDATAPREPARE_OVERFLOW\000"
	.4byte	0x486
	.ascii	"ERR_MAXRXACKPREPARE_OVERFLOWS\000"
	.4byte	0x48c
	.ascii	"ERR_MAXRXDATAPREPARE_OVERFLOWS\000"
	.4byte	0x492
	.ascii	"ERR_MAXTXACKPREPARE_OVERFLOWS\000"
	.4byte	0x498
	.ascii	"ERR_WDDATADURATION_OVERFLOWS\000"
	.4byte	0x49e
	.ascii	"ERR_WDRADIO_OVERFLOWS\000"
	.4byte	0x4a4
	.ascii	"ERR_WDRADIOTX_OVERFLOWS\000"
	.4byte	0x4aa
	.ascii	"ERR_WDACKDURATION_OVERFLOWS\000"
	.4byte	0x4b0
	.ascii	"ERR_SECURITY\000"
	.4byte	0x4b6
	.ascii	"ERR_INVALID_PACKET_FROM_RADIO\000"
	.4byte	0x4bc
	.ascii	"ERR_GETDATA_ASKS_TOO_FEW_BYTES\000"
	.4byte	0x4c2
	.ascii	"ERR_WRONG_CRC_INPUT\000"
	.4byte	0x4c8
	.ascii	"ERR_BUFFER_OVERFLOW\000"
	.4byte	0x4ce
	.ascii	"ERR_BUSY_SENDING\000"
	.4byte	0x4d4
	.ascii	"ERR_UNEXPECTED_SENDDONE\000"
	.4byte	0x4da
	.ascii	"ERR_NO_FREE_PACKET_BUFFER\000"
	.4byte	0x4e0
	.ascii	"ERR_NO_FREE_TIMER_OR_QUEUE_ENTRY\000"
	.4byte	0x4e6
	.ascii	"ERR_FREEING_UNUSED\000"
	.4byte	0x4ec
	.ascii	"ERR_FREEING_ERROR\000"
	.4byte	0x4f2
	.ascii	"ERR_MSG_UNKNOWN_TYPE\000"
	.4byte	0x4f8
	.ascii	"ERR_WRONG_ADDR_TYPE\000"
	.4byte	0x4fe
	.ascii	"ERR_PACKET_TOO_LONG\000"
	.4byte	0x504
	.ascii	"ERR_PACKET_TOO_SHORT\000"
	.4byte	0x50a
	.ascii	"ERR_INPUTBUFFER_LENGTH\000"
	.4byte	0x510
	.ascii	"ERR_BOOTED\000"
	.4byte	0x516
	.ascii	"ERR_MAXRETRIES_REACHED\000"
	.4byte	0x51c
	.ascii	"ERR_EMPTY_QUEUE_OR_UNKNOWN_TIMER\000"
	.4byte	0x522
	.ascii	"ERR_PUSH_LOWER_LAYER\000"
	.4byte	0x528
	.ascii	"ERR_INVALID_PARAM\000"
	.4byte	0x52e
	.ascii	"ERR_COPY_TO_SPKT\000"
	.4byte	0x534
	.ascii	"ERR_COPY_TO_BPKT\000"
	.4byte	0x99b
	.ascii	"IPHC_TF_4B\000"
	.4byte	0x9a1
	.ascii	"IPHC_TF_3B\000"
	.4byte	0x9a7
	.ascii	"IPHC_TF_1B\000"
	.4byte	0x9ad
	.ascii	"IPHC_TF_ELIDED\000"
	.4byte	0x9c6
	.ascii	"IPHC_NH_INLINE\000"
	.4byte	0x9cc
	.ascii	"IPHC_NH_COMPRESSED\000"
	.4byte	0x9e5
	.ascii	"IPHC_HLIM_INLINE\000"
	.4byte	0x9eb
	.ascii	"IPHC_HLIM_1\000"
	.4byte	0x9f1
	.ascii	"IPHC_HLIM_64\000"
	.4byte	0x9f7
	.ascii	"IPHC_HLIM_255\000"
	.4byte	0xa10
	.ascii	"IPHC_CID_NO\000"
	.4byte	0xa16
	.ascii	"IPHC_CID_YES\000"
	.4byte	0xa2f
	.ascii	"IPHC_SAC_STATELESS\000"
	.4byte	0xa35
	.ascii	"IPHC_SAC_STATEFUL\000"
	.4byte	0xa4e
	.ascii	"IPHC_SAM_128B\000"
	.4byte	0xa54
	.ascii	"IPHC_SAM_64B\000"
	.4byte	0xa5a
	.ascii	"IPHC_SAM_16B\000"
	.4byte	0xa60
	.ascii	"IPHC_SAM_ELIDED\000"
	.4byte	0xa79
	.ascii	"IPHC_M_NO\000"
	.4byte	0xa7f
	.ascii	"IPHC_M_YES\000"
	.4byte	0xa98
	.ascii	"IPHC_DAC_STATELESS\000"
	.4byte	0xa9e
	.ascii	"IPHC_DAC_STATEFUL\000"
	.4byte	0xab7
	.ascii	"IPHC_DAM_128B\000"
	.4byte	0xabd
	.ascii	"IPHC_DAM_64B\000"
	.4byte	0xac3
	.ascii	"IPHC_DAM_16B\000"
	.4byte	0xac9
	.ascii	"IPHC_DAM_ELIDED\000"
	.4byte	0xae2
	.ascii	"FORMAT_6LORH_MASK\000"
	.4byte	0xae8
	.ascii	"CRITICAL_6LORH\000"
	.4byte	0xaee
	.ascii	"ELECTIVE_6LoRH\000"
	.4byte	0xb07
	.ascii	"IPINIP_LEN_6LORH_MASK\000"
	.4byte	0xb0d
	.ascii	"IPINIP_TYPE_6LORH\000"
	.4byte	0xb26
	.ascii	"RH3_6LOTH_TYPE_0\000"
	.4byte	0xb2c
	.ascii	"RH3_6LOTH_TYPE_1\000"
	.4byte	0xb32
	.ascii	"RH3_6LOTH_TYPE_2\000"
	.4byte	0xb38
	.ascii	"RH3_6LOTH_TYPE_3\000"
	.4byte	0xb3e
	.ascii	"RH3_6LOTH_TYPE_4\000"
	.4byte	0xb44
	.ascii	"RPI_6LOTH_TYPE\000"
	.4byte	0xb4a
	.ascii	"IPECAP_6LOTH_TYPE\000"
	.4byte	0xb63
	.ascii	"RH3_6LOTH_SIZE_MASK\000"
	.4byte	0xc77
	.ascii	"PCKTFORWARD\000"
	.4byte	0xc7d
	.ascii	"PCKTSEND\000"
	.4byte	0xc92
	.ascii	"O_FLAG\000"
	.4byte	0xc98
	.ascii	"R_FLAG\000"
	.4byte	0xc9e
	.ascii	"F_FLAG\000"
	.4byte	0xca4
	.ascii	"I_FLAG\000"
	.4byte	0xcaa
	.ascii	"K_FLAG\000"
	.4byte	0xcb0
	.ascii	"FLAG_MASK\000"
	.4byte	0xcc5
	.ascii	"L_CRITICAL\000"
	.4byte	0xccb
	.ascii	"L_ERROR\000"
	.4byte	0xcd1
	.ascii	"L_SUCCESS\000"
	.4byte	0xcd7
	.ascii	"L_WARNING\000"
	.4byte	0xcdd
	.ascii	"L_INFO\000"
	.4byte	0xce3
	.ascii	"L_VERBOSE\000"
	.4byte	0xcff
	.ascii	"linklocalprefix\000"
	.4byte	0xd26
	.ascii	"all_routers_multicast\000"
	.4byte	0xd3a
	.ascii	"icmpv6rpl_getRPLIntanceID\000"
	.4byte	0xd46
	.ascii	"iphc_retrieveIPv6HopByHopHeader\000"
	.4byte	0xd6e
	.ascii	"packetfunctions_reserveHeader\000"
	.4byte	0xd8f
	.ascii	"icmpv6rpl_getRPLDODAGid\000"
	.4byte	0xda5
	.ascii	"iphc_sendFromForwarding\000"
	.4byte	0xdea
	.ascii	"neighbors_isStableNeighbor\000"
	.4byte	0xe06
	.ascii	"icmpv6rpl_getPreferredParentEui64\000"
	.4byte	0xe1c
	.ascii	"icmpv6rpl_getMyDAGrank\000"
	.4byte	0xe28
	.ascii	"openqueue_isHighPriorityEntryEnough\000"
	.4byte	0xe34
	.ascii	"icmpv6_receive\000"
	.4byte	0xe46
	.ascii	"udp_receive\000"
	.4byte	0xe58
	.ascii	"packetfunctions_tossHeader\000"
	.4byte	0xe6f
	.ascii	"idmanager_isMyAddress\000"
	.4byte	0xe85
	.ascii	"icmpv6_sendDone\000"
	.4byte	0xe9c
	.ascii	"udp_sendDone\000"
	.4byte	0xeb3
	.ascii	"openqueue_freePacketBuffer\000"
	.4byte	0xec9
	.ascii	"openserial_printLog\000"
	.4byte	0xef3
	.ascii	"iphc_prependIPv6Header\000"
	.4byte	0xf55
	.ascii	"memcpy\000"
	.4byte	0xf7c
	.ascii	"packetfunctions_isBroadcastMulticast\000"
	.4byte	0xf92
	.ascii	"packetfunctions_sameAddress\000"
	.4byte	0xfad
	.ascii	"memset\000"
	.4byte	0xfcd
	.ascii	"packetfunctions_isAllHostsMulticast\000"
	.4byte	0xfe3
	.ascii	"packetfunctions_isAllRoutersMulticast\000"
	.4byte	0xff9
	.ascii	"packetfunctions_isLinkLocal\000"
	.4byte	0x100f
	.ascii	"packetfunctions_ip128bToMac64b\000"
	.4byte	0x102b
	.ascii	"idmanager_getMyID\000"
	.4byte	0x1041
	.ascii	"forwarding_createRplOption\000"
	.4byte	0x1095
	.ascii	"forwarding_send_internal_SourceRouting\000"
	.4byte	0x1219
	.ascii	"forwarding_send_internal_RoutingTable\000"
	.4byte	0x12a5
	.ascii	"forwarding_getNextHop\000"
	.4byte	0x12eb
	.ascii	"forwarding_receive\000"
	.4byte	0x1363
	.ascii	"forwarding_sendDone\000"
	.4byte	0x1398
	.ascii	"forwarding_send\000"
	.4byte	0x14d7
	.ascii	"forwarding_init\000"
	.4byte	0
	.section	.debug_pubtypes,"",%progbits
	.4byte	0x28a
	.2byte	0x2
	.4byte	.Ldebug_info0
	.4byte	0x14ea
	.4byte	0x29
	.ascii	"int\000"
	.4byte	0x30
	.ascii	"char\000"
	.4byte	0x37
	.ascii	"unsigned int\000"
	.4byte	0x4a
	.ascii	"signed char\000"
	.4byte	0x3e
	.ascii	"int8_t\000"
	.4byte	0x62
	.ascii	"unsigned char\000"
	.4byte	0x51
	.ascii	"uint8_t\000"
	.4byte	0x75
	.ascii	"short int\000"
	.4byte	0x69
	.ascii	"int16_t\000"
	.4byte	0x88
	.ascii	"short unsigned int\000"
	.4byte	0x7c
	.ascii	"uint16_t\000"
	.4byte	0x8f
	.ascii	"uint32_t\000"
	.4byte	0x9b
	.ascii	"long long int\000"
	.4byte	0xa2
	.ascii	"long long unsigned int\000"
	.4byte	0xa9
	.ascii	"size_t\000"
	.4byte	0x53b
	.ascii	"errorparameter_t\000"
	.4byte	0x548
	.ascii	"dagrank_t\000"
	.4byte	0x555
	.ascii	"owerror_t\000"
	.4byte	0x597
	.ascii	"asn_t\000"
	.4byte	0x5d9
	.ascii	"cellInfo_ht\000"
	.4byte	0x681
	.ascii	"open_addr_t\000"
	.4byte	0x97c
	.ascii	"OpenQueueEntry_t\000"
	.4byte	0x989
	.ascii	"IPHC_TF_enums\000"
	.4byte	0x9b4
	.ascii	"IPHC_NH_enums\000"
	.4byte	0x9d3
	.ascii	"IPHC_HLIM_enums\000"
	.4byte	0x9fe
	.ascii	"IPHC_CID_enums\000"
	.4byte	0xa1d
	.ascii	"IPHC_SAC_enums\000"
	.4byte	0xa3c
	.ascii	"IPHC_SAM_enums\000"
	.4byte	0xa67
	.ascii	"IPHC_M_enums\000"
	.4byte	0xa86
	.ascii	"IPHC_DAC_enums\000"
	.4byte	0xaa5
	.ascii	"IPHC_DAM_enums\000"
	.4byte	0xad0
	.ascii	"FORMAT_6LORH_enums\000"
	.4byte	0xaf5
	.ascii	"IPINIP_LEN_6LORH_enums\000"
	.4byte	0xb14
	.ascii	"TYPE_6LORH_enums\000"
	.4byte	0xb51
	.ascii	"SIZE_6LORH_RH3_enums\000"
	.4byte	0xc13
	.ascii	"ipv6_header_iht\000"
	.4byte	0xc5d
	.ascii	"rpl_option_ht\000"
	.4byte	0
	.section	.debug_aranges,"",%progbits
	.4byte	0x54
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0
	.2byte	0
	.2byte	0
	.4byte	.LFB115
	.4byte	.LFE115-.LFB115
	.4byte	.LFB116
	.4byte	.LFE116-.LFB116
	.4byte	.LFB117
	.4byte	.LFE117-.LFB117
	.4byte	.LFB118
	.4byte	.LFE118-.LFB118
	.4byte	.LFB119
	.4byte	.LFE119-.LFB119
	.4byte	.LFB120
	.4byte	.LFE120-.LFB120
	.4byte	.LFB121
	.4byte	.LFE121-.LFB121
	.4byte	.LFB122
	.4byte	.LFE122-.LFB122
	.4byte	0
	.4byte	0
	.section	.debug_ranges,"",%progbits
.Ldebug_ranges0:
	.4byte	.LFB115
	.4byte	.LFE115
	.4byte	.LFB116
	.4byte	.LFE116
	.4byte	.LFB117
	.4byte	.LFE117
	.4byte	.LFB118
	.4byte	.LFE118
	.4byte	.LFB119
	.4byte	.LFE119
	.4byte	.LFB120
	.4byte	.LFE120
	.4byte	.LFB121
	.4byte	.LFE121
	.4byte	.LFB122
	.4byte	.LFE122
	.4byte	0
	.4byte	0
	.section	.debug_macro,"",%progbits
.Ldebug_macro0:
	.2byte	0x4
	.byte	0x2
	.4byte	.Ldebug_line0
	.byte	0x7
	.4byte	.Ldebug_macro2
	.byte	0x3
	.uleb128 0
	.uleb128 0x1
	.byte	0x3
	.uleb128 0x1
	.uleb128 0x5
	.byte	0x5
	.uleb128 0xd
	.4byte	.LASF482
	.file 16 "C:/Users/16603/AppData/Local/SEGGER/SEGGER Embedded Studio/v3/packages/libraries/libcxx/include/stdint.h"
	.byte	0x3
	.uleb128 0x10
	.uleb128 0x10
	.byte	0x5
	.uleb128 0xf
	.4byte	.LASF483
	.file 17 "C:/Users/16603/AppData/Local/SEGGER/SEGGER Embedded Studio/v3/packages/libraries/libcxx/include/__config"
	.byte	0x3
	.uleb128 0x6a
	.uleb128 0x11
	.byte	0x5
	.uleb128 0xb
	.4byte	.LASF484
	.byte	0x4
	.byte	0x3
	.uleb128 0x7b
	.uleb128 0x2
	.byte	0x5
	.uleb128 0xb
	.4byte	.LASF485
	.file 18 "C:/Program Files/SEGGER/SEGGER Embedded Studio for ARM 6.30/include/__SEGGER_RTL.h"
	.byte	0x3
	.uleb128 0x14
	.uleb128 0x12
	.byte	0x5
	.uleb128 0xb
	.4byte	.LASF486
	.file 19 "C:/Program Files/SEGGER/SEGGER Embedded Studio for ARM 6.30/include/__SEGGER_RTL_ConfDefaults.h"
	.byte	0x3
	.uleb128 0x11
	.uleb128 0x13
	.byte	0x5
	.uleb128 0xb
	.4byte	.LASF487
	.file 20 "C:/Program Files/SEGGER/SEGGER Embedded Studio for ARM 6.30/include/__SEGGER_RTL_Conf.h"
	.byte	0x3
	.uleb128 0xd
	.uleb128 0x14
	.byte	0x5
	.uleb128 0xb
	.4byte	.LASF488
	.file 21 "C:/Program Files/SEGGER/SEGGER Embedded Studio for ARM 6.30/include/__SEGGER_RTL_Arm_Conf.h"
	.byte	0x3
	.uleb128 0x19
	.uleb128 0x15
	.byte	0x7
	.4byte	.Ldebug_macro3
	.byte	0x4
	.byte	0x4
	.byte	0x7
	.4byte	.Ldebug_macro4
	.byte	0x4
	.byte	0x7
	.4byte	.Ldebug_macro5
	.byte	0x4
	.byte	0x7
	.4byte	.Ldebug_macro6
	.byte	0x4
	.byte	0x4
	.file 22 "../../inc/config.h"
	.byte	0x3
	.uleb128 0x11
	.uleb128 0x16
	.byte	0x7
	.4byte	.Ldebug_macro7
	.file 23 "../../inc/check_config.h"
	.byte	0x3
	.uleb128 0x1c9
	.uleb128 0x17
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF765
	.byte	0x4
	.byte	0x4
	.file 24 "../../bsp/boards/toolchain_defs.h"
	.byte	0x3
	.uleb128 0x12
	.uleb128 0x18
	.byte	0x7
	.4byte	.Ldebug_macro8
	.byte	0x4
	.byte	0x3
	.uleb128 0x13
	.uleb128 0x4
	.byte	0x5
	.uleb128 0x8
	.4byte	.LASF773
	.file 25 "C:/Users/16603/AppData/Local/SEGGER/SEGGER Embedded Studio/v3/packages/libraries/libcxx/include/string.h"
	.byte	0x3
	.uleb128 0xb
	.uleb128 0x19
	.byte	0x5
	.uleb128 0xb
	.4byte	.LASF774
	.byte	0x3
	.uleb128 0x3c
	.uleb128 0x3
	.byte	0x7
	.4byte	.Ldebug_macro9
	.byte	0x4
	.byte	0x4
	.file 26 "../../bsp/boards/nrf52840_dk/sdk/cmsis_gcc.h"
	.byte	0x3
	.uleb128 0xc
	.uleb128 0x1a
	.byte	0x7
	.4byte	.Ldebug_macro10
	.byte	0x4
	.byte	0x7
	.4byte	.Ldebug_macro11
	.byte	0x4
	.file 27 "../../inc/af.h"
	.byte	0x3
	.uleb128 0x14
	.uleb128 0x1b
	.byte	0x7
	.4byte	.Ldebug_macro12
	.byte	0x4
	.byte	0x7
	.4byte	.Ldebug_macro13
	.byte	0x4
	.byte	0x3
	.uleb128 0x2
	.uleb128 0x7
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF862
	.byte	0x3
	.uleb128 0xb
	.uleb128 0x6
	.byte	0x7
	.4byte	.Ldebug_macro14
	.byte	0x4
	.byte	0x5
	.uleb128 0xf
	.4byte	.LASF867
	.byte	0x4
	.byte	0x3
	.uleb128 0x4
	.uleb128 0xd
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF868
	.byte	0x3
	.uleb128 0xb
	.uleb128 0x16
	.byte	0x4
	.file 28 "../../openstack/02a-MAClow/IEEE802154.h"
	.byte	0x3
	.uleb128 0xd
	.uleb128 0x1c
	.byte	0x7
	.4byte	.Ldebug_macro15
	.byte	0x4
	.byte	0x7
	.4byte	.Ldebug_macro16
	.byte	0x4
	.byte	0x3
	.uleb128 0x5
	.uleb128 0x8
	.byte	0x7
	.4byte	.Ldebug_macro17
	.byte	0x4
	.byte	0x3
	.uleb128 0x6
	.uleb128 0x9
	.byte	0x7
	.4byte	.Ldebug_macro18
	.byte	0x4
	.byte	0x3
	.uleb128 0x7
	.uleb128 0xb
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF904
	.byte	0x4
	.byte	0x3
	.uleb128 0x8
	.uleb128 0xc
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF905
	.byte	0x3
	.uleb128 0xb
	.uleb128 0xa
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF906
	.file 29 "../../drivers/common/opentimers.h"
	.byte	0x3
	.uleb128 0xb
	.uleb128 0x1d
	.byte	0x7
	.4byte	.Ldebug_macro19
	.byte	0x4
	.byte	0x7
	.4byte	.Ldebug_macro20
	.byte	0x4
	.byte	0x7
	.4byte	.Ldebug_macro21
	.byte	0x4
	.byte	0x3
	.uleb128 0x9
	.uleb128 0xe
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF962
	.byte	0x4
	.file 30 "C:\\Users\\16603\\Desktop\\HKUSTGZ\\IOTA5109-WSN\\openwsnProj\\mywsn\\openstack\\03b-IPv6\\icmpv6rpl.h"
	.byte	0x3
	.uleb128 0xa
	.uleb128 0x1e
	.byte	0x4
	.byte	0x3
	.uleb128 0xb
	.uleb128 0xf
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF963
	.byte	0x4
	.file 31 "../../bsp/boards/debugpins.h"
	.byte	0x3
	.uleb128 0xc
	.uleb128 0x1f
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF964
	.byte	0x4
	.file 32 "../../kernel/scheduler.h"
	.byte	0x3
	.uleb128 0xd
	.uleb128 0x20
	.byte	0x7
	.4byte	.Ldebug_macro22
	.file 33 "../../kernel/openos/scheduler_types.h"
	.byte	0x3
	.uleb128 0x3a
	.uleb128 0x21
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF967
	.byte	0x4
	.byte	0x4
	.byte	0x4
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.0.d1e83b79da16b575869668fdcb1062cf,comdat
.Ldebug_macro2:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0
	.4byte	.LASF0
	.byte	0x5
	.uleb128 0
	.4byte	.LASF1
	.byte	0x5
	.uleb128 0
	.4byte	.LASF2
	.byte	0x5
	.uleb128 0
	.4byte	.LASF3
	.byte	0x5
	.uleb128 0
	.4byte	.LASF4
	.byte	0x5
	.uleb128 0
	.4byte	.LASF5
	.byte	0x5
	.uleb128 0
	.4byte	.LASF6
	.byte	0x5
	.uleb128 0
	.4byte	.LASF7
	.byte	0x5
	.uleb128 0
	.4byte	.LASF8
	.byte	0x5
	.uleb128 0
	.4byte	.LASF9
	.byte	0x5
	.uleb128 0
	.4byte	.LASF10
	.byte	0x5
	.uleb128 0
	.4byte	.LASF11
	.byte	0x5
	.uleb128 0
	.4byte	.LASF12
	.byte	0x5
	.uleb128 0
	.4byte	.LASF13
	.byte	0x5
	.uleb128 0
	.4byte	.LASF14
	.byte	0x5
	.uleb128 0
	.4byte	.LASF15
	.byte	0x5
	.uleb128 0
	.4byte	.LASF16
	.byte	0x5
	.uleb128 0
	.4byte	.LASF17
	.byte	0x5
	.uleb128 0
	.4byte	.LASF18
	.byte	0x5
	.uleb128 0
	.4byte	.LASF19
	.byte	0x5
	.uleb128 0
	.4byte	.LASF20
	.byte	0x5
	.uleb128 0
	.4byte	.LASF21
	.byte	0x5
	.uleb128 0
	.4byte	.LASF22
	.byte	0x5
	.uleb128 0
	.4byte	.LASF23
	.byte	0x5
	.uleb128 0
	.4byte	.LASF24
	.byte	0x5
	.uleb128 0
	.4byte	.LASF25
	.byte	0x5
	.uleb128 0
	.4byte	.LASF26
	.byte	0x5
	.uleb128 0
	.4byte	.LASF27
	.byte	0x5
	.uleb128 0
	.4byte	.LASF28
	.byte	0x5
	.uleb128 0
	.4byte	.LASF29
	.byte	0x5
	.uleb128 0
	.4byte	.LASF30
	.byte	0x5
	.uleb128 0
	.4byte	.LASF31
	.byte	0x5
	.uleb128 0
	.4byte	.LASF32
	.byte	0x5
	.uleb128 0
	.4byte	.LASF33
	.byte	0x5
	.uleb128 0
	.4byte	.LASF34
	.byte	0x5
	.uleb128 0
	.4byte	.LASF35
	.byte	0x5
	.uleb128 0
	.4byte	.LASF36
	.byte	0x5
	.uleb128 0
	.4byte	.LASF37
	.byte	0x5
	.uleb128 0
	.4byte	.LASF38
	.byte	0x5
	.uleb128 0
	.4byte	.LASF39
	.byte	0x5
	.uleb128 0
	.4byte	.LASF40
	.byte	0x5
	.uleb128 0
	.4byte	.LASF41
	.byte	0x5
	.uleb128 0
	.4byte	.LASF42
	.byte	0x5
	.uleb128 0
	.4byte	.LASF43
	.byte	0x5
	.uleb128 0
	.4byte	.LASF44
	.byte	0x5
	.uleb128 0
	.4byte	.LASF45
	.byte	0x5
	.uleb128 0
	.4byte	.LASF46
	.byte	0x5
	.uleb128 0
	.4byte	.LASF47
	.byte	0x5
	.uleb128 0
	.4byte	.LASF48
	.byte	0x5
	.uleb128 0
	.4byte	.LASF49
	.byte	0x5
	.uleb128 0
	.4byte	.LASF50
	.byte	0x5
	.uleb128 0
	.4byte	.LASF51
	.byte	0x5
	.uleb128 0
	.4byte	.LASF52
	.byte	0x5
	.uleb128 0
	.4byte	.LASF53
	.byte	0x5
	.uleb128 0
	.4byte	.LASF54
	.byte	0x5
	.uleb128 0
	.4byte	.LASF55
	.byte	0x5
	.uleb128 0
	.4byte	.LASF56
	.byte	0x5
	.uleb128 0
	.4byte	.LASF57
	.byte	0x5
	.uleb128 0
	.4byte	.LASF58
	.byte	0x5
	.uleb128 0
	.4byte	.LASF59
	.byte	0x5
	.uleb128 0
	.4byte	.LASF60
	.byte	0x5
	.uleb128 0
	.4byte	.LASF61
	.byte	0x5
	.uleb128 0
	.4byte	.LASF62
	.byte	0x5
	.uleb128 0
	.4byte	.LASF63
	.byte	0x5
	.uleb128 0
	.4byte	.LASF64
	.byte	0x5
	.uleb128 0
	.4byte	.LASF65
	.byte	0x5
	.uleb128 0
	.4byte	.LASF66
	.byte	0x5
	.uleb128 0
	.4byte	.LASF67
	.byte	0x5
	.uleb128 0
	.4byte	.LASF68
	.byte	0x5
	.uleb128 0
	.4byte	.LASF69
	.byte	0x5
	.uleb128 0
	.4byte	.LASF70
	.byte	0x5
	.uleb128 0
	.4byte	.LASF71
	.byte	0x5
	.uleb128 0
	.4byte	.LASF72
	.byte	0x5
	.uleb128 0
	.4byte	.LASF73
	.byte	0x5
	.uleb128 0
	.4byte	.LASF74
	.byte	0x5
	.uleb128 0
	.4byte	.LASF75
	.byte	0x5
	.uleb128 0
	.4byte	.LASF76
	.byte	0x5
	.uleb128 0
	.4byte	.LASF77
	.byte	0x5
	.uleb128 0
	.4byte	.LASF78
	.byte	0x5
	.uleb128 0
	.4byte	.LASF79
	.byte	0x5
	.uleb128 0
	.4byte	.LASF80
	.byte	0x5
	.uleb128 0
	.4byte	.LASF81
	.byte	0x5
	.uleb128 0
	.4byte	.LASF82
	.byte	0x5
	.uleb128 0
	.4byte	.LASF83
	.byte	0x5
	.uleb128 0
	.4byte	.LASF84
	.byte	0x5
	.uleb128 0
	.4byte	.LASF85
	.byte	0x5
	.uleb128 0
	.4byte	.LASF86
	.byte	0x5
	.uleb128 0
	.4byte	.LASF87
	.byte	0x5
	.uleb128 0
	.4byte	.LASF88
	.byte	0x5
	.uleb128 0
	.4byte	.LASF89
	.byte	0x5
	.uleb128 0
	.4byte	.LASF90
	.byte	0x5
	.uleb128 0
	.4byte	.LASF91
	.byte	0x5
	.uleb128 0
	.4byte	.LASF92
	.byte	0x5
	.uleb128 0
	.4byte	.LASF93
	.byte	0x5
	.uleb128 0
	.4byte	.LASF94
	.byte	0x5
	.uleb128 0
	.4byte	.LASF95
	.byte	0x5
	.uleb128 0
	.4byte	.LASF96
	.byte	0x5
	.uleb128 0
	.4byte	.LASF97
	.byte	0x5
	.uleb128 0
	.4byte	.LASF98
	.byte	0x5
	.uleb128 0
	.4byte	.LASF99
	.byte	0x5
	.uleb128 0
	.4byte	.LASF100
	.byte	0x5
	.uleb128 0
	.4byte	.LASF101
	.byte	0x5
	.uleb128 0
	.4byte	.LASF102
	.byte	0x5
	.uleb128 0
	.4byte	.LASF103
	.byte	0x5
	.uleb128 0
	.4byte	.LASF104
	.byte	0x5
	.uleb128 0
	.4byte	.LASF105
	.byte	0x5
	.uleb128 0
	.4byte	.LASF106
	.byte	0x5
	.uleb128 0
	.4byte	.LASF107
	.byte	0x5
	.uleb128 0
	.4byte	.LASF108
	.byte	0x5
	.uleb128 0
	.4byte	.LASF109
	.byte	0x5
	.uleb128 0
	.4byte	.LASF110
	.byte	0x5
	.uleb128 0
	.4byte	.LASF111
	.byte	0x5
	.uleb128 0
	.4byte	.LASF112
	.byte	0x5
	.uleb128 0
	.4byte	.LASF113
	.byte	0x5
	.uleb128 0
	.4byte	.LASF114
	.byte	0x5
	.uleb128 0
	.4byte	.LASF115
	.byte	0x5
	.uleb128 0
	.4byte	.LASF116
	.byte	0x5
	.uleb128 0
	.4byte	.LASF117
	.byte	0x5
	.uleb128 0
	.4byte	.LASF118
	.byte	0x5
	.uleb128 0
	.4byte	.LASF119
	.byte	0x5
	.uleb128 0
	.4byte	.LASF120
	.byte	0x5
	.uleb128 0
	.4byte	.LASF121
	.byte	0x5
	.uleb128 0
	.4byte	.LASF122
	.byte	0x5
	.uleb128 0
	.4byte	.LASF123
	.byte	0x5
	.uleb128 0
	.4byte	.LASF124
	.byte	0x5
	.uleb128 0
	.4byte	.LASF125
	.byte	0x5
	.uleb128 0
	.4byte	.LASF126
	.byte	0x5
	.uleb128 0
	.4byte	.LASF127
	.byte	0x5
	.uleb128 0
	.4byte	.LASF128
	.byte	0x5
	.uleb128 0
	.4byte	.LASF129
	.byte	0x5
	.uleb128 0
	.4byte	.LASF130
	.byte	0x5
	.uleb128 0
	.4byte	.LASF131
	.byte	0x5
	.uleb128 0
	.4byte	.LASF132
	.byte	0x5
	.uleb128 0
	.4byte	.LASF133
	.byte	0x5
	.uleb128 0
	.4byte	.LASF134
	.byte	0x5
	.uleb128 0
	.4byte	.LASF135
	.byte	0x5
	.uleb128 0
	.4byte	.LASF136
	.byte	0x5
	.uleb128 0
	.4byte	.LASF137
	.byte	0x5
	.uleb128 0
	.4byte	.LASF138
	.byte	0x5
	.uleb128 0
	.4byte	.LASF139
	.byte	0x5
	.uleb128 0
	.4byte	.LASF140
	.byte	0x5
	.uleb128 0
	.4byte	.LASF141
	.byte	0x5
	.uleb128 0
	.4byte	.LASF142
	.byte	0x5
	.uleb128 0
	.4byte	.LASF143
	.byte	0x5
	.uleb128 0
	.4byte	.LASF144
	.byte	0x5
	.uleb128 0
	.4byte	.LASF145
	.byte	0x5
	.uleb128 0
	.4byte	.LASF146
	.byte	0x5
	.uleb128 0
	.4byte	.LASF147
	.byte	0x5
	.uleb128 0
	.4byte	.LASF148
	.byte	0x5
	.uleb128 0
	.4byte	.LASF149
	.byte	0x5
	.uleb128 0
	.4byte	.LASF150
	.byte	0x5
	.uleb128 0
	.4byte	.LASF151
	.byte	0x5
	.uleb128 0
	.4byte	.LASF152
	.byte	0x5
	.uleb128 0
	.4byte	.LASF153
	.byte	0x5
	.uleb128 0
	.4byte	.LASF154
	.byte	0x5
	.uleb128 0
	.4byte	.LASF155
	.byte	0x5
	.uleb128 0
	.4byte	.LASF156
	.byte	0x5
	.uleb128 0
	.4byte	.LASF157
	.byte	0x5
	.uleb128 0
	.4byte	.LASF158
	.byte	0x5
	.uleb128 0
	.4byte	.LASF159
	.byte	0x5
	.uleb128 0
	.4byte	.LASF160
	.byte	0x5
	.uleb128 0
	.4byte	.LASF161
	.byte	0x5
	.uleb128 0
	.4byte	.LASF162
	.byte	0x5
	.uleb128 0
	.4byte	.LASF163
	.byte	0x5
	.uleb128 0
	.4byte	.LASF164
	.byte	0x5
	.uleb128 0
	.4byte	.LASF165
	.byte	0x5
	.uleb128 0
	.4byte	.LASF166
	.byte	0x5
	.uleb128 0
	.4byte	.LASF167
	.byte	0x5
	.uleb128 0
	.4byte	.LASF168
	.byte	0x5
	.uleb128 0
	.4byte	.LASF169
	.byte	0x5
	.uleb128 0
	.4byte	.LASF170
	.byte	0x5
	.uleb128 0
	.4byte	.LASF171
	.byte	0x5
	.uleb128 0
	.4byte	.LASF172
	.byte	0x5
	.uleb128 0
	.4byte	.LASF173
	.byte	0x5
	.uleb128 0
	.4byte	.LASF174
	.byte	0x5
	.uleb128 0
	.4byte	.LASF175
	.byte	0x5
	.uleb128 0
	.4byte	.LASF176
	.byte	0x5
	.uleb128 0
	.4byte	.LASF177
	.byte	0x5
	.uleb128 0
	.4byte	.LASF178
	.byte	0x5
	.uleb128 0
	.4byte	.LASF179
	.byte	0x5
	.uleb128 0
	.4byte	.LASF180
	.byte	0x5
	.uleb128 0
	.4byte	.LASF181
	.byte	0x5
	.uleb128 0
	.4byte	.LASF182
	.byte	0x5
	.uleb128 0
	.4byte	.LASF183
	.byte	0x5
	.uleb128 0
	.4byte	.LASF184
	.byte	0x5
	.uleb128 0
	.4byte	.LASF185
	.byte	0x5
	.uleb128 0
	.4byte	.LASF186
	.byte	0x5
	.uleb128 0
	.4byte	.LASF187
	.byte	0x5
	.uleb128 0
	.4byte	.LASF188
	.byte	0x5
	.uleb128 0
	.4byte	.LASF189
	.byte	0x5
	.uleb128 0
	.4byte	.LASF190
	.byte	0x5
	.uleb128 0
	.4byte	.LASF191
	.byte	0x5
	.uleb128 0
	.4byte	.LASF192
	.byte	0x5
	.uleb128 0
	.4byte	.LASF193
	.byte	0x5
	.uleb128 0
	.4byte	.LASF194
	.byte	0x5
	.uleb128 0
	.4byte	.LASF195
	.byte	0x5
	.uleb128 0
	.4byte	.LASF196
	.byte	0x5
	.uleb128 0
	.4byte	.LASF197
	.byte	0x5
	.uleb128 0
	.4byte	.LASF198
	.byte	0x5
	.uleb128 0
	.4byte	.LASF199
	.byte	0x5
	.uleb128 0
	.4byte	.LASF200
	.byte	0x5
	.uleb128 0
	.4byte	.LASF201
	.byte	0x5
	.uleb128 0
	.4byte	.LASF202
	.byte	0x5
	.uleb128 0
	.4byte	.LASF203
	.byte	0x5
	.uleb128 0
	.4byte	.LASF204
	.byte	0x5
	.uleb128 0
	.4byte	.LASF205
	.byte	0x5
	.uleb128 0
	.4byte	.LASF206
	.byte	0x5
	.uleb128 0
	.4byte	.LASF207
	.byte	0x5
	.uleb128 0
	.4byte	.LASF208
	.byte	0x5
	.uleb128 0
	.4byte	.LASF209
	.byte	0x5
	.uleb128 0
	.4byte	.LASF210
	.byte	0x5
	.uleb128 0
	.4byte	.LASF211
	.byte	0x5
	.uleb128 0
	.4byte	.LASF212
	.byte	0x5
	.uleb128 0
	.4byte	.LASF213
	.byte	0x5
	.uleb128 0
	.4byte	.LASF214
	.byte	0x5
	.uleb128 0
	.4byte	.LASF215
	.byte	0x5
	.uleb128 0
	.4byte	.LASF216
	.byte	0x5
	.uleb128 0
	.4byte	.LASF217
	.byte	0x5
	.uleb128 0
	.4byte	.LASF218
	.byte	0x5
	.uleb128 0
	.4byte	.LASF219
	.byte	0x5
	.uleb128 0
	.4byte	.LASF220
	.byte	0x5
	.uleb128 0
	.4byte	.LASF221
	.byte	0x5
	.uleb128 0
	.4byte	.LASF222
	.byte	0x5
	.uleb128 0
	.4byte	.LASF223
	.byte	0x5
	.uleb128 0
	.4byte	.LASF224
	.byte	0x5
	.uleb128 0
	.4byte	.LASF225
	.byte	0x5
	.uleb128 0
	.4byte	.LASF226
	.byte	0x5
	.uleb128 0
	.4byte	.LASF227
	.byte	0x5
	.uleb128 0
	.4byte	.LASF228
	.byte	0x5
	.uleb128 0
	.4byte	.LASF229
	.byte	0x5
	.uleb128 0
	.4byte	.LASF230
	.byte	0x5
	.uleb128 0
	.4byte	.LASF231
	.byte	0x5
	.uleb128 0
	.4byte	.LASF232
	.byte	0x5
	.uleb128 0
	.4byte	.LASF233
	.byte	0x5
	.uleb128 0
	.4byte	.LASF234
	.byte	0x5
	.uleb128 0
	.4byte	.LASF235
	.byte	0x5
	.uleb128 0
	.4byte	.LASF236
	.byte	0x5
	.uleb128 0
	.4byte	.LASF237
	.byte	0x5
	.uleb128 0
	.4byte	.LASF238
	.byte	0x5
	.uleb128 0
	.4byte	.LASF239
	.byte	0x5
	.uleb128 0
	.4byte	.LASF240
	.byte	0x5
	.uleb128 0
	.4byte	.LASF241
	.byte	0x5
	.uleb128 0
	.4byte	.LASF242
	.byte	0x5
	.uleb128 0
	.4byte	.LASF243
	.byte	0x5
	.uleb128 0
	.4byte	.LASF244
	.byte	0x5
	.uleb128 0
	.4byte	.LASF245
	.byte	0x5
	.uleb128 0
	.4byte	.LASF246
	.byte	0x5
	.uleb128 0
	.4byte	.LASF247
	.byte	0x5
	.uleb128 0
	.4byte	.LASF248
	.byte	0x5
	.uleb128 0
	.4byte	.LASF249
	.byte	0x5
	.uleb128 0
	.4byte	.LASF250
	.byte	0x5
	.uleb128 0
	.4byte	.LASF251
	.byte	0x5
	.uleb128 0
	.4byte	.LASF252
	.byte	0x5
	.uleb128 0
	.4byte	.LASF253
	.byte	0x5
	.uleb128 0
	.4byte	.LASF254
	.byte	0x5
	.uleb128 0
	.4byte	.LASF255
	.byte	0x5
	.uleb128 0
	.4byte	.LASF256
	.byte	0x5
	.uleb128 0
	.4byte	.LASF257
	.byte	0x5
	.uleb128 0
	.4byte	.LASF258
	.byte	0x5
	.uleb128 0
	.4byte	.LASF259
	.byte	0x5
	.uleb128 0
	.4byte	.LASF260
	.byte	0x5
	.uleb128 0
	.4byte	.LASF261
	.byte	0x5
	.uleb128 0
	.4byte	.LASF262
	.byte	0x5
	.uleb128 0
	.4byte	.LASF263
	.byte	0x5
	.uleb128 0
	.4byte	.LASF264
	.byte	0x5
	.uleb128 0
	.4byte	.LASF265
	.byte	0x5
	.uleb128 0
	.4byte	.LASF266
	.byte	0x5
	.uleb128 0
	.4byte	.LASF267
	.byte	0x5
	.uleb128 0
	.4byte	.LASF268
	.byte	0x5
	.uleb128 0
	.4byte	.LASF269
	.byte	0x5
	.uleb128 0
	.4byte	.LASF270
	.byte	0x5
	.uleb128 0
	.4byte	.LASF271
	.byte	0x5
	.uleb128 0
	.4byte	.LASF272
	.byte	0x5
	.uleb128 0
	.4byte	.LASF273
	.byte	0x5
	.uleb128 0
	.4byte	.LASF274
	.byte	0x5
	.uleb128 0
	.4byte	.LASF275
	.byte	0x5
	.uleb128 0
	.4byte	.LASF276
	.byte	0x5
	.uleb128 0
	.4byte	.LASF277
	.byte	0x5
	.uleb128 0
	.4byte	.LASF278
	.byte	0x5
	.uleb128 0
	.4byte	.LASF279
	.byte	0x5
	.uleb128 0
	.4byte	.LASF280
	.byte	0x5
	.uleb128 0
	.4byte	.LASF281
	.byte	0x5
	.uleb128 0
	.4byte	.LASF282
	.byte	0x5
	.uleb128 0
	.4byte	.LASF283
	.byte	0x5
	.uleb128 0
	.4byte	.LASF284
	.byte	0x5
	.uleb128 0
	.4byte	.LASF285
	.byte	0x5
	.uleb128 0
	.4byte	.LASF286
	.byte	0x5
	.uleb128 0
	.4byte	.LASF287
	.byte	0x5
	.uleb128 0
	.4byte	.LASF288
	.byte	0x5
	.uleb128 0
	.4byte	.LASF289
	.byte	0x5
	.uleb128 0
	.4byte	.LASF290
	.byte	0x5
	.uleb128 0
	.4byte	.LASF291
	.byte	0x5
	.uleb128 0
	.4byte	.LASF292
	.byte	0x5
	.uleb128 0
	.4byte	.LASF293
	.byte	0x5
	.uleb128 0
	.4byte	.LASF294
	.byte	0x5
	.uleb128 0
	.4byte	.LASF295
	.byte	0x5
	.uleb128 0
	.4byte	.LASF296
	.byte	0x5
	.uleb128 0
	.4byte	.LASF297
	.byte	0x5
	.uleb128 0
	.4byte	.LASF298
	.byte	0x5
	.uleb128 0
	.4byte	.LASF299
	.byte	0x5
	.uleb128 0
	.4byte	.LASF300
	.byte	0x5
	.uleb128 0
	.4byte	.LASF301
	.byte	0x5
	.uleb128 0
	.4byte	.LASF302
	.byte	0x5
	.uleb128 0
	.4byte	.LASF303
	.byte	0x5
	.uleb128 0
	.4byte	.LASF304
	.byte	0x5
	.uleb128 0
	.4byte	.LASF305
	.byte	0x5
	.uleb128 0
	.4byte	.LASF306
	.byte	0x5
	.uleb128 0
	.4byte	.LASF307
	.byte	0x5
	.uleb128 0
	.4byte	.LASF308
	.byte	0x5
	.uleb128 0
	.4byte	.LASF309
	.byte	0x5
	.uleb128 0
	.4byte	.LASF310
	.byte	0x5
	.uleb128 0
	.4byte	.LASF311
	.byte	0x5
	.uleb128 0
	.4byte	.LASF312
	.byte	0x5
	.uleb128 0
	.4byte	.LASF313
	.byte	0x5
	.uleb128 0
	.4byte	.LASF314
	.byte	0x5
	.uleb128 0
	.4byte	.LASF315
	.byte	0x5
	.uleb128 0
	.4byte	.LASF316
	.byte	0x5
	.uleb128 0
	.4byte	.LASF317
	.byte	0x5
	.uleb128 0
	.4byte	.LASF318
	.byte	0x5
	.uleb128 0
	.4byte	.LASF319
	.byte	0x5
	.uleb128 0
	.4byte	.LASF320
	.byte	0x5
	.uleb128 0
	.4byte	.LASF321
	.byte	0x5
	.uleb128 0
	.4byte	.LASF322
	.byte	0x5
	.uleb128 0
	.4byte	.LASF323
	.byte	0x5
	.uleb128 0
	.4byte	.LASF324
	.byte	0x5
	.uleb128 0
	.4byte	.LASF325
	.byte	0x5
	.uleb128 0
	.4byte	.LASF326
	.byte	0x5
	.uleb128 0
	.4byte	.LASF327
	.byte	0x5
	.uleb128 0
	.4byte	.LASF328
	.byte	0x5
	.uleb128 0
	.4byte	.LASF329
	.byte	0x5
	.uleb128 0
	.4byte	.LASF330
	.byte	0x5
	.uleb128 0
	.4byte	.LASF331
	.byte	0x5
	.uleb128 0
	.4byte	.LASF332
	.byte	0x5
	.uleb128 0
	.4byte	.LASF333
	.byte	0x5
	.uleb128 0
	.4byte	.LASF334
	.byte	0x5
	.uleb128 0
	.4byte	.LASF335
	.byte	0x5
	.uleb128 0
	.4byte	.LASF336
	.byte	0x5
	.uleb128 0
	.4byte	.LASF337
	.byte	0x5
	.uleb128 0
	.4byte	.LASF338
	.byte	0x5
	.uleb128 0
	.4byte	.LASF339
	.byte	0x5
	.uleb128 0
	.4byte	.LASF340
	.byte	0x5
	.uleb128 0
	.4byte	.LASF341
	.byte	0x5
	.uleb128 0
	.4byte	.LASF342
	.byte	0x5
	.uleb128 0
	.4byte	.LASF343
	.byte	0x5
	.uleb128 0
	.4byte	.LASF344
	.byte	0x5
	.uleb128 0
	.4byte	.LASF345
	.byte	0x5
	.uleb128 0
	.4byte	.LASF346
	.byte	0x5
	.uleb128 0
	.4byte	.LASF347
	.byte	0x5
	.uleb128 0
	.4byte	.LASF348
	.byte	0x5
	.uleb128 0
	.4byte	.LASF349
	.byte	0x5
	.uleb128 0
	.4byte	.LASF350
	.byte	0x5
	.uleb128 0
	.4byte	.LASF351
	.byte	0x5
	.uleb128 0
	.4byte	.LASF352
	.byte	0x5
	.uleb128 0
	.4byte	.LASF353
	.byte	0x5
	.uleb128 0
	.4byte	.LASF354
	.byte	0x5
	.uleb128 0
	.4byte	.LASF355
	.byte	0x5
	.uleb128 0
	.4byte	.LASF356
	.byte	0x5
	.uleb128 0
	.4byte	.LASF357
	.byte	0x5
	.uleb128 0
	.4byte	.LASF358
	.byte	0x5
	.uleb128 0
	.4byte	.LASF359
	.byte	0x5
	.uleb128 0
	.4byte	.LASF360
	.byte	0x5
	.uleb128 0
	.4byte	.LASF361
	.byte	0x5
	.uleb128 0
	.4byte	.LASF362
	.byte	0x5
	.uleb128 0
	.4byte	.LASF363
	.byte	0x5
	.uleb128 0
	.4byte	.LASF364
	.byte	0x5
	.uleb128 0
	.4byte	.LASF365
	.byte	0x5
	.uleb128 0
	.4byte	.LASF366
	.byte	0x5
	.uleb128 0
	.4byte	.LASF367
	.byte	0x5
	.uleb128 0
	.4byte	.LASF368
	.byte	0x5
	.uleb128 0
	.4byte	.LASF369
	.byte	0x5
	.uleb128 0
	.4byte	.LASF370
	.byte	0x5
	.uleb128 0
	.4byte	.LASF371
	.byte	0x5
	.uleb128 0
	.4byte	.LASF372
	.byte	0x5
	.uleb128 0
	.4byte	.LASF373
	.byte	0x5
	.uleb128 0
	.4byte	.LASF374
	.byte	0x5
	.uleb128 0
	.4byte	.LASF375
	.byte	0x5
	.uleb128 0
	.4byte	.LASF376
	.byte	0x5
	.uleb128 0
	.4byte	.LASF377
	.byte	0x5
	.uleb128 0
	.4byte	.LASF378
	.byte	0x5
	.uleb128 0
	.4byte	.LASF379
	.byte	0x5
	.uleb128 0
	.4byte	.LASF380
	.byte	0x5
	.uleb128 0
	.4byte	.LASF381
	.byte	0x5
	.uleb128 0
	.4byte	.LASF382
	.byte	0x5
	.uleb128 0
	.4byte	.LASF383
	.byte	0x5
	.uleb128 0
	.4byte	.LASF384
	.byte	0x5
	.uleb128 0
	.4byte	.LASF385
	.byte	0x5
	.uleb128 0
	.4byte	.LASF386
	.byte	0x5
	.uleb128 0
	.4byte	.LASF387
	.byte	0x5
	.uleb128 0
	.4byte	.LASF388
	.byte	0x5
	.uleb128 0
	.4byte	.LASF389
	.byte	0x5
	.uleb128 0
	.4byte	.LASF390
	.byte	0x5
	.uleb128 0
	.4byte	.LASF391
	.byte	0x5
	.uleb128 0
	.4byte	.LASF392
	.byte	0x5
	.uleb128 0
	.4byte	.LASF393
	.byte	0x5
	.uleb128 0
	.4byte	.LASF394
	.byte	0x5
	.uleb128 0
	.4byte	.LASF395
	.byte	0x5
	.uleb128 0
	.4byte	.LASF396
	.byte	0x5
	.uleb128 0
	.4byte	.LASF397
	.byte	0x5
	.uleb128 0
	.4byte	.LASF398
	.byte	0x5
	.uleb128 0
	.4byte	.LASF399
	.byte	0x5
	.uleb128 0
	.4byte	.LASF400
	.byte	0x5
	.uleb128 0
	.4byte	.LASF401
	.byte	0x5
	.uleb128 0
	.4byte	.LASF402
	.byte	0x5
	.uleb128 0
	.4byte	.LASF403
	.byte	0x5
	.uleb128 0
	.4byte	.LASF404
	.byte	0x6
	.uleb128 0
	.4byte	.LASF405
	.byte	0x5
	.uleb128 0
	.4byte	.LASF406
	.byte	0x6
	.uleb128 0
	.4byte	.LASF407
	.byte	0x6
	.uleb128 0
	.4byte	.LASF408
	.byte	0x6
	.uleb128 0
	.4byte	.LASF409
	.byte	0x6
	.uleb128 0
	.4byte	.LASF410
	.byte	0x5
	.uleb128 0
	.4byte	.LASF411
	.byte	0x6
	.uleb128 0
	.4byte	.LASF412
	.byte	0x6
	.uleb128 0
	.4byte	.LASF413
	.byte	0x6
	.uleb128 0
	.4byte	.LASF414
	.byte	0x5
	.uleb128 0
	.4byte	.LASF415
	.byte	0x5
	.uleb128 0
	.4byte	.LASF416
	.byte	0x6
	.uleb128 0
	.4byte	.LASF417
	.byte	0x5
	.uleb128 0
	.4byte	.LASF418
	.byte	0x5
	.uleb128 0
	.4byte	.LASF419
	.byte	0x5
	.uleb128 0
	.4byte	.LASF420
	.byte	0x6
	.uleb128 0
	.4byte	.LASF421
	.byte	0x5
	.uleb128 0
	.4byte	.LASF422
	.byte	0x5
	.uleb128 0
	.4byte	.LASF423
	.byte	0x6
	.uleb128 0
	.4byte	.LASF424
	.byte	0x5
	.uleb128 0
	.4byte	.LASF425
	.byte	0x5
	.uleb128 0
	.4byte	.LASF426
	.byte	0x5
	.uleb128 0
	.4byte	.LASF427
	.byte	0x5
	.uleb128 0
	.4byte	.LASF428
	.byte	0x5
	.uleb128 0
	.4byte	.LASF429
	.byte	0x5
	.uleb128 0
	.4byte	.LASF430
	.byte	0x6
	.uleb128 0
	.4byte	.LASF431
	.byte	0x5
	.uleb128 0
	.4byte	.LASF432
	.byte	0x5
	.uleb128 0
	.4byte	.LASF433
	.byte	0x5
	.uleb128 0
	.4byte	.LASF434
	.byte	0x6
	.uleb128 0
	.4byte	.LASF435
	.byte	0x5
	.uleb128 0
	.4byte	.LASF436
	.byte	0x5
	.uleb128 0
	.4byte	.LASF437
	.byte	0x6
	.uleb128 0
	.4byte	.LASF438
	.byte	0x5
	.uleb128 0
	.4byte	.LASF439
	.byte	0x6
	.uleb128 0
	.4byte	.LASF440
	.byte	0x6
	.uleb128 0
	.4byte	.LASF441
	.byte	0x6
	.uleb128 0
	.4byte	.LASF442
	.byte	0x5
	.uleb128 0
	.4byte	.LASF443
	.byte	0x6
	.uleb128 0
	.4byte	.LASF444
	.byte	0x6
	.uleb128 0
	.4byte	.LASF445
	.byte	0x6
	.uleb128 0
	.4byte	.LASF446
	.byte	0x5
	.uleb128 0
	.4byte	.LASF447
	.byte	0x5
	.uleb128 0
	.4byte	.LASF448
	.byte	0x5
	.uleb128 0
	.4byte	.LASF449
	.byte	0x5
	.uleb128 0
	.4byte	.LASF450
	.byte	0x6
	.uleb128 0
	.4byte	.LASF451
	.byte	0x5
	.uleb128 0
	.4byte	.LASF452
	.byte	0x5
	.uleb128 0
	.4byte	.LASF453
	.byte	0x5
	.uleb128 0
	.4byte	.LASF454
	.byte	0x6
	.uleb128 0
	.4byte	.LASF455
	.byte	0x5
	.uleb128 0
	.4byte	.LASF456
	.byte	0x6
	.uleb128 0
	.4byte	.LASF457
	.byte	0x6
	.uleb128 0
	.4byte	.LASF458
	.byte	0x6
	.uleb128 0
	.4byte	.LASF459
	.byte	0x6
	.uleb128 0
	.4byte	.LASF460
	.byte	0x6
	.uleb128 0
	.4byte	.LASF461
	.byte	0x6
	.uleb128 0
	.4byte	.LASF462
	.byte	0x5
	.uleb128 0
	.4byte	.LASF463
	.byte	0x5
	.uleb128 0
	.4byte	.LASF464
	.byte	0x5
	.uleb128 0
	.4byte	.LASF465
	.byte	0x5
	.uleb128 0
	.4byte	.LASF448
	.byte	0x5
	.uleb128 0
	.4byte	.LASF466
	.byte	0x5
	.uleb128 0
	.4byte	.LASF467
	.byte	0x5
	.uleb128 0
	.4byte	.LASF468
	.byte	0x5
	.uleb128 0
	.4byte	.LASF469
	.byte	0x5
	.uleb128 0
	.4byte	.LASF470
	.byte	0x5
	.uleb128 0
	.4byte	.LASF471
	.byte	0x5
	.uleb128 0
	.4byte	.LASF472
	.byte	0x5
	.uleb128 0
	.4byte	.LASF473
	.byte	0x5
	.uleb128 0
	.4byte	.LASF474
	.byte	0x5
	.uleb128 0
	.4byte	.LASF475
	.byte	0x5
	.uleb128 0
	.4byte	.LASF476
	.byte	0x5
	.uleb128 0
	.4byte	.LASF477
	.byte	0x5
	.uleb128 0
	.4byte	.LASF478
	.byte	0x5
	.uleb128 0
	.4byte	.LASF479
	.byte	0x5
	.uleb128 0
	.4byte	.LASF480
	.byte	0x5
	.uleb128 0
	.4byte	.LASF481
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.__SEGGER_RTL_Arm_Conf.h.11.07484ddfe2bfa2dc5a9595d705212976,comdat
.Ldebug_macro3:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0xb
	.4byte	.LASF489
	.byte	0x5
	.uleb128 0x27
	.4byte	.LASF490
	.byte	0x5
	.uleb128 0x28
	.4byte	.LASF491
	.byte	0x5
	.uleb128 0x29
	.4byte	.LASF492
	.byte	0x5
	.uleb128 0x36
	.4byte	.LASF493
	.byte	0x5
	.uleb128 0x3e
	.4byte	.LASF494
	.byte	0x5
	.uleb128 0x46
	.4byte	.LASF495
	.byte	0x5
	.uleb128 0x51
	.4byte	.LASF496
	.byte	0x5
	.uleb128 0x59
	.4byte	.LASF497
	.byte	0x5
	.uleb128 0x5f
	.4byte	.LASF498
	.byte	0x5
	.uleb128 0x67
	.4byte	.LASF499
	.byte	0x5
	.uleb128 0x6e
	.4byte	.LASF500
	.byte	0x5
	.uleb128 0x76
	.4byte	.LASF501
	.byte	0x5
	.uleb128 0x77
	.4byte	.LASF502
	.byte	0x5
	.uleb128 0x7e
	.4byte	.LASF503
	.byte	0x5
	.uleb128 0x84
	.4byte	.LASF504
	.byte	0x5
	.uleb128 0x8f
	.4byte	.LASF505
	.byte	0x5
	.uleb128 0xa1
	.4byte	.LASF506
	.byte	0x5
	.uleb128 0xbb
	.4byte	.LASF507
	.byte	0x5
	.uleb128 0xc2
	.4byte	.LASF508
	.byte	0x5
	.uleb128 0xcb
	.4byte	.LASF509
	.byte	0x5
	.uleb128 0xef
	.4byte	.LASF510
	.byte	0x5
	.uleb128 0x115
	.4byte	.LASF511
	.byte	0x5
	.uleb128 0x11e
	.4byte	.LASF512
	.byte	0x5
	.uleb128 0x125
	.4byte	.LASF513
	.byte	0x5
	.uleb128 0x12c
	.4byte	.LASF514
	.byte	0x5
	.uleb128 0x134
	.4byte	.LASF515
	.byte	0x5
	.uleb128 0x13c
	.4byte	.LASF516
	.byte	0x5
	.uleb128 0x14a
	.4byte	.LASF517
	.byte	0x5
	.uleb128 0x157
	.4byte	.LASF518
	.byte	0x5
	.uleb128 0x158
	.4byte	.LASF519
	.byte	0x5
	.uleb128 0x15f
	.4byte	.LASF520
	.byte	0x5
	.uleb128 0x16d
	.4byte	.LASF521
	.byte	0x5
	.uleb128 0x172
	.4byte	.LASF522
	.byte	0x5
	.uleb128 0x176
	.4byte	.LASF523
	.byte	0x5
	.uleb128 0x17f
	.4byte	.LASF524
	.byte	0x5
	.uleb128 0x187
	.4byte	.LASF525
	.byte	0x5
	.uleb128 0x19d
	.4byte	.LASF526
	.byte	0x5
	.uleb128 0x1b5
	.4byte	.LASF527
	.byte	0x5
	.uleb128 0x1da
	.4byte	.LASF528
	.byte	0x5
	.uleb128 0x201
	.4byte	.LASF529
	.byte	0x5
	.uleb128 0x207
	.4byte	.LASF530
	.byte	0x5
	.uleb128 0x20d
	.4byte	.LASF531
	.byte	0x5
	.uleb128 0x213
	.4byte	.LASF532
	.byte	0x5
	.uleb128 0x219
	.4byte	.LASF533
	.byte	0x5
	.uleb128 0x21f
	.4byte	.LASF534
	.byte	0x5
	.uleb128 0x225
	.4byte	.LASF535
	.byte	0x5
	.uleb128 0x22b
	.4byte	.LASF536
	.byte	0x5
	.uleb128 0x231
	.4byte	.LASF537
	.byte	0x5
	.uleb128 0x237
	.4byte	.LASF538
	.byte	0x5
	.uleb128 0x23d
	.4byte	.LASF539
	.byte	0x5
	.uleb128 0x243
	.4byte	.LASF540
	.byte	0x5
	.uleb128 0x249
	.4byte	.LASF541
	.byte	0x5
	.uleb128 0x250
	.4byte	.LASF542
	.byte	0x5
	.uleb128 0x255
	.4byte	.LASF543
	.byte	0x5
	.uleb128 0x25d
	.4byte	.LASF544
	.byte	0x5
	.uleb128 0x260
	.4byte	.LASF545
	.byte	0x5
	.uleb128 0x263
	.4byte	.LASF546
	.byte	0x5
	.uleb128 0x268
	.4byte	.LASF547
	.byte	0x5
	.uleb128 0x26f
	.4byte	.LASF548
	.byte	0x5
	.uleb128 0x275
	.4byte	.LASF549
	.byte	0x5
	.uleb128 0x27a
	.4byte	.LASF550
	.byte	0x5
	.uleb128 0x280
	.4byte	.LASF551
	.byte	0x5
	.uleb128 0x281
	.4byte	.LASF552
	.byte	0x5
	.uleb128 0x288
	.4byte	.LASF553
	.byte	0x5
	.uleb128 0x289
	.4byte	.LASF554
	.byte	0x5
	.uleb128 0x28a
	.4byte	.LASF555
	.byte	0x5
	.uleb128 0x28f
	.4byte	.LASF556
	.byte	0x5
	.uleb128 0x290
	.4byte	.LASF557
	.byte	0x5
	.uleb128 0x291
	.4byte	.LASF558
	.byte	0x5
	.uleb128 0x292
	.4byte	.LASF559
	.byte	0x5
	.uleb128 0x293
	.4byte	.LASF560
	.byte	0x5
	.uleb128 0x294
	.4byte	.LASF561
	.byte	0x5
	.uleb128 0x295
	.4byte	.LASF562
	.byte	0x5
	.uleb128 0x296
	.4byte	.LASF563
	.byte	0x5
	.uleb128 0x297
	.4byte	.LASF564
	.byte	0x5
	.uleb128 0x298
	.4byte	.LASF565
	.byte	0x5
	.uleb128 0x299
	.4byte	.LASF566
	.byte	0x5
	.uleb128 0x355
	.4byte	.LASF567
	.byte	0x5
	.uleb128 0x364
	.4byte	.LASF568
	.byte	0x5
	.uleb128 0x365
	.4byte	.LASF569
	.byte	0x5
	.uleb128 0x366
	.4byte	.LASF570
	.byte	0x5
	.uleb128 0x367
	.4byte	.LASF571
	.byte	0x5
	.uleb128 0x368
	.4byte	.LASF572
	.byte	0x5
	.uleb128 0x369
	.4byte	.LASF573
	.byte	0x5
	.uleb128 0x36b
	.4byte	.LASF574
	.byte	0x5
	.uleb128 0x36c
	.4byte	.LASF575
	.byte	0x5
	.uleb128 0x36d
	.4byte	.LASF576
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.__SEGGER_RTL_ConfDefaults.h.22.24d3414578738a0ad260ab85a6e5bd10,comdat
.Ldebug_macro4:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x16
	.4byte	.LASF577
	.byte	0x5
	.uleb128 0x17
	.4byte	.LASF578
	.byte	0x5
	.uleb128 0x18
	.4byte	.LASF579
	.byte	0x5
	.uleb128 0x1a
	.4byte	.LASF580
	.byte	0x5
	.uleb128 0x1b
	.4byte	.LASF581
	.byte	0x5
	.uleb128 0x1c
	.4byte	.LASF582
	.byte	0x5
	.uleb128 0x1e
	.4byte	.LASF583
	.byte	0x5
	.uleb128 0x1f
	.4byte	.LASF584
	.byte	0x5
	.uleb128 0x20
	.4byte	.LASF585
	.byte	0x5
	.uleb128 0x2d
	.4byte	.LASF586
	.byte	0x5
	.uleb128 0x31
	.4byte	.LASF587
	.byte	0x5
	.uleb128 0x35
	.4byte	.LASF588
	.byte	0x5
	.uleb128 0x3d
	.4byte	.LASF589
	.byte	0x5
	.uleb128 0x45
	.4byte	.LASF590
	.byte	0x5
	.uleb128 0x49
	.4byte	.LASF591
	.byte	0x5
	.uleb128 0x75
	.4byte	.LASF592
	.byte	0x5
	.uleb128 0x76
	.4byte	.LASF593
	.byte	0x5
	.uleb128 0x77
	.4byte	.LASF594
	.byte	0x5
	.uleb128 0x78
	.4byte	.LASF595
	.byte	0x5
	.uleb128 0x79
	.4byte	.LASF596
	.byte	0x5
	.uleb128 0x7a
	.4byte	.LASF597
	.byte	0x5
	.uleb128 0x7b
	.4byte	.LASF598
	.byte	0x5
	.uleb128 0x7c
	.4byte	.LASF599
	.byte	0x5
	.uleb128 0x7d
	.4byte	.LASF600
	.byte	0x5
	.uleb128 0x7e
	.4byte	.LASF601
	.byte	0x5
	.uleb128 0x7f
	.4byte	.LASF602
	.byte	0x5
	.uleb128 0x80
	.4byte	.LASF603
	.byte	0x5
	.uleb128 0x81
	.4byte	.LASF604
	.byte	0x5
	.uleb128 0x82
	.4byte	.LASF605
	.byte	0x5
	.uleb128 0x83
	.4byte	.LASF606
	.byte	0x5
	.uleb128 0x84
	.4byte	.LASF607
	.byte	0x5
	.uleb128 0x85
	.4byte	.LASF608
	.byte	0x5
	.uleb128 0x87
	.4byte	.LASF609
	.byte	0x5
	.uleb128 0x88
	.4byte	.LASF610
	.byte	0x5
	.uleb128 0x89
	.4byte	.LASF611
	.byte	0x5
	.uleb128 0x8c
	.4byte	.LASF612
	.byte	0x5
	.uleb128 0x8d
	.4byte	.LASF613
	.byte	0x5
	.uleb128 0x8e
	.4byte	.LASF614
	.byte	0x5
	.uleb128 0x8f
	.4byte	.LASF615
	.byte	0x5
	.uleb128 0x90
	.4byte	.LASF616
	.byte	0x5
	.uleb128 0xca
	.4byte	.LASF617
	.byte	0x5
	.uleb128 0xd4
	.4byte	.LASF618
	.byte	0x5
	.uleb128 0xd8
	.4byte	.LASF619
	.byte	0x5
	.uleb128 0xdc
	.4byte	.LASF620
	.byte	0x5
	.uleb128 0xe0
	.4byte	.LASF621
	.byte	0x5
	.uleb128 0xe4
	.4byte	.LASF622
	.byte	0x5
	.uleb128 0xe8
	.4byte	.LASF623
	.byte	0x6
	.uleb128 0xec
	.4byte	.LASF624
	.byte	0x5
	.uleb128 0xed
	.4byte	.LASF619
	.byte	0x6
	.uleb128 0xee
	.4byte	.LASF625
	.byte	0x5
	.uleb128 0xef
	.4byte	.LASF622
	.byte	0x5
	.uleb128 0xf3
	.4byte	.LASF626
	.byte	0x5
	.uleb128 0xf7
	.4byte	.LASF627
	.byte	0x5
	.uleb128 0xfb
	.4byte	.LASF628
	.byte	0x5
	.uleb128 0xff
	.4byte	.LASF629
	.byte	0x5
	.uleb128 0x107
	.4byte	.LASF630
	.byte	0x5
	.uleb128 0x10b
	.4byte	.LASF631
	.byte	0x5
	.uleb128 0x12b
	.4byte	.LASF632
	.byte	0x5
	.uleb128 0x146
	.4byte	.LASF633
	.byte	0x5
	.uleb128 0x14e
	.4byte	.LASF634
	.byte	0x5
	.uleb128 0x156
	.4byte	.LASF635
	.byte	0x5
	.uleb128 0x15e
	.4byte	.LASF636
	.byte	0x5
	.uleb128 0x163
	.4byte	.LASF637
	.byte	0x5
	.uleb128 0x164
	.4byte	.LASF638
	.byte	0x5
	.uleb128 0x18f
	.4byte	.LASF639
	.byte	0x5
	.uleb128 0x193
	.4byte	.LASF640
	.byte	0x5
	.uleb128 0x1a6
	.4byte	.LASF641
	.byte	0x5
	.uleb128 0x1b8
	.4byte	.LASF642
	.byte	0x5
	.uleb128 0x1bc
	.4byte	.LASF643
	.byte	0x5
	.uleb128 0x1c0
	.4byte	.LASF644
	.byte	0x5
	.uleb128 0x1c4
	.4byte	.LASF645
	.byte	0x5
	.uleb128 0x1d1
	.4byte	.LASF646
	.byte	0x5
	.uleb128 0x1d2
	.4byte	.LASF647
	.byte	0x5
	.uleb128 0x1da
	.4byte	.LASF648
	.byte	0x5
	.uleb128 0x1de
	.4byte	.LASF649
	.byte	0x5
	.uleb128 0x1e2
	.4byte	.LASF650
	.byte	0x5
	.uleb128 0x1e5
	.4byte	.LASF651
	.byte	0x5
	.uleb128 0x1e8
	.4byte	.LASF652
	.byte	0x5
	.uleb128 0x1eb
	.4byte	.LASF653
	.byte	0x5
	.uleb128 0x1ee
	.4byte	.LASF654
	.byte	0x5
	.uleb128 0x206
	.4byte	.LASF655
	.byte	0x5
	.uleb128 0x20a
	.4byte	.LASF656
	.byte	0x5
	.uleb128 0x20e
	.4byte	.LASF657
	.byte	0x5
	.uleb128 0x212
	.4byte	.LASF658
	.byte	0x5
	.uleb128 0x222
	.4byte	.LASF659
	.byte	0x5
	.uleb128 0x227
	.4byte	.LASF660
	.byte	0x5
	.uleb128 0x22c
	.4byte	.LASF661
	.byte	0x5
	.uleb128 0x22d
	.4byte	.LASF662
	.byte	0x5
	.uleb128 0x238
	.4byte	.LASF663
	.byte	0x5
	.uleb128 0x23c
	.4byte	.LASF664
	.byte	0x5
	.uleb128 0x240
	.4byte	.LASF665
	.byte	0x5
	.uleb128 0x244
	.4byte	.LASF666
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.__SEGGER_RTL.h.26.dafde22208ccda87397994258692170b,comdat
.Ldebug_macro5:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x1a
	.4byte	.LASF667
	.byte	0x5
	.uleb128 0x1b
	.4byte	.LASF668
	.byte	0x5
	.uleb128 0x25
	.4byte	.LASF669
	.byte	0x5
	.uleb128 0x29
	.4byte	.LASF670
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.stdint.h.36.e38343cc32f8e399448e748c7ba81875,comdat
.Ldebug_macro6:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x24
	.4byte	.LASF671
	.byte	0x5
	.uleb128 0x25
	.4byte	.LASF672
	.byte	0x5
	.uleb128 0x26
	.4byte	.LASF673
	.byte	0x5
	.uleb128 0x27
	.4byte	.LASF674
	.byte	0x5
	.uleb128 0x28
	.4byte	.LASF675
	.byte	0x5
	.uleb128 0x29
	.4byte	.LASF676
	.byte	0x5
	.uleb128 0x2a
	.4byte	.LASF677
	.byte	0x5
	.uleb128 0x2b
	.4byte	.LASF678
	.byte	0x5
	.uleb128 0x34
	.4byte	.LASF679
	.byte	0x5
	.uleb128 0x35
	.4byte	.LASF680
	.byte	0x5
	.uleb128 0x36
	.4byte	.LASF681
	.byte	0x5
	.uleb128 0x37
	.4byte	.LASF682
	.byte	0x5
	.uleb128 0x41
	.4byte	.LASF683
	.byte	0x5
	.uleb128 0x42
	.4byte	.LASF684
	.byte	0x5
	.uleb128 0x43
	.4byte	.LASF685
	.byte	0x5
	.uleb128 0x4d
	.4byte	.LASF686
	.byte	0x5
	.uleb128 0x4e
	.4byte	.LASF687
	.byte	0x5
	.uleb128 0x4f
	.4byte	.LASF688
	.byte	0x5
	.uleb128 0x50
	.4byte	.LASF689
	.byte	0x5
	.uleb128 0x51
	.4byte	.LASF690
	.byte	0x5
	.uleb128 0x52
	.4byte	.LASF691
	.byte	0x5
	.uleb128 0x53
	.4byte	.LASF692
	.byte	0x5
	.uleb128 0x54
	.4byte	.LASF693
	.byte	0x5
	.uleb128 0x55
	.4byte	.LASF694
	.byte	0x5
	.uleb128 0x56
	.4byte	.LASF695
	.byte	0x5
	.uleb128 0x57
	.4byte	.LASF696
	.byte	0x5
	.uleb128 0x58
	.4byte	.LASF697
	.byte	0x5
	.uleb128 0x62
	.4byte	.LASF698
	.byte	0x5
	.uleb128 0x63
	.4byte	.LASF699
	.byte	0x5
	.uleb128 0x64
	.4byte	.LASF700
	.byte	0x5
	.uleb128 0x65
	.4byte	.LASF701
	.byte	0x5
	.uleb128 0x66
	.4byte	.LASF702
	.byte	0x5
	.uleb128 0x67
	.4byte	.LASF703
	.byte	0x5
	.uleb128 0x68
	.4byte	.LASF704
	.byte	0x5
	.uleb128 0x69
	.4byte	.LASF705
	.byte	0x5
	.uleb128 0x6a
	.4byte	.LASF706
	.byte	0x5
	.uleb128 0x6b
	.4byte	.LASF707
	.byte	0x5
	.uleb128 0x6c
	.4byte	.LASF708
	.byte	0x5
	.uleb128 0x6d
	.4byte	.LASF709
	.byte	0x5
	.uleb128 0x77
	.4byte	.LASF710
	.byte	0x5
	.uleb128 0x78
	.4byte	.LASF711
	.byte	0x5
	.uleb128 0x79
	.4byte	.LASF712
	.byte	0x5
	.uleb128 0x7a
	.4byte	.LASF713
	.byte	0x5
	.uleb128 0x7b
	.4byte	.LASF714
	.byte	0x5
	.uleb128 0x7c
	.4byte	.LASF715
	.byte	0x5
	.uleb128 0x8d
	.4byte	.LASF716
	.byte	0x5
	.uleb128 0x8e
	.4byte	.LASF717
	.byte	0x5
	.uleb128 0x97
	.4byte	.LASF718
	.byte	0x5
	.uleb128 0x98
	.4byte	.LASF719
	.byte	0x5
	.uleb128 0x99
	.4byte	.LASF720
	.byte	0x5
	.uleb128 0x9a
	.4byte	.LASF721
	.byte	0x5
	.uleb128 0xa3
	.4byte	.LASF722
	.byte	0x5
	.uleb128 0xa4
	.4byte	.LASF723
	.byte	0x5
	.uleb128 0xa5
	.4byte	.LASF724
	.byte	0x5
	.uleb128 0xa6
	.4byte	.LASF725
	.byte	0x5
	.uleb128 0xaf
	.4byte	.LASF726
	.byte	0x5
	.uleb128 0xb0
	.4byte	.LASF727
	.byte	0x5
	.uleb128 0xba
	.4byte	.LASF728
	.byte	0x5
	.uleb128 0xbc
	.4byte	.LASF729
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.config.h.2.af61b221da56f871452d31053eec4fba,comdat
.Ldebug_macro7:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF730
	.byte	0x5
	.uleb128 0x14
	.4byte	.LASF731
	.byte	0x5
	.uleb128 0x22
	.4byte	.LASF732
	.byte	0x5
	.uleb128 0x2e
	.4byte	.LASF733
	.byte	0x5
	.uleb128 0x3a
	.4byte	.LASF734
	.byte	0x5
	.uleb128 0x46
	.4byte	.LASF735
	.byte	0x5
	.uleb128 0x52
	.4byte	.LASF736
	.byte	0x5
	.uleb128 0x5e
	.4byte	.LASF737
	.byte	0x5
	.uleb128 0x6a
	.4byte	.LASF738
	.byte	0x5
	.uleb128 0x76
	.4byte	.LASF739
	.byte	0x5
	.uleb128 0x82
	.4byte	.LASF740
	.byte	0x5
	.uleb128 0x8e
	.4byte	.LASF741
	.byte	0x5
	.uleb128 0x9a
	.4byte	.LASF742
	.byte	0x5
	.uleb128 0xa6
	.4byte	.LASF743
	.byte	0x5
	.uleb128 0xbc
	.4byte	.LASF744
	.byte	0x5
	.uleb128 0xc8
	.4byte	.LASF745
	.byte	0x5
	.uleb128 0xd6
	.4byte	.LASF746
	.byte	0x5
	.uleb128 0xe0
	.4byte	.LASF747
	.byte	0x5
	.uleb128 0xfb
	.4byte	.LASF748
	.byte	0x5
	.uleb128 0x10d
	.4byte	.LASF749
	.byte	0x5
	.uleb128 0x119
	.4byte	.LASF750
	.byte	0x5
	.uleb128 0x124
	.4byte	.LASF751
	.byte	0x5
	.uleb128 0x12f
	.4byte	.LASF752
	.byte	0x5
	.uleb128 0x13c
	.4byte	.LASF753
	.byte	0x5
	.uleb128 0x14a
	.4byte	.LASF754
	.byte	0x5
	.uleb128 0x161
	.4byte	.LASF755
	.byte	0x5
	.uleb128 0x16c
	.4byte	.LASF756
	.byte	0x5
	.uleb128 0x176
	.4byte	.LASF757
	.byte	0x5
	.uleb128 0x180
	.4byte	.LASF758
	.byte	0x5
	.uleb128 0x18d
	.4byte	.LASF759
	.byte	0x5
	.uleb128 0x198
	.4byte	.LASF760
	.byte	0x5
	.uleb128 0x1a3
	.4byte	.LASF761
	.byte	0x5
	.uleb128 0x1ae
	.4byte	.LASF762
	.byte	0x5
	.uleb128 0x1ba
	.4byte	.LASF763
	.byte	0x5
	.uleb128 0x1c6
	.4byte	.LASF764
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.toolchain_defs.h.2.e5fd326231d01413e5361944b26cde07,comdat
.Ldebug_macro8:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF766
	.byte	0x5
	.uleb128 0xe
	.4byte	.LASF767
	.byte	0x5
	.uleb128 0x19
	.4byte	.LASF768
	.byte	0x5
	.uleb128 0x1a
	.4byte	.LASF769
	.byte	0x5
	.uleb128 0x24
	.4byte	.LASF770
	.byte	0x5
	.uleb128 0x2f
	.4byte	.LASF771
	.byte	0x5
	.uleb128 0x30
	.4byte	.LASF772
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.string.h.11.3ded87d0afb3062a44f34fa0d6f65e1d,comdat
.Ldebug_macro9:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0xb
	.4byte	.LASF775
	.byte	0x5
	.uleb128 0x22
	.4byte	.LASF776
	.byte	0x5
	.uleb128 0x2d
	.4byte	.LASF777
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.cmsis_gcc.h.26.78077cef1206e937f7b56043ffca496a,comdat
.Ldebug_macro10:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x1a
	.4byte	.LASF778
	.byte	0x5
	.uleb128 0x29
	.4byte	.LASF779
	.byte	0x5
	.uleb128 0x2c
	.4byte	.LASF780
	.byte	0x5
	.uleb128 0x2f
	.4byte	.LASF781
	.byte	0x5
	.uleb128 0x32
	.4byte	.LASF782
	.byte	0x5
	.uleb128 0x35
	.4byte	.LASF783
	.byte	0x5
	.uleb128 0x38
	.4byte	.LASF784
	.byte	0x5
	.uleb128 0x3b
	.4byte	.LASF785
	.byte	0x5
	.uleb128 0x3e
	.4byte	.LASF786
	.byte	0x5
	.uleb128 0x41
	.4byte	.LASF787
	.byte	0x5
	.uleb128 0x44
	.4byte	.LASF788
	.byte	0x5
	.uleb128 0x4c
	.4byte	.LASF789
	.byte	0x5
	.uleb128 0x54
	.4byte	.LASF790
	.byte	0x5
	.uleb128 0x5c
	.4byte	.LASF791
	.byte	0x5
	.uleb128 0x64
	.4byte	.LASF792
	.byte	0x5
	.uleb128 0x6c
	.4byte	.LASF793
	.byte	0x5
	.uleb128 0x6f
	.4byte	.LASF794
	.byte	0x5
	.uleb128 0x72
	.4byte	.LASF795
	.byte	0x5
	.uleb128 0x75
	.4byte	.LASF796
	.byte	0x5
	.uleb128 0xa6
	.4byte	.LASF797
	.byte	0x5
	.uleb128 0xaa
	.4byte	.LASF798
	.byte	0x5
	.uleb128 0xae
	.4byte	.LASF799
	.byte	0x5
	.uleb128 0xb2
	.4byte	.LASF800
	.byte	0x5
	.uleb128 0xb6
	.4byte	.LASF801
	.byte	0x5
	.uleb128 0x37e
	.4byte	.LASF802
	.byte	0x5
	.uleb128 0x37f
	.4byte	.LASF803
	.byte	0x5
	.uleb128 0x380
	.4byte	.LASF804
	.byte	0x5
	.uleb128 0x387
	.4byte	.LASF805
	.byte	0x5
	.uleb128 0x38d
	.4byte	.LASF806
	.byte	0x5
	.uleb128 0x395
	.4byte	.LASF807
	.byte	0x5
	.uleb128 0x39c
	.4byte	.LASF808
	.byte	0x5
	.uleb128 0x40f
	.4byte	.LASF809
	.byte	0x5
	.uleb128 0x4d4
	.4byte	.LASF810
	.byte	0x5
	.uleb128 0x4e4
	.4byte	.LASF811
	.byte	0x5
	.uleb128 0x787
	.4byte	.LASF812
	.byte	0x5
	.uleb128 0x78e
	.4byte	.LASF813
	.byte	0x5
	.uleb128 0x864
	.4byte	.LASF814
	.byte	0x5
	.uleb128 0x867
	.4byte	.LASF815
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.board_info.h.18.1c3d3d33b248fd41c3b91635c01b5b31,comdat
.Ldebug_macro11:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x12
	.4byte	.LASF816
	.byte	0x5
	.uleb128 0x13
	.4byte	.LASF817
	.byte	0x5
	.uleb128 0x14
	.4byte	.LASF818
	.byte	0x5
	.uleb128 0x18
	.4byte	.LASF819
	.byte	0x5
	.uleb128 0x19
	.4byte	.LASF820
	.byte	0x5
	.uleb128 0x1b
	.4byte	.LASF821
	.byte	0x5
	.uleb128 0x1c
	.4byte	.LASF822
	.byte	0x5
	.uleb128 0x1d
	.4byte	.LASF823
	.byte	0x5
	.uleb128 0x1e
	.4byte	.LASF824
	.byte	0x5
	.uleb128 0x21
	.4byte	.LASF825
	.byte	0x5
	.uleb128 0x22
	.4byte	.LASF826
	.byte	0x5
	.uleb128 0x26
	.4byte	.LASF827
	.byte	0x5
	.uleb128 0x2a
	.4byte	.LASF828
	.byte	0x5
	.uleb128 0x2d
	.4byte	.LASF829
	.byte	0x5
	.uleb128 0x2e
	.4byte	.LASF830
	.byte	0x5
	.uleb128 0x2f
	.4byte	.LASF831
	.byte	0x5
	.uleb128 0x34
	.4byte	.LASF832
	.byte	0x5
	.uleb128 0x73
	.4byte	.LASF833
	.byte	0x5
	.uleb128 0x77
	.4byte	.LASF834
	.byte	0x5
	.uleb128 0x78
	.4byte	.LASF835
	.byte	0x5
	.uleb128 0x79
	.4byte	.LASF836
	.byte	0x5
	.uleb128 0x7a
	.4byte	.LASF837
	.byte	0x5
	.uleb128 0x7d
	.4byte	.LASF838
	.byte	0x5
	.uleb128 0x7e
	.4byte	.LASF839
	.byte	0x5
	.uleb128 0x90
	.4byte	.LASF840
	.byte	0x5
	.uleb128 0x94
	.4byte	.LASF841
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.af.h.2.35c4d1662df9f57f4385cbbbb849d6b1,comdat
.Ldebug_macro12:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF842
	.byte	0x5
	.uleb128 0xa
	.4byte	.LASF843
	.byte	0x5
	.uleb128 0xc
	.4byte	.LASF844
	.byte	0x5
	.uleb128 0xe
	.4byte	.LASF845
	.byte	0x5
	.uleb128 0x10
	.4byte	.LASF846
	.byte	0x5
	.uleb128 0x12
	.4byte	.LASF847
	.byte	0x5
	.uleb128 0x14
	.4byte	.LASF848
	.byte	0x5
	.uleb128 0x15
	.4byte	.LASF849
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.opendefs.h.26.ab7143d41adee8785d9b276f2a6708f0,comdat
.Ldebug_macro13:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x1a
	.4byte	.LASF850
	.byte	0x5
	.uleb128 0x1b
	.4byte	.LASF851
	.byte	0x5
	.uleb128 0x1c
	.4byte	.LASF852
	.byte	0x5
	.uleb128 0x1f
	.4byte	.LASF853
	.byte	0x5
	.uleb128 0x23
	.4byte	.LASF854
	.byte	0x5
	.uleb128 0x26
	.4byte	.LASF855
	.byte	0x5
	.uleb128 0x27
	.4byte	.LASF856
	.byte	0x5
	.uleb128 0x28
	.4byte	.LASF857
	.byte	0x5
	.uleb128 0x2a
	.4byte	.LASF858
	.byte	0x5
	.uleb128 0x2d
	.4byte	.LASF859
	.byte	0x5
	.uleb128 0x30
	.4byte	.LASF860
	.byte	0x5
	.uleb128 0x35
	.4byte	.LASF861
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.iphc.h.2.edeb743e1a760cedc2836edfe6fc24cb,comdat
.Ldebug_macro14:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF863
	.byte	0x5
	.uleb128 0xf
	.4byte	.LASF864
	.byte	0x5
	.uleb128 0x10
	.4byte	.LASF865
	.byte	0x5
	.uleb128 0x11
	.4byte	.LASF866
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.IEEE802154.h.2.a55ed60203d979c99e9c3635390c531f,comdat
.Ldebug_macro15:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF869
	.byte	0x5
	.uleb128 0x72
	.4byte	.LASF870
	.byte	0x5
	.uleb128 0x75
	.4byte	.LASF871
	.byte	0x5
	.uleb128 0x78
	.4byte	.LASF872
	.byte	0x5
	.uleb128 0x7b
	.4byte	.LASF873
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.openqueue.h.20.c2deca5135d14ad877e355148c5fe3e9,comdat
.Ldebug_macro16:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x14
	.4byte	.LASF874
	.byte	0x5
	.uleb128 0x1a
	.4byte	.LASF875
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.openserial.h.9.e155d9b80f5341bab7008a84c82eb1b7,comdat
.Ldebug_macro17:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x9
	.4byte	.LASF876
	.byte	0x5
	.uleb128 0x1d
	.4byte	.LASF877
	.byte	0x5
	.uleb128 0x1e
	.4byte	.LASF878
	.byte	0x5
	.uleb128 0x26
	.4byte	.LASF879
	.byte	0x5
	.uleb128 0x29
	.4byte	.LASF880
	.byte	0x5
	.uleb128 0x2a
	.4byte	.LASF881
	.byte	0x5
	.uleb128 0x2b
	.4byte	.LASF882
	.byte	0x5
	.uleb128 0x2c
	.4byte	.LASF883
	.byte	0x5
	.uleb128 0x2d
	.4byte	.LASF884
	.byte	0x5
	.uleb128 0x2e
	.4byte	.LASF885
	.byte	0x5
	.uleb128 0x2f
	.4byte	.LASF886
	.byte	0x5
	.uleb128 0x30
	.4byte	.LASF887
	.byte	0x5
	.uleb128 0x31
	.4byte	.LASF888
	.byte	0x5
	.uleb128 0x32
	.4byte	.LASF889
	.byte	0x5
	.uleb128 0x35
	.4byte	.LASF890
	.byte	0x5
	.uleb128 0x36
	.4byte	.LASF891
	.byte	0x5
	.uleb128 0x37
	.4byte	.LASF892
	.byte	0x5
	.uleb128 0x38
	.4byte	.LASF893
	.byte	0x5
	.uleb128 0x41
	.4byte	.LASF894
	.byte	0x5
	.uleb128 0x47
	.4byte	.LASF895
	.byte	0x5
	.uleb128 0x4d
	.4byte	.LASF896
	.byte	0x5
	.uleb128 0x53
	.4byte	.LASF897
	.byte	0x5
	.uleb128 0x59
	.4byte	.LASF898
	.byte	0x5
	.uleb128 0x5f
	.4byte	.LASF899
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.idmanager.h.2.234f9cb08fafb20b4de6945d3cf15cc0,comdat
.Ldebug_macro18:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF900
	.byte	0x5
	.uleb128 0xf
	.4byte	.LASF901
	.byte	0x5
	.uleb128 0x10
	.4byte	.LASF902
	.byte	0x5
	.uleb128 0x11
	.4byte	.LASF903
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.opentimers.h.8.d477464cf138583deb1b726e0524cc03,comdat
.Ldebug_macro19:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x8
	.4byte	.LASF907
	.byte	0x5
	.uleb128 0x17
	.4byte	.LASF908
	.byte	0x5
	.uleb128 0x18
	.4byte	.LASF909
	.byte	0x5
	.uleb128 0x19
	.4byte	.LASF910
	.byte	0x5
	.uleb128 0x1a
	.4byte	.LASF911
	.byte	0x5
	.uleb128 0x1b
	.4byte	.LASF912
	.byte	0x5
	.uleb128 0x1d
	.4byte	.LASF913
	.byte	0x5
	.uleb128 0x1e
	.4byte	.LASF914
	.byte	0x5
	.uleb128 0x1f
	.4byte	.LASF915
	.byte	0x5
	.uleb128 0x21
	.4byte	.LASF916
	.byte	0x5
	.uleb128 0x23
	.4byte	.LASF917
	.byte	0x5
	.uleb128 0x24
	.4byte	.LASF918
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.icmpv6rpl.h.15.ea1c33c2ed88145f3bad15ef7ace3b0f,comdat
.Ldebug_macro20:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0xf
	.4byte	.LASF919
	.byte	0x5
	.uleb128 0x10
	.4byte	.LASF920
	.byte	0x5
	.uleb128 0x13
	.4byte	.LASF921
	.byte	0x5
	.uleb128 0x14
	.4byte	.LASF922
	.byte	0x5
	.uleb128 0x15
	.4byte	.LASF923
	.byte	0x5
	.uleb128 0x17
	.4byte	.LASF924
	.byte	0x5
	.uleb128 0x18
	.4byte	.LASF925
	.byte	0x5
	.uleb128 0x19
	.4byte	.LASF926
	.byte	0x5
	.uleb128 0x1b
	.4byte	.LASF927
	.byte	0x5
	.uleb128 0x1d
	.4byte	.LASF928
	.byte	0x5
	.uleb128 0x1e
	.4byte	.LASF929
	.byte	0x5
	.uleb128 0x1f
	.4byte	.LASF930
	.byte	0x5
	.uleb128 0x20
	.4byte	.LASF931
	.byte	0x5
	.uleb128 0x21
	.4byte	.LASF932
	.byte	0x5
	.uleb128 0x22
	.4byte	.LASF933
	.byte	0x5
	.uleb128 0x23
	.4byte	.LASF934
	.byte	0x5
	.uleb128 0x24
	.4byte	.LASF935
	.byte	0x5
	.uleb128 0x26
	.4byte	.LASF936
	.byte	0x5
	.uleb128 0x28
	.4byte	.LASF937
	.byte	0x5
	.uleb128 0x29
	.4byte	.LASF938
	.byte	0x5
	.uleb128 0x2b
	.4byte	.LASF939
	.byte	0x5
	.uleb128 0x2c
	.4byte	.LASF940
	.byte	0x5
	.uleb128 0x2e
	.4byte	.LASF941
	.byte	0x5
	.uleb128 0x2f
	.4byte	.LASF942
	.byte	0x5
	.uleb128 0x31
	.4byte	.LASF943
	.byte	0x5
	.uleb128 0x32
	.4byte	.LASF944
	.byte	0x5
	.uleb128 0x34
	.4byte	.LASF945
	.byte	0x5
	.uleb128 0x35
	.4byte	.LASF946
	.byte	0x5
	.uleb128 0x37
	.4byte	.LASF947
	.byte	0x5
	.uleb128 0x39
	.4byte	.LASF948
	.byte	0x5
	.uleb128 0x3a
	.4byte	.LASF949
	.byte	0x5
	.uleb128 0x3e
	.4byte	.LASF950
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.neighbors.h.15.12d7ffc122e46c26e5444025074c602a,comdat
.Ldebug_macro21:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0xf
	.4byte	.LASF951
	.byte	0x5
	.uleb128 0x11
	.4byte	.LASF952
	.byte	0x5
	.uleb128 0x14
	.4byte	.LASF953
	.byte	0x5
	.uleb128 0x17
	.4byte	.LASF954
	.byte	0x5
	.uleb128 0x1a
	.4byte	.LASF955
	.byte	0x5
	.uleb128 0x1c
	.4byte	.LASF956
	.byte	0x5
	.uleb128 0x1e
	.4byte	.LASF957
	.byte	0x5
	.uleb128 0x1f
	.4byte	.LASF958
	.byte	0x5
	.uleb128 0x20
	.4byte	.LASF959
	.byte	0x5
	.uleb128 0x21
	.4byte	.LASF960
	.byte	0x5
	.uleb128 0x23
	.4byte	.LASF961
	.byte	0
	.section	.debug_macro,"G",%progbits,wm4.scheduler.h.2.9c17d72ca48ee3fe9618c60b3573ac7a,comdat
.Ldebug_macro22:
	.2byte	0x4
	.byte	0
	.byte	0x5
	.uleb128 0x2
	.4byte	.LASF965
	.byte	0x5
	.uleb128 0x26
	.4byte	.LASF966
	.byte	0
	.section	.debug_line,"",%progbits
.Ldebug_line0:
	.section	.debug_str,"MS",%progbits,1
.LASF857:
	.ascii	"LENGTH_ADDR128b 16\000"
.LASF993:
	.ascii	"ADDR_PANID\000"
.LASF463:
	.ascii	"__GXX_TYPEINFO_EQUALITY_INLINE 0\000"
.LASF953:
	.ascii	"GOODNEIGHBORMINRSSI -80\000"
.LASF1051:
	.ascii	"COMPONENT_UINJECT\000"
.LASF882:
	.ascii	"SERFRAME_MOTE2PC_VERBOSE ((uint8_t)'V')\000"
.LASF370:
	.ascii	"__UHA_FBIT__ 8\000"
.LASF594:
	.ascii	"__SEGGER_RTL_U32 unsigned\000"
.LASF416:
	.ascii	"__ARM_FEATURE_CLZ 1\000"
.LASF971:
	.ascii	"int8_t\000"
.LASF1211:
	.ascii	"IPHC_TF_4B\000"
.LASF1283:
	.ascii	"F_FLAG\000"
.LASF1228:
	.ascii	"IPHC_SAC_STATELESS\000"
.LASF853:
	.ascii	"TRUE 1\000"
.LASF873:
	.ascii	"PAYLOAD_TERMINATION_IE 0xF800\000"
.LASF1136:
	.ascii	"ERR_MAXRETRIES_REACHED\000"
.LASF936:
	.ascii	"E_DAO_Transit_Info 0<<7\000"
.LASF369:
	.ascii	"__TA_IBIT__ 64\000"
.LASF981:
	.ascii	"size_t\000"
.LASF561:
	.ascii	"__SEGGER_RTL_BYTE_PATTERN(X) __SEGGER_RTL_BYTE_PATT"
	.ascii	"ERN_func(X)\000"
.LASF1150:
	.ascii	"slotoffset\000"
.LASF1354:
	.ascii	"temp_dest_mac64b\000"
.LASF750:
	.ascii	"OPENWSN_IEEE802154E_SECURITY_C (0)\000"
.LASF1008:
	.ascii	"IANA_ICMPv6_RPL_DIO\000"
.LASF334:
	.ascii	"__LLACCUM_MIN__ (-0X1P31LLK-0X1P31LLK)\000"
.LASF223:
	.ascii	"__FLT32_EPSILON__ 1.1\000"
.LASF1007:
	.ascii	"IANA_ICMPv6_RPL_DIS\000"
.LASF762:
	.ascii	"BOARD_SENSORS_ENABLED (0)\000"
.LASF79:
	.ascii	"__PTRDIFF_MAX__ 0x7fffffff\000"
.LASF1111:
	.ascii	"ERR_MAXTXDATAPREPARE_OVERFLOW\000"
.LASF91:
	.ascii	"__INTMAX_C(c) c ## LL\000"
.LASF239:
	.ascii	"__FLT64_MIN__ 1.1\000"
.LASF896:
	.ascii	"LOG_WARNING(component,message,p1,p2) openserial_pri"
	.ascii	"ntLog(L_WARNING, (component), (message), (p1), (p2)"
	.ascii	")\000"
.LASF1000:
	.ascii	"IANA_ICMPv6\000"
.LASF1270:
	.ascii	"rhe_length\000"
.LASF351:
	.ascii	"__TQ_IBIT__ 0\000"
.LASF1075:
	.ascii	"ERR_INVALID_FWDMODE\000"
.LASF236:
	.ascii	"__FLT64_DECIMAL_DIG__ 17\000"
.LASF759:
	.ascii	"BOARD_CRYPTOENGINE_ENABLED (0)\000"
.LASF732:
	.ascii	"OPENWSN_C6T_C (0)\000"
.LASF690:
	.ascii	"INT_LEAST32_MIN INT32_MIN\000"
.LASF14:
	.ascii	"__ATOMIC_CONSUME 1\000"
.LASF284:
	.ascii	"__LFRACT_MIN__ (-0.5LR-0.5LR)\000"
.LASF75:
	.ascii	"__WCHAR_MAX__ 0xffffffffU\000"
.LASF314:
	.ascii	"__ACCUM_MIN__ (-0X1P15K-0X1P15K)\000"
.LASF629:
	.ascii	"__SEGGER_RTL_STDOUT_BUFFER_LEN 64\000"
.LASF1185:
	.ascii	"l2_sixtop_messageType\000"
.LASF850:
	.ascii	"OPENWSN_VERSION_MAJOR 1\000"
.LASF772:
	.ascii	"END_PACK _Pragma(\"pack()\");\000"
.LASF18:
	.ascii	"__SIZEOF_LONG_LONG__ 8\000"
.LASF169:
	.ascii	"__DBL_MAX_10_EXP__ 308\000"
.LASF809:
	.ascii	"__BKPT(value) __ASM volatile (\"bkpt \"#value)\000"
.LASF274:
	.ascii	"__FRACT_MIN__ (-0.5R-0.5R)\000"
.LASF340:
	.ascii	"__ULLACCUM_MAX__ 0XFFFFFFFFFFFFFFFFP-32ULLK\000"
.LASF985:
	.ascii	"infoRadioName\000"
.LASF994:
	.ascii	"ADDR_PREFIX\000"
.LASF262:
	.ascii	"__SFRACT_FBIT__ 7\000"
.LASF94:
	.ascii	"__INTMAX_WIDTH__ 64\000"
.LASF460:
	.ascii	"__ARM_FEATURE_BF16_SCALAR_ARITHMETIC\000"
.LASF347:
	.ascii	"__SQ_IBIT__ 0\000"
.LASF28:
	.ascii	"__ORDER_PDP_ENDIAN__ 3412\000"
.LASF34:
	.ascii	"__SIZE_TYPE__ unsigned int\000"
.LASF540:
	.ascii	"__SEGGER_RTL_CORE_HAS_BLX_REG 1\000"
.LASF159:
	.ascii	"__FLT_HAS_DENORM__ 1\000"
.LASF43:
	.ascii	"__INT8_TYPE__ signed char\000"
.LASF422:
	.ascii	"__ARM_ARCH_PROFILE 77\000"
.LASF1357:
	.ascii	"temp_src_prefix\000"
.LASF1139:
	.ascii	"ERR_INVALID_PARAM\000"
.LASF219:
	.ascii	"__FLT32_DECIMAL_DIG__ 9\000"
.LASF36:
	.ascii	"__WCHAR_TYPE__ unsigned int\000"
.LASF186:
	.ascii	"__DECIMAL_DIG__ 17\000"
.LASF182:
	.ascii	"__LDBL_MIN_EXP__ (-1021)\000"
.LASF1328:
	.ascii	"next_size\000"
.LASF2:
	.ascii	"__STDC_UTF_16__ 1\000"
.LASF1252:
	.ascii	"IPINIP_TYPE_6LORH\000"
.LASF119:
	.ascii	"__UINT8_C(c) c\000"
.LASF44:
	.ascii	"__INT16_TYPE__ short int\000"
.LASF1142:
	.ascii	"errorparameter_t\000"
.LASF649:
	.ascii	"__SEGGER_RTL_FILE_IMPL __SEGGER_RTL_FILE_impl\000"
.LASF1231:
	.ascii	"IPHC_SAM_128B\000"
.LASF820:
	.ascii	"PORT_RADIOTIMER_WIDTH uint32_t\000"
.LASF330:
	.ascii	"__ULACCUM_MAX__ 0XFFFFFFFFFFFFFFFFP-32ULK\000"
.LASF784:
	.ascii	"__USED __attribute__((used))\000"
.LASF1175:
	.ascii	"l2_nextORpreviousHop\000"
.LASF306:
	.ascii	"__SACCUM_EPSILON__ 0x1P-7HK\000"
.LASF1345:
	.ascii	"destination128b\000"
.LASF786:
	.ascii	"__PACKED __attribute__((packed, aligned(1)))\000"
.LASF776:
	.ascii	"NULL 0\000"
.LASF912:
	.ascii	"opentimers_id_t uint8_t\000"
.LASF1182:
	.ascii	"l2_sixtop_celllist_add\000"
.LASF1065:
	.ascii	"ERR_UNSUPPORTED_PORT_NUMBER\000"
.LASF1155:
	.ascii	"addr_128b\000"
.LASF1019:
	.ascii	"COMPONENT_RADIO\000"
.LASF590:
	.ascii	"__SEGGER_RTL_INCLUDE_SEGGER_API 0\000"
.LASF4:
	.ascii	"__STDC_HOSTED__ 1\000"
.LASF297:
	.ascii	"__ULLFRACT_FBIT__ 64\000"
.LASF469:
	.ascii	"__SES_VERSION 63000\000"
.LASF545:
	.ascii	"__SEGGER_RTL_FLOAT64_C_COMPLEX double _Complex\000"
.LASF714:
	.ascii	"INTPTR_MAX INT32_MAX\000"
.LASF1325:
	.ascii	"temp_8b\000"
.LASF1311:
	.ascii	"openserial_printLog\000"
.LASF1358:
	.ascii	"temp_src_mac64b\000"
.LASF669:
	.ascii	"__SEGGER_RTL_FILE_IMPL_DEFINED \000"
.LASF637:
	.ascii	"__SEGGER_RTL_SMULL_X(X,Y) __SEGGER_RTL_SMULL_X_func"
	.ascii	"((X), (Y))\000"
.LASF1237:
	.ascii	"IPHC_M_YES\000"
.LASF1034:
	.ascii	"COMPONENT_ICMPv6ECHO\000"
.LASF1183:
	.ascii	"l2_sixtop_celllist_delete\000"
.LASF575:
	.ascii	"__SEGGER_RTL_SIGNAL_SIG_ERR __aeabi_SIG_ERR\000"
.LASF270:
	.ascii	"__USFRACT_MAX__ 0XFFP-8UHR\000"
.LASF847:
	.ascii	"AF_INET6 AF_INET6\000"
.LASF228:
	.ascii	"__FP_FAST_FMAF32 1\000"
.LASF662:
	.ascii	"__SEGGER_RTL_SUBNORMALS_FLUSH_TO_ZERO 1\000"
.LASF531:
	.ascii	"__SEGGER_RTL_CORE_HAS_REV 1\000"
.LASF711:
	.ascii	"PTRDIFF_MAX INT32_MAX\000"
.LASF560:
	.ascii	"__SEGGER_RTL_DIFF_BYTE(X,N) __SEGGER_RTL_DIFF_BYTE_"
	.ascii	"func(X, N)\000"
.LASF215:
	.ascii	"__FLT32_MIN_EXP__ (-125)\000"
.LASF1320:
	.ascii	"packetfunctions_ip128bToMac64b\000"
.LASF647:
	.ascii	"__SEGGER_RTL_CLZ_U64_SYNTHESIZED \000"
.LASF680:
	.ascii	"UINT16_MAX 65535\000"
.LASF1169:
	.ascii	"l4_payload\000"
.LASF615:
	.ascii	"__SEGGER_RTL_WCHAR_T __WCHAR_TYPE__\000"
.LASF1158:
	.ascii	"type\000"
.LASF1130:
	.ascii	"ERR_MSG_UNKNOWN_TYPE\000"
.LASF1024:
	.ascii	"COMPONENT_SIXTOP\000"
.LASF481:
	.ascii	"OPENWSN_UINJECT_C 1\000"
.LASF743:
	.ascii	"OPENWSN_UEXP_MONITOR_C (0)\000"
.LASF679:
	.ascii	"UINT8_MAX 255\000"
.LASF210:
	.ascii	"__FLT16_HAS_INFINITY__ 1\000"
.LASF367:
	.ascii	"__DA_IBIT__ 32\000"
.LASF1039:
	.ascii	"COMPONENT_UDP_TO_SOCK\000"
.LASF579:
	.ascii	"__SEGGER_RTL_NAN_FORMAT_COMPACT 2\000"
.LASF233:
	.ascii	"__FLT64_MIN_10_EXP__ (-307)\000"
.LASF32:
	.ascii	"__GNUC_EXECUTION_CHARSET_NAME \"UTF-8\"\000"
.LASF886:
	.ascii	"SERFRAME_MOTE2PC_ERROR ((uint8_t)'E')\000"
.LASF651:
	.ascii	"__SEGGER_RTL_U64_L(X) ((__SEGGER_RTL_U32)(__SEGGER_"
	.ascii	"RTL_U64)(X))\000"
.LASF133:
	.ascii	"__INT_FAST64_WIDTH__ 64\000"
.LASF1:
	.ascii	"__STDC_VERSION__ 199901L\000"
.LASF1261:
	.ascii	"SIZE_6LORH_RH3_enums\000"
.LASF703:
	.ascii	"INT_FAST32_MAX INT32_MAX\000"
.LASF266:
	.ascii	"__SFRACT_EPSILON__ 0x1P-7HR\000"
.LASF503:
	.ascii	"__SEGGER_RTL_FLOAT16 _Float16\000"
.LASF113:
	.ascii	"__INT32_C(c) c ## L\000"
.LASF356:
	.ascii	"__USQ_FBIT__ 32\000"
.LASF27:
	.ascii	"__ORDER_BIG_ENDIAN__ 4321\000"
.LASF1049:
	.ascii	"COMPONENT_CWELLKNOWN\000"
.LASF773:
	.ascii	"__BOARD_INFO_H \000"
.LASF346:
	.ascii	"__SQ_FBIT__ 31\000"
.LASF237:
	.ascii	"__FLT64_MAX__ 1.1\000"
.LASF376:
	.ascii	"__UTA_FBIT__ 64\000"
.LASF830:
	.ascii	"RADIO_PRIORITY 0\000"
.LASF164:
	.ascii	"__DBL_MANT_DIG__ 53\000"
.LASF1178:
	.ascii	"l2_retriesLeft\000"
.LASF595:
	.ascii	"__SEGGER_RTL_I32 int\000"
.LASF354:
	.ascii	"__UHQ_FBIT__ 16\000"
.LASF524:
	.ascii	"__SEGGER_RTL_PUBLIC_API __attribute__((__weak__))\000"
.LASF232:
	.ascii	"__FLT64_MIN_EXP__ (-1021)\000"
.LASF1018:
	.ascii	"COMPONENT_RANDOM\000"
.LASF88:
	.ascii	"__PTRDIFF_WIDTH__ 32\000"
.LASF1135:
	.ascii	"ERR_BOOTED\000"
.LASF256:
	.ascii	"__FLT32X_EPSILON__ 1.1\000"
.LASF218:
	.ascii	"__FLT32_MAX_10_EXP__ 38\000"
.LASF134:
	.ascii	"__UINT_FAST8_MAX__ 0xffffffffU\000"
.LASF1239:
	.ascii	"IPHC_DAC_STATELESS\000"
.LASF535:
	.ascii	"__SEGGER_RTL_CORE_HAS_IDIV 1\000"
.LASF474:
	.ascii	"DEBUG 1\000"
.LASF154:
	.ascii	"__FLT_MAX__ 1.1\000"
.LASF54:
	.ascii	"__INT_LEAST64_TYPE__ long long int\000"
.LASF1310:
	.ascii	"openqueue_freePacketBuffer\000"
.LASF779:
	.ascii	"__ASM __asm\000"
.LASF1119:
	.ascii	"ERR_SECURITY\000"
.LASF129:
	.ascii	"__INT_FAST16_WIDTH__ 32\000"
.LASF1215:
	.ascii	"IPHC_TF_enums\000"
.LASF964:
	.ascii	"__DEBUGPINS_H \000"
.LASF1204:
	.ascii	"l2_FrameCounter\000"
.LASF434:
	.ascii	"__VFP_FP__ 1\000"
.LASF986:
	.ascii	"infoStackName\000"
.LASF138:
	.ascii	"__INTPTR_MAX__ 0x7fffffff\000"
.LASF135:
	.ascii	"__UINT_FAST16_MAX__ 0xffffffffU\000"
.LASF180:
	.ascii	"__LDBL_MANT_DIG__ 53\000"
.LASF1055:
	.ascii	"COMPONENT_UEXPIRATION\000"
.LASF209:
	.ascii	"__FLT16_HAS_DENORM__ 1\000"
.LASF863:
	.ascii	"OPENWSN_IPHC_H \000"
.LASF1006:
	.ascii	"IANA_ICMPv6_RPL\000"
.LASF504:
	.ascii	"__SEGGER_RTL_MAX_ALIGN 8\000"
.LASF1166:
	.ascii	"l4_protocol_compressed\000"
.LASF1199:
	.ascii	"l2_keyIdMode\000"
.LASF279:
	.ascii	"__UFRACT_MIN__ 0.0UR\000"
.LASF674:
	.ascii	"INT16_MAX 32767\000"
.LASF195:
	.ascii	"__LDBL_HAS_QUIET_NAN__ 1\000"
.LASF585:
	.ascii	"__WIDTH_DOUBLE 2\000"
.LASF458:
	.ascii	"__ARM_FEATURE_CDE_COPROC\000"
.LASF631:
	.ascii	"__SEGGER_RTL_LOCALE_THREAD \000"
.LASF1048:
	.ascii	"COMPONENT_CSTORM\000"
.LASF259:
	.ascii	"__FLT32X_HAS_INFINITY__ 1\000"
.LASF712:
	.ascii	"SIZE_MAX INT32_MAX\000"
.LASF790:
	.ascii	"__UNALIGNED_UINT16_WRITE(addr,val) (void)((((struct"
	.ascii	" T_UINT16_WRITE *)(void *)(addr))->v) = (val))\000"
.LASF918:
	.ascii	"PRE_CALL_TIMER_WINDOW PORT_TsSlotDuration\000"
.LASF930:
	.ascii	"FLAG_DAO_C 0<<2\000"
.LASF55:
	.ascii	"__UINT_LEAST8_TYPE__ unsigned char\000"
.LASF1203:
	.ascii	"commandFrameIdentifier\000"
.LASF206:
	.ascii	"__FLT16_MIN__ 1.1\000"
.LASF501:
	.ascii	"__SEGGER_RTL_TYPESET 32\000"
.LASF318:
	.ascii	"__UACCUM_IBIT__ 16\000"
.LASF717:
	.ascii	"WINT_MAX 2147483647L\000"
.LASF1343:
	.ascii	"forwarding_createRplOption\000"
.LASF497:
	.ascii	"__SEGGER_RTL_INCLUDE_GNU_FP16_API 1\000"
.LASF255:
	.ascii	"__FLT32X_MIN__ 1.1\000"
.LASF574:
	.ascii	"__SEGGER_RTL_SIGNAL_SIG_DFL __aeabi_SIG_DFL\000"
.LASF132:
	.ascii	"__INT_FAST64_MAX__ 0x7fffffffffffffffLL\000"
.LASF252:
	.ascii	"__FLT32X_DECIMAL_DIG__ 17\000"
.LASF360:
	.ascii	"__UTQ_FBIT__ 128\000"
.LASF260:
	.ascii	"__FLT32X_HAS_QUIET_NAN__ 1\000"
.LASF407:
	.ascii	"__ARM_FEATURE_QRDMX\000"
.LASF1339:
	.ascii	"forwarding_send_internal_SourceRouting\000"
.LASF1041:
	.ascii	"COMPONENT_CJOIN\000"
.LASF557:
	.ascii	"__SEGGER_RTL_ZBYTE_CHECK(X) __SEGGER_RTL_ZBYTE_CHEC"
	.ascii	"K_func(X)\000"
.LASF374:
	.ascii	"__UDA_FBIT__ 32\000"
.LASF1309:
	.ascii	"udp_sendDone\000"
.LASF763:
	.ascii	"BOARD_FASTSIM_ENABLED (0)\000"
.LASF903:
	.ascii	"ACTION_TOGGLE 'T'\000"
.LASF93:
	.ascii	"__UINTMAX_C(c) c ## ULL\000"
.LASF31:
	.ascii	"__SIZEOF_POINTER__ 4\000"
.LASF51:
	.ascii	"__INT_LEAST8_TYPE__ signed char\000"
.LASF556:
	.ascii	"__SEGGER_RTL_WORD unsigned\000"
.LASF947:
	.ascii	"DEFAULT_PATH_CONTROL_SIZE 0\000"
.LASF1287:
	.ascii	"L_CRITICAL\000"
.LASF386:
	.ascii	"__GCC_ATOMIC_BOOL_LOCK_FREE 2\000"
.LASF1241:
	.ascii	"IPHC_DAM_enums\000"
.LASF1172:
	.ascii	"l3_sourceAdd\000"
.LASF610:
	.ascii	"__SEGGER_RTL_SIZEOF_LONG 4\000"
.LASF444:
	.ascii	"__ARM_NEON__\000"
.LASF217:
	.ascii	"__FLT32_MAX_EXP__ 128\000"
.LASF704:
	.ascii	"INT_FAST64_MIN INT64_MIN\000"
.LASF774:
	.ascii	"_LIBCPP_STRING_H \000"
.LASF447:
	.ascii	"__THUMB_INTERWORK__ 1\000"
.LASF300:
	.ascii	"__ULLFRACT_MAX__ 0XFFFFFFFFFFFFFFFFP-64ULLR\000"
.LASF1356:
	.ascii	"p_src\000"
.LASF852:
	.ascii	"OPENWSN_VERSION_PATCH 0\000"
.LASF1280:
	.ascii	"PCKTSEND\000"
.LASF405:
	.ascii	"__ARM_FEATURE_CRYPTO\000"
.LASF33:
	.ascii	"__GNUC_WIDE_EXECUTION_CHARSET_NAME \"UTF-32LE\"\000"
.LASF858:
	.ascii	"MAXNUMNEIGHBORS 30\000"
.LASF249:
	.ascii	"__FLT32X_MIN_10_EXP__ (-307)\000"
.LASF794:
	.ascii	"__ALIGNED(x) __attribute__((aligned(x)))\000"
.LASF518:
	.ascii	"__SEGGER_RTL_UNLIKELY(X) __builtin_expect((X), 0)\000"
.LASF41:
	.ascii	"__CHAR32_TYPE__ long unsigned int\000"
.LASF551:
	.ascii	"__SEGGER_RTL_P2I(X) ((unsigned)(X))\000"
.LASF1284:
	.ascii	"I_FLAG\000"
.LASF681:
	.ascii	"UINT32_MAX 4294967295UL\000"
.LASF1080:
	.ascii	"ERR_FORWARDING_PACKET_DROPPED\000"
.LASF682:
	.ascii	"UINT64_MAX 18446744073709551615ULL\000"
.LASF179:
	.ascii	"__DBL_IS_IEC_60559__ 2\000"
.LASF1349:
	.ascii	"error\000"
.LASF151:
	.ascii	"__FLT_MAX_EXP__ 128\000"
.LASF17:
	.ascii	"__SIZEOF_LONG__ 4\000"
.LASF1259:
	.ascii	"RPI_6LOTH_TYPE\000"
.LASF1322:
	.ascii	"rpl_option\000"
.LASF572:
	.ascii	"__SEGGER_RTL_SIGNAL_SIGSEGV __aeabi_SIGSEGV\000"
.LASF1340:
	.ascii	"forwarding_send_internal_RoutingTable\000"
.LASF21:
	.ascii	"__SIZEOF_DOUBLE__ 8\000"
.LASF1348:
	.ascii	"forwarding_sendDone\000"
.LASF156:
	.ascii	"__FLT_MIN__ 1.1\000"
.LASF248:
	.ascii	"__FLT32X_MIN_EXP__ (-1021)\000"
.LASF758:
	.ascii	"PANID_DEFINED (0xeeee)\000"
.LASF696:
	.ascii	"UINT_LEAST32_MAX UINT32_MAX\000"
.LASF627:
	.ascii	"__SEGGER_RTL_MAX_HEAP_SIZE (8*1024*1024u)\000"
.LASF616:
	.ascii	"__SEGGER_RTL_SIZEOF_WCHAR_T __SIZEOF_WCHAR_T__\000"
.LASF505:
	.ascii	"__SEGGER_RTL_FP_ABI 2\000"
.LASF859:
	.ascii	"CELLLIST_MAX_LEN 5\000"
.LASF126:
	.ascii	"__INT_FAST8_MAX__ 0x7fffffff\000"
.LASF1085:
	.ascii	"ERR_FRAG_REASSEMBLY_OR_VRB_TIMEOUT\000"
.LASF707:
	.ascii	"UINT_FAST16_MAX UINT32_MAX\000"
.LASF735:
	.ascii	"OPENWSN_CINFRARED_C (0)\000"
.LASF788:
	.ascii	"__PACKED_UNION union __attribute__((packed, aligned"
	.ascii	"(1)))\000"
.LASF150:
	.ascii	"__FLT_MIN_10_EXP__ (-37)\000"
.LASF1002:
	.ascii	"IANA_ICMPv6_ECHO_REPLY\000"
.LASF1189:
	.ascii	"l2_ASNpayload\000"
.LASF803:
	.ascii	"__CMSIS_GCC_RW_REG(r) \"+r\" (r)\000"
.LASF701:
	.ascii	"INT_FAST16_MAX INT32_MAX\000"
.LASF967:
	.ascii	"OPENWSN_SCHEDULER_TYPES_H \000"
.LASF970:
	.ascii	"signed char\000"
.LASF926:
	.ascii	"PRF_DIO_C 0<<0\000"
.LASF972:
	.ascii	"uint8_t\000"
.LASF1186:
	.ascii	"l2_sixtop_command\000"
.LASF443:
	.ascii	"__ARM_FEATURE_FMA 1\000"
.LASF191:
	.ascii	"__LDBL_EPSILON__ 1.1\000"
.LASF380:
	.ascii	"__GNUC_STDC_INLINE__ 1\000"
.LASF523:
	.ascii	"__SEGGER_RTL_REQUEST_INLINE __inline__\000"
.LASF288:
	.ascii	"__ULFRACT_IBIT__ 0\000"
.LASF272:
	.ascii	"__FRACT_FBIT__ 15\000"
.LASF695:
	.ascii	"UINT_LEAST16_MAX UINT16_MAX\000"
.LASF161:
	.ascii	"__FLT_HAS_QUIET_NAN__ 1\000"
.LASF591:
	.ascii	"__SEGGER_RTL_INCLUDE_C_API 1\000"
.LASF7:
	.ascii	"__GNUC_PATCHLEVEL__ 1\000"
.LASF389:
	.ascii	"__GCC_ATOMIC_CHAR32_T_LOCK_FREE 2\000"
.LASF767:
	.ascii	"bool uint8_t\000"
.LASF15:
	.ascii	"__FINITE_MATH_ONLY__ 0\000"
.LASF754:
	.ascii	"ADAPTIVE_MSF (0)\000"
.LASF120:
	.ascii	"__UINT_LEAST16_MAX__ 0xffff\000"
.LASF1279:
	.ascii	"PCKTFORWARD\000"
.LASF1094:
	.ascii	"ERR_SIXTOP_REQUEST\000"
.LASF1069:
	.ascii	"ERR_6LORH_DEADLINE_EXPIRED\000"
.LASF724:
	.ascii	"UINT32_C(x) (x ##u)\000"
.LASF1044:
	.ascii	"COMPONENT_CEXAMPLE\000"
.LASF477:
	.ascii	"NRF52840_DK 1\000"
.LASF702:
	.ascii	"INT_FAST32_MIN INT32_MIN\000"
.LASF332:
	.ascii	"__LLACCUM_FBIT__ 31\000"
.LASF371:
	.ascii	"__UHA_IBIT__ 8\000"
.LASF235:
	.ascii	"__FLT64_MAX_10_EXP__ 308\000"
.LASF1351:
	.ascii	"myprefix\000"
.LASF1221:
	.ascii	"IPHC_HLIM_1\000"
.LASF1145:
	.ascii	"byte4\000"
.LASF1013:
	.ascii	"COMPONENT_OPENWSN\000"
.LASF973:
	.ascii	"unsigned char\000"
.LASF3:
	.ascii	"__STDC_UTF_32__ 1\000"
.LASF244:
	.ascii	"__FLT64_HAS_QUIET_NAN__ 1\000"
.LASF303:
	.ascii	"__SACCUM_IBIT__ 8\000"
.LASF764:
	.ascii	"SCHEDULER_DEBUG_ENABLE (0)\000"
.LASF152:
	.ascii	"__FLT_MAX_10_EXP__ 38\000"
.LASF984:
	.ascii	"infouCName\000"
.LASF507:
	.ascii	"__SEGGER_RTL_FLT_SELECT(HEX,DEC) HEX\000"
.LASF1042:
	.ascii	"COMPONENT_OSCORE\000"
.LASF167:
	.ascii	"__DBL_MIN_10_EXP__ (-307)\000"
.LASF898:
	.ascii	"LOG_ERROR(component,message,p1,p2) openserial_print"
	.ascii	"Log(L_ERROR, (component), (message), (p1), (p2))\000"
.LASF516:
	.ascii	"__SEGGER_RTL_UMULL_X(x,y) ((__SEGGER_RTL_U64)(__SEG"
	.ascii	"GER_RTL_U32)(x) * (__SEGGER_RTL_U32)(y))\000"
.LASF130:
	.ascii	"__INT_FAST32_MAX__ 0x7fffffff\000"
.LASF10:
	.ascii	"__ATOMIC_SEQ_CST 5\000"
.LASF778:
	.ascii	"__CMSIS_GCC_H \000"
.LASF887:
	.ascii	"SERFRAME_MOTE2PC_CRITICAL ((uint8_t)'C')\000"
.LASF783:
	.ascii	"__NO_RETURN __attribute__((__noreturn__))\000"
.LASF1361:
	.ascii	"C:\\Users\\16603\\Desktop\\HKUSTGZ\\IOTA5109-WSN\\o"
	.ascii	"penwsnProj\\mywsn\\projects\\nrf52840_dk\000"
.LASF804:
	.ascii	"__CMSIS_GCC_USE_REG(r) \"r\" (r)\000"
.LASF872:
	.ascii	"HEADER_TERMINATION_2_IE 0x3F80\000"
.LASF536:
	.ascii	"__SEGGER_RTL_CORE_HAS_CBZ_CBNZ 1\000"
.LASF677:
	.ascii	"INT64_MIN (-9223372036854775807LL-1)\000"
.LASF513:
	.ascii	"__SEGGER_RTL_SMLAL(lo,hi,x0,x1) do { __asm__( \"sml"
	.ascii	"al %0, %1, %2, %3\" : \"+r\"(lo), \"+r\"(hi) : \"r\""
	.ascii	"((unsigned)(x0)), \"r\"((unsigned)(x1)) ); } while "
	.ascii	"(0)\000"
.LASF851:
	.ascii	"OPENWSN_VERSION_MINOR 25\000"
.LASF319:
	.ascii	"__UACCUM_MIN__ 0.0UK\000"
.LASF871:
	.ascii	"HEADER_TERMINATION_1_IE 0x3F00\000"
.LASF726:
	.ascii	"INTMAX_C(x) (x ##LL)\000"
.LASF1220:
	.ascii	"IPHC_HLIM_INLINE\000"
.LASF755:
	.ascii	"IEEE802154E_SINGLE_CHANNEL 0\000"
.LASF1359:
	.ascii	"GNU C99 11.2.1 20220111 -fmessage-length=0 -std=gnu"
	.ascii	"99 -mcpu=cortex-m4 -mlittle-endian -mfloat-abi=hard"
	.ascii	" -mfpu=fpv4-sp-d16 -mthumb -mtp=soft -mfp16-format="
	.ascii	"ieee -munaligned-access -gdwarf-4 -g3 -gpubnames -f"
	.ascii	"omit-frame-pointer -fno-dwarf2-cfi-asm -ffunction-s"
	.ascii	"ections -fdata-sections -fshort-enums -fno-common\000"
.LASF1267:
	.ascii	"routing_header\000"
.LASF801:
	.ascii	"__VECTOR_TABLE_ATTRIBUTE __attribute((used, section"
	.ascii	"(\".vectors\")))\000"
.LASF721:
	.ascii	"INT64_C(x) (x ##LL)\000"
.LASF273:
	.ascii	"__FRACT_IBIT__ 0\000"
.LASF175:
	.ascii	"__DBL_DENORM_MIN__ ((double)1.1)\000"
.LASF782:
	.ascii	"__STATIC_FORCEINLINE __attribute__((always_inline))"
	.ascii	" static inline\000"
.LASF664:
	.ascii	"__SEGGER_RTL_CORE_HAS_IDIV_X 0\000"
.LASF673:
	.ascii	"INT16_MIN (-32767-1)\000"
.LASF19:
	.ascii	"__SIZEOF_SHORT__ 2\000"
.LASF1290:
	.ascii	"L_WARNING\000"
.LASF1084:
	.ascii	"ERR_FRAG_STORED\000"
.LASF62:
	.ascii	"__INT_FAST64_TYPE__ long long int\000"
.LASF496:
	.ascii	"__SEGGER_RTL_INCLUDE_AEABI_API 2\000"
.LASF904:
	.ascii	"__PACKETFUNCTIONS_H \000"
.LASF1143:
	.ascii	"dagrank_t\000"
.LASF1027:
	.ascii	"COMPONENT_SIXTOP_RES\000"
.LASF326:
	.ascii	"__LACCUM_EPSILON__ 0x1P-31LK\000"
.LASF741:
	.ascii	"OPENWSN_UECHO_C (0)\000"
.LASF510:
	.ascii	"__SEGGER_RTL_CORE_HAS_EXT_MUL 1\000"
.LASF731:
	.ascii	"OPENWSN_DEBUG_LEVEL 6\000"
.LASF1275:
	.ascii	"flags\000"
.LASF1083:
	.ascii	"ERR_FRAG_FAST_FORWARD\000"
.LASF485:
	.ascii	"__SEGGER_RTL_STDINT_H \000"
.LASF398:
	.ascii	"__PRAGMA_REDEFINE_EXTNAME 1\000"
.LASF1217:
	.ascii	"IPHC_NH_INLINE\000"
.LASF480:
	.ascii	"OPENWSN_UDP_C 1\000"
.LASF968:
	.ascii	"char\000"
.LASF373:
	.ascii	"__USA_IBIT__ 16\000"
.LASF1147:
	.ascii	"bytes0and1\000"
.LASF384:
	.ascii	"__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 1\000"
.LASF1316:
	.ascii	"memset\000"
.LASF580:
	.ascii	"__WIDTH_INT 0\000"
.LASF952:
	.ascii	"BADNEIGHBORMAXRSSI -70\000"
.LASF642:
	.ascii	"__SEGGER_RTL_RODATA_IS_RW 0\000"
.LASF1323:
	.ascii	"ipv6_outer_header\000"
.LASF66:
	.ascii	"__UINT_FAST64_TYPE__ long long unsigned int\000"
.LASF1294:
	.ascii	"all_routers_multicast\000"
.LASF1299:
	.ascii	"neighbors_isStableNeighbor\000"
.LASF511:
	.ascii	"__SEGGER_RTL_SMULL_HI(x0,x1) ({ long __trash, __hi;"
	.ascii	" __asm__( \"smull %0, %1, %2, %3\" : \"=r\"(__trash"
	.ascii	"), \"=r\"(__hi) : \"r\"((unsigned)(x0)), \"r\"((uns"
	.ascii	"igned)(x1)) ); __hi; })\000"
.LASF1030:
	.ascii	"COMPONENT_IPHC\000"
.LASF362:
	.ascii	"__HA_FBIT__ 7\000"
.LASF451:
	.ascii	"__FDPIC__\000"
.LASF493:
	.ascii	"__SEGGER_RTL_NO_BUILTIN __attribute__((optimize(\"-"
	.ascii	"fno-tree-loop-distribute-patterns\")))\000"
.LASF1249:
	.ascii	"ELECTIVE_6LoRH\000"
.LASF229:
	.ascii	"__FLT32_IS_IEC_60559__ 2\000"
.LASF611:
	.ascii	"__SEGGER_RTL_SIZEOF_PTR 4\000"
.LASF257:
	.ascii	"__FLT32X_DENORM_MIN__ 1.1\000"
.LASF1302:
	.ascii	"icmpv6rpl_getMyDAGrank\000"
.LASF202:
	.ascii	"__FLT16_MAX_10_EXP__ 4\000"
.LASF612:
	.ascii	"__SEGGER_RTL_PTRDIFF_T __PTRDIFF_TYPE__\000"
.LASF268:
	.ascii	"__USFRACT_IBIT__ 0\000"
.LASF1362:
	.ascii	"forwarding_init\000"
.LASF867:
	.ascii	"RPL_HOPBYHOP_HEADER_OPTION_TYPE 0x63\000"
.LASF1120:
	.ascii	"ERR_INVALID_PACKET_FROM_RADIO\000"
.LASF269:
	.ascii	"__USFRACT_MIN__ 0.0UHR\000"
.LASF1121:
	.ascii	"ERR_GETDATA_ASKS_TOO_FEW_BYTES\000"
.LASF465:
	.ascii	"__SIZEOF_WCHAR_T 4\000"
.LASF445:
	.ascii	"__ARM_NEON\000"
.LASF102:
	.ascii	"__UINT8_MAX__ 0xff\000"
.LASF337:
	.ascii	"__ULLACCUM_FBIT__ 32\000"
.LASF1352:
	.ascii	"myadd64\000"
.LASF184:
	.ascii	"__LDBL_MAX_EXP__ 1024\000"
.LASF582:
	.ascii	"__WIDTH_LONG_LONG 2\000"
.LASF554:
	.ascii	"__SEGGER_RTL_ALIGN_REM(X) 0\000"
.LASF660:
	.ascii	"__SEGGER_RTL_RODATA const\000"
.LASF894:
	.ascii	"LOG_VERBOSE(component,message,p1,p2) openserial_pri"
	.ascii	"ntLog(L_VERBOSE, (component), (message), (p1), (p2)"
	.ascii	")\000"
.LASF176:
	.ascii	"__DBL_HAS_DENORM__ 1\000"
.LASF1276:
	.ascii	"rplInstanceID\000"
.LASF902:
	.ascii	"ACTION_NO 'N'\000"
.LASF1115:
	.ascii	"ERR_WDDATADURATION_OVERFLOWS\000"
.LASF603:
	.ascii	"__SEGGER_RTL_LEAST_U8 unsigned\000"
.LASF1292:
	.ascii	"L_VERBOSE\000"
.LASF793:
	.ascii	"__UNALIGNED_UINT32_READ(addr) (((const struct T_UIN"
	.ascii	"T32_READ *)(const void *)(addr))->v)\000"
.LASF628:
	.ascii	"__SEGGER_RTL_ATEXIT_COUNT 1\000"
.LASF366:
	.ascii	"__DA_FBIT__ 31\000"
.LASF1208:
	.ascii	"l1_crc\000"
.LASF672:
	.ascii	"INT8_MAX 127\000"
.LASF69:
	.ascii	"__GXX_ABI_VERSION 1016\000"
.LASF212:
	.ascii	"__FLT16_IS_IEC_60559__ 2\000"
.LASF109:
	.ascii	"__INT_LEAST16_MAX__ 0x7fff\000"
.LASF666:
	.ascii	"__SEGGER_RTL_CORE_HAS_IDIVM_X 0\000"
.LASF807:
	.ascii	"__WFE() __ASM volatile (\"wfe\")\000"
.LASF1206:
	.ascii	"l1_rssi\000"
.LASF350:
	.ascii	"__TQ_FBIT__ 127\000"
.LASF652:
	.ascii	"__SEGGER_RTL_U64_MK(H,L) (((__SEGGER_RTL_U64)(__SEG"
	.ascii	"GER_RTL_U32)(H) << 32) + (__SEGGER_RTL_U32)(L))\000"
.LASF868:
	.ascii	"OPENWSN_OPENQUEUE_H \000"
.LASF341:
	.ascii	"__ULLACCUM_EPSILON__ 0x1P-32ULLK\000"
.LASF648:
	.ascii	"__SEGGER_RTL_SCALED_INTEGER 0\000"
.LASF1226:
	.ascii	"IPHC_CID_YES\000"
.LASF909:
	.ascii	"MAX_TICKS_IN_SINGLE_CLOCK PORT_MAX_TICKS_IN_SINGLE_"
	.ascii	"CLOCK\000"
.LASF686:
	.ascii	"INT_LEAST8_MIN INT8_MIN\000"
.LASF632:
	.ascii	"__SEGGER_RTL_NAN_FORMAT __SEGGER_RTL_NAN_FORMAT_IEE"
	.ascii	"E\000"
.LASF123:
	.ascii	"__UINT32_C(c) c ## UL\000"
.LASF1038:
	.ascii	"COMPONENT_SOCK_TO_UDP\000"
.LASF1128:
	.ascii	"ERR_FREEING_UNUSED\000"
.LASF1173:
	.ascii	"l3_useSourceRouting\000"
.LASF1026:
	.ascii	"COMPONENT_SCHEDULE\000"
.LASF1129:
	.ascii	"ERR_FREEING_ERROR\000"
.LASF238:
	.ascii	"__FLT64_NORM_MAX__ 1.1\000"
.LASF1011:
	.ascii	"IANA_UNDEFINED\000"
.LASF1355:
	.ascii	"p_dest\000"
.LASF806:
	.ascii	"__WFI() __ASM volatile (\"wfi\")\000"
.LASF1353:
	.ascii	"temp_dest_prefix\000"
.LASF431:
	.ascii	"__ARM_ARCH_ISA_THUMB\000"
.LASF1106:
	.ascii	"ERR_WRONG_STATE_IN_ENDFRAME_SYNC\000"
.LASF951:
	.ascii	"MAXPREFERENCE 2\000"
.LASF1269:
	.ascii	"hop_limit\000"
.LASF321:
	.ascii	"__UACCUM_EPSILON__ 0x1P-16UK\000"
.LASF1312:
	.ascii	"iphc_prependIPv6Header\000"
.LASF644:
	.ascii	"__SEGGER_RTL_SIDE_BY_SIZE 0\000"
.LASF656:
	.ascii	"__SEGGER_RTL_NAN __builtin_nanf(\"0x7fc00000\")\000"
.LASF391:
	.ascii	"__GCC_ATOMIC_SHORT_LOCK_FREE 2\000"
.LASF1105:
	.ascii	"ERR_LARGE_TIMECORRECTION\000"
.LASF942:
	.ascii	"PC3_B_DAO_Transit_Info 0<<2\000"
.LASF345:
	.ascii	"__HQ_IBIT__ 0\000"
.LASF559:
	.ascii	"__SEGGER_RTL_DIFF_INDEX(X,Y) __SEGGER_RTL_DIFF_INDE"
	.ascii	"X_func(X, Y)\000"
.LASF307:
	.ascii	"__USACCUM_FBIT__ 8\000"
.LASF699:
	.ascii	"INT_FAST8_MAX INT8_MAX\000"
.LASF395:
	.ascii	"__GCC_ATOMIC_TEST_AND_SET_TRUEVAL 1\000"
.LASF730:
	.ascii	"OPENWSN_CONFIG_H \000"
.LASF304:
	.ascii	"__SACCUM_MIN__ (-0X1P7HK-0X1P7HK)\000"
.LASF1201:
	.ascii	"l2_keySource\000"
.LASF320:
	.ascii	"__UACCUM_MAX__ 0XFFFFFFFFP-16UK\000"
.LASF948:
	.ascii	"RPL_OPTION_PIO 0x8\000"
.LASF487:
	.ascii	"__SEGGER_RTL_LIBC_CONF_DEFAULTS_H \000"
.LASF528:
	.ascii	"__SEGGER_RTL_CLZ_U32(X) __SEGGER_RTL_CLZ_U32_safe_i"
	.ascii	"nline(X)\000"
.LASF995:
	.ascii	"ADDR_ANYCAST\000"
.LASF227:
	.ascii	"__FLT32_HAS_QUIET_NAN__ 1\000"
.LASF459:
	.ascii	"__ARM_FEATURE_MATMUL_INT8\000"
.LASF885:
	.ascii	"SERFRAME_MOTE2PC_SUCCESS ((uint8_t)'U')\000"
.LASF573:
	.ascii	"__SEGGER_RTL_SIGNAL_SIGTERM __aeabi_SIGTERM\000"
.LASF194:
	.ascii	"__LDBL_HAS_INFINITY__ 1\000"
.LASF368:
	.ascii	"__TA_FBIT__ 63\000"
.LASF723:
	.ascii	"UINT16_C(x) (x ##u)\000"
.LASF251:
	.ascii	"__FLT32X_MAX_10_EXP__ 308\000"
.LASF1117:
	.ascii	"ERR_WDRADIOTX_OVERFLOWS\000"
.LASF537:
	.ascii	"__SEGGER_RTL_CORE_HAS_TBB_TBH 1\000"
.LASF452:
	.ascii	"__ARM_ARCH_EXT_IDIV__ 1\000"
.LASF849:
	.ascii	"AF_MAX AF_NUMOF\000"
.LASF605:
	.ascii	"__SEGGER_RTL_I32_C(X) X\000"
.LASF1045:
	.ascii	"COMPONENT_CINFO\000"
.LASF1061:
	.ascii	"ERR_REPLAY_FAILED\000"
.LASF751:
	.ascii	"OPENWSN_FORCETOPOLOGY_C (0)\000"
.LASF765:
	.ascii	"OPENWSN_CHECK_CONFIG_H \000"
.LASF96:
	.ascii	"__SIG_ATOMIC_MIN__ (-__SIG_ATOMIC_MAX__ - 1)\000"
.LASF635:
	.ascii	"__SEGGER_RTL_BitcastToU64(X) __SEGGER_RTL_BitcastTo"
	.ascii	"U64_inline(X)\000"
.LASF118:
	.ascii	"__UINT_LEAST8_MAX__ 0xff\000"
.LASF910:
	.ascii	"ERROR_NO_AVAILABLE_ENTRIES 255\000"
.LASF663:
	.ascii	"__SEGGER_RTL_CORE_HAS_UDIV_X 0\000"
.LASF798:
	.ascii	"__INITIAL_SP __StackTop\000"
.LASF625:
	.ascii	"__SEGGER_RTL_FORMAT_WIDTH_PRECISION\000"
.LASF906:
	.ascii	"OPENWSN_ICMPv6RPL_H \000"
.LASF822:
	.ascii	"PORT_TICS_PER_MS 33\000"
.LASF162:
	.ascii	"__FP_FAST_FMAF 1\000"
.LASF937:
	.ascii	"PC1_A_DAO_Transit_Info 0<<7\000"
.LASF1073:
	.ascii	"ERR_6LOWPAN_UNSUPPORTED\000"
.LASF823:
	.ascii	"PORT_US_PER_TICK 30\000"
.LASF1207:
	.ascii	"l1_lqi\000"
.LASF491:
	.ascii	"__SEGGER_RTL_ISA_T32 1\000"
.LASF831:
	.ascii	"UART_PRIORITY 2\000"
.LASF568:
	.ascii	"__SEGGER_RTL_SIGNAL_SIGABRT __aeabi_SIGABRT\000"
.LASF1331:
	.ascii	"nextAddr\000"
.LASF1254:
	.ascii	"RH3_6LOTH_TYPE_0\000"
.LASF1157:
	.ascii	"prefix\000"
.LASF742:
	.ascii	"OPENWSN_UEXPIRATION_C (0)\000"
.LASF111:
	.ascii	"__INT_LEAST16_WIDTH__ 16\000"
.LASF287:
	.ascii	"__ULFRACT_FBIT__ 32\000"
.LASF1293:
	.ascii	"linklocalprefix\000"
.LASF1124:
	.ascii	"ERR_BUSY_SENDING\000"
.LASF814:
	.ascii	"__PKHBT(ARG1,ARG2,ARG3) ( ((((uint32_t)(ARG1)) ) & "
	.ascii	"0x0000FFFFUL) | ((((uint32_t)(ARG2)) << (ARG3)) & 0"
	.ascii	"xFFFF0000UL) )\000"
.LASF1086:
	.ascii	"ERR_FRAG_FRAGMENTING\000"
.LASF1317:
	.ascii	"packetfunctions_isAllHostsMulticast\000"
.LASF174:
	.ascii	"__DBL_EPSILON__ ((double)1.1)\000"
.LASF855:
	.ascii	"LENGTH_ADDR16b 2\000"
.LASF1332:
	.ascii	"temp_prefix\000"
.LASF547:
	.ascii	"__SEGGER_RTL_PREFER_BRANCH_FREE_CODE 1\000"
.LASF271:
	.ascii	"__USFRACT_EPSILON__ 0x1P-8UHR\000"
.LASF688:
	.ascii	"INT_LEAST16_MIN INT16_MIN\000"
.LASF587:
	.ascii	"__SEGGER_RTL_FORCE_SOFT_FLOAT 0\000"
.LASF1240:
	.ascii	"IPHC_DAC_STATEFUL\000"
.LASF771:
	.ascii	"BEGIN_PACK _Pragma(\"pack(1)\");\000"
.LASF1159:
	.ascii	"open_addr_t\000"
.LASF1235:
	.ascii	"IPHC_M_enums\000"
.LASF1341:
	.ascii	"fw_SendOrfw_Rcv\000"
.LASF105:
	.ascii	"__UINT64_MAX__ 0xffffffffffffffffULL\000"
.LASF738:
	.ascii	"OPENWSN_CSTORM_C (0)\000"
.LASF835:
	.ascii	"PORT_maxRxAckPrepare 13\000"
.LASF104:
	.ascii	"__UINT32_MAX__ 0xffffffffUL\000"
.LASF622:
	.ascii	"__SEGGER_RTL_FORMAT_WIDTH_PRECISION 1\000"
.LASF1177:
	.ascii	"l2_dsn\000"
.LASF1050:
	.ascii	"COMPONENT_UECHO\000"
.LASF954:
	.ascii	"SWITCHSTABILITYTHRESHOLD 3\000"
.LASF601:
	.ascii	"__SEGGER_RTL_LEAST_U16 unsigned\000"
.LASF106:
	.ascii	"__INT_LEAST8_MAX__ 0x7f\000"
.LASF819:
	.ascii	"PORT_TIMER_WIDTH uint32_t\000"
.LASF396:
	.ascii	"__GCC_ATOMIC_POINTER_LOCK_FREE 2\000"
.LASF403:
	.ascii	"__ARM_FEATURE_QBIT 1\000"
.LASF1079:
	.ascii	"ERR_WRONG_DIRECTION\000"
.LASF812:
	.ascii	"__SSAT16(ARG1,ARG2) ({ int32_t __RES, __ARG1 = (ARG"
	.ascii	"1); __ASM (\"ssat16 %0, %1, %2\" : \"=r\" (__RES) :"
	.ascii	" \"I\" (ARG2), \"r\" (__ARG1) ); __RES; })\000"
.LASF11:
	.ascii	"__ATOMIC_ACQUIRE 2\000"
.LASF410:
	.ascii	"__ARM_FEATURE_COMPLEX\000"
.LASF808:
	.ascii	"__SEV() __ASM volatile (\"sev\")\000"
.LASF153:
	.ascii	"__FLT_DECIMAL_DIG__ 9\000"
.LASF449:
	.ascii	"__ARM_PCS_VFP 1\000"
.LASF815:
	.ascii	"__PKHTB(ARG1,ARG2,ARG3) ( ((((uint32_t)(ARG1)) ) & "
	.ascii	"0xFFFF0000UL) | ((((uint32_t)(ARG2)) >> (ARG3)) & 0"
	.ascii	"x0000FFFFUL) )\000"
.LASF917:
	.ascii	"SPLITE_TIMER_DURATION 15\000"
.LASF420:
	.ascii	"__ARM_SIZEOF_WCHAR_T 4\000"
.LASF1122:
	.ascii	"ERR_WRONG_CRC_INPUT\000"
.LASF566:
	.ascii	"__SEGGER_RTL_WR_PARTIAL_WORD(A,W,N) __SEGGER_RTL_WR"
	.ascii	"_PARTIAL_WORD_func(A, W, N)\000"
.LASF1098:
	.ascii	"ERR_UNSUPPORTED_METADATA\000"
.LASF122:
	.ascii	"__UINT_LEAST32_MAX__ 0xffffffffUL\000"
.LASF620:
	.ascii	"__SEGGER_RTL_FORMAT_FLOAT_WIDTH __WIDTH_DOUBLE\000"
.LASF698:
	.ascii	"INT_FAST8_MIN INT8_MIN\000"
.LASF1056:
	.ascii	"COMPONENT_UMONITOR\000"
.LASF466:
	.ascii	"__SES_ARM 1\000"
.LASF117:
	.ascii	"__INT_LEAST64_WIDTH__ 64\000"
.LASF160:
	.ascii	"__FLT_HAS_INFINITY__ 1\000"
.LASF506:
	.ascii	"__SEGGER_RTL_FP_HW 1\000"
.LASF1174:
	.ascii	"l2_sendDoneError\000"
.LASF1285:
	.ascii	"K_FLAG\000"
.LASF98:
	.ascii	"__INT8_MAX__ 0x7f\000"
.LASF768:
	.ascii	"__PRAGMA__(x) _Pragma(#x)\000"
.LASF8:
	.ascii	"__VERSION__ \"11.2.1 20220111\"\000"
.LASF408:
	.ascii	"__ARM_FEATURE_CRC32\000"
.LASF264:
	.ascii	"__SFRACT_MIN__ (-0.5HR-0.5HR)\000"
.LASF365:
	.ascii	"__SA_IBIT__ 16\000"
.LASF64:
	.ascii	"__UINT_FAST16_TYPE__ unsigned int\000"
.LASF142:
	.ascii	"__GCC_IEC_559_COMPLEX 0\000"
.LASF412:
	.ascii	"__ARM_FEATURE_MVE\000"
.LASF1131:
	.ascii	"ERR_WRONG_ADDR_TYPE\000"
.LASF874:
	.ascii	"QUEUELENGTH PACKETQUEUE_LENGTH\000"
.LASF48:
	.ascii	"__UINT16_TYPE__ short unsigned int\000"
.LASF588:
	.ascii	"__SEGGER_RTL_CONFIG_CODE_COVERAGE 0\000"
.LASF1101:
	.ascii	"ERR_WRONG_CELLTYPE\000"
.LASF1223:
	.ascii	"IPHC_HLIM_255\000"
.LASF482:
	.ascii	"OPENWSN_OPENDEFS_H \000"
.LASF645:
	.ascii	"__SEGGER_RTL_SPECIALIZE_COMPARES 1\000"
.LASF919:
	.ascii	"DIO_PERIOD 10000\000"
.LASF189:
	.ascii	"__LDBL_NORM_MAX__ 1.1\000"
.LASF565:
	.ascii	"__SEGGER_RTL_WR_WORD(A,W) __SEGGER_RTL_WR_WORD_func"
	.ascii	"(A, W)\000"
.LASF641:
	.ascii	"__SEGGER_RTL_NO_RETURN \000"
.LASF1088:
	.ascii	"ERR_SCHEDULE_ADD_DUPLICATE_SLOT\000"
.LASF144:
	.ascii	"__FLT_EVAL_METHOD_TS_18661_3__ 0\000"
.LASF81:
	.ascii	"__SCHAR_WIDTH__ 8\000"
.LASF900:
	.ascii	"OPENWSN_IDMANAGER_H \000"
.LASF1242:
	.ascii	"IPHC_DAM_128B\000"
.LASF333:
	.ascii	"__LLACCUM_IBIT__ 32\000"
.LASF402:
	.ascii	"__ARM_FEATURE_DSP 1\000"
.LASF276:
	.ascii	"__FRACT_EPSILON__ 0x1P-15R\000"
.LASF839:
	.ascii	"PORT_delayRx 0\000"
.LASF1015:
	.ascii	"COMPONENT_OPENQUEUE\000"
.LASF100:
	.ascii	"__INT32_MAX__ 0x7fffffffL\000"
.LASF1291:
	.ascii	"L_INFO\000"
.LASF85:
	.ascii	"__LONG_LONG_WIDTH__ 64\000"
.LASF1070:
	.ascii	"ERR_6LORH_DEADLINE_DROPPED\000"
.LASF747:
	.ascii	"OPENWSN_COAP_PORT_DEFAULT (5683)\000"
.LASF988:
	.ascii	"E_FAIL\000"
.LASF1187:
	.ascii	"l2_sixtop_cellOptions\000"
.LASF1066:
	.ascii	"ERR_INVALID_CHECKSUM\000"
.LASF1248:
	.ascii	"CRITICAL_6LORH\000"
.LASF224:
	.ascii	"__FLT32_DENORM_MIN__ 1.1\000"
.LASF1289:
	.ascii	"L_SUCCESS\000"
.LASF140:
	.ascii	"__UINTPTR_MAX__ 0xffffffffU\000"
.LASF653:
	.ascii	"__SEGGER_RTL_I64_H(X) ((__SEGGER_RTL_I32)((__SEGGER"
	.ascii	"_RTL_I64)(X) >> 32))\000"
.LASF661:
	.ascii	"__SEGGER_RTL_SUBNORMALS_READ_AS_ZERO 1\000"
.LASF58:
	.ascii	"__UINT_LEAST64_TYPE__ long long unsigned int\000"
.LASF729:
	.ascii	"WCHAR_MIN __WCHAR_MIN__\000"
.LASF838:
	.ascii	"PORT_delayTx 8\000"
.LASF267:
	.ascii	"__USFRACT_FBIT__ 8\000"
.LASF1090:
	.ascii	"ERR_NO_SENT_PACKET\000"
.LASF538:
	.ascii	"__SEGGER_RTL_CORE_HAS_UXT_SXT 1\000"
.LASF52:
	.ascii	"__INT_LEAST16_TYPE__ short int\000"
.LASF486:
	.ascii	"__SEGGER_RTL_H \000"
.LASF1058:
	.ascii	"ERR_JOINED\000"
.LASF643:
	.ascii	"__SEGGER_RTL_USE_PARA(Para) (void)Para\000"
.LASF168:
	.ascii	"__DBL_MAX_EXP__ 1024\000"
.LASF12:
	.ascii	"__ATOMIC_RELEASE 3\000"
.LASF740:
	.ascii	"OPENWSN_RRT_C (0)\000"
.LASF1326:
	.ascii	"next_type\000"
.LASF258:
	.ascii	"__FLT32X_HAS_DENORM__ 1\000"
.LASF147:
	.ascii	"__FLT_MANT_DIG__ 24\000"
.LASF992:
	.ascii	"ADDR_128B\000"
.LASF1162:
	.ascii	"payload\000"
.LASF400:
	.ascii	"__SIZEOF_WINT_T__ 4\000"
.LASF844:
	.ascii	"AF_UNIX AF_UNIX\000"
.LASF1127:
	.ascii	"ERR_NO_FREE_TIMER_OR_QUEUE_ENTRY\000"
.LASF957:
	.ascii	"MAXDAGRANK 0xffff\000"
.LASF1053:
	.ascii	"COMPONENT_SECURITY\000"
.LASF829:
	.ascii	"RTC_PRIORITY 0\000"
.LASF895:
	.ascii	"LOG_INFO(component,message,p1,p2) openserial_printL"
	.ascii	"og(L_INFO, (component), (message), (p1), (p2))\000"
.LASF1113:
	.ascii	"ERR_MAXRXDATAPREPARE_OVERFLOWS\000"
.LASF1078:
	.ascii	"ERR_LOOP_DETECTED\000"
.LASF1016:
	.ascii	"COMPONENT_OPENSERIAL\000"
.LASF692:
	.ascii	"INT_LEAST64_MIN INT64_MIN\000"
.LASF530:
	.ascii	"__SEGGER_RTL_CORE_HAS_UQADD_UQSUB 1\000"
.LASF564:
	.ascii	"__SEGGER_RTL_RD_WORD(A) __SEGGER_RTL_RD_WORD_func(A"
	.ascii	")\000"
.LASF101:
	.ascii	"__INT64_MAX__ 0x7fffffffffffffffLL\000"
.LASF404:
	.ascii	"__ARM_FEATURE_SAT 1\000"
.LASF1102:
	.ascii	"ERR_IEEE154_UNSUPPORTED\000"
.LASF298:
	.ascii	"__ULLFRACT_IBIT__ 0\000"
.LASF596:
	.ascii	"__SEGGER_RTL_U16 unsigned short\000"
.LASF1071:
	.ascii	"ERR_UNEXPECTED_DAO\000"
.LASF478:
	.ascii	"BOARD_PCA10056 1\000"
.LASF865:
	.ascii	"IPv6HOP_HDR_LEN 2\000"
.LASF1104:
	.ascii	"ERR_SYNCHRONIZED\000"
.LASF966:
	.ascii	"TASK_LIST_DEPTH 10\000"
.LASF439:
	.ascii	"__ARM_FP16_ARGS 1\000"
.LASF1035:
	.ascii	"COMPONENT_ICMPv6ROUTER\000"
.LASF5:
	.ascii	"__GNUC__ 11\000"
.LASF781:
	.ascii	"__STATIC_INLINE static inline\000"
.LASF241:
	.ascii	"__FLT64_DENORM_MIN__ 1.1\000"
.LASF959:
	.ascii	"MINHOPRANKINCREASE 256\000"
.LASF745:
	.ascii	"OPENWSN_CJOIN_C (0)\000"
.LASF862:
	.ascii	"OPENWSN_FORWARDING_H \000"
.LASF470:
	.ascii	"__GNU_LINKER 1\000"
.LASF84:
	.ascii	"__LONG_WIDTH__ 32\000"
.LASF833:
	.ascii	"PORT_TsSlotDuration 656\000"
.LASF613:
	.ascii	"__SEGGER_RTL_SIZE_T __SIZE_TYPE__\000"
.LASF929:
	.ascii	"FLAG_DAO_B 0<<1\000"
.LASF317:
	.ascii	"__UACCUM_FBIT__ 16\000"
.LASF1274:
	.ascii	"optionType\000"
.LASF281:
	.ascii	"__UFRACT_EPSILON__ 0x1P-16UR\000"
.LASF76:
	.ascii	"__WCHAR_MIN__ 0U\000"
.LASF203:
	.ascii	"__FLT16_DECIMAL_DIG__ 5\000"
.LASF192:
	.ascii	"__LDBL_DENORM_MIN__ 1.1\000"
.LASF353:
	.ascii	"__UQQ_IBIT__ 0\000"
.LASF544:
	.ascii	"__SEGGER_RTL_FLOAT32_C_COMPLEX float _Complex\000"
.LASF472:
	.ascii	"_LIBCPP_HAS_NO_OFF_T_FUNCTIONS 1\000"
.LASF393:
	.ascii	"__GCC_ATOMIC_LONG_LOCK_FREE 2\000"
.LASF261:
	.ascii	"__FLT32X_IS_IEC_60559__ 2\000"
.LASF1137:
	.ascii	"ERR_EMPTY_QUEUE_OR_UNKNOWN_TIMER\000"
.LASF425:
	.ascii	"__ARM_ARCH 7\000"
.LASF1014:
	.ascii	"COMPONENT_IDMANAGER\000"
.LASF390:
	.ascii	"__GCC_ATOMIC_WCHAR_T_LOCK_FREE 2\000"
.LASF146:
	.ascii	"__FLT_RADIX__ 2\000"
.LASF979:
	.ascii	"long long int\000"
.LASF1219:
	.ascii	"IPHC_HLIM_enums\000"
.LASF935:
	.ascii	"K_DAO 0<<7\000"
.LASF413:
	.ascii	"__ARM_FEATURE_CMSE\000"
.LASF1110:
	.ascii	"ERR_WRONG_STATE_IN_ENDOFFRAME\000"
.LASF476:
	.ascii	"NRF52840_XXAA 1\000"
.LASF907:
	.ascii	"__OPENTIMERS_H \000"
.LASF542:
	.ascii	"__SEGGER_RTL_FAST_CODE_SECTION(X) __attribute__((__"
	.ascii	"section__(\".fast.\" X)))\000"
.LASF1238:
	.ascii	"IPHC_DAC_enums\000"
.LASF1255:
	.ascii	"RH3_6LOTH_TYPE_1\000"
.LASF1256:
	.ascii	"RH3_6LOTH_TYPE_2\000"
.LASF1257:
	.ascii	"RH3_6LOTH_TYPE_3\000"
.LASF1258:
	.ascii	"RH3_6LOTH_TYPE_4\000"
.LASF1152:
	.ascii	"cellInfo_ht\000"
.LASF914:
	.ascii	"TIMER_TSCH 1\000"
.LASF875:
	.ascii	"BIGQUEUELENGTH 0\000"
.LASF442:
	.ascii	"__ARM_FEATURE_FP16_FML\000"
.LASF866:
	.ascii	"MAXNUM_RH3 3\000"
.LASF61:
	.ascii	"__INT_FAST32_TYPE__ int\000"
.LASF435:
	.ascii	"__ARM_FP\000"
.LASF1190:
	.ascii	"l2_nextHop_payload\000"
.LASF363:
	.ascii	"__HA_IBIT__ 8\000"
.LASF634:
	.ascii	"__SEGGER_RTL_BitcastToF32(X) __SEGGER_RTL_BitcastTo"
	.ascii	"F32_inline(X)\000"
.LASF139:
	.ascii	"__INTPTR_WIDTH__ 32\000"
.LASF394:
	.ascii	"__GCC_ATOMIC_LLONG_LOCK_FREE 1\000"
.LASF555:
	.ascii	"__SEGGER_RTL_UNALIGNED_ATTR __attribute__((__aligne"
	.ascii	"d__(1)))\000"
.LASF916:
	.ascii	"TIMER_NUMBER_NON_GENERAL 2\000"
.LASF1314:
	.ascii	"packetfunctions_isBroadcastMulticast\000"
.LASF756:
	.ascii	"PACKETQUEUE_LENGTH 20\000"
.LASF705:
	.ascii	"INT_FAST64_MAX INT64_MAX\000"
.LASF234:
	.ascii	"__FLT64_MAX_EXP__ 1024\000"
.LASF541:
	.ascii	"__SEGGER_RTL_CORE_HAS_LONG_SHIFT 1\000"
.LASF171:
	.ascii	"__DBL_MAX__ ((double)1.1)\000"
.LASF665:
	.ascii	"__SEGGER_RTL_CORE_HAS_UDIVM_X 0\000"
.LASF115:
	.ascii	"__INT_LEAST64_MAX__ 0x7fffffffffffffffLL\000"
.LASF1281:
	.ascii	"O_FLAG\000"
.LASF944:
	.ascii	"PC4_B_DAO_Transit_Info 0<<0\000"
.LASF636:
	.ascii	"__SEGGER_RTL_BitcastToF64(X) __SEGGER_RTL_BitcastTo"
	.ascii	"F64_inline(X)\000"
.LASF87:
	.ascii	"__WINT_WIDTH__ 32\000"
.LASF46:
	.ascii	"__INT64_TYPE__ long long int\000"
.LASF805:
	.ascii	"__NOP() __ASM volatile (\"nop\")\000"
.LASF190:
	.ascii	"__LDBL_MIN__ 1.1\000"
.LASF24:
	.ascii	"__CHAR_BIT__ 8\000"
.LASF399:
	.ascii	"__SIZEOF_WCHAR_T__ 4\000"
.LASF525:
	.ascii	"__SEGGER_RTL_FLOAT32_ABS(__m) ({ float __d; __asm__"
	.ascii	" __volatile__(\"vabs.f32 %[d], %[m]\" : [d] \"=t\"("
	.ascii	"__d) : [m] \"t\"(__m)); __d; })\000"
.LASF854:
	.ascii	"FALSE 0\000"
.LASF254:
	.ascii	"__FLT32X_NORM_MAX__ 1.1\000"
.LASF915:
	.ascii	"TIMER_GENERAL_PURPOSE 255\000"
.LASF1036:
	.ascii	"COMPONENT_ICMPv6RPL\000"
.LASF927:
	.ascii	"G_DIO 1<<7\000"
.LASF427:
	.ascii	"__GCC_ASM_FLAG_OUTPUTS__ 1\000"
.LASF1202:
	.ascii	"l2_authenticationLength\000"
.LASF280:
	.ascii	"__UFRACT_MAX__ 0XFFFFP-16UR\000"
.LASF691:
	.ascii	"INT_LEAST32_MAX INT32_MAX\000"
.LASF1068:
	.ascii	"ERR_RCVD_ECHO_REPLY\000"
.LASF201:
	.ascii	"__FLT16_MAX_EXP__ 16\000"
.LASF608:
	.ascii	"__SEGGER_RTL_U64_C(X) X ##uLL\000"
.LASF962:
	.ascii	"OPENWSN_ICMPv6_H \000"
.LASF1268:
	.ascii	"hopByhop_option\000"
.LASF263:
	.ascii	"__SFRACT_IBIT__ 0\000"
.LASF604:
	.ascii	"__SEGGER_RTL_LEAST_I8 int\000"
.LASF1077:
	.ascii	"ERR_HOP_LIMIT_REACHED\000"
.LASF792:
	.ascii	"__UNALIGNED_UINT32_WRITE(addr,val) (void)((((struct"
	.ascii	" T_UINT32_WRITE *)(void *)(addr))->v) = (val))\000"
.LASF567:
	.ascii	"__SEGGER_RTL_SIGNAL_MAX 6\000"
.LASF718:
	.ascii	"INT8_C(x) (x)\000"
.LASF29:
	.ascii	"__BYTE_ORDER__ __ORDER_LITTLE_ENDIAN__\000"
.LASF1164:
	.ascii	"is_cjoin_response\000"
.LASF446:
	.ascii	"__ARM_NEON_FP\000"
.LASF310:
	.ascii	"__USACCUM_MAX__ 0XFFFFP-8UHK\000"
.LASF295:
	.ascii	"__LLFRACT_MAX__ 0X7FFFFFFFFFFFFFFFP-63LLR\000"
.LASF998:
	.ascii	"IANA_IPv6ROUTING\000"
.LASF379:
	.ascii	"__USER_LABEL_PREFIX__ \000"
.LASF861:
	.ascii	"IPV6_PACKET_SIZE IEEE802154_FRAME_SIZE\000"
.LASF37:
	.ascii	"__WINT_TYPE__ unsigned int\000"
.LASF358:
	.ascii	"__UDQ_FBIT__ 64\000"
.LASF158:
	.ascii	"__FLT_DENORM_MIN__ 1.1\000"
.LASF282:
	.ascii	"__LFRACT_FBIT__ 31\000"
.LASF185:
	.ascii	"__LDBL_MAX_10_EXP__ 308\000"
.LASF456:
	.ascii	"__ARM_FEATURE_COPROC 15\000"
.LASF678:
	.ascii	"INT64_MAX 9223372036854775807LL\000"
.LASF204:
	.ascii	"__FLT16_MAX__ 1.1\000"
.LASF795:
	.ascii	"__RESTRICT __restrict\000"
.LASF515:
	.ascii	"__SEGGER_RTL_UMULL(lo,hi,x0,x1) do { __asm__( \"umu"
	.ascii	"ll %0, %1, %2, %3\" : \"=r\"(lo), \"=r\"(hi) : \"r\""
	.ascii	"((unsigned)(x0)), \"r\"((unsigned)(x1)) ); } while "
	.ascii	"(0)\000"
.LASF897:
	.ascii	"LOG_SUCCESS(component,message,p1,p2) openserial_pri"
	.ascii	"ntLog(L_SUCCESS, (component), (message), (p1), (p2)"
	.ascii	")\000"
.LASF563:
	.ascii	"__SEGGER_RTL_FILL_TAIL(N,W,C) __SEGGER_RTL_FILL_TAI"
	.ascii	"L_func(N, W, C)\000"
.LASF675:
	.ascii	"INT32_MIN (-2147483647L-1)\000"
.LASF253:
	.ascii	"__FLT32X_MAX__ 1.1\000"
.LASF577:
	.ascii	"__SEGGER_RTL_NAN_FORMAT_IEEE 0\000"
.LASF969:
	.ascii	"unsigned int\000"
.LASF549:
	.ascii	"__SEGGER_RTL_X_assert __aeabi_assert\000"
.LASF275:
	.ascii	"__FRACT_MAX__ 0X7FFFP-15R\000"
.LASF1338:
	.ascii	"sizeRH\000"
.LASF335:
	.ascii	"__LLACCUM_MAX__ 0X7FFFFFFFFFFFFFFFP-31LLK\000"
.LASF149:
	.ascii	"__FLT_MIN_EXP__ (-125)\000"
.LASF114:
	.ascii	"__INT_LEAST32_WIDTH__ 32\000"
.LASF1272:
	.ascii	"header_length\000"
.LASF1246:
	.ascii	"FORMAT_6LORH_enums\000"
.LASF1125:
	.ascii	"ERR_UNEXPECTED_SENDDONE\000"
.LASF1222:
	.ascii	"IPHC_HLIM_64\000"
.LASF448:
	.ascii	"__ARM_ARCH_7EM__ 1\000"
.LASF1112:
	.ascii	"ERR_MAXRXACKPREPARE_OVERFLOWS\000"
.LASF242:
	.ascii	"__FLT64_HAS_DENORM__ 1\000"
.LASF148:
	.ascii	"__FLT_DIG__ 6\000"
.LASF39:
	.ascii	"__UINTMAX_TYPE__ long long unsigned int\000"
.LASF1091:
	.ascii	"ERR_NO_RECEIVED_PACKET\000"
.LASF1126:
	.ascii	"ERR_NO_FREE_PACKET_BUFFER\000"
.LASF797:
	.ascii	"__PROGRAM_START __cmsis_start\000"
.LASF727:
	.ascii	"UINTMAX_C(x) (x ##uLL)\000"
.LASF143:
	.ascii	"__FLT_EVAL_METHOD__ 0\000"
.LASF787:
	.ascii	"__PACKED_STRUCT struct __attribute__((packed, align"
	.ascii	"ed(1)))\000"
.LASF856:
	.ascii	"LENGTH_ADDR64b 8\000"
.LASF671:
	.ascii	"INT8_MIN (-128)\000"
.LASF70:
	.ascii	"__SCHAR_MAX__ 0x7f\000"
.LASF127:
	.ascii	"__INT_FAST8_WIDTH__ 32\000"
.LASF700:
	.ascii	"INT_FAST16_MIN INT32_MIN\000"
.LASF901:
	.ascii	"ACTION_YES 'Y'\000"
.LASF414:
	.ascii	"__ARM_FEATURE_LDREX\000"
.LASF1140:
	.ascii	"ERR_COPY_TO_SPKT\000"
.LASF352:
	.ascii	"__UQQ_FBIT__ 8\000"
.LASF1165:
	.ascii	"l4_protocol\000"
.LASF141:
	.ascii	"__GCC_IEC_559 0\000"
.LASF583:
	.ascii	"__WIDTH_NONE 0\000"
.LASF562:
	.ascii	"__SEGGER_RTL_FILL_HEAD(A,W,C) __SEGGER_RTL_FILL_HEA"
	.ascii	"D_func(A, W, C)\000"
.LASF500:
	.ascii	"__SEGGER_RTL_UNALIGNED_RW_FAULTS 0\000"
.LASF285:
	.ascii	"__LFRACT_MAX__ 0X7FFFFFFFP-31LR\000"
.LASF401:
	.ascii	"__SIZEOF_PTRDIFF_T__ 4\000"
.LASF286:
	.ascii	"__LFRACT_EPSILON__ 0x1P-31LR\000"
.LASF0:
	.ascii	"__STDC__ 1\000"
.LASF884:
	.ascii	"SERFRAME_MOTE2PC_WARNING ((uint8_t)'W')\000"
.LASF668:
	.ascii	"__SEGGER_RTL_MAX_CATEGORY 5\000"
.LASF467:
	.ascii	"__ARM_ARCH_FPV4_SP_D16__ 1\000"
.LASF453:
	.ascii	"__ARM_FEATURE_IDIV 1\000"
.LASF30:
	.ascii	"__FLOAT_WORD_ORDER__ __ORDER_LITTLE_ENDIAN__\000"
.LASF47:
	.ascii	"__UINT8_TYPE__ unsigned char\000"
.LASF173:
	.ascii	"__DBL_MIN__ ((double)1.1)\000"
.LASF1138:
	.ascii	"ERR_PUSH_LOWER_LAYER\000"
.LASF619:
	.ascii	"__SEGGER_RTL_FORMAT_INT_WIDTH __WIDTH_LONG_LONG\000"
.LASF42:
	.ascii	"__SIG_ATOMIC_TYPE__ int\000"
.LASF1330:
	.ascii	"firstAddr\000"
.LASF1096:
	.ascii	"ERR_SIXTOP_LIST\000"
.LASF796:
	.ascii	"__COMPILER_BARRIER() __ASM volatile(\"\":::\"memory"
	.ascii	"\")\000"
.LASF82:
	.ascii	"__SHRT_WIDTH__ 16\000"
.LASF589:
	.ascii	"__SEGGER_RTL_INCLUDE_GNU_API 0\000"
.LASF421:
	.ascii	"__ARM_ARCH_PROFILE\000"
.LASF245:
	.ascii	"__FLT64_IS_IEC_60559__ 2\000"
.LASF891:
	.ascii	"SERFRAME_PC2MOTE_RESET ((uint8_t)'Q')\000"
.LASF713:
	.ascii	"INTPTR_MIN INT32_MIN\000"
.LASF1108:
	.ascii	"ERR_WRONG_STATE_IN_TIMERFIRES\000"
.LASF372:
	.ascii	"__USA_FBIT__ 16\000"
.LASF982:
	.ascii	"rreg_uriquery\000"
.LASF145:
	.ascii	"__DEC_EVAL_METHOD__ 2\000"
.LASF183:
	.ascii	"__LDBL_MIN_10_EXP__ (-307)\000"
.LASF888:
	.ascii	"SERFRAME_MOTE2PC_SNIFFED_PACKET ((uint8_t)'P')\000"
.LASF1305:
	.ascii	"udp_receive\000"
.LASF387:
	.ascii	"__GCC_ATOMIC_CHAR_LOCK_FREE 2\000"
.LASF1297:
	.ascii	"icmpv6rpl_getRPLDODAGid\000"
.LASF283:
	.ascii	"__LFRACT_IBIT__ 0\000"
.LASF1021:
	.ascii	"COMPONENT_IEEE802154E\000"
.LASF1250:
	.ascii	"IPINIP_LEN_6LORH_enums\000"
.LASF558:
	.ascii	"__SEGGER_RTL_ZBYTE_INDEX(X) __SEGGER_RTL_ZBYTE_INDE"
	.ascii	"X_func(X)\000"
.LASF172:
	.ascii	"__DBL_NORM_MAX__ ((double)1.1)\000"
.LASF821:
	.ascii	"PORT_SIGNED_INT_WIDTH int32_t\000"
.LASF419:
	.ascii	"__ARM_SIZEOF_MINIMAL_ENUM 1\000"
.LASF1263:
	.ascii	"traffic_class\000"
.LASF534:
	.ascii	"__SEGGER_RTL_CORE_HAS_MOVW_MOVT 1\000"
.LASF1192:
	.ascii	"l2_IEListPresent\000"
.LASF1047:
	.ascii	"COMPONENT_CSENSORS\000"
.LASF1063:
	.ascii	"ERR_ABORT_JOIN_PROCESS\000"
.LASF490:
	.ascii	"__SEGGER_RTL_ISA_T16 0\000"
.LASF715:
	.ascii	"UINTPTR_MAX UINT32_MAX\000"
.LASF216:
	.ascii	"__FLT32_MIN_10_EXP__ (-37)\000"
.LASF512:
	.ascii	"__SEGGER_RTL_SMULL(lo,hi,x0,x1) do { __asm__( \"smu"
	.ascii	"ll %0, %1, %2, %3\" : \"=r\"(lo), \"=r\"(hi) : \"r\""
	.ascii	"((unsigned)(x0)), \"r\"((unsigned)(x1)) ); } while "
	.ascii	"(0)\000"
.LASF1176:
	.ascii	"l2_frameType\000"
.LASF1333:
	.ascii	"temp_addr64\000"
.LASF461:
	.ascii	"__ARM_FEATURE_BF16_VECTOR_ARITHMETIC\000"
.LASF438:
	.ascii	"__ARM_FP16_FORMAT_ALTERNATIVE\000"
.LASF766:
	.ascii	"__TOOLCHAIN_DEFS_H \000"
.LASF728:
	.ascii	"WCHAR_MAX __WCHAR_MAX__\000"
.LASF676:
	.ascii	"INT32_MAX 2147483647L\000"
.LASF584:
	.ascii	"__WIDTH_FLOAT 1\000"
.LASF955:
	.ascii	"DEFAULTLINKCOST 4\000"
.LASF25:
	.ascii	"__BIGGEST_ALIGNMENT__ 8\000"
.LASF309:
	.ascii	"__USACCUM_MIN__ 0.0UHK\000"
.LASF689:
	.ascii	"INT_LEAST16_MAX INT16_MAX\000"
.LASF921:
	.ascii	"MOP_DIO_A 0<<5\000"
.LASF640:
	.ascii	"__SEGGER_RTL_DIVMOD_U64(Q,R,N,D) do { Q = N / D; R "
	.ascii	"= N - Q*D; } while (0)\000"
.LASF899:
	.ascii	"LOG_CRITICAL(component,message,p1,p2) openserial_pr"
	.ascii	"intLog(L_CRITICAL, (component), (message), (p1), (p"
	.ascii	"2))\000"
.LASF908:
	.ascii	"MAX_NUM_TIMERS 15\000"
.LASF1214:
	.ascii	"IPHC_TF_ELIDED\000"
.LASF941:
	.ascii	"PC3_A_DAO_Transit_Info 0<<3\000"
.LASF938:
	.ascii	"PC1_B_DAO_Transit_Info 1<<6\000"
.LASF1260:
	.ascii	"IPECAP_6LOTH_TYPE\000"
.LASF1230:
	.ascii	"IPHC_SAM_enums\000"
.LASF1335:
	.ascii	"RH_copy\000"
.LASF576:
	.ascii	"__SEGGER_RTL_SIGNAL_SIG_IGN __aeabi_SIG_IGN\000"
.LASF432:
	.ascii	"__ARM_ARCH_ISA_THUMB 2\000"
.LASF1089:
	.ascii	"ERR_NEIGHBORS_FULL\000"
.LASF74:
	.ascii	"__LONG_LONG_MAX__ 0x7fffffffffffffffLL\000"
.LASF250:
	.ascii	"__FLT32X_MAX_EXP__ 1024\000"
.LASF197:
	.ascii	"__FLT16_MANT_DIG__ 11\000"
.LASF1161:
	.ascii	"owner\000"
.LASF1181:
	.ascii	"l2_payload\000"
.LASF578:
	.ascii	"__SEGGER_RTL_NAN_FORMAT_FAST 1\000"
.LASF593:
	.ascii	"__SEGGER_RTL_I64 long long\000"
.LASF357:
	.ascii	"__USQ_IBIT__ 0\000"
.LASF655:
	.ascii	"__SEGGER_RTL_INFINITY __builtin_inff()\000"
.LASF22:
	.ascii	"__SIZEOF_LONG_DOUBLE__ 8\000"
.LASF278:
	.ascii	"__UFRACT_IBIT__ 0\000"
.LASF411:
	.ascii	"__ARM_32BIT_STATE 1\000"
.LASF618:
	.ascii	"__SEGGER_RTL_OPTIMIZE 0\000"
.LASF107:
	.ascii	"__INT8_C(c) c\000"
.LASF1149:
	.ascii	"isUsed\000"
.LASF522:
	.ascii	"__SEGGER_RTL_ALWAYS_INLINE __inline__ __attribute__"
	.ascii	"((__always_inline__))\000"
.LASF329:
	.ascii	"__ULACCUM_MIN__ 0.0ULK\000"
.LASF725:
	.ascii	"UINT64_C(x) (x ##uLL)\000"
.LASF965:
	.ascii	"OPENWSN_SCHEDULER_H \000"
.LASF166:
	.ascii	"__DBL_MIN_EXP__ (-1021)\000"
.LASF883:
	.ascii	"SERFRAME_MOTE2PC_INFO ((uint8_t)'I')\000"
.LASF890:
	.ascii	"SERFRAME_PC2MOTE_SETROOT ((uint8_t)'R')\000"
.LASF626:
	.ascii	"__SEGGER_RTL_MINIMAL_LOCALE 0\000"
.LASF1054:
	.ascii	"COMPONENT_USERIALBRIDGE\000"
.LASF200:
	.ascii	"__FLT16_MIN_10_EXP__ (-4)\000"
.LASF1334:
	.ascii	"rpi_length\000"
.LASF1295:
	.ascii	"iphc_retrieveIPv6HopByHopHeader\000"
.LASF489:
	.ascii	"__SEGGER_RTL_ARM_CONF_H \000"
.LASF214:
	.ascii	"__FLT32_DIG__ 6\000"
.LASF997:
	.ascii	"IANA_UDP\000"
.LASF1195:
	.ascii	"l2_isNegativeACK\000"
.LASF1300:
	.ascii	"icmpv6rpl_getPreferredParentEui64\000"
.LASF802:
	.ascii	"__CMSIS_GCC_OUT_REG(r) \"=r\" (r)\000"
.LASF552:
	.ascii	"__SEGGER_RTL_I2P(X) ((void *)(X))\000"
.LASF1171:
	.ascii	"l3_destinationAdd\000"
.LASF193:
	.ascii	"__LDBL_HAS_DENORM__ 1\000"
.LASF397:
	.ascii	"__HAVE_SPECULATION_SAFE_VALUE 1\000"
.LASF385:
	.ascii	"__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 1\000"
.LASF1095:
	.ascii	"ERR_SIXTOP_COUNT\000"
.LASF553:
	.ascii	"__SEGGER_RTL_ALIGN_PTR(X) (void *)(X)\000"
.LASF125:
	.ascii	"__UINT64_C(c) c ## ULL\000"
.LASF1004:
	.ascii	"IANA_ICMPv6_RA\000"
.LASF989:
	.ascii	"ADDR_NONE\000"
.LASF53:
	.ascii	"__INT_LEAST32_TYPE__ long int\000"
.LASF1350:
	.ascii	"forwarding_send\000"
.LASF473:
	.ascii	"__NO_AEABI_ERR__ 1\000"
.LASF1188:
	.ascii	"l2_sixtop_returnCode\000"
.LASF137:
	.ascii	"__UINT_FAST64_MAX__ 0xffffffffffffffffULL\000"
.LASF1029:
	.ascii	"COMPONENT_OPENBRIDGE\000"
.LASF1003:
	.ascii	"IANA_ICMPv6_RS\000"
.LASF623:
	.ascii	"__SEGGER_RTL_FORMAT_CHAR_CLASS 1\000"
.LASF1198:
	.ascii	"l2_securityLevel\000"
.LASF922:
	.ascii	"MOP_DIO_B 0<<4\000"
.LASF26:
	.ascii	"__ORDER_LITTLE_ENDIAN__ 1234\000"
.LASF1327:
	.ascii	"size\000"
.LASF811:
	.ascii	"__USAT(ARG1,ARG2) __extension__ ({ uint32_t __RES, "
	.ascii	"__ARG1 = (ARG1); __ASM (\"usat %0, %1, %2\" : \"=r\""
	.ascii	" (__RES) : \"I\" (ARG2), \"r\" (__ARG1) ); __RES; }"
	.ascii	")\000"
.LASF1282:
	.ascii	"R_FLAG\000"
.LASF800:
	.ascii	"__VECTOR_TABLE __Vectors\000"
.LASF980:
	.ascii	"long long unsigned int\000"
.LASF687:
	.ascii	"INT_LEAST8_MAX INT8_MAX\000"
.LASF328:
	.ascii	"__ULACCUM_IBIT__ 32\000"
.LASF508:
	.ascii	"__SEGGER_RTL_CORE_HAS_MLA 1\000"
.LASF71:
	.ascii	"__SHRT_MAX__ 0x7fff\000"
.LASF196:
	.ascii	"__LDBL_IS_IEC_60559__ 2\000"
.LASF709:
	.ascii	"UINT_FAST64_MAX UINT64_MAX\000"
.LASF35:
	.ascii	"__PTRDIFF_TYPE__ int\000"
.LASF1296:
	.ascii	"packetfunctions_reserveHeader\000"
.LASF426:
	.ascii	"__APCS_32__ 1\000"
.LASF77:
	.ascii	"__WINT_MAX__ 0xffffffffU\000"
.LASF308:
	.ascii	"__USACCUM_IBIT__ 8\000"
.LASF1315:
	.ascii	"packetfunctions_sameAddress\000"
.LASF1163:
	.ascii	"length\000"
.LASF976:
	.ascii	"uint16_t\000"
.LASF1052:
	.ascii	"COMPONENT_RRT\000"
.LASF225:
	.ascii	"__FLT32_HAS_DENORM__ 1\000"
.LASF65:
	.ascii	"__UINT_FAST32_TYPE__ unsigned int\000"
.LASF752:
	.ascii	"OPENWSN_ADAPTIVE_SYNC_C (0)\000"
.LASF348:
	.ascii	"__DQ_FBIT__ 63\000"
.LASF1308:
	.ascii	"icmpv6_sendDone\000"
.LASF1278:
	.ascii	"rpl_option_ht\000"
.LASF842:
	.ascii	"OPENWSN_AF_H \000"
.LASF60:
	.ascii	"__INT_FAST16_TYPE__ int\000"
.LASF949:
	.ascii	"RPL_OPTION_CONFIG 0x4\000"
.LASF1005:
	.ascii	"IANA_ICMPv6_RA_PREFIX_INFORMATION\000"
.LASF290:
	.ascii	"__ULFRACT_MAX__ 0XFFFFFFFFP-32ULR\000"
.LASF539:
	.ascii	"__SEGGER_RTL_CORE_HAS_BFC_BFI_BFX 1\000"
.LASF56:
	.ascii	"__UINT_LEAST16_TYPE__ short unsigned int\000"
.LASF931:
	.ascii	"FLAG_DAO_D 0<<3\000"
.LASF157:
	.ascii	"__FLT_EPSILON__ 1.1\000"
.LASF325:
	.ascii	"__LACCUM_MAX__ 0X7FFFFFFFFFFFFFFFP-31LK\000"
.LASF1081:
	.ascii	"ERR_FRAG_INVALID_SIZE\000"
.LASF199:
	.ascii	"__FLT16_MIN_EXP__ (-13)\000"
.LASF932:
	.ascii	"FLAG_DAO_E 0<<4\000"
.LASF247:
	.ascii	"__FLT32X_DIG__ 15\000"
.LASF1266:
	.ascii	"next_header\000"
.LASF791:
	.ascii	"__UNALIGNED_UINT16_READ(addr) (((const struct T_UIN"
	.ascii	"T16_READ *)(const void *)(addr))->v)\000"
.LASF1116:
	.ascii	"ERR_WDRADIO_OVERFLOWS\000"
.LASF1057:
	.ascii	"COMPONENT_CINFRARED\000"
.LASF205:
	.ascii	"__FLT16_NORM_MAX__ 1.1\000"
.LASF336:
	.ascii	"__LLACCUM_EPSILON__ 0x1P-31LLK\000"
.LASF1114:
	.ascii	"ERR_MAXTXACKPREPARE_OVERFLOWS\000"
.LASF1028:
	.ascii	"COMPONENT_MSF\000"
.LASF128:
	.ascii	"__INT_FAST16_MAX__ 0x7fffffff\000"
.LASF292:
	.ascii	"__LLFRACT_FBIT__ 63\000"
.LASF789:
	.ascii	"__UNALIGNED_UINT32(x) (((struct T_UINT32 *)(x))->v)"
	.ascii	"\000"
.LASF1082:
	.ascii	"ERR_FRAG_REASSEMBLED\000"
.LASF1076:
	.ascii	"ERR_LARGE_DAGRANK\000"
.LASF646:
	.ascii	"__SEGGER_RTL_CLZ_U64(X) __SEGGER_RTL_CLZ_U64_inline"
	.ascii	"(X)\000"
.LASF836:
	.ascii	"PORT_maxRxDataPrepare 13\000"
.LASF598:
	.ascii	"__SEGGER_RTL_U8 unsigned char\000"
.LASF739:
	.ascii	"OPENWSN_CWELLKNOWN_C (0)\000"
.LASF1010:
	.ascii	"IANA_RSVP\000"
.LASF950:
	.ascii	"MAX_TARGET_PARENTS 0x01\000"
.LASF877:
	.ascii	"SERIAL_OUTPUT_BUFFER_SIZE 1024\000"
.LASF1251:
	.ascii	"IPINIP_LEN_6LORH_MASK\000"
.LASF617:
	.ascii	"__SEGGER_RTL_SIZEOF_LDOUBLE 8\000"
.LASF110:
	.ascii	"__INT16_C(c) c\000"
.LASF958:
	.ascii	"DEFAULTDAGRANK MAXDAGRANK\000"
.LASF1329:
	.ascii	"hlen\000"
.LASF63:
	.ascii	"__UINT_FAST8_TYPE__ unsigned int\000"
.LASF1264:
	.ascii	"flow_label\000"
.LASF799:
	.ascii	"__STACK_LIMIT __StackLimit\000"
.LASF817:
	.ascii	"DISABLE_INTERRUPTS() __disable_irq()\000"
.LASF349:
	.ascii	"__DQ_IBIT__ 0\000"
.LASF1194:
	.ascii	"l2_joinPriorityPresent\000"
.LASF462:
	.ascii	"__ARM_BF16_FORMAT_ALTERNATIVE\000"
.LASF569:
	.ascii	"__SEGGER_RTL_SIGNAL_SIGFPE __aeabi_SIGFPE\000"
.LASF1301:
	.ascii	"icmpv6rpl_getRPLIntanceID\000"
.LASF963:
	.ascii	"OPENWSN_UDP_H \000"
.LASF736:
	.ascii	"OPENWSN_CLED_C (0)\000"
.LASF1107:
	.ascii	"ERR_WRONG_STATE_IN_STARTSLOT\000"
.LASF609:
	.ascii	"__SEGGER_RTL_SIZEOF_INT 4\000"
.LASF1100:
	.ascii	"ERR_RX_CELL_USAGE\000"
.LASF1060:
	.ascii	"ERR_SEQUENCE_NUMBER_OVERFLOW\000"
.LASF322:
	.ascii	"__LACCUM_FBIT__ 31\000"
.LASF1092:
	.ascii	"ERR_SCHEDULE_OVERFLOWN\000"
.LASF1224:
	.ascii	"IPHC_CID_enums\000"
.LASF1262:
	.ascii	"RH3_6LOTH_SIZE_MASK\000"
.LASF697:
	.ascii	"UINT_LEAST64_MAX UINT64_MAX\000"
.LASF597:
	.ascii	"__SEGGER_RTL_I16 short\000"
.LASF879:
	.ascii	"SERIAL_INPUT_BUFFER_SIZE 200\000"
.LASF827:
	.ascii	"CAPTURE_TIME() \000"
.LASF1319:
	.ascii	"packetfunctions_isLinkLocal\000"
.LASF1154:
	.ascii	"addr_64b\000"
.LASF361:
	.ascii	"__UTQ_IBIT__ 0\000"
.LASF364:
	.ascii	"__SA_FBIT__ 15\000"
.LASF832:
	.ascii	"SLOTDURATION 20\000"
.LASF543:
	.ascii	"__SEGGER_RTL_USE_FPU_FOR_IDIV 0\000"
.LASF1009:
	.ascii	"IANA_ICMPv6_RPL_DAO\000"
.LASF1132:
	.ascii	"ERR_PACKET_TOO_LONG\000"
.LASF1218:
	.ascii	"IPHC_NH_COMPRESSED\000"
.LASF450:
	.ascii	"__ARM_EABI__ 1\000"
.LASF1043:
	.ascii	"COMPONENT_C6T\000"
.LASF581:
	.ascii	"__WIDTH_LONG 1\000"
.LASF464:
	.ascii	"__ELF__ 1\000"
.LASF163:
	.ascii	"__FLT_IS_IEC_60559__ 2\000"
.LASF430:
	.ascii	"__THUMBEL__ 1\000"
.LASF1271:
	.ascii	"dest\000"
.LASF1072:
	.ascii	"ERR_UNSUPPORTED_ICMPV6_TYPE\000"
.LASF816:
	.ascii	"INTERRUPT_DECLARATION() \000"
.LASF777:
	.ascii	"__SEGGER_RTL_SIZE_T_DEFINED \000"
.LASF343:
	.ascii	"__QQ_IBIT__ 0\000"
.LASF934:
	.ascii	"D_DAO 1<<6\000"
.LASF685:
	.ascii	"UINTMAX_MAX UINT64_MAX\000"
.LASF939:
	.ascii	"PC2_A_DAO_Transit_Info 0<<5\000"
.LASF869:
	.ascii	"OPENWSN_IEEE802154_H \000"
.LASF870:
	.ascii	"TERMINATIONIE_LEN 2\000"
.LASF659:
	.ascii	"__SEGGER_RTL_HIDE(X) __c_ ##X\000"
.LASF514:
	.ascii	"__SEGGER_RTL_UMULL_HI(x0,x1) ({ unsigned long __tra"
	.ascii	"sh, __hi; __asm__( \"umull %0, %1, %2, %3\" : \"=r\""
	.ascii	"(__trash), \"=r\"(__hi) : \"r\"((unsigned)(x0)), \""
	.ascii	"r\"((unsigned)(x1)) ); __hi; })\000"
.LASF222:
	.ascii	"__FLT32_MIN__ 1.1\000"
.LASF913:
	.ascii	"TIMER_INHIBIT 0\000"
.LASF6:
	.ascii	"__GNUC_MINOR__ 2\000"
.LASF943:
	.ascii	"PC4_A_DAO_Transit_Info 0<<1\000"
.LASF571:
	.ascii	"__SEGGER_RTL_SIGNAL_SIGINT __aeabi_SIGINT\000"
.LASF57:
	.ascii	"__UINT_LEAST32_TYPE__ long unsigned int\000"
.LASF1243:
	.ascii	"IPHC_DAM_64B\000"
.LASF1118:
	.ascii	"ERR_WDACKDURATION_OVERFLOWS\000"
.LASF417:
	.ascii	"__ARM_FEATURE_NUMERIC_MAXMIN\000"
.LASF484:
	.ascii	"_LIBCPP_CONFIG \000"
.LASF38:
	.ascii	"__INTMAX_TYPE__ long long int\000"
.LASF392:
	.ascii	"__GCC_ATOMIC_INT_LOCK_FREE 2\000"
.LASF382:
	.ascii	"__CHAR_UNSIGNED__ 1\000"
.LASF960:
	.ascii	"DAGMAXRANKINCREASE 768\000"
.LASF828:
	.ascii	"NRF_GPIO_PIN_MAP(port,pin) (((port) << 5) | ((pin) "
	.ascii	"& 0x1F))\000"
.LASF1001:
	.ascii	"IANA_ICMPv6_ECHO_REQUEST\000"
.LASF136:
	.ascii	"__UINT_FAST32_MAX__ 0xffffffffU\000"
.LASF488:
	.ascii	"__SEGGER_RTL_CONF_H \000"
.LASF1134:
	.ascii	"ERR_INPUTBUFFER_LENGTH\000"
.LASF1022:
	.ascii	"COMPONENT_SIXTOP_TO_IEEE802154E\000"
.LASF753:
	.ascii	"DEADLINE_OPTION (0)\000"
.LASF841:
	.ascii	"NUMSENSORS 2\000"
.LASF670:
	.ascii	"__SEGGER_RTL_SIZE_MAX 4294967295uL\000"
.LASF440:
	.ascii	"__ARM_FEATURE_FP16_SCALAR_ARITHMETIC\000"
.LASF881:
	.ascii	"SERFRAME_MOTE2PC_STATUS ((uint8_t)'S')\000"
.LASF311:
	.ascii	"__USACCUM_EPSILON__ 0x1P-8UHK\000"
.LASF95:
	.ascii	"__SIG_ATOMIC_MAX__ 0x7fffffff\000"
.LASF243:
	.ascii	"__FLT64_HAS_INFINITY__ 1\000"
.LASF1180:
	.ascii	"l2_asn\000"
.LASF1040:
	.ascii	"COMPONENT_OPENCOAP\000"
.LASF1059:
	.ascii	"ERR_JOIN_REQUEST\000"
.LASF406:
	.ascii	"__ARM_FEATURE_UNALIGNED 1\000"
.LASF848:
	.ascii	"AF_NUMOF AF_NUMOF\000"
.LASF1109:
	.ascii	"ERR_WRONG_STATE_IN_NEWSLOT\000"
.LASF860:
	.ascii	"IEEE802154_FRAME_SIZE 127\000"
.LASF305:
	.ascii	"__SACCUM_MAX__ 0X7FFFP-7HK\000"
.LASF67:
	.ascii	"__INTPTR_TYPE__ int\000"
.LASF40:
	.ascii	"__CHAR16_TYPE__ short unsigned int\000"
.LASF68:
	.ascii	"__UINTPTR_TYPE__ unsigned int\000"
.LASF961:
	.ascii	"DEFAULTJOINPRIORITY 0xff\000"
.LASF378:
	.ascii	"__REGISTER_PREFIX__ \000"
.LASF658:
	.ascii	"__SEGGER_RTL_HUGE_VALF __builtin_huge_valf()\000"
.LASF165:
	.ascii	"__DBL_DIG__ 15\000"
.LASF291:
	.ascii	"__ULFRACT_EPSILON__ 0x1P-32ULR\000"
.LASF546:
	.ascii	"__SEGGER_RTL_LDOUBLE_C_COMPLEX long double _Complex"
	.ascii	"\000"
.LASF1033:
	.ascii	"COMPONENT_ICMPv6\000"
.LASF155:
	.ascii	"__FLT_NORM_MAX__ 1.1\000"
.LASF1236:
	.ascii	"IPHC_M_NO\000"
.LASF23:
	.ascii	"__SIZEOF_SIZE_T__ 4\000"
.LASF638:
	.ascii	"__SEGGER_RTL_SMULL_X_SYNTHESIZED \000"
.LASF1191:
	.ascii	"l2_joinPriority\000"
.LASF50:
	.ascii	"__UINT64_TYPE__ long long unsigned int\000"
.LASF116:
	.ascii	"__INT64_C(c) c ## LL\000"
.LASF323:
	.ascii	"__LACCUM_IBIT__ 32\000"
.LASF843:
	.ascii	"AF_UNSPEC AF_UNSPEC\000"
.LASF864:
	.ascii	"IPHC_DEFAULT_HOP_LIMIT 65\000"
.LASF837:
	.ascii	"PORT_maxTxAckPrepare 13\000"
.LASF533:
	.ascii	"__SEGGER_RTL_CORE_HAS_ADDW_SUBW 1\000"
.LASF479:
	.ascii	"__WIN32__ 1\000"
.LASF1153:
	.ascii	"addr_16b\000"
.LASF602:
	.ascii	"__SEGGER_RTL_LEAST_I16 int\000"
.LASF1298:
	.ascii	"iphc_sendFromForwarding\000"
.LASF606:
	.ascii	"__SEGGER_RTL_U32_C(X) X ##u\000"
.LASF457:
	.ascii	"__ARM_FEATURE_CDE\000"
.LASF313:
	.ascii	"__ACCUM_IBIT__ 16\000"
.LASF592:
	.ascii	"__SEGGER_RTL_U64 unsigned long long\000"
.LASF388:
	.ascii	"__GCC_ATOMIC_CHAR16_T_LOCK_FREE 2\000"
.LASF1205:
	.ascii	"l1_txPower\000"
.LASF1133:
	.ascii	"ERR_PACKET_TOO_SHORT\000"
.LASF734:
	.ascii	"OPENWSN_CINFO_C (0)\000"
.LASF975:
	.ascii	"short int\000"
.LASF1227:
	.ascii	"IPHC_SAC_enums\000"
.LASF277:
	.ascii	"__UFRACT_FBIT__ 16\000"
.LASF121:
	.ascii	"__UINT16_C(c) c\000"
.LASF825:
	.ascii	"SCHEDULER_WAKEUP() \000"
.LASF1286:
	.ascii	"FLAG_MASK\000"
.LASF667:
	.ascii	"__SEGGER_RTL_VERSION 41600\000"
.LASF375:
	.ascii	"__UDA_IBIT__ 32\000"
.LASF780:
	.ascii	"__INLINE inline\000"
.LASF746:
	.ascii	"OPENWSN_COAP_C (0)\000"
.LASF381:
	.ascii	"__NO_INLINE__ 1\000"
.LASF1346:
	.ascii	"addressToWrite64b\000"
.LASF532:
	.ascii	"__SEGGER_RTL_CORE_HAS_PKHTB_PKHBT 1\000"
.LASF845:
	.ascii	"AF_PACKET AF_PACKET\000"
.LASF878:
	.ascii	"OUTPUT_BUFFER_MASK 0x3FF\000"
.LASF9:
	.ascii	"__ATOMIC_RELAXED 0\000"
.LASF813:
	.ascii	"__USAT16(ARG1,ARG2) ({ uint32_t __RES, __ARG1 = (AR"
	.ascii	"G1); __ASM (\"usat16 %0, %1, %2\" : \"=r\" (__RES) "
	.ascii	": \"I\" (ARG2), \"r\" (__ARG1) ); __RES; })\000"
.LASF455:
	.ascii	"__ARM_FEATURE_COPROC\000"
.LASF1347:
	.ascii	"forwarding_receive\000"
.LASF1244:
	.ascii	"IPHC_DAM_16B\000"
.LASF177:
	.ascii	"__DBL_HAS_INFINITY__ 1\000"
.LASF974:
	.ascii	"int16_t\000"
.LASF230:
	.ascii	"__FLT64_MANT_DIG__ 53\000"
.LASF550:
	.ascii	"__SEGGER_RTL_X_errno_addr __aeabi_errno_addr\000"
.LASF760:
	.ascii	"BOARD_OPENSERIAL_PRINTF (0)\000"
.LASF769:
	.ascii	"ISR(v) __PRAGMA__(vector=v ##_VECTOR) __interrupt v"
	.ascii	"oid v ##_ISR(void)\000"
.LASF1344:
	.ascii	"forwarding_getNextHop\000"
.LASF824:
	.ascii	"PORT_MAX_TICKS_IN_SINGLE_CLOCK (uint32_t)(0x00fffff"
	.ascii	"f)\000"
.LASF1306:
	.ascii	"packetfunctions_tossHeader\000"
.LASF20:
	.ascii	"__SIZEOF_FLOAT__ 4\000"
.LASF1144:
	.ascii	"owerror_t\000"
.LASF810:
	.ascii	"__SSAT(ARG1,ARG2) __extension__ ({ int32_t __RES, _"
	.ascii	"_ARG1 = (ARG1); __ASM (\"ssat %0, %1, %2\" : \"=r\""
	.ascii	" (__RES) : \"I\" (ARG2), \"r\" (__ARG1) ); __RES; }"
	.ascii	")\000"
.LASF170:
	.ascii	"__DBL_DECIMAL_DIG__ 17\000"
.LASF1037:
	.ascii	"COMPONENT_UDP\000"
.LASF492:
	.ascii	"__SEGGER_RTL_ISA_ARM 2\000"
.LASF1232:
	.ascii	"IPHC_SAM_64B\000"
.LASF1167:
	.ascii	"l4_sourcePortORicmpv6Type\000"
.LASF327:
	.ascii	"__ULACCUM_FBIT__ 32\000"
.LASF1225:
	.ascii	"IPHC_CID_NO\000"
.LASF693:
	.ascii	"INT_LEAST64_MAX INT64_MAX\000"
.LASF471:
	.ascii	"_LIBCPP_HAS_NO_THREADS 1\000"
.LASF770:
	.ascii	"port_INLINE inline\000"
.LASF716:
	.ascii	"WINT_MIN (-2147483647L-1)\000"
.LASF99:
	.ascii	"__INT16_MAX__ 0x7fff\000"
.LASF775:
	.ascii	"__SEGGER_RTL_STRING_H \000"
.LASF733:
	.ascii	"OPENWSN_CEXAMPLE_C (0)\000"
.LASF1025:
	.ascii	"COMPONENT_NEIGHBORS\000"
.LASF83:
	.ascii	"__INT_WIDTH__ 32\000"
.LASF418:
	.ascii	"__ARM_FEATURE_SIMD32 1\000"
.LASF220:
	.ascii	"__FLT32_MAX__ 1.1\000"
.LASF708:
	.ascii	"UINT_FAST32_MAX UINT32_MAX\000"
.LASF624:
	.ascii	"__SEGGER_RTL_FORMAT_INT_WIDTH\000"
.LASF991:
	.ascii	"ADDR_64B\000"
.LASF710:
	.ascii	"PTRDIFF_MIN INT32_MIN\000"
.LASF342:
	.ascii	"__QQ_FBIT__ 7\000"
.LASF928:
	.ascii	"FLAG_DAO_A 0<<0\000"
.LASF289:
	.ascii	"__ULFRACT_MIN__ 0.0ULR\000"
.LASF312:
	.ascii	"__ACCUM_FBIT__ 15\000"
.LASF97:
	.ascii	"__SIG_ATOMIC_WIDTH__ 32\000"
.LASF720:
	.ascii	"INT32_C(x) (x)\000"
.LASF1062:
	.ascii	"ERR_DECRYPTION_FAILED\000"
.LASF607:
	.ascii	"__SEGGER_RTL_I64_C(X) X ##LL\000"
.LASF761:
	.ascii	"BOARD_OPENSERIAL_SNIFFER (0)\000"
.LASF1321:
	.ascii	"idmanager_getMyID\000"
.LASF377:
	.ascii	"__UTA_IBIT__ 64\000"
.LASF338:
	.ascii	"__ULLACCUM_IBIT__ 32\000"
.LASF893:
	.ascii	"SERFRAME_PC2MOTE_TRIGGERSERIALECHO ((uint8_t)'S')\000"
.LASF996:
	.ascii	"IANA_IPv6HOPOPT\000"
.LASF301:
	.ascii	"__ULLFRACT_EPSILON__ 0x1P-64ULLR\000"
.LASF722:
	.ascii	"UINT8_C(x) (x ##u)\000"
.LASF483:
	.ascii	"_LIBCPP_STDINT_H \000"
.LASF1123:
	.ascii	"ERR_BUFFER_OVERFLOW\000"
.LASF1209:
	.ascii	"packet\000"
.LASF1168:
	.ascii	"l4_destination_port\000"
.LASF527:
	.ascii	"__SEGGER_RTL_CORE_HAS_CLZ 1\000"
.LASF112:
	.ascii	"__INT_LEAST32_MAX__ 0x7fffffffL\000"
.LASF294:
	.ascii	"__LLFRACT_MIN__ (-0.5LLR-0.5LLR)\000"
.LASF1067:
	.ascii	"ERR_RCVD_ECHO_REQUEST\000"
.LASF933:
	.ascii	"FLAG_DAO_F 0<<5\000"
.LASF1032:
	.ascii	"COMPONENT_FORWARDING\000"
.LASF324:
	.ascii	"__LACCUM_MIN__ (-0X1P31LK-0X1P31LK)\000"
.LASF1247:
	.ascii	"FORMAT_6LORH_MASK\000"
.LASF1074:
	.ascii	"ERR_NO_NEXTHOP\000"
.LASF213:
	.ascii	"__FLT32_MANT_DIG__ 24\000"
.LASF208:
	.ascii	"__FLT16_DENORM_MIN__ 1.1\000"
.LASF1156:
	.ascii	"panid\000"
.LASF1216:
	.ascii	"IPHC_NH_enums\000"
.LASF131:
	.ascii	"__INT_FAST32_WIDTH__ 32\000"
.LASF757:
	.ascii	"DAGROOT (0)\000"
.LASF423:
	.ascii	"__arm__ 1\000"
.LASF1313:
	.ascii	"memcpy\000"
.LASF454:
	.ascii	"__ARM_ASM_SYNTAX_UNIFIED__ 1\000"
.LASF1179:
	.ascii	"l2_numTxAttempts\000"
.LASF846:
	.ascii	"AF_INET AF_INET\000"
.LASF49:
	.ascii	"__UINT32_TYPE__ long unsigned int\000"
.LASF834:
	.ascii	"PORT_maxTxDataPrepare 13\000"
.LASF409:
	.ascii	"__ARM_FEATURE_DOTPROD\000"
.LASF429:
	.ascii	"__thumb2__ 1\000"
.LASF1229:
	.ascii	"IPHC_SAC_STATEFUL\000"
.LASF706:
	.ascii	"UINT_FAST8_MAX UINT8_MAX\000"
.LASF840:
	.ascii	"SYNC_ACCURACY 1\000"
.LASF178:
	.ascii	"__DBL_HAS_QUIET_NAN__ 1\000"
.LASF521:
	.ascii	"__SEGGER_RTL_NEVER_INLINE __attribute__((__noinline"
	.ascii	"__, __noclone__))\000"
.LASF987:
	.ascii	"E_SUCCESS\000"
.LASF437:
	.ascii	"__ARM_FP16_FORMAT_IEEE 1\000"
.LASF299:
	.ascii	"__ULLFRACT_MIN__ 0.0ULLR\000"
.LASF599:
	.ascii	"__SEGGER_RTL_I8 signed char\000"
.LASF1234:
	.ascii	"IPHC_SAM_ELIDED\000"
.LASF744:
	.ascii	"OPENWSN_USERIALBRIDGE_C (0)\000"
.LASF359:
	.ascii	"__UDQ_IBIT__ 0\000"
.LASF16:
	.ascii	"__SIZEOF_INT__ 4\000"
.LASF1099:
	.ascii	"ERR_TX_CELL_USAGE\000"
.LASF187:
	.ascii	"__LDBL_DECIMAL_DIG__ 17\000"
.LASF1233:
	.ascii	"IPHC_SAM_16B\000"
.LASF978:
	.ascii	"uint32_t\000"
.LASF1324:
	.ascii	"ipv6_inner_header\000"
.LASF683:
	.ascii	"INTMAX_MIN INT64_MIN\000"
.LASF498:
	.ascii	"__SEGGER_RTL_STRING_ASM 1\000"
.LASF1064:
	.ascii	"ERR_WRONG_TRAN_PROTOCOL\000"
.LASF826:
	.ascii	"SCHEDULER_ENABLE_INTERRUPT() \000"
.LASF198:
	.ascii	"__FLT16_DIG__ 3\000"
.LASF383:
	.ascii	"__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 1\000"
.LASF1213:
	.ascii	"IPHC_TF_1B\000"
.LASF1093:
	.ascii	"ERR_SIXTOP_RETURNCODE\000"
.LASF654:
	.ascii	"__SEGGER_RTL_I64_L(X) ((__SEGGER_RTL_U32)(__SEGGER_"
	.ascii	"RTL_U64)(X))\000"
.LASF436:
	.ascii	"__ARM_FP 4\000"
.LASF818:
	.ascii	"ENABLE_INTERRUPTS() __enable_irq()\000"
.LASF1160:
	.ascii	"creator\000"
.LASF990:
	.ascii	"ADDR_16B\000"
.LASF499:
	.ascii	"__SEGGER_RTL_BYTE_ORDER (-1)\000"
.LASF1336:
	.ascii	"RH_length\000"
.LASF316:
	.ascii	"__ACCUM_EPSILON__ 0x1P-15K\000"
.LASF331:
	.ascii	"__ULACCUM_EPSILON__ 0x1P-32ULK\000"
.LASF1265:
	.ascii	"next_header_compressed\000"
.LASF181:
	.ascii	"__LDBL_DIG__ 15\000"
.LASF1197:
	.ascii	"l2_sendOnTxCell\000"
.LASF586:
	.ascii	"__SEGGER_RTL_SIDE_BY_SIDE 0\000"
.LASF89:
	.ascii	"__SIZE_WIDTH__ 32\000"
.LASF475:
	.ascii	"DEBUG_NRF 1\000"
.LASF78:
	.ascii	"__WINT_MIN__ 0U\000"
.LASF494:
	.ascii	"__SEGGER_RTL_UNREACHABLE() __builtin_unreachable()\000"
.LASF1307:
	.ascii	"idmanager_isMyAddress\000"
.LASF231:
	.ascii	"__FLT64_DIG__ 15\000"
.LASF1210:
	.ascii	"OpenQueueEntry_t\000"
.LASF719:
	.ascii	"INT16_C(x) (x)\000"
.LASF1245:
	.ascii	"IPHC_DAM_ELIDED\000"
.LASF108:
	.ascii	"__INT_LEAST8_WIDTH__ 8\000"
.LASF940:
	.ascii	"PC2_B_DAO_Transit_Info 0<<4\000"
.LASF920:
	.ascii	"DAO_PERIOD 60000\000"
.LASF520:
	.ascii	"__SEGGER_RTL_THREAD __thread\000"
.LASF1342:
	.ascii	"temp_prefix64btoWrite\000"
.LASF1337:
	.ascii	"RH3_length\000"
.LASF946:
	.ascii	"Prf_B_dio_options 0<<3\000"
.LASF905:
	.ascii	"OPENWSN_NEIGHBORS_H \000"
.LASF188:
	.ascii	"__LDBL_MAX__ 1.1\000"
.LASF977:
	.ascii	"short unsigned int\000"
.LASF1193:
	.ascii	"l2_payloadIEpresent\000"
.LASF226:
	.ascii	"__FLT32_HAS_INFINITY__ 1\000"
.LASF207:
	.ascii	"__FLT16_EPSILON__ 1.1\000"
.LASF428:
	.ascii	"__thumb__ 1\000"
.LASF657:
	.ascii	"__SEGGER_RTL_HUGE_VAL __builtin_huge_val()\000"
.LASF876:
	.ascii	"OPENWSN_OPENSERIAL_H \000"
.LASF433:
	.ascii	"__ARMEL__ 1\000"
.LASF1031:
	.ascii	"COMPONENT_FRAG\000"
.LASF519:
	.ascii	"__SEGGER_RTL_LIKELY(X) __builtin_expect((X), 1)\000"
.LASF344:
	.ascii	"__HQ_FBIT__ 15\000"
.LASF614:
	.ascii	"__SEGGER_RTL_WINT_T __WINT_TYPE__\000"
.LASF548:
	.ascii	"__SEGGER_RTL_VA_LIST __builtin_va_list\000"
.LASF1288:
	.ascii	"L_ERROR\000"
.LASF315:
	.ascii	"__ACCUM_MAX__ 0X7FFFFFFFP-15K\000"
.LASF1304:
	.ascii	"icmpv6_receive\000"
.LASF80:
	.ascii	"__SIZE_MAX__ 0xffffffffU\000"
.LASF956:
	.ascii	"MINIMAL_NUM_TX 16\000"
.LASF911:
	.ascii	"MAX_DURATION_ISR 33\000"
.LASF600:
	.ascii	"__SEGGER_RTL_LEAST_U32 unsigned\000"
.LASF570:
	.ascii	"__SEGGER_RTL_SIGNAL_SIGILL __aeabi_SIGILL\000"
.LASF1012:
	.ascii	"COMPONENT_NULL\000"
.LASF1151:
	.ascii	"channeloffset\000"
.LASF424:
	.ascii	"__ARM_ARCH\000"
.LASF1303:
	.ascii	"openqueue_isHighPriorityEntryEnough\000"
.LASF221:
	.ascii	"__FLT32_NORM_MAX__ 1.1\000"
.LASF73:
	.ascii	"__LONG_MAX__ 0x7fffffffL\000"
.LASF468:
	.ascii	"__HEAP_SIZE__ 8192\000"
.LASF999:
	.ascii	"IANA_IPv6ROUTE\000"
.LASF529:
	.ascii	"__SEGGER_RTL_CORE_HAS_ISA_SIMD32 1\000"
.LASF1273:
	.ascii	"ipv6_header_iht\000"
.LASF892:
	.ascii	"SERFRAME_PC2MOTE_DATA ((uint8_t)'D')\000"
.LASF785:
	.ascii	"__WEAK __attribute__((weak))\000"
.LASF441:
	.ascii	"__ARM_FEATURE_FP16_VECTOR_ARITHMETIC\000"
.LASF639:
	.ascii	"__SEGGER_RTL_DIVMOD_U32(Q,R,N,D) do { Q = N / D; R "
	.ascii	"= N - Q*D; } while (0)\000"
.LASF415:
	.ascii	"__ARM_FEATURE_LDREX 7\000"
.LASF1200:
	.ascii	"l2_keyIndex\000"
.LASF502:
	.ascii	"__SEGGER_RTL_ADDRSIZE 32\000"
.LASF1277:
	.ascii	"senderRank\000"
.LASF1146:
	.ascii	"bytes2and3\000"
.LASF296:
	.ascii	"__LLFRACT_EPSILON__ 0x1P-63LLR\000"
.LASF124:
	.ascii	"__UINT_LEAST64_MAX__ 0xffffffffffffffffULL\000"
.LASF1184:
	.ascii	"l2_sixtop_frameID\000"
.LASF265:
	.ascii	"__SFRACT_MAX__ 0X7FP-7HR\000"
.LASF246:
	.ascii	"__FLT32X_MANT_DIG__ 53\000"
.LASF86:
	.ascii	"__WCHAR_WIDTH__ 32\000"
.LASF925:
	.ascii	"PRF_DIO_B 0<<1\000"
.LASF293:
	.ascii	"__LLFRACT_IBIT__ 0\000"
.LASF495:
	.ascii	"__SEGGER_RTL_TARGET_ISA __SEGGER_RTL_ISA_T32\000"
.LASF1023:
	.ascii	"COMPONENT_IEEE802154E_TO_SIXTOP\000"
.LASF880:
	.ascii	"SERFRAME_MOTE2PC_DATA ((uint8_t)'D')\000"
.LASF983:
	.ascii	"infoBoardname\000"
.LASF748:
	.ascii	"OPENWSN_6LO_FRAGMENTATION_C (0)\000"
.LASF1212:
	.ascii	"IPHC_TF_3B\000"
.LASF1170:
	.ascii	"l4_length\000"
.LASF633:
	.ascii	"__SEGGER_RTL_BitcastToU32(X) __SEGGER_RTL_BitcastTo"
	.ascii	"U32_inline(X)\000"
.LASF90:
	.ascii	"__INTMAX_MAX__ 0x7fffffffffffffffLL\000"
.LASF211:
	.ascii	"__FLT16_HAS_QUIET_NAN__ 1\000"
.LASF630:
	.ascii	"__SEGGER_RTL_STATE_THREAD __SEGGER_RTL_THREAD\000"
.LASF737:
	.ascii	"OPENWSN_CSENSORS_C (0)\000"
.LASF924:
	.ascii	"PRF_DIO_A 0<<2\000"
.LASF1017:
	.ascii	"COMPONENT_PACKETFUNCTIONS\000"
.LASF13:
	.ascii	"__ATOMIC_ACQ_REL 4\000"
.LASF1148:
	.ascii	"asn_t\000"
.LASF45:
	.ascii	"__INT32_TYPE__ long int\000"
.LASF650:
	.ascii	"__SEGGER_RTL_U64_H(X) ((__SEGGER_RTL_U32)((__SEGGER"
	.ascii	"_RTL_U64)(X) >> 32))\000"
.LASF1020:
	.ascii	"COMPONENT_IEEE802154\000"
.LASF621:
	.ascii	"__SEGGER_RTL_FORMAT_WCHAR 1\000"
.LASF517:
	.ascii	"__SEGGER_RTL_UMLAL(lo,hi,x0,x1) do { __asm__(\"umla"
	.ascii	"l %0, %1, %2, %3\" : \"+r\"(lo), \"+r\"(hi) : \"r\""
	.ascii	"((unsigned)(x0)), \"r\"((unsigned)(x1)) ); } while "
	.ascii	"(0)\000"
.LASF945:
	.ascii	"Prf_A_dio_options 0<<4\000"
.LASF59:
	.ascii	"__INT_FAST8_TYPE__ int\000"
.LASF1318:
	.ascii	"packetfunctions_isAllRoutersMulticast\000"
.LASF1253:
	.ascii	"TYPE_6LORH_enums\000"
.LASF1196:
	.ascii	"l2_timeCorrection\000"
.LASF1097:
	.ascii	"ERR_UNSUPPORTED_FORMAT\000"
.LASF240:
	.ascii	"__FLT64_EPSILON__ 1.1\000"
.LASF355:
	.ascii	"__UHQ_IBIT__ 0\000"
.LASF684:
	.ascii	"INTMAX_MAX INT64_MAX\000"
.LASF92:
	.ascii	"__UINTMAX_MAX__ 0xffffffffffffffffULL\000"
.LASF509:
	.ascii	"__SEGGER_RTL_CORE_HAS_MLS 1\000"
.LASF1360:
	.ascii	"C:\\Users\\16603\\Desktop\\HKUSTGZ\\IOTA5109-WSN\\o"
	.ascii	"penwsnProj\\mywsn\\openstack\\03b-IPv6\\forwarding."
	.ascii	"c\000"
.LASF1046:
	.ascii	"COMPONENT_CLEDS\000"
.LASF1087:
	.ascii	"ERR_BRIDGE_MISMATCH\000"
.LASF749:
	.ascii	"OPENWSN_ICMPV6ECHO_C (0)\000"
.LASF526:
	.ascii	"__SEGGER_RTL_FLOAT32_SQRT(__m) ({ float __d; __asm_"
	.ascii	"_ __volatile__(\"vsqrt.f32 %[d], %[m]\" : [d] \"=t\""
	.ascii	"(__d) : [m] \"t\"(__m)); __d; })\000"
.LASF923:
	.ascii	"MOP_DIO_C 1<<3\000"
.LASF1141:
	.ascii	"ERR_COPY_TO_BPKT\000"
.LASF72:
	.ascii	"__INT_MAX__ 0x7fffffff\000"
.LASF889:
	.ascii	"SERFRAME_MOTE2PC_PRINTF ((uint8_t)'F')\000"
.LASF103:
	.ascii	"__UINT16_MAX__ 0xffff\000"
.LASF1103:
	.ascii	"ERR_DESYNCHRONIZED\000"
.LASF302:
	.ascii	"__SACCUM_FBIT__ 7\000"
.LASF339:
	.ascii	"__ULLACCUM_MIN__ 0.0ULLK\000"
.LASF694:
	.ascii	"UINT_LEAST8_MAX UINT8_MAX\000"
	.ident	"GCC: (based on arm-11.2-2022.02 GCC) 11.2.1 20220111"
