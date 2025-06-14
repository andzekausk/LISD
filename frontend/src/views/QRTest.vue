<template>
  <div>
    <div id="reader"></div>

    <p v-if="scannedCode">Skenēšanas rezultāts: {{ scannedCode }}</p>

    <div v-if="itemData">
      <p><strong>Inventāra numurs:</strong> {{ itemData.item_number || '-' }}</p>
      <p><strong>Nosaukums:</strong> {{ itemData.title || '-' }}</p>
      <p><strong>Apraksts:</strong> {{ itemData.description || '-' }}</p>
      <p><strong>Mat. atb. persona:</strong> {{ itemData.email || '-' }}</p>
      <p><strong>Atrašanās vieta:</strong> {{ itemData.room || '-' }}</p>
    </div>

    <div v-if="scannerRunning">
      <input v-model="manualCode" @keyup.enter="handleManualSearch" placeholder="Ievadi inventāra numuru" />
      <button @click="handleManualSearch">Meklēt</button>
    </div>

    <div>
      <!-- <button @click="stopScanner" v-if="scannerRunning">Beigt skenēšanu</button> -->
      <button @click="resumeScanner" v-if="scannedCode">Turpināt</button>
    </div>

  </div>
</template>

<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import {
  Html5Qrcode,
  Html5QrcodeScanType,
  Html5QrcodeSupportedFormats
} from 'html5-qrcode'
import api from "../services/api";

const scannedCode = ref(null)
const manualCode = ref('')
const scannerRunning = ref(false)
const itemData = ref(null)

let html5QrCode = null
const qrRegionId = "reader"

const config = {
  fps: 10,
  supportedScanTypes: [Html5QrcodeScanType.SCAN_TYPE_CAMERA],
  formatsToSupport: [
    // Html5QrcodeSupportedFormats.QR_CODE,
    Html5QrcodeSupportedFormats.CODE_128,
    // Html5QrcodeSupportedFormats.EAN_13,
    // Html5QrcodeSupportedFormats.UPC_A,
    // Html5QrcodeSupportedFormats.UPC_E,
    Html5QrcodeSupportedFormats.CODE_39
  ]
}

const startScanner = async () => {
  try {
    html5QrCode = new Html5Qrcode(qrRegionId)

    await html5QrCode.start(
      { facingMode: "environment" },
      config,
      async (decodedText, decodedResult) => {
        scannedCode.value = decodedText
        console.log("Decoded:", decodedText, decodedResult)

        try {
          const { data } = await api.get(`/items/item_number/${decodedText}`)
          itemData.value = data
          await stopScanner()
        } catch (err) {
          if (err.response?.status === 404) {
            itemData.value = null
          } else {
            console.error("Server error:", err)
          }
        }
      },
      (errorMessage) => {
        console.warn("Scan error:", errorMessage)
      }
    )

    scannerRunning.value = true
  } catch (err) {
    console.error("Failed to start scanner", err)
  }
}

const stopScanner = async () => {
  if (html5QrCode && scannerRunning.value) {
    await html5QrCode.stop()
    html5QrCode.clear()
    scannerRunning.value = false
  }
}

const resumeScanner = async () => {
  itemData.value = null
  scannedCode.value = null
  manualCode.value = ''
  await startScanner()
}

const handleManualSearch = async () => {
  const code = manualCode.value.trim()
  if (!code) return

  scannedCode.value = code
  try {
    const { data } = await api.get(`/items/item_number/${code}`)
    itemData.value = data
    await stopScanner()
  } catch (err) {
    if (err.response?.status === 404) {
      itemData.value = null
    } else {
      console.error("Server error:", err)
    }
  }
}

onMounted(() => {
  startScanner()
})

onBeforeUnmount(() => {
  stopScanner()
})
</script>
