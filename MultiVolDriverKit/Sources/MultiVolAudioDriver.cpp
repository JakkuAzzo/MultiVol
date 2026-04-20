#include <DriverKit/IOBufferMemoryDescriptor.h>
#include <DriverKit/OSString.h>

#include "MultiVolAudioDevice.h"
#include "MultiVolAudioDriver.h"
#include "MultiVolAudioUserClient.h"
#include "MultiVolDriverConfig.hpp"

kern_return_t
IMPL(MultiVolAudioDriver, Start)
{
    auto result = Start(provider, SUPERDISPATCH);
    if (result != kIOReturnSuccess)
    {
        return result;
    }

    auto name = OSSharedPtr(OSString::withCString(MultiVolDriverConfig::kDriverName), OSNoRetain);
    if (name)
    {
        SetName(name.get());
    }
    SetTransportType(IOUserAudioTransportType::BuiltIn);

    auto deviceUID = OSSharedPtr(OSString::withCString(MultiVolDriverConfig::kDeviceUID), OSNoRetain);
    auto modelUID = OSSharedPtr(OSString::withCString(MultiVolDriverConfig::kModelUID), OSNoRetain);
    auto manufacturerUID = OSSharedPtr(OSString::withCString(MultiVolDriverConfig::kManufacturerUID), OSNoRetain);

    auto device = OSSharedPtr(OSTypeAlloc(MultiVolAudioDevice), OSNoRetain);
    if (!device ||
        !deviceUID ||
        !modelUID ||
        !manufacturerUID ||
        !device->init(this,
                      false,
                      deviceUID.get(),
                      modelUID.get(),
                      manufacturerUID.get(),
                      MultiVolDriverConfig::kZeroTimestampPeriod))
    {
        return kIOReturnNoMemory;
    }

    return RegisterService();
}

kern_return_t
IMPL(MultiVolAudioDriver, Stop)
{
    return Stop(provider, SUPERDISPATCH);
}

kern_return_t
IMPL(MultiVolAudioDriver, NewUserClient)
{
    if (out_user_client == nullptr)
    {
        return kIOReturnBadArgument;
    }

    if (in_type == MultiVolDriverConfig::kBridgeUserClientType)
    {
        auto userClient = OSSharedPtr(OSTypeAlloc(MultiVolAudioUserClient), OSNoRetain);
        if (!userClient || !userClient->init())
        {
            return kIOReturnNoMemory;
        }

        userClient->retain();
        *out_user_client = userClient.get();
        return kIOReturnSuccess;
    }

    return NewUserClient(in_type, out_user_client, SUPERDISPATCH);
}

kern_return_t
MultiVolAudioDriver::StartDevice(IOUserAudioObjectID in_object_id,
                                 IOUserAudioStartStopFlags in_flags)
{
    return super::StartDevice(in_object_id, in_flags);
}

kern_return_t
MultiVolAudioDriver::StopDevice(IOUserAudioObjectID in_object_id,
                                IOUserAudioStartStopFlags in_flags)
{
    return super::StopDevice(in_object_id, in_flags);
}
