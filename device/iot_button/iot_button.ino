#include <WiFiManager.h>
#include <WiFiClientSecure.h>
#include <MQTT.h>
#include <ArduinoJson.h>
#include <M5StampC3LED.h>
#include "secrets.h"

#define BUTTON_PIN (3)

WiFiManager wifiManager;
WiFiClientSecure wifiClient = WiFiClientSecure();
MQTTClient mqttClient = MQTTClient(256);
M5StampC3LED led = M5StampC3LED();
uint64_t chipId = ESP.getEfuseMac();

void deepSleep() {
  esp_deep_sleep_enable_gpio_wakeup(BIT(BUTTON_PIN), ESP_GPIO_WAKEUP_GPIO_LOW);
  esp_deep_sleep_start();
}

bool buttonPressed() {
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  int button = digitalRead(BUTTON_PIN);
  return button == LOW;
}

void waitForButtonRelease() {
  while (buttonPressed()) {
    delay(100);
  }
}

bool connect() {
  char apName[64] = { 0 };
  sprintf(apName, "%s-%04X", AP_NAME_PREFIX, chipId);

  // 強制的にWi-Fi設定画面を表示する場合はコメントアウトを外す
  //wifiManager.startConfigPortal(apName);
  wifiManager.autoConnect(apName, AP_PASSWORD);

  wifiClient.setCACert(AWS_CERT_CA);
  wifiClient.setCertificate(AWS_CERT_CRT);
  wifiClient.setPrivateKey(AWS_CERT_PRIVATE);
  mqttClient.begin(AWS_IOT_ENDPOINT, 8883, wifiClient);
  mqttClient.connect(THINGNAME);

  return mqttClient.connected();
}

bool publish() {
  StaticJsonDocument<200> doc;
  doc["device"] = chipId;
  doc["time"] = millis();

  char jsonBuffer[512];
  serializeJson(doc, jsonBuffer);
  return mqttClient.publish(AWS_IOT_TOPIC, jsonBuffer);
}

void setup() {
  Serial.begin(115200);
  Serial.println("Start to IoT Button.");

  if (!buttonPressed()) {
    deepSleep();
    return;
  }

  led.show(10, 10, 0);
  (connect() && publish()) ? led.show(0, 0, 10) : led.show(10, 0, 0);
  delay(1000);

  led.clear();
  waitForButtonRelease();
  Serial.println("End to IoT Button.");
  deepSleep();
}

void loop() {
  delay(100);
}
