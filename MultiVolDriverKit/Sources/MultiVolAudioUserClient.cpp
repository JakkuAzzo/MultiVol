#include <DriverKit/IOBufferMemoryDescriptor.h>
#include <DriverKit/OSSharedPtr.h>

#include "MultiVolAudioUserClient.h"
#include "MultiVolDriverConfig.hpp"

namespace
{
OSSharedPtr<IOBufferMemoryDescriptor> gBridgeBuffer;
}

bool
MultiVolAudioUserClient::init()
{
    if (!super::init())
    {
        return false;
    }

    IOBufferMemoryDescriptor* rawBuffer = nullptr;
    auto result = IOBufferMemoryDescriptor::Create(kIOMemoryDirectionOutIn,
                                                   4096,
                                                   0,
                                                   &rawBuffer);
    if (result != kIOReturnSuccess || rawBuffer == nullptr)
    {
        return false;
    }

    gBridgeBuffer.reset(rawBuffer, OSNoRetain);
    gBridgeBuffer->SetLength(4096);
    return true;
}

void
MultiVolAudioUserClient::free()
{
    gBridgeBuffer.reset();
    super::free();
}

kern_return_t
IMPL(MultiVolAudioUserClient, Start)
{
    return Start(provider, SUPERDISPATCH);
}

kern_return_t
IMPL(MultiVolAudioUserClient, Stop)
{
    return Stop(provider, SUPERDISPATCH);
}

kern_return_t
MultiVolAudioUserClient::ExternalMethod(uint64_t selector,
                                        IOUserClientMethodArguments* arguments,
                                        const IOUserClientMethodDispatch* dispatch,
                                        OSObject* target,
                                        void* reference)
{
    if (selector == 0 && arguments != nullptr && arguments->scalarOutput != nullptr && arguments->scalarOutputCount >= 1)
    {
        arguments->scalarOutput[0] = 1;
        return kIOReturnSuccess;
    }

    return super::ExternalMethod(selector, arguments, dispatch, target, reference);
}

void
IMPL(MultiVolAudioUserClient, AsyncCompletion)
{
    (void)action;
    (void)status;
    (void)asyncData;
    (void)asyncDataCount;
}

kern_return_t
IMPL(MultiVolAudioUserClient, CopyClientMemoryForType)
{
    if (type != MultiVolDriverConfig::kBridgeMemoryType || !gBridgeBuffer || memory == nullptr)
    {
        return kIOReturnBadArgument;
    }

    if (options != nullptr)
    {
        *options = 0;
    }

    gBridgeBuffer->retain();
    *memory = gBridgeBuffer.get();
    return kIOReturnSuccess;
}
