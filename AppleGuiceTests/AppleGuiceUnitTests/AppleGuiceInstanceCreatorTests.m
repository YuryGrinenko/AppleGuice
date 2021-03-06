//
//  AppleGuiceInstanceCreatorTests.m
//  AppleGuiceTests
//
//  Created by Tomer Shiri on 4/2/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceInstanceCreatorTests.h"
#import "AppleGuiceInstanceCreator.h"
#import "AppleGuiceSettingsProvider.h"
#import "AppleGuiceInjectorProtocol.h"
#import "AppleGuiceProtocolLocatorProtocol.h"
#import "AppleGuiceSingletonRepositoryProtocol.h"
#import "AppleGuiceSingleton.h"

@interface TestClass : NSObject {
}
@end
@implementation TestClass
@end


@implementation AppleGuiceInstanceCreatorTests {
    AppleGuiceInstanceCreator* serviceUnderTest;
    AppleGuiceSettingsProvider* settingsProvider;
    id singletonRepository;
    id protocolLocator;
    id injector;
}

-(void)setUp
{
    [super setUp];
    serviceUnderTest = [[AppleGuiceInstanceCreator alloc] init];
    
    settingsProvider = [[AppleGuiceSettingsProvider alloc] init];
    singletonRepository = [OCMockObject mockForProtocol:@protocol(AppleGuiceSingletonRepositoryProtocol)];
    protocolLocator = [OCMockObject mockForProtocol:@protocol(AppleGuiceProtocolLocatorProtocol)];
    injector = [OCMockObject mockForProtocol:@protocol(AppleGuiceInjectorProtocol)];
    
    serviceUnderTest.settingsProvider = settingsProvider;
    serviceUnderTest.singletonRepository = singletonRepository;
    serviceUnderTest.protocolLocator = protocolLocator;
    serviceUnderTest.injector = injector;
}


//instanceForClass

-(void) test__instanceForClass__nilClass__returnsNil {
    id classInstance = [serviceUnderTest instanceForClass:NSClassFromString(INVALID_CLASS_NAME)];
    EXP_expect(classInstance).to.equal(nil);
}

