#include <WiFiManager.h>
#include <WiFiClientSecure.h>
#include <MQTT.h>
#include <ArduinoJson.h>
#include <M5StampC3LED.h>
#include "secrets.h"

WiFiManager wifiManager;
WiFiClientSecure wifiClient = WiFiClientSecure();
MQTTClient mqttClient = MQTTClient(256);
M5StampC3LED led = M5StampC3LED();
uint64_t chipId = ESP.getEfuseMac();

bool connect() {
  char apName[64] = {0};
  sprintf(apName, "%s-%04X", AP_NAME_PREFIX, chipId);

  // wifiManager.startConfigPortal(apName);
  wifiManager.autoConnect(apName, AP_PASSWORD);
  Serial.println("wifi connected");

  wifiClient.setCACert(AWS_CERT_CA);
  wifiClient.setCertificate(AWS_CERT_CRT);
  wifiClient.setPrivateKey(AWS_CERT_PRIVATE);
  mqttClient.begin(AWS_IOT_ENDPOINT, 8883, wifiClient);
  
  for (int retry = 0 ; retry < 3 ; retry++) {
    mqttClient.connect(THINGNAME);
    if (mqttClient.connected()) {
      break;
    }
    Serial.print(".");
    delay(5000);
  }

  return true;
}

void publish() {
  StaticJsonDocument<200> doc;
  doc["device"] = chipId;
  doc["time"] = millis();
  
  char jsonBuffer[512];
  serializeJson(doc, jsonBuffer);
  mqttClient.publish("m5stamp-c3", jsonBuffer);
}

void setup() {
  Serial.begin(115200);
  esp_deep_sleep_enable_gpio_wakeup(BIT(3), ESP_GPIO_WAKEUP_GPIO_LOW);
  led.show(10, 10, 0);

  bool ret = connect();
  if (!ret) {
    led.show(10, 0, 0);
  } else {
    publish();
    led.show(0, 0, 10);
  }

  delay(1000);
  led.clear();
  esp_deep_sleep_start();
}

void loop() {
  delay(100);
}
