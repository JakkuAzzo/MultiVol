/* iig(DriverKit-440) generated from MultiVolAudioUserClient.iig */

/* MultiVolAudioUserClient.iig:1-6 */
#ifndef MultiVolAudioUserClient_h
#define MultiVolAudioUserClient_h

#include <Availability.h>
#include <DriverKit/IOUserClient.h>  /* .iig include */

/* source class MultiVolAudioUserClient MultiVolAudioUserClient.iig:7-25 */

#if __DOCUMENTATION__
#define KERNEL IIG_KERNEL

class MultiVolAudioUserClient: public IOUserClient
{
public:
    virtual bool init() override;
    virtual void free() override;
    virtual kern_return_t Start(IOService* provider) override;
    virtual kern_return_t Stop(IOService* provider) override;
    virtual kern_return_t ExternalMethod(uint64_t selector,
                                         IOUserClientMethodArguments* arguments,
                                         const IOUserClientMethodDispatch* dispatch,
                                         OSObject* target,
                                         void* reference) override;
    virtual void AsyncCompletion(OSAction* action,
                                 IOReturn status,
                                 const IOUserClientAsyncArgumentsArray asyncData,
                                 uint32_t asyncDataCount) override;
    virtual kern_return_t CopyClientMemoryForType(uint64_t type,
                                                  uint64_t* options,
                                                  IOMemoryDescriptor** memory) override;
};

#undef KERNEL
#else /* __DOCUMENTATION__ */

/* generated class MultiVolAudioUserClient MultiVolAudioUserClient.iig:7-25 */


#define MultiVolAudioUserClient_Start_Args \
        IOService * provider

#define MultiVolAudioUserClient_Stop_Args \
        IOService * provider

#define MultiVolAudioUserClient_AsyncCompletion_Args \
        OSAction * action, \
        IOReturn status, \
        const unsigned long long * asyncData, \
        uint32_t asyncDataCount

#define MultiVolAudioUserClient_CopyClientMemoryForType_Args \
        uint64_t type, \
        uint64_t * options, \
        IOMemoryDescriptor ** memory

#define MultiVolAudioUserClient_Methods \
\
public:\
\
    virtual kern_return_t\
    Dispatch(const IORPC rpc) APPLE_KEXT_OVERRIDE;\
\
    static kern_return_t\
    _Dispatch(MultiVolAudioUserClient * self, const IORPC rpc);\
\
\
protected:\
    /* _Impl methods */\
\
    kern_return_t\
    Start_Impl(IOService_Start_Args);\
\
    kern_return_t\
    Stop_Impl(IOService_Stop_Args);\
\
    void\
    AsyncCompletion_Impl(IOUserClient_AsyncCompletion_Args);\
\
    kern_return_t\
    CopyClientMemoryForType_Impl(IOUserClient_CopyClientMemoryForType_Args);\
\
\
public:\
    /* _Invoke methods */\
\


#define MultiVolAudioUserClient_KernelMethods \
\
protected:\
    /* _Impl methods */\
\


#define MultiVolAudioUserClient_VirtualMethods \
\
public:\
\
    virtual bool\
    init(\
) APPLE_KEXT_OVERRIDE;\
\
    virtual void\
    free(\
) APPLE_KEXT_OVERRIDE;\
\
    virtual kern_return_t\
    ExternalMethod(\
        uint64_t selector,\
        IOUserClientMethodArguments * arguments,\
        const IOUserClientMethodDispatch * dispatch,\
        OSObject * target,\
        void * reference) APPLE_KEXT_OVERRIDE;\
\


#if !KERNEL

extern OSMetaClass          * gMultiVolAudioUserClientMetaClass;
extern const OSClassLoadInformation MultiVolAudioUserClient_Class;

class MultiVolAudioUserClientMetaClass : public OSMetaClass
{
public:
    virtual kern_return_t
    New(OSObject * instance) override;
    virtual kern_return_t
    Dispatch(const IORPC rpc) override;
};

#endif /* !KERNEL */

#if !KERNEL

class  MultiVolAudioUserClientInterface : public OSInterface
{
public:
};

struct MultiVolAudioUserClient_IVars;
struct MultiVolAudioUserClient_LocalIVars;

class MultiVolAudioUserClient : public IOUserClient, public MultiVolAudioUserClientInterface
{
#if !KERNEL
    friend class MultiVolAudioUserClientMetaClass;
#endif /* !KERNEL */

#if !KERNEL
public:
#ifdef MultiVolAudioUserClient_DECLARE_IVARS
MultiVolAudioUserClient_DECLARE_IVARS
#else /* MultiVolAudioUserClient_DECLARE_IVARS */
    union
    {
        MultiVolAudioUserClient_IVars * ivars;
        MultiVolAudioUserClient_LocalIVars * lvars;
    };
#endif /* MultiVolAudioUserClient_DECLARE_IVARS */
#endif /* !KERNEL */

#if !KERNEL
    static OSMetaClass *
    sGetMetaClass() { return gMultiVolAudioUserClientMetaClass; };
#endif /* KERNEL */

    using super = IOUserClient;

#if !KERNEL
    MultiVolAudioUserClient_Methods
    MultiVolAudioUserClient_VirtualMethods
#endif /* !KERNEL */

};
#endif /* !KERNEL */


#endif /* !__DOCUMENTATION__ */

/* MultiVolAudioUserClient.iig:27- */

#endif
