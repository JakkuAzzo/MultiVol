/* iig(DriverKit-440 Apr  7 2026 02:26:18) generated from MultiVolAudioUserClient.iig */

#undef	IIG_IMPLEMENTATION
#define	IIG_IMPLEMENTATION 	MultiVolAudioUserClient.iig

#if KERNEL
#include <libkern/c++/OSString.h>
#else
#include <DriverKit/DriverKit.h>
#endif /* KERNEL */
#include <DriverKit/IOReturn.h>
#include "MultiVolAudioUserClient.h"


#if __has_builtin(__builtin_load_member_function_pointer)
#define SimpleMemberFunctionCast(cfnty, self, func) (cfnty)__builtin_load_member_function_pointer(self, func)
#else
#define SimpleMemberFunctionCast(cfnty, self, func) ({ union { typeof(func) memfun; cfnty cfun; } pair; pair.memfun = func; pair.cfun; })
#endif


#if !KERNEL
extern OSMetaClass * gOSContainerMetaClass;
extern OSMetaClass * gOSDataMetaClass;
extern OSMetaClass * gOSNumberMetaClass;
extern OSMetaClass * gOSBooleanMetaClass;
extern OSMetaClass * gOSDictionaryMetaClass;
extern OSMetaClass * gOSArrayMetaClass;
extern OSMetaClass * gOSSetMetaClass;
extern OSMetaClass * gOSOrderedSetMetaClass;
extern OSMetaClass * gIODispatchQueueMetaClass;
extern OSMetaClass * gOSStringMetaClass;
extern OSMetaClass * gIOServiceStateNotificationDispatchSourceMetaClass;
extern OSMetaClass * gIOMemoryMapMetaClass;
extern OSMetaClass * gOSAction_IOUserClient_KernelCompletionMetaClass;
#endif /* !KERNEL */

#if !KERNEL

#define MultiVolAudioUserClient_QueueNames  "" \
    "\037IOUserClientQueueExternalMethod"

#define MultiVolAudioUserClient_MethodNames  "" \
    "\017_ExternalMethod"

#define MultiVolAudioUserClientMetaClass_MethodNames  ""

struct OSClassDescription_MultiVolAudioUserClient_t
{
    OSClassDescription base;
    uint64_t           methodOptions[2 * 1];
    uint64_t           metaMethodOptions[2 * 0];
    char               queueNames[sizeof(MultiVolAudioUserClient_QueueNames)];
    char               methodNames[sizeof(MultiVolAudioUserClient_MethodNames)];
    char               metaMethodNames[sizeof(MultiVolAudioUserClientMetaClass_MethodNames)];
};

const struct OSClassDescription_MultiVolAudioUserClient_t
OSClassDescription_MultiVolAudioUserClient =
{
    .base =
    {
        .descriptionSize         = sizeof(OSClassDescription_MultiVolAudioUserClient_t),
        .name                    = "MultiVolAudioUserClient",
        .superName               = "IOUserClient",
        .methodOptionsSize       = 2 * sizeof(uint64_t) * 1,
        .methodOptionsOffset     = __builtin_offsetof(struct OSClassDescription_MultiVolAudioUserClient_t, methodOptions),
        .metaMethodOptionsSize   = 2 * sizeof(uint64_t) * 0,
        .metaMethodOptionsOffset = __builtin_offsetof(struct OSClassDescription_MultiVolAudioUserClient_t, metaMethodOptions),
        .queueNamesSize       = sizeof(MultiVolAudioUserClient_QueueNames),
        .queueNamesOffset     = __builtin_offsetof(struct OSClassDescription_MultiVolAudioUserClient_t, queueNames),
        .methodNamesSize         = sizeof(MultiVolAudioUserClient_MethodNames),
        .methodNamesOffset       = __builtin_offsetof(struct OSClassDescription_MultiVolAudioUserClient_t, methodNames),
        .metaMethodNamesSize     = sizeof(MultiVolAudioUserClientMetaClass_MethodNames),
        .metaMethodNamesOffset   = __builtin_offsetof(struct OSClassDescription_MultiVolAudioUserClient_t, metaMethodNames),
        .flags                   = 0*kOSClassCanRemote,
        .resv1                   = {0},
    },
    .methodOptions =
    {
        IOUserClient__ExternalMethod_ID,
        0x0000000000000000,
    },
    .metaMethodOptions =
    {
    },
    .queueNames      = MultiVolAudioUserClient_QueueNames,
    .methodNames     = MultiVolAudioUserClient_MethodNames,
    .metaMethodNames = MultiVolAudioUserClientMetaClass_MethodNames,
};

