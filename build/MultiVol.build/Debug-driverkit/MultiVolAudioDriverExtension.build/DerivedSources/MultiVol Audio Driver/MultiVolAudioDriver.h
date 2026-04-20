/* iig(DriverKit-440) generated from MultiVolAudioDriver.iig */

/* MultiVolAudioDriver.iig:1-6 */
#ifndef MultiVolAudioDriver_h
#define MultiVolAudioDriver_h

#include <Availability.h>
#include <AudioDriverKit/IOUserAudioDriver.h>  /* .iig include */

/* source class MultiVolAudioDriver MultiVolAudioDriver.iig:7-16 */

#if __DOCUMENTATION__
#define KERNEL IIG_KERNEL

class MultiVolAudioDriver: public IOUserAudioDriver
{
public:
    virtual kern_return_t Start(IOService* provider) override;
    virtual kern_return_t Stop(IOService* provider) override;
    virtual kern_return_t NewUserClient(uint32_t in_type, IOUserClient** out_user_client) override;
    virtual kern_return_t StartDevice(IOUserAudioObjectID in_object_id,
                                      IOUserAudioStartStopFlags in_flags) override;
    virtual kern_return_t StopDevice(IOUserAudioObjectID in_object_id,
                                     IOUserAudioStartStopFlags in_flags) override;
};

#undef KERNEL
#else /* __DOCUMENTATION__ */

/* generated class MultiVolAudioDriver MultiVolAudioDriver.iig:7-16 */


#define MultiVolAudioDriver_Start_Args \
        IOService * provider

#define MultiVolAudioDriver_Stop_Args \
        IOService * provider

#define MultiVolAudioDriver_NewUserClient_Args \
        uint32_t in_type, \
        IOUserClient ** out_user_client

#define MultiVolAudioDriver_Methods \
\
public:\
\
    virtual kern_return_t\
    Dispatch(const IORPC rpc) APPLE_KEXT_OVERRIDE;\
\
    static kern_return_t\
    _Dispatch(MultiVolAudioDriver * self, const IORPC rpc);\
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
    kern_return_t\
    NewUserClient_Impl(IOService_NewUserClient_Args);\
\
\
public:\
    /* _Invoke methods */\
\


#define MultiVolAudioDriver_KernelMethods \
\
protected:\
    /* _Impl methods */\
\


#define MultiVolAudioDriver_VirtualMethods \
\
public:\
\
    virtual kern_return_t\
    StartDevice(\
        IOUserAudioObjectID in_object_id,\
        IOUserAudioStartStopFlags in_flags) APPLE_KEXT_OVERRIDE;\
\
    virtual kern_return_t\
    StopDevice(\
        IOUserAudioObjectID in_object_id,\
        IOUserAudioStartStopFlags in_flags) APPLE_KEXT_OVERRIDE;\
\


#if !KERNEL

extern OSMetaClass          * gMultiVolAudioDriverMetaClass;
extern const OSClassLoadInformation MultiVolAudioDriver_Class;

class MultiVolAudioDriverMetaClass : public OSMetaClass
{
public:
    virtual kern_return_t
    New(OSObject * instance) override;
    virtual kern_return_t
    Dispatch(const IORPC rpc) override;
};

#endif /* !KERNEL */

#if !KERNEL

class  MultiVolAudioDriverInterface : public OSInterface
{
public:
};

struct MultiVolAudioDriver_IVars;
struct MultiVolAudioDriver_LocalIVars;

class MultiVolAudioDriver : public IOUserAudioDriver, public MultiVolAudioDriverInterface
{
#if !KERNEL
    friend class MultiVolAudioDriverMetaClass;
#endif /* !KERNEL */

#if !KERNEL
public:
#ifdef MultiVolAudioDriver_DECLARE_IVARS
MultiVolAudioDriver_DECLARE_IVARS
#else /* MultiVolAudioDriver_DECLARE_IVARS */
    union
    {
        MultiVolAudioDriver_IVars * ivars;
        MultiVolAudioDriver_LocalIVars * lvars;
    };
#endif /* MultiVolAudioDriver_DECLARE_IVARS */
#endif /* !KERNEL */

#if !KERNEL
    static OSMetaClass *
    sGetMetaClass() { return gMultiVolAudioDriverMetaClass; };
#endif /* KERNEL */

    using super = IOUserAudioDriver;

#if !KERNEL
    MultiVolAudioDriver_Methods
    MultiVolAudioDriver_VirtualMethods
#endif /* !KERNEL */

};
#endif /* !KERNEL */


#endif /* !__DOCUMENTATION__ */

/* MultiVolAudioDriver.iig:18- */

#endif
