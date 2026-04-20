/* iig(DriverKit-440) generated from MultiVolAudioDevice.iig */

/* MultiVolAudioDevice.iig:1-6 */
#ifndef MultiVolAudioDevice_h
#define MultiVolAudioDevice_h

#include <Availability.h>
#include <AudioDriverKit/IOUserAudioDevice.h>  /* .iig include */

/* source class MultiVolAudioDevice MultiVolAudioDevice.iig:7-23 */

#if __DOCUMENTATION__
#define KERNEL IIG_KERNEL

class MultiVolAudioDevice: public IOUserAudioDevice
{
public:
    virtual bool init(IOUserAudioDriver* in_driver,
                      bool in_supports_prewarming,
                      OSString* in_device_uid,
                      OSString* in_model_uid,
                      OSString* in_manufacturer_uid,
                      uint32_t in_zero_timestamp_period) override;
    virtual void free() override;
    virtual kern_return_t StartIO(IOUserAudioStartStopFlags in_flags) override;
    virtual kern_return_t StopIO(IOUserAudioStartStopFlags in_flags) override;
    virtual kern_return_t PerformDeviceConfigurationChange(uint64_t in_change_action,
                                                           OSObject* in_change_info) override;
    virtual kern_return_t AbortDeviceConfigurationChange(uint64_t in_change_action,
                                                         OSObject* in_change_info) override;
    virtual kern_return_t HandleChangeSampleRate(double in_sample_rate) override;
};

#undef KERNEL
#else /* __DOCUMENTATION__ */

/* generated class MultiVolAudioDevice MultiVolAudioDevice.iig:7-23 */


#define MultiVolAudioDevice_Methods \
\
public:\
\
    virtual kern_return_t\
    Dispatch(const IORPC rpc) APPLE_KEXT_OVERRIDE;\
\
    static kern_return_t\
    _Dispatch(MultiVolAudioDevice * self, const IORPC rpc);\
\
\
protected:\
    /* _Impl methods */\
\
\
public:\
    /* _Invoke methods */\
\


#define MultiVolAudioDevice_KernelMethods \
\
protected:\
    /* _Impl methods */\
\


#define MultiVolAudioDevice_VirtualMethods \
\
public:\
\
    virtual bool\
    init(\
        IOUserAudioDriver * in_driver,\
        bool in_supports_prewarming,\
        OSString * in_device_uid,\
        OSString * in_model_uid,\
        OSString * in_manufacturer_uid,\
        uint32_t in_zero_timestamp_period) APPLE_KEXT_OVERRIDE;\
\
    virtual void\
    free(\
) APPLE_KEXT_OVERRIDE;\
\
    virtual kern_return_t\
    StartIO(\
        IOUserAudioStartStopFlags in_flags) APPLE_KEXT_OVERRIDE;\
\
    virtual kern_return_t\
    StopIO(\
        IOUserAudioStartStopFlags in_flags) APPLE_KEXT_OVERRIDE;\
\
    virtual kern_return_t\
    PerformDeviceConfigurationChange(\
        uint64_t in_change_action,\
        OSObject * in_change_info) APPLE_KEXT_OVERRIDE;\
\
    virtual kern_return_t\
    AbortDeviceConfigurationChange(\
        uint64_t in_change_action,\
        OSObject * in_change_info) APPLE_KEXT_OVERRIDE;\
\
    virtual kern_return_t\
    HandleChangeSampleRate(\
        double in_sample_rate) APPLE_KEXT_OVERRIDE;\
\


#if !KERNEL

extern OSMetaClass          * gMultiVolAudioDeviceMetaClass;
extern const OSClassLoadInformation MultiVolAudioDevice_Class;

class MultiVolAudioDeviceMetaClass : public OSMetaClass
{
public:
    virtual kern_return_t
    New(OSObject * instance) override;
    virtual kern_return_t
    Dispatch(const IORPC rpc) override;
};

#endif /* !KERNEL */

#if !KERNEL

class  MultiVolAudioDeviceInterface : public OSInterface
{
public:
};

struct MultiVolAudioDevice_IVars;
struct MultiVolAudioDevice_LocalIVars;

class MultiVolAudioDevice : public IOUserAudioDevice, public MultiVolAudioDeviceInterface
{
#if !KERNEL
    friend class MultiVolAudioDeviceMetaClass;
#endif /* !KERNEL */

#if !KERNEL
public:
#ifdef MultiVolAudioDevice_DECLARE_IVARS
MultiVolAudioDevice_DECLARE_IVARS
#else /* MultiVolAudioDevice_DECLARE_IVARS */
    union
    {
        MultiVolAudioDevice_IVars * ivars;
        MultiVolAudioDevice_LocalIVars * lvars;
    };
#endif /* MultiVolAudioDevice_DECLARE_IVARS */
#endif /* !KERNEL */

#if !KERNEL
    static OSMetaClass *
    sGetMetaClass() { return gMultiVolAudioDeviceMetaClass; };
#endif /* KERNEL */

    using super = IOUserAudioDevice;

#if !KERNEL
    MultiVolAudioDevice_Methods
    MultiVolAudioDevice_VirtualMethods
#endif /* !KERNEL */

};
#endif /* !KERNEL */


#endif /* !__DOCUMENTATION__ */

/* MultiVolAudioDevice.iig:25- */

#endif
