/* iig(DriverKit-440) generated from MultiVolAudioStream.iig */

/* MultiVolAudioStream.iig:1-6 */
#ifndef MultiVolAudioStream_h
#define MultiVolAudioStream_h

#include <Availability.h>
#include <AudioDriverKit/IOUserAudioStream.h>  /* .iig include */

/* source class MultiVolAudioStream MultiVolAudioStream.iig:7-17 */

#if __DOCUMENTATION__
#define KERNEL IIG_KERNEL

class MultiVolAudioStream: public IOUserAudioStream
{
public:
    virtual bool init(IOUserAudioDriver* in_driver,
                      IOUserAudioStreamDirection in_direction,
                      IOMemoryDescriptor* in_io_memory_descriptor) override;
    virtual void free() override;
    virtual kern_return_t StartIO(IOUserAudioStartStopFlags in_flags) override;
    virtual kern_return_t StopIO(IOUserAudioStartStopFlags in_flags) override;
    virtual kern_return_t HandleChangeCurrentStreamFormat(const IOUserAudioStreamBasicDescription* in_format) override;
    virtual kern_return_t HandleChangeStreamIsActive(bool in_is_active) override;
};

#undef KERNEL
#else /* __DOCUMENTATION__ */

/* generated class MultiVolAudioStream MultiVolAudioStream.iig:7-17 */


#define MultiVolAudioStream_Methods \
\
public:\
\
    virtual kern_return_t\
    Dispatch(const IORPC rpc) APPLE_KEXT_OVERRIDE;\
\
    static kern_return_t\
    _Dispatch(MultiVolAudioStream * self, const IORPC rpc);\
\
\
protected:\
    /* _Impl methods */\
\
\
public:\
    /* _Invoke methods */\
\


#define MultiVolAudioStream_KernelMethods \
\
protected:\
    /* _Impl methods */\
\


#define MultiVolAudioStream_VirtualMethods \
\
public:\
\
    virtual bool\
    init(\
        IOUserAudioDriver * in_driver,\
        IOUserAudioStreamDirection in_direction,\
        IOMemoryDescriptor * in_io_memory_descriptor) APPLE_KEXT_OVERRIDE;\
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
    HandleChangeCurrentStreamFormat(\
        const IOUserAudioStreamBasicDescription * in_format) APPLE_KEXT_OVERRIDE;\
\
    virtual kern_return_t\
    HandleChangeStreamIsActive(\
        bool in_is_active) APPLE_KEXT_OVERRIDE;\
\


#if !KERNEL

extern OSMetaClass          * gMultiVolAudioStreamMetaClass;
extern const OSClassLoadInformation MultiVolAudioStream_Class;

class MultiVolAudioStreamMetaClass : public OSMetaClass
{
public:
    virtual kern_return_t
    New(OSObject * instance) override;
    virtual kern_return_t
    Dispatch(const IORPC rpc) override;
};

#endif /* !KERNEL */

#if !KERNEL

class  MultiVolAudioStreamInterface : public OSInterface
{
public:
};

struct MultiVolAudioStream_IVars;
struct MultiVolAudioStream_LocalIVars;

class MultiVolAudioStream : public IOUserAudioStream, public MultiVolAudioStreamInterface
{
#if !KERNEL
    friend class MultiVolAudioStreamMetaClass;
#endif /* !KERNEL */

#if !KERNEL
public:
#ifdef MultiVolAudioStream_DECLARE_IVARS
MultiVolAudioStream_DECLARE_IVARS
#else /* MultiVolAudioStream_DECLARE_IVARS */
    union
    {
        MultiVolAudioStream_IVars * ivars;
        MultiVolAudioStream_LocalIVars * lvars;
    };
#endif /* MultiVolAudioStream_DECLARE_IVARS */
#endif /* !KERNEL */

#if !KERNEL
    static OSMetaClass *
    sGetMetaClass() { return gMultiVolAudioStreamMetaClass; };
#endif /* KERNEL */

    using super = IOUserAudioStream;

#if !KERNEL
    MultiVolAudioStream_Methods
    MultiVolAudioStream_VirtualMethods
#endif /* !KERNEL */

};
#endif /* !KERNEL */


#endif /* !__DOCUMENTATION__ */

/* MultiVolAudioStream.iig:19- */

#endif
