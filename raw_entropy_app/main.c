// Copyright (C) 2022 - Tillitis AB
// SPDX-License-Identifier: GPL-2.0-only

#include "app_proto.h"
#include "../common/mta1_mkdf_mem.h"

// clang-format off
static volatile uint32_t *led = (volatile uint32_t *)MTA1_MKDF_MMIO_MTA1_LED;

static volatile uint32_t *trng_status = (volatile uint32_t *)MTA1_MKDF_MMIO_TRNG_STATUS;
static volatile uint32_t *trng_sample_rate = (volatile uint32_t *)MTA1_MKDF_MMIO_TRNG_SAMPLE_RATE;
static volatile uint32_t *trng_entropy = (volatile uint32_t *)MTA1_MKDF_MMIO_TRNG_ENTROPY;

static volatile uint32_t *uart_tx_status = (volatile uint32_t *)MTA1_MKDF_MMIO_UART_TX_STATUS;
static volatile uint32_t *uart_tx_data = (volatile uint32_t *)MTA1_MKDF_MMIO_UART_TX_DATA;


void send_w32(uint32_t w) {
  while (!*uart_tx_status) {
  }
  *uart_tx_data = w >> 24;

  while (!*uart_tx_status) {
  }
  *uart_tx_data = w >> 16 & 0xff;

  while (!*uart_tx_status) {
  }
  *uart_tx_data = w >> 8 & 0xff;

  while (!*uart_tx_status) {
  }
  *uart_tx_data = w & 0xff;
}


int main(void) {
  volatile uint32_t trng_data;

  *trng_sample_rate = 2048;

  for (;;) {
    while (!*trng_status) {
    }

    trng_data =  *trng_entropy;
    *led =  trng_data;
    send_w32(trng_data);
  }
}
