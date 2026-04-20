#pragma once

#include <cstdint>
#include <AudioDriverKit/AudioDriverKit.h>

namespace MultiVolDriverConfig
{
constexpr const char* kDriverName = "MultiVol Audio Driver";
constexpr const char* kDeviceName = "MultiVol Output";
constexpr const char* kDeviceUID = "com.jakkuazzo.multivol.output.main";
constexpr const char* kModelUID = "MultiVolOutputModel";
constexpr const char* kManufacturerUID = "com.jakkuazzo.multivol";

constexpr uint32_t kBridgeMemoryType = 0;
constexpr uint32_t kBridgeUserClientType = 'MVUC';

constexpr uint32_t kChannelCount = 2;
constexpr uint32_t kFramesPerPacket = 1;
constexpr uint32_t kBitsPerChannel = 32;
constexpr uint32_t kBytesPerChannel = kBitsPerChannel / 8;
constexpr uint32_t kBytesPerFrame = kChannelCount * kBytesPerChannel;
constexpr uint32_t kZeroTimestampPeriod = 256;
constexpr uint32_t kBufferFrameCapacity = 2048;
constexpr uint32_t kBufferByteCapacity = kBytesPerFrame * kBufferFrameCapacity;
constexpr double kDefaultSampleRate = 48000.0;
constexpr double kSupportedSampleRates[] = {44100.0, 48000.0};
} // namespace MultiVolDriverConfig
