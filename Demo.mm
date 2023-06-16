#if !OBJC_APPLE
#import "Demo_mutable_generated.h"
#else
#import "Demo_generated.h"
#import "Demo_generated_internal.h"
#endif

#import <Foundation/Foundation.h>

#define OBJC 1
#define CPP 1

using namespace apple::aiml;

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSLog(@"start");

		// MARK: ----- ObjC -----
#if OBJC
		DM_MutableAsset *dmAssetA = [[DM_MutableAsset alloc] init];
		dmAssetA.name = @"DEMO-A";
		DM_MutableProgress *dmProgressA = [[DM_MutableProgress alloc] init];
		dmProgressA.total = 100;
		dmProgressA.completed = 1;
		dmAssetA.progress = dmProgressA;
		dmAssetA.state = DM_State_Available;
		dmAssetA.components = @[];

		DM_MutableAsset *dmAssetB = [[DM_MutableAsset alloc] init];
		dmAssetB.name = @"DEMO-B";
		DM_MutableProgress *dmProgressB = [[DM_MutableProgress alloc] init];
		dmProgressB.total = 100;
		dmProgressB.completed = 2;
		dmAssetB.progress = dmProgressB;
		dmAssetB.state = DM_State_Available;
		dmAssetB.components = @[];

		DM_MutableAssets *dmAssets = [[DM_MutableAssets alloc] init];
		dmAssets.name = @"DEMO";
		dmAssets.enabled = YES;
		dmAssets.count = 2;
		dmAssets.assets = @[dmAssetA, dmAssetB];

		// serialize
		NSData *dmData = [dmAssets flatbuffData];

		// deserialize
		#if !OBJC_APPLE
		DM_Assets *dmAssetsOut = [[DM_Assets alloc] initWithFlatbuffData:dmData];
		#else
		DM_Assets *dmAssetsOut = [[DM_Assets alloc] initVerifiedRootObjectFromData:dmData];
		#endif
		NSLog(@"%i",dmAssetsOut.count);

		DM_Asset *dmAssetOut = dmAssetsOut.assets.firstObject;
		NSLog(@"asset name: %@", dmAssetOut.name);
#endif
		// MARK: ----- C++ -----
#if CPP
		// builder
        flatbuffers2::FlatBufferBuilder builder;

		// create container
		std::vector<flatbuffers2::Offset<DM::Asset>> assets_vector;

		// asset A
        auto nameA = builder.CreateString("DEMO-A");	
		auto progressA = DM::CreateProgress(builder, 100, 1);
	
		std::vector<flatbuffers2::Offset<DM::Asset>> componentsA_vector;
		auto componentsA = builder.CreateVector(componentsA_vector);

	#if !OBJC_APPLE
		auto state = DM::State_Available;
	#else
		auto state = DM::State::Available;
	#endif

		auto assetA = DM::CreateAsset(builder, nameA, progressA, state, componentsA);
		assets_vector.push_back(assetA);

		// asset B
        auto nameB = builder.CreateString("DEMO-B");
		auto progressB = DM::CreateProgress(builder, 100, 1);
	
		std::vector<flatbuffers2::Offset<DM::Asset>> componentsB_vector;
		auto componentsB = builder.CreateVector(componentsB_vector);

		auto assetB = DM::CreateAsset(builder, nameB, progressB, state, componentsB);
		assets_vector.push_back(assetB);

		// asset container
        auto name = builder.CreateString("DEMO");
		auto assets = builder.CreateVector(assets_vector);
		auto asset = CreateAssets(builder, name, 2, true, assets);

		// serialize
		builder.Finish(asset);
		char *buffer = (char *)builder.GetBufferPointer();
		NSLog(@"buffer size: %d", builder.GetSize());

		// deserialize
	 	auto assetsOut = DM::GetAssets(buffer);
		NSLog(@"%i",assetsOut->count());

		auto assetOut = assetsOut->assets()->Get(0);
		NSString *nameOut = [NSString stringWithUTF8String:assetOut->name()->c_str()];
		NSLog(@"asset name: %@", nameOut);
#endif		
		NSLog(@"stop");
  }
}