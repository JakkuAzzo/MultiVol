#include <DriverKit/IOBufferMemoryDescriptor.h>
#include <DriverKit/IOMemoryDescriptor.h>
#include <DriverKit/OSString.h>

#include "MultiVolAudioDevice.h"
#include "MultiVolAudioStream.h"
#include "MultiVolDriverConfig.hpp"

namespace
{
OSSharedPtr<IOBufferMemoryDescriptor> gOutputBuffer;
}

bool
MultiVolAudioDevice::init(IOUserAudioDriver* in_driver,
                          bool in_supports_prewarming,
                          OSString* in_device_uid,
                          OSString* in_model_uid,
                          OSString* in_manufacturer_uid,
                          uint32_t in_zero_timestamp_period)
{
    if (!super::init(in_driver,
                     in_supports_prewarming,
                     in_device_uid,
                     in_model_uid,
                     in_manufacturer_uid,
                     in_zero_timestamp_period))
    {
        return false;
    }

    auto name = OSSharedPtr(OSString::withCString(MultiVolDriverConfig::kDeviceName), OSNoRetain);
    if (name)
    {
        SetName(name.get());
    }

    SetCanBeDefaultOutputDevice(true);
    SetPreferredChannelsForStereo(1, 2);
    SetSampleRate(MultiVolDriverConfig::kDefaultSampleRate);
    SetAvailableSampleRates(MultiVolDriverConfig::kSupportedSampleRates,
                            sizeof(MultiVolDriverConfig::kSupportedSampleRates) / sizeof(double));

    IOBufferMemoryDescriptor* rawBuffer = nullptr;
    auto createBufferResult = IOBufferMemoryDescriptor::Create(kIOMemoryDirectionOutIn,
                                                               MultiVolDriverConfig::kBufferByteCapacity,
                                                               0,
                                                               &rawBuffer);
    if (createBufferResult != kIOReturnSuccess || rawBuffer == nullptr)
    {
        return false;
    }

    gOutputBuffer.reset(rawBuffer, OSNoRetain);
    gOutputBuffer->SetLength(MultiVolDriverConfig::kBufferByteCapacity);

    auto stream = OSSharedPtr(OSTypeAlloc(MultiVolAudioStream), OSNoRetain);
    if (!stream || !stream->init(in_driver, IOUserAudioStreamDirection::Output, gOutputBuffer.get()))
    {
        return false;
    }

    if (AddStream(stream.get()) != kIOReturnSuccess)
    {
        return false;
    }

    return true;
}

void
MultiVolAudioDevice::free()
{
    gOutputBuffer.reset();
    super::free();
}

kern_return_t
MultiVolAudioDevice::StartIO(IOUserAudioStartStopFlags in_flags)
{
    return super::StartIO(in_flags);
}

kern_return_t
MultiVolAudioDevice::StopIO(IOUserAudioStartStopFlags in_flags)
{
    return super::StopIO(in_flags);
}

kern_return_t
MultiVolAudioDevice::PerformDeviceConfigurationChange(uint64_t in_change_action,
                                                      OSObject* in_change_info)
{
    return super::PerformDeviceConfigurationChange(in_change_action, in_change_info);
}

kern_return_t
MultiVolAudioDevice::AbortDeviceConfigurationChange(uint64_t in_change_action,
                                                    OSObject* in_change_info)
{
    return super::AbortDeviceConfigurationChange(in_change_action, in_change_info);
}

kern_return_t
MultiVolAudioDevice::HandleChangeSampleRate(double in_sample_rate)
{
    return super::HandleChangeSampleRate(in_sample_rate);
}
