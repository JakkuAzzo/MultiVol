/* iig(DriverKit-440 Apr  7 2026 02:26:18) generated from MultiVolAudioDevice.iig */

#undef	IIG_IMPLEMENTATION
#define	IIG_IMPLEMENTATION 	MultiVolAudioDevice.iig

#if KERNEL
#include <libkern/c++/OSString.h>
#else
#include <DriverKit/DriverKit.h>
#endif /* KERNEL */
#include <DriverKit/IOReturn.h>
#include "MultiVolAudioDevice.h"


#if __has_builtin(__builtin_load_member_function_pointer)
#define SimpleMemberFunctionCast(cfnty, self, func) (cfnty)__builtin_load_member_function_pointer(self, func)
#else
#define SimpleMemberFunctionCast(cfnty, self, func) ({ union { typeof(func) memfun; cfnty cfun; } pair; pair.memfun = func; pair.cfun; })
#endif


#if !KERNEL
extern OSMetaClass * gOSContainerMetaClass;
extern OSMetaClass * gOSDataMetaClass;
extern OSMetaClass * gOSNumberMetaClass;
extern OSMetaClass * gOSStringMetaClass;
extern OSMetaClass * gOSBooleanMetaClass;
extern OSMetaClass * gOSDictionaryMetaClass;
extern OSMetaClass * gOSArrayMetaClass;
extern OSMetaClass * gOSSetMetaClass;
extern OSMetaClass * gOSOrderedSetMetaClass;
extern OSMetaClass * gIOMemoryDescriptorMetaClass;
extern OSMetaClass * gIOBufferMemoryDescriptorMetaClass;
extern OSMetaClass * gIOUserClientMetaClass;
extern OSMetaClass * gOSActionMetaClass;
extern OSMetaClass * gIOServiceStateNotificationDispatchSourceMetaClass;
extern OSMetaClass * gIOUserAudioCustomPropertyMetaClass;
extern OSMetaClass * gIOUserAudioDriverMetaClass;
extern OSMetaClass * gIODispatchQueueMetaClass;
extern OSMetaClass * gIOUserAudioStreamMetaClass;
extern OSMetaClass * gIOUserAudioControlMetaClass;
#endif /* !KERNEL */

#if !KERNEL

#define MultiVolAudioDevice_QueueNames  ""

#define MultiVolAudioDevice_MethodNames  ""

#define MultiVolAudioDeviceMetaClass_MethodNames  ""

struct OSClassDescription_MultiVolAudioDevice_t
{
    OSClassDescription base;
    uint64_t           methodOptions[2 * 0];
    uint64_t           metaMethodOptions[2 * 0];
    char               queueNames[sizeof(MultiVolAudioDevice_QueueNames)];
    char               methodNames[sizeof(MultiVolAudioDevice_MethodNames)];
    char               metaMethodNames[sizeof(MultiVolAudioDeviceMetaClass_MethodNames)];
};

const struct OSClassDescription_MultiVolAudioDevice_t
OSClassDescription_MultiVolAudioDevice =
{
    .base =
    {
        .descriptionSize         = sizeof(OSClassDescription_MultiVolAudioDevice_t),
        .name                    = "MultiVolAudioDevice",
        .superName               = "IOUserAudioDevice",
        .methodOptionsSize       = 2 * sizeof(uint64_t) * 0,
        .methodOptionsOffset     = __builtin_offsetof(struct OSClassDescription_MultiVolAudioDevice_t, methodOptions),
        .metaMethodOptionsSize   = 2 * sizeof(uint64_t) * 0,
        .metaMethodOptionsOffset = __builtin_offsetof(struct OSClassDescription_MultiVolAudioDevice_t, metaMethodOptions),
        .queueNamesSize       = sizeof(MultiVolAudioDevice_QueueNames),
        .queueNamesOffset     = __builtin_offsetof(struct OSClassDescription_MultiVolAudioDevice_t, queueNames),
        .methodNamesSize         = sizeof(MultiVolAudioDevice_MethodNames),
        .methodNamesOffset       = __builtin_offsetof(struct OSClassDescription_MultiVolAudioDevice_t, methodNames),
        .metaMethodNamesSize     = sizeof(MultiVolAudioDeviceMetaClass_MethodNames),
        .metaMethodNamesOffset   = __builtin_offsetof(struct OSClassDescription_MultiVolAudioDevice_t, metaMethodNames),
        .flags                   = 0*kOSClassCanRemote,
        .resv1                   = {0},
    },
    .methodOptions =
    {
    },
    .metaMethodOptions =
    {
    },
    .queueNames      = MultiVolAudioDevice_QueueNames,
    .methodNames     = MultiVolAudioDevice_MethodNames,
    .metaMethodNames = MultiVolAudioDeviceMetaClass_MethodNames,
};