-(void) test__instanceForClass__validClassWithDefaultInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[injector reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:[TestClass class]];
    
    [protocolLocator verify];
    [injector verify];
    STAssertEquals([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([TestClass class]);
}

-(void) test__instanceForClass__validClassWithDefaultInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[injector expect] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:[TestClass class]];
    
    [injector verify];
    [protocolLocator verify];
    STAssertEquals([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([TestClass class]);
}

-(void) test__instanceForClass__validClassWithLazyLoadInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[injector reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:[TestClass class]];
    
    [protocolLocator verify];
    [injector verify];
    STAssertEquals([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([TestClass class]);
}

-(void) test__instanceForClass__validClassWithLazyLoadInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[injector expect] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:[TestClass class]];
    
    [protocolLocator verify];
    [injector verify];
    STAssertEquals([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([TestClass class]);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    Class mockedClass = [TestClass class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    [[singletonRepository expect] setInstance:OCMOCK_ANY forClass:mockedClass];
    [[[singletonRepository expect] andReturn:nil] instanceForClass:mockedClass];
    
    id classInstance = [serviceUnderTest instanceForClass:mockedClass];
    
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(mockedClass);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    Class mockedClass = [TestClass class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    [[singletonRepository expect] setInstance:OCMOCK_ANY forClass:mockedClass];
    [[[singletonRepository expect] andReturn:nil] instanceForClass:mockedClass];
    [[injector expect] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:mockedClass];
    
    [injector verify];
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(mockedClass);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonProtocolAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    
    Class injectedClass = [TestClass class];
    
    [[[protocolLocator expect] andReturn:@[ injectedClass ]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[singletonRepository expect] setInstance:OCMOCK_ANY forClass:injectedClass];
    [[[singletonRepository expect] andReturn:nil] instanceForClass:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonProtocolAndManualInjectionPolicy__NewInstanceIsReturned {
    Class injectedClass = [TestClass class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    
    [[[protocolLocator expect] andReturn:@[ injectedClass ]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[singletonRepository expect] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepository expect] andReturn:nil] instanceForClass:OCMOCK_ANY];
    [[injector expect] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [injector verify];
    [singletonRepository verify];
    [protocolLocator verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    Class injectedClass = [TestClass class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;

    [[singletonRepository reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepository expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    Class injectedClass = [TestClass class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;

    [[singletonRepository reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepository expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
    [[injector reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [injector verify];
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonProtocolAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    
    Class injectedClass = [TestClass class];
    
    [[[protocolLocator expect] andReturn:@[ injectedClass ]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[singletonRepository reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepository expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [protocolLocator verify];
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonProtocolAndManualInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    
    Class injectedClass = [TestClass class];
    [[[protocolLocator expect] andReturn:@[ injectedClass ]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[singletonRepository reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepository expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
    [[injector reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [protocolLocator verify];
    [injector verify];
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

//instanceForProtocol

-(void) test__instanceForProtocol__invalidProtocol__returnsNil {
    id result = [serviceUnderTest instanceForProtocol:NSProtocolFromString(INVALID_PROTOCOL_NAME)];
    EXP_expect(result).to.beNil();
}

-(void) test__instanceForProtocol__noImplementations__returnsNil {
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(NSCopying)];
    id result = [serviceUnderTest instanceForProtocol:@protocol(NSCopying)];
    [protocolLocator verify];
    EXP_expect(result).to.beNil();
}

-(void) test__instanceForProtocol__nilImplementations__returnsNil {
    [[[protocolLocator expect] andReturn:nil] getAllClassesByProtocolType:@protocol(NSCopying)];
    id result = [serviceUnderTest instanceForProtocol:@protocol(NSCopying)];
    [protocolLocator verify];
    EXP_expect(result).to.beNil();
}

-(void) test__instanceForProtocol__singleImplementation__callsInstanceForClassWithFirstImplementation {
    Class injectedClass = [TestClass class];
    [[[protocolLocator expect] andReturn:@[ injectedClass, [NSArray class] ]] getAllClassesByProtocolType:@protocol(NSCopying)];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andReturn:[[injectedClass alloc] init]] instanceForClass:injectedClass];
    
    id result = [mockedInjector instanceForProtocol:@protocol(NSCopying)];
    
    [protocolLocator verify];
    [mockedInjector verify];
    EXP_expect(result).to.beKindOf(injectedClass);
}

//allInstancesForProtocol

-(void) test__allInstancesForProtocol__invalidProtocol__returnsNil {
    id result = [serviceUnderTest allInstancesForProtocol:NSProtocolFromString(INVALID_PROTOCOL_NAME)];
    EXP_expect(result).to.beNil();
}

-(void) test__allInstancesForProtocol__noImplementations__returnsNil {
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(NSCopying)];
    id result = [serviceUnderTest allInstancesForProtocol:@protocol(NSCopying)];
    [protocolLocator verify];
    EXP_expect(result).to.beNil();
}

-(void) test__allInstancesForProtocol__nilImplementations__returnsNil {
    [[[protocolLocator expect] andReturn:nil] getAllClassesByProtocolType:@protocol(NSCopying)];
    id result = [serviceUnderTest allInstancesForProtocol:@protocol(NSCopying)];
    [protocolLocator verify];
    EXP_expect(result).to.beNil();
}

-(void) test__allInstancesForProtocol__validProtocols__InstanceForClassIsCalledForEachImplementation {
    Class injectedClass = [TestClass class];
    Protocol* protocol = @protocol(NSCopying);
    
    [[[protocolLocator expect] andReturn:@[ injectedClass, injectedClass ]] getAllClassesByProtocolType:protocol];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andReturn:[NSSet set]] instanceForClass:injectedClass];
    [[[mockedInjector expect] andReturn:[NSArray array]] instanceForClass:injectedClass];
    
    id result = [mockedInjector allInstancesForProtocol:protocol];
    
    [protocolLocator verify];
    [mockedInjector verify];
    EXP_expect(result).to.beKindOf([NSArray class]);
    EXP_expect(result).notTo.beKindOf([NSMutableArray class]);
    EXP_expect([result count]).to.equal(2);
    EXP_expect([result objectAtIndex:0]).to.beKindOf([NSSet class]);
    EXP_expect([result objectAtIndex:1]).to.beKindOf([NSArray class]);
}

-(void) test__allInstancesForProtocol__instanceForClassResturnsNil__instanceIsNotSaved {
    Class injectedClass = [TestClass class];
    Protocol* protocol = @protocol(NSCopying);
    
    [[[protocolLocator expect] andReturn:@[ injectedClass, injectedClass ]] getAllClassesByProtocolType:protocol];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andReturn:nil] instanceForClass:injectedClass];
    [[[mockedInjector expect] andReturn:[NSSet set]] instanceForClass:injectedClass];
    
    id result = [mockedInjector allInstancesForProtocol:protocol];
    
    [protocolLocator verify];
    [mockedInjector verify];
    EXP_expect(result).to.beKindOf([NSArray class]);
    EXP_expect(result).notTo.beKindOf([NSMutableArray class]);
    EXP_expect([result count]).to.equal(1);
    EXP_expect([result objectAtIndex:0]).to.beKindOf([NSSet class]);
}
@end
