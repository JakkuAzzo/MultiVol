/* iig(DriverKit-440 Apr  7 2026 02:26:18) generated from MultiVolAudioStream.iig */

#undef	IIG_IMPLEMENTATION
#define	IIG_IMPLEMENTATION 	MultiVolAudioStream.iig

#if KERNEL
#include <libkern/c++/OSString.h>
#else
#include <DriverKit/DriverKit.h>
#endif /* KERNEL */
#include <DriverKit/IOReturn.h>
#include "MultiVolAudioStream.h"


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
extern OSMetaClass * gIOUserAudioDeviceMetaClass;
#endif /* !KERNEL */

#if !KERNEL

#define MultiVolAudioStream_QueueNames  ""

#define MultiVolAudioStream_MethodNames  ""

#define MultiVolAudioStreamMetaClass_MethodNames  ""

struct OSClassDescription_MultiVolAudioStream_t
{
    OSClassDescription base;
    uint64_t           methodOptions[2 * 0];
    uint64_t           metaMethodOptions[2 * 0];
    char               queueNames[sizeof(MultiVolAudioStream_QueueNames)];
    char               methodNames[sizeof(MultiVolAudioStream_MethodNames)];
    char               metaMethodNames[sizeof(MultiVolAudioStreamMetaClass_MethodNames)];
};

const struct OSClassDescription_MultiVolAudioStream_t
OSClassDescription_MultiVolAudioStream =
{
    .base =
    {
        .descriptionSize         = sizeof(OSClassDescription_MultiVolAudioStream_t),
        .name                    = "MultiVolAudioStream",
        .superName               = "IOUserAudioStream",
        .methodOptionsSize       = 2 * sizeof(uint64_t) * 0,
        .methodOptionsOffset     = __builtin_offsetof(struct OSClassDescription_MultiVolAudioStream_t, methodOptions),
        .metaMethodOptionsSize   = 2 * sizeof(uint64_t) * 0,
        .metaMethodOptionsOffset = __builtin_offsetof(struct OSClassDescription_MultiVolAudioStream_t, metaMethodOptions),
        .queueNamesSize       = sizeof(MultiVolAudioStream_QueueNames),
        .queueNamesOffset     = __builtin_offsetof(struct OSClassDescription_MultiVolAudioStream_t, queueNames),
        .methodNamesSize         = sizeof(MultiVolAudioStream_MethodNames),
        .methodNamesOffset       = __builtin_offsetof(struct OSClassDescription_MultiVolAudioStream_t, methodNames),
        .metaMethodNamesSize     = sizeof(MultiVolAudioStreamMetaClass_MethodNames),
        .metaMethodNamesOffset   = __builtin_offsetof(struct OSClassDescription_MultiVolAudioStream_t, metaMethodNames),
        .flags                   = 0*kOSClassCanRemote,
        .resv1                   = {0},
    },
    .methodOptions =
    {
    },
    .metaMethodOptions =
    {
    },
    .queueNames      = MultiVolAudioStream_QueueNames,
    .methodNames     = MultiVolAudioStream_MethodNames,
    .metaMethodNames = MultiVolAudioStreamMetaClass_MethodNames,
};

OSMetaClass * gMultiVolAudioStreamMetaClass;

static kern_return_t
MultiVolAudioStream_New(OSMetaClass * instance);

const OSClassLoadInformation
MultiVolAudioStream_Class = 
{
    .description       = &OSClassDescription_MultiVolAudioStream.base,
    .metaPointer       = &gMultiVolAudioStreamMetaClass,
    .version           = 1,
    .instanceSize      = sizeof(MultiVolAudioStream),

    .resv2             = {0},

    .New               = &MultiVolAudioStream_New,
    .resv3             = {0},

};

extern const void * const
gMultiVolAudioStream_Declaration;
const void * const
gMultiVolAudioStream_Declaration
__attribute__((used,visibility("hidden"),section("__DATA_CONST,__osclassinfo,regular,no_dead_strip"),no_sanitize("address")))
    = &MultiVolAudioStream_Class;

static kern_return_t
MultiVolAudioStream_New(OSMetaClass * instance)
{
    if (!new(instance) MultiVolAudioStreamMetaClass) return (kIOReturnNoMemory);
    return (kIOReturnSuccess);
}

kern_return_t
MultiVolAudioStreamMetaClass::New(OSObject * instance)
{
    if (!new(instance) MultiVolAudioStream) return (kIOReturnNoMemory);
    return (kIOReturnSuccess);
}

#endif /* !KERNEL */

#ifdef KERNEL
#define MESSAGE_CONTENT(__field) (messageContent->__field)
#else /* KERNEL */
#define MESSAGE_CONTENT(__field) (message->content.__field)
#endif /* KERNEL */

kern_return_t
MultiVolAudioStream::Dispatch(const IORPC rpc)
{
    return _Dispatch(this, rpc);
}

kern_return_t
MultiVolAudioStream::_Dispatch(MultiVolAudioStream * self, const IORPC rpc)
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
            ret = IOUserAudioStream::_Dispatch(self, rpc);
            break;
    }

    return (ret);
}

#if KERNEL
kern_return_t
MultiVolAudioStream::MetaClass::Dispatch(const IORPC rpc)
{
#else /* KERNEL */
kern_return_t
MultiVolAudioStreamMetaClass::Dispatch(const IORPC rpc)
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



