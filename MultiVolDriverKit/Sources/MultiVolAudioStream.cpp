#include "MultiVolAudioStream.h"
#include "MultiVolDriverConfig.hpp"

bool
MultiVolAudioStream::init(IOUserAudioDriver* in_driver,
                          IOUserAudioStreamDirection in_direction,
                          IOMemoryDescriptor* in_io_memory_descriptor)
{
    if (!super::init(in_driver, in_direction, in_io_memory_descriptor))
    {
        return false;
    }

    IOUserAudioStreamBasicDescription format = {};
    format.mSampleRate = MultiVolDriverConfig::kDefaultSampleRate;
    format.mFormatID = IOUserAudioFormatID::LinearPCM;
    format.mFormatFlags = IOUserAudioFormatFlags::FormatFlagsNativeFloatPacked;
    format.mBytesPerPacket = MultiVolDriverConfig::kBytesPerFrame;
    format.mFramesPerPacket = MultiVolDriverConfig::kFramesPerPacket;
    format.mBytesPerFrame = MultiVolDriverConfig::kBytesPerFrame;
    format.mChannelsPerFrame = MultiVolDriverConfig::kChannelCount;
    format.mBitsPerChannel = MultiVolDriverConfig::kBitsPerChannel;

    SetCurrentStreamFormat(&format);
    SetTerminalType(IOUserAudioStreamTerminalType::Speaker);
    SetLatency(0);

    return true;
}

void
MultiVolAudioStream::free()
{
    super::free();
}

kern_return_t
MultiVolAudioStream::StartIO(IOUserAudioStartStopFlags in_flags)
{
    return super::StartIO(in_flags);
}

kern_return_t
MultiVolAudioStream::StopIO(IOUserAudioStartStopFlags in_flags)
{
    return super::StopIO(in_flags);
}

kern_return_t
MultiVolAudioStream::HandleChangeCurrentStreamFormat(const IOUserAudioStreamBasicDescription* in_format)
{
    return super::HandleChangeCurrentStreamFormat(in_format);
}

kern_return_t
MultiVolAudioStream::HandleChangeStreamIsActive(bool in_is_active)
{
    return super::HandleChangeStreamIsActive(in_is_active);
}
