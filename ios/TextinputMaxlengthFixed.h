
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNTextinputMaxlengthFixedSpec.h"

@interface TextinputMaxlengthFixed : NSObject <NativeTextinputMaxlengthFixedSpec>
#else
#import <React/RCTBridgeModule.h>

@interface TextinputMaxlengthFixed : NSObject <RCTBridgeModule>
#endif

@end