OSMetaClass * gMultiVolAudioDeviceMetaClass;

static kern_return_t
MultiVolAudioDevice_New(OSMetaClass * instance);

const OSClassLoadInformation
MultiVolAudioDevice_Class = 
{
    .description       = &OSClassDescription_MultiVolAudioDevice.base,
    .metaPointer       = &gMultiVolAudioDeviceMetaClass,
    .version           = 1,
    .instanceSize      = sizeof(MultiVolAudioDevice),

    .resv2             = {0},

    .New               = &MultiVolAudioDevice_New,
    .resv3             = {0},

};

extern const void * const
gMultiVolAudioDevice_Declaration;
const void * const
gMultiVolAudioDevice_Declaration
__attribute__((used,visibility("hidden"),section("__DATA_CONST,__osclassinfo,regular,no_dead_strip"),no_sanitize("address")))
    = &MultiVolAudioDevice_Class;

static kern_return_t
MultiVolAudioDevice_New(OSMetaClass * instance)
{
    if (!new(instance) MultiVolAudioDeviceMetaClass) return (kIOReturnNoMemory);
    return (kIOReturnSuccess);
}

kern_return_t
MultiVolAudioDeviceMetaClass::New(OSObject * instance)
{
    if (!new(instance) MultiVolAudioDevice) return (kIOReturnNoMemory);
    return (kIOReturnSuccess);
}

#endif /* !KERNEL */

#ifdef KERNEL
#define MESSAGE_CONTENT(__field) (messageContent->__field)
#else /* KERNEL */
#define MESSAGE_CONTENT(__field) (message->content.__field)
#endif /* KERNEL */

kern_return_t
MultiVolAudioDevice::Dispatch(const IORPC rpc)
{
    return _Dispatch(this, rpc);
}

kern_return_t
MultiVolAudioDevice::_Dispatch(MultiVolAudioDevice * self, const IORPC rpc)
{
    kern_return_t ret = kIOReturnUnsupported;
#ifdef KERNEL
    IORPCMessage * msg = rpc.kernelContent;
#else /* KERNEL */
    IORPCMessage * msg = IORPCMessageFromMach(rpc.message, false);
#endif /* KERNEL */

    switch (msg->msgid)
    {

        default:
            ret = IOUserAudioDevice::_Dispatch(self, rpc);
            break;
    }

    return (ret);
}

#if KERNEL
kern_return_t
MultiVolAudioDevice::MetaClass::Dispatch(const IORPC rpc)
{
#else /* KERNEL */
kern_return_t
MultiVolAudioDeviceMetaClass::Dispatch(const IORPC rpc)
{
#endif /* !KERNEL */

    kern_return_t ret = kIOReturnUnsupported;
#ifdef KERNEL
    IORPCMessage * msg = rpc.kernelContent;
#else /* KERNEL */
    IORPCMessage * msg = IORPCMessageFromMach(rpc.message, false);
#endif /* KERNEL */

    switch (msg->msgid)
    {

        default:
            ret = OSMetaClassBase::Dispatch(rpc);
            break;
    }

    return (ret);
}