OSMetaClass * gMultiVolAudioUserClientMetaClass;

static kern_return_t
MultiVolAudioUserClient_New(OSMetaClass * instance);

const OSClassLoadInformation
MultiVolAudioUserClient_Class = 
{
    .description       = &OSClassDescription_MultiVolAudioUserClient.base,
    .metaPointer       = &gMultiVolAudioUserClientMetaClass,
    .version           = 1,
    .instanceSize      = sizeof(MultiVolAudioUserClient),

    .resv2             = {0},

    .New               = &MultiVolAudioUserClient_New,
    .resv3             = {0},

};

extern const void * const
gMultiVolAudioUserClient_Declaration;
const void * const
gMultiVolAudioUserClient_Declaration
__attribute__((used,visibility("hidden"),section("__DATA_CONST,__osclassinfo,regular,no_dead_strip"),no_sanitize("address")))
    = &MultiVolAudioUserClient_Class;

static kern_return_t
MultiVolAudioUserClient_New(OSMetaClass * instance)
{
    if (!new(instance) MultiVolAudioUserClientMetaClass) return (kIOReturnNoMemory);
    return (kIOReturnSuccess);
}

kern_return_t
MultiVolAudioUserClientMetaClass::New(OSObject * instance)
{
    if (!new(instance) MultiVolAudioUserClient) return (kIOReturnNoMemory);
    return (kIOReturnSuccess);
}

#endif /* !KERNEL */

#ifdef KERNEL
#define MESSAGE_CONTENT(__field) (messageContent->__field)
#else /* KERNEL */
#define MESSAGE_CONTENT(__field) (message->content.__field)
#endif /* KERNEL */

kern_return_t
MultiVolAudioUserClient::Dispatch(const IORPC rpc)
{
    return _Dispatch(this, rpc);
}

kern_return_t
MultiVolAudioUserClient::_Dispatch(MultiVolAudioUserClient * self, const IORPC rpc)
{
    kern_return_t ret = kIOReturnUnsupported;
#ifdef KERNEL
    IORPCMessage * msg = rpc.kernelContent;
#else /* KERNEL */
    IORPCMessage * msg = IORPCMessageFromMach(rpc.message, false);
#endif /* KERNEL */

    switch (msg->msgid)
    {
        case IOService_Start_ID:
        {
            ret = IOService::Start_Invoke(rpc, self, SimpleMemberFunctionCast(IOService::Start_Handler, *self, &MultiVolAudioUserClient::Start_Impl));
            break;
        }
        case IOService_Stop_ID:
        {
            ret = IOService::Stop_Invoke(rpc, self, SimpleMemberFunctionCast(IOService::Stop_Handler, *self, &MultiVolAudioUserClient::Stop_Impl));
            break;
        }
        case IOUserClient_AsyncCompletion_ID:
#if !KERNEL
        if (self->IsRemote())
        {
            ret = self->OSMetaClassBase::Dispatch(rpc);
            break;
        }
        else
#endif /* !KERNEL */
        {
            ret = IOUserClient::AsyncCompletion_Invoke(rpc, self, SimpleMemberFunctionCast(IOUserClient::AsyncCompletion_Handler, *self, &MultiVolAudioUserClient::AsyncCompletion_Impl));
            break;
        }
        case IOUserClient_CopyClientMemoryForType_ID:
#if !KERNEL
        if (self->IsRemote())
        {
            ret = self->OSMetaClassBase::Dispatch(rpc);
            break;
        }
        else
#endif /* !KERNEL */
        {
            ret = IOUserClient::CopyClientMemoryForType_Invoke(rpc, self, SimpleMemberFunctionCast(IOUserClient::CopyClientMemoryForType_Handler, *self, &MultiVolAudioUserClient::CopyClientMemoryForType_Impl));
            break;
        }

        default:
            ret = IOUserClient::_Dispatch(self, rpc);
            break;
    }

    return (ret);
}

#if KERNEL
kern_return_t
MultiVolAudioUserClient::MetaClass::Dispatch(const IORPC rpc)
{
#else /* KERNEL */
kern_return_t
MultiVolAudioUserClientMetaClass::Dispatch(const IORPC rpc)
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



