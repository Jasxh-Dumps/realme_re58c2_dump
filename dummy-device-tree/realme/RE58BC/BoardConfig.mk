DEVICE_PATH := device/realme/RE58BC
BOARD_VENDOR := realme

# Security patch level
VENDOR_SECURITY_PATCH := 2023-07-05

# HIDL
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/ai_engine-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.biometrics.fingerprint@2.1-service.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.cas@1.2-service.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.drm-service.clearkey.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.gatekeeper@1.0-service.trusty.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.health-service.example.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.security.keymint@2.0-unisoc.service.trusty.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.sensors-multihal.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.thermal@2.0-service.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.usb-service.example.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.wifi.hostapd.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.wifi.supplicant.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/android.hardware.wifi@1.0-service.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/bluetooth_audio.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/cplog_svc-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/enhance-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/face-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/hdcp-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/lights.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest_android.hardware.drm-service.widevine.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest_dualsim.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest_media_c2_V1_1_unisoc.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest_oplus_performance.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/memtrack.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/network-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/power.stats-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/rebootescrow-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/soter_default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/trusty-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/tui-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/vendor-fingerprintmmi-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/vendor-log-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/vendor-oemlock-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/vendor-power-default.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/vendor.sprd.hardware.boot@1.2.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/vendor.sprd.hardware.commondcs@1.0-service.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/vendor.sprd.hardware.gnss@2.2-service.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/vendor.sprd.hardware.thermal@2.0-service.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/vibrator.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(DEVICE_PATH)/framework_compatibility_matrix.xml

-include vendor/realme/RE58BC/BoardConfigVendor.mk