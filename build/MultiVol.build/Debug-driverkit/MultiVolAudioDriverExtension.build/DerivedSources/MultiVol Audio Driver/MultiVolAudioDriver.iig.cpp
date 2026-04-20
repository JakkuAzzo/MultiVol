/* iig(DriverKit-440 Apr  7 2026 02:26:18) generated from MultiVolAudioDriver.iig */

#undef	IIG_IMPLEMENTATION
#define	IIG_IMPLEMENTATION 	MultiVolAudioDriver.iig

#if KERNEL
#include <libkern/c++/OSString.h>
#else
#include <DriverKit/DriverKit.h>
#endif /* KERNEL */
#include <DriverKit/IOReturn.h>
#include "MultiVolAudioDriver.h"


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
extern OSMetaClass * gIODispatchQueueMetaClass;
extern OSMetaClass * gIOMemoryDescriptorMetaClass;
extern OSMetaClass * gIOBufferMemoryDescriptorMetaClass;
extern OSMetaClass * gIOUserClientMetaClass;
extern OSMetaClass * gOSActionMetaClass;
extern OSMetaClass * gIOServiceStateNotificationDispatchSourceMetaClass;
extern OSMetaClass * gIOUserAudioObjectMetaClass;
extern OSMetaClass * gIOUserAudioDeviceMetaClass;
extern OSMetaClass * gIOUserAudioCustomPropertyMetaClass;
#endif /* !KERNEL */

#if !KERNEL

#define MultiVolAudioDriver_QueueNames  ""

#define MultiVolAudioDriver_MethodNames  ""

#define MultiVolAudioDriverMetaClass_MethodNames  ""

struct OSClassDescription_MultiVolAudioDriver_t
{
    OSClassDescription base;
    uint64_t           methodOptions[2 * 0];
    uint64_t           metaMethodOptions[2 * 0];
    char               queueNames[sizeof(MultiVolAudioDriver_QueueNames)];
    char               methodNames[sizeof(MultiVolAudioDriver_MethodNames)];
    char               metaMethodNames[sizeof(MultiVolAudioDriverMetaClass_MethodNames)];
};

const struct OSClassDescription_MultiVolAudioDriver_t
OSClassDescription_MultiVolAudioDriver =
{
    .base =
    {
        .descriptionSize         = sizeof(OSClassDescription_MultiVolAudioDriver_t),
        .name                    = "MultiVolAudioDriver",
        .superName               = "IOUserAudioDriver",
        .methodOptionsSize       = 2 * sizeof(uint64_t) * 0,
        .methodOptionsOffset     = __builtin_offsetof(struct OSClassDescription_MultiVolAudioDriver_t, methodOptions),
        .metaMethodOptionsSize   = 2 * sizeof(uint64_t) * 0,
        .metaMethodOptionsOffset = __builtin_offsetof(struct OSClassDescription_MultiVolAudioDriver_t, metaMethodOptions),
        .queueNamesSize       = sizeof(MultiVolAudioDriver_QueueNames),
        .queueNamesOffset     = __builtin_offsetof(struct OSClassDescription_MultiVolAudioDriver_t, queueNames),
        .methodNamesSize         = sizeof(MultiVolAudioDriver_MethodNames),
        .methodNamesOffset       = __builtin_offsetof(struct OSClassDescription_MultiVolAudioDriver_t, methodNames),
        .metaMethodNamesSize     = sizeof(MultiVolAudioDriverMetaClass_MethodNames),
        .metaMethodNamesOffset   = __builtin_offsetof(struct OSClassDescription_MultiVolAudioDriver_t, metaMethodNames),
        .flags                   = 0*kOSClassCanRemote,
        .resv1                   = {0},
    },
    .methodOptions =
    {
    },
    .metaMethodOptions =
    {
    },
    .queueNames      = MultiVolAudioDriver_QueueNames,
    .methodNames     = MultiVolAudioDriver_MethodNames,
    .metaMethodNames = MultiVolAudioDriverMetaClass_MethodNames,
};

OSMetaClass * gMultiVolAudioDriverMetaClass;

static kern_return_t
MultiVolAudioDriver_New(OSMetaClass * instance);

const OSClassLoadInformation
MultiVolAudioDriver_Class = 
{
    .description       = &OSClassDescription_MultiVolAudioDriver.base,
    .metaPointer       = &gMultiVolAudioDriverMetaClass,
    .version           = 1,
    .instanceSize      = sizeof(MultiVolAudioDriver),

    .resv2             = {0},

    .New               = &MultiVolAudioDriver_New,
    .resv3             = {0},

};

extern const void * const
gMultiVolAudioDriver_Declaration;
const void * const
gMultiVolAudioDriver_Declaration
__attribute__((used,visibility("hidden"),section("__DATA_CONST,__osclassinfo,regular,no_dead_strip"),no_sanitize("address")))
    = &MultiVolAudioDriver_Class;

static kern_return_t
MultiVolAudioDriver_New(OSMetaClass * instance)
{
    if (!new(instance) MultiVolAudioDriverMetaClass) return (kIOReturnNoMemory);
    return (kIOReturnSuccess);
}

kern_return_t
MultiVolAudioDriverMetaClass::New(OSObject * instance)
{
    if (!new(instance) MultiVolAudioDriver) return (kIOReturnNoMemory);
    return (kIOReturnSuccess);
}

#endif /* !KERNEL */

#ifdef KERNEL
#define MESSAGE_CONTENT(__field) (messageContent->__field)
#else /* KERNEL */
#define MESSAGE_CONTENT(__field) (message->content.__field)
#endif /* KERNEL */

kern_return_t
MultiVolAudioDriver::Dispatch(const IORPC rpc)
{
    return _Dispatch(this, rpc);
}

kern_return_t
MultiVolAudioDriver::_Dispatch(MultiVolAudioDriver * self, const IORPC rpc)
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
            ret = IOService::Start_Invoke(rpc, self, SimpleMemberFunctionCast(IOService::Start_Handler, *self, &MultiVolAudioDriver::Start_Impl));
            break;
        }
        case IOService_Stop_ID:
        {
            ret = IOService::Stop_Invoke(rpc, self, SimpleMemberFunctionCast(IOService::Stop_Handler, *self, &MultiVolAudioDriver::Stop_Impl));
            break;
        }
        case IOService_NewUserClient_ID:
#if !KERNEL
        if (self->IsRemote())
        {
            ret = self->OSMetaClassBase::Dispatch(rpc);
            break;
        }
        else
#endif /* !KERNEL */
        {
            ret = IOService::NewUserClient_Invoke(rpc, self, SimpleMemberFunctionCast(IOService::NewUserClient_Handler, *self, &MultiVolAudioDriver::NewUserClient_Impl));
            break;
        }

        default:
            ret = IOUserAudioDriver::_Dispatch(self, rpc);
            break;
    }

    return (ret);
}

#if KERNEL
kern_return_t
MultiVolAudioDriver::MetaClass::Dispatch(const IORPC rpc)
{
#else /* KERNEL */
kern_return_t
MultiVolAudioDriverMetaClass::Dispatch(const IORPC rpc)
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



