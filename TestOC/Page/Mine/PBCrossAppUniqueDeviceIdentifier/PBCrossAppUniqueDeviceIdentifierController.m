//
//  PBCrossAppUniqueDeviceIdentifierController.m
//  TestOC
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossAppUniqueDeviceIdentifierController.h"

#if __has_include(<PBCrossAppUniqueDeviceIdentifier/PBCrossAppUniqueDeviceIdentifier.h>)
#import <PBCrossAppUniqueDeviceIdentifier/PBCrossAppUniqueDeviceIdentifier.h>
#else
#import "PBCrossAppUniqueDeviceIdentifier.h"
#endif

static NSString * const PBCrossDemoSalt = @"testoc-crossapp-demo-salt";

typedef NS_ENUM(NSInteger, PBCrossDemoSection) {
    PBCrossDemoSectionOverview = 0,
    PBCrossDemoSectionAttributes,
    PBCrossDemoSectionActions,
    PBCrossDemoSectionAdRequest,
    PBCrossDemoSectionCount,
};

@interface PBCrossAppUniqueDeviceIdentifierController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, nullable) PBCrossIdentity *identity;
@property (nonatomic, copy, nullable) NSError *lastError;
@property (nonatomic, copy) NSString *lastAction;
@property (nonatomic, assign) BOOL busy;
@property (nonatomic, copy) NSArray<PBCrossAttributeKey> *attributeKeys;
@property (nonatomic, copy) NSArray<NSString *> *actionTitles;
@property (nonatomic, copy) NSArray<NSString *> *actionDetails;
@property (nonatomic, copy) NSArray<PBCrossAttributeKey> *currentVersionFields;
@property (nonatomic, copy) NSArray<PBCrossAttributeKey> *compatibilityVersionFields;

@end

@implementation PBCrossAppUniqueDeviceIdentifierController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // “我的”首页隐藏了导航栏，进入 Demo 时恢复，返回时由 TestOC 的导航逻辑恢复。
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"跨 App 设备标识";
    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    self.lastAction = @"准备加载身份…";
    // 这里只是 Demo 的“展示清单”：决定页面上显示哪些字段，并标注它们是否参与当前/兼容版本指纹。
    // 真正的指纹字段由 SDK 的 PBCrossIdentifierVersion 决定，不由此数组决定。
    self.attributeKeys = @[
        PBCrossAttributeKeyMachine,
        PBCrossAttributeKeyModel,
        PBCrossAttributeKeyDeviceName,
        PBCrossAttributeKeySystemVersion,
        PBCrossAttributeKeyBootTimeInSec,
        PBCrossAttributeKeyDeviceInitTime,
        PBCrossAttributeKeySysFileTime,
        PBCrossAttributeKeyMntID,
        PBCrossAttributeKeyDisk,
        PBCrossAttributeKeyMemory,
        PBCrossAttributeKeyScreenResolution,
        PBCrossAttributeKeyProcessorCount,
        PBCrossAttributeKeyIDFV,
        PBCrossAttributeKeyIDFAMD5,
        PBCrossAttributeKeyCarrierInfo,
        PBCrossAttributeKeyCarrierMCC,
        PBCrossAttributeKeyCarrierMNC,
        PBCrossAttributeKeyTimeZone,
        PBCrossAttributeKeyCountryCode,
        PBCrossAttributeKeyLanguage,
    ];
    self.actionTitles = @[
        @"重新加载身份",
        @"强制刷新（重新采集）",
        @"复制身份 JSON",
        @"复制广告 Device JSON",
        @"复制 Device.ext",
        @"验证跨公司匹配",
        @"清除本地身份",
    ];
    self.actionDetails = @[
        @"优先使用 SDK 内存缓存",
        @"忽略缓存，重新采集设备属性",
        @"identity.dictionaryRepresentation",
        @"拼多多 Bid Request 的 Device 对象",
        @"Device.ext（pb_cross_app 身份快照）",
        @"把 ext 还原为身份并运行 PBCrossIdentityMatcher",
        @"删除共享 ID、远端缓存与请求计数",
    ];
    self.currentVersionFields = [[PBCrossIdentifierVersion defaultVersion] attributeKeys];
    self.compatibilityVersionFields = [[PBCrossIdentifierVersion compatibilityVersion] attributeKeys];

    [self configureSDK];
    [self setupTableView];
    [self setupNavigationItem];
    [self registerNotifications];
    [self loadIdentityForce:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - SDK

- (BOOL)configureSDK {
    NSError *error = nil;
    BOOL configured = [[PBCrossAppUniqueDeviceIdentifierManager sharedManager]
                       configureWithBlock:^(PBCrossConfiguration *configuration) {
        // Demo 使用固定 salt；跨公司接入时，双方必须使用完全相同的 salt。
        configuration.salt = PBCrossDemoSalt;
        configuration.loggingEnabled = NO;
        configuration.allowsAdvertisingIdentifier = NO; // Demo 不请求 ATT
        configuration.emitsLegacyCAIDFields = YES;      // 展示 caid/caid_info 兼容字段
        configuration.remoteConfiguration.enabled = NO; // 默认纯本地
    } error:&error];

    if (!configured) {
        self.lastError = error;
        self.lastAction = [NSString stringWithFormat:@"SDK 配置失败：%@", error.localizedDescription];
    }
    return configured;
}

- (void)loadIdentityForce:(BOOL)force {
    if (self.busy) {
        return;
    }

    self.busy = YES;
    self.lastError = nil;
    self.lastAction = force ? @"正在重新采集设备属性…" : @"正在加载身份…";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.tableView reloadData];

    __weak typeof(self) weakSelf = self;
    PBCrossIdentityCompletion completion = ^(PBCrossIdentity *identity, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.busy = NO;
        strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
        if (identity) {
            strongSelf.identity = identity;
        }
        strongSelf.lastError = error;
        if (error) {
            strongSelf.lastAction = [NSString stringWithFormat:@"加载失败：%@", error.localizedDescription];
        } else {
            strongSelf.lastAction = force ? @"已重新采集设备属性" : @"身份加载完成";
        }
        [strongSelf.tableView reloadData];
    };

    PBCrossAppUniqueDeviceIdentifierManager *manager =
        [PBCrossAppUniqueDeviceIdentifierManager sharedManager];
    if (force) {
        [manager refreshIdentityWithCompletion:completion];
    } else {
        [manager loadIdentityWithCompletion:completion];
    }
}

- (void)identityDidUpdate:(NSNotification *)notification {
    id identity = notification.userInfo[PBCrossAppUniqueDeviceIdentifierIdentityUserInfoKey];
    if (![identity isKindOfClass:[PBCrossIdentity class]]) {
        return;
    }
    self.identity = identity;
    self.lastError = nil;
    self.lastAction = @"收到身份更新通知（例如远端 ID 返回）";
    [self.tableView reloadData];
}

- (void)applicationDidBecomeActive {
    if (!self.busy) {
        [self loadIdentityForce:NO];
    }
}

#pragma mark - UI

- (void)setupNavigationItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
        style:UIBarButtonItemStylePlain target:self action:@selector(forceRefresh)];
}

- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 100;
    tableView.estimatedSectionHeaderHeight = 40;
    tableView.estimatedSectionFooterHeight = 60;
    tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    tableView.sectionFooterHeight = UITableViewAutomaticDimension;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    [NSLayoutConstraint activateConstraints:@[
        [tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];
    self.tableView = tableView;
}

- (void)registerNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(identityDidUpdate:)
                   name:PBCrossAppUniqueDeviceIdentifierDidUpdateNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(applicationDidBecomeActive)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(applicationDidBecomeActive)
                   name:UIApplicationProtectedDataDidBecomeAvailable
                 object:nil];
}

#pragma mark - Helpers

- (nullable PBCrossAdRequestAdapter *)makeAdapter {
    if (!self.identity) {
        return nil;
    }
    PBCrossAdRequestContext *context = [[PBCrossAdRequestContext alloc] init];
    // 仅用于 Demo 展示；正式环境由宿主提供真实 UA / IP / 网络类型。
    context.userAgent = @"TestOC/1.0 (iPhone; iOS)";
    context.ipAddress = @"127.0.0.1";
    context.connectionType = PBCrossConnectionTypeWiFi;
    PBCrossAdRequestAdapter *adapter =
        [[PBCrossAdRequestAdapter alloc] initWithIdentity:self.identity context:context];
    PBCrossConfiguration *configuration =
        [PBCrossAppUniqueDeviceIdentifierManager sharedManager].configuration;
    adapter.emitsRawAdvertisingIdentifier = configuration.emitsRawAdvertisingIdentifier;
    adapter.emitsLegacyCAIDFields = configuration.emitsLegacyCAIDFields;
    return adapter;
}

- (NSString *)JSONString:(id)object {
    if (!object) {
        return @"";
    }
    if (![NSJSONSerialization isValidJSONObject:object]) {
        return [object description] ?: @"";
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:object
                                                   options:(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys)
                                                     error:NULL];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"";
}

- (NSString *)trackingQueryString {
    PBCrossAdRequestAdapter *adapter = [self makeAdapter];
    if (!adapter) {
        return @"";
    }
    NSDictionary<NSString *, NSString *> *parameters = [adapter trackingParameters];
    NSCharacterSet *allowed = [NSCharacterSet characterSetWithCharactersInString:
                               @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"];
    NSMutableArray<NSString *> *pairs = [NSMutableArray arrayWithCapacity:parameters.count];
    for (NSString *key in [parameters.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        NSString *value = parameters[key];
        NSString *encoded = [value stringByAddingPercentEncodingWithAllowedCharacters:allowed] ?: value;
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, encoded]];
    }
    return [pairs componentsJoinedByString:@"&"];
}

- (NSString *)attributeUsageForKey:(PBCrossAttributeKey)key {
    BOOL current = [self.currentVersionFields containsObject:key];
    BOOL compatibility = [self.compatibilityVersionFields containsObject:key];
    if (current && compatibility) {
        return @"参与：当前版本 + CAID 兼容版本";
    }
    if (current) {
        return @"参与：当前版本";
    }
    if (compatibility) {
        return @"参与：CAID 兼容版本";
    }
    return @"仅上报 / 匹配，不参与默认指纹";
}

- (NSString *)previewString:(NSString *)string limit:(NSUInteger)limit {
    if (string.length <= limit) {
        return string;
    }
    return [[string substringToIndex:limit] stringByAppendingString:@"…"];
}

- (NSString *)generatedAtString {
    if (!self.identity.generatedAt) {
        return @"-";
    }
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    return [formatter stringFromDate:self.identity.generatedAt];
}

- (void)showMessage:(NSString *)message title:(NSString *)title {
    if (self.presentedViewController) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)copyText:(nullable NSString *)text title:(NSString *)title {
    if (text.length == 0) {
        [self showMessage:@"当前没有可复制的内容，请先刷新身份。" title:@"暂无数据"];
        return;
    }
    UIPasteboard.generalPasteboard.string = text;
    [self showMessage:text title:[NSString stringWithFormat:@"已复制 %@", title]];
}

#pragma mark - Actions

- (void)forceRefresh {
    [self loadIdentityForce:YES];
}

- (void)copyIdentityJSON {
    [self copyText:[self JSONString:self.identity.dictionaryRepresentation] title:@"身份 JSON"];
}

- (void)copyDeviceJSON {
    PBCrossAdRequestAdapter *adapter = [self makeAdapter];
    [self copyText:[self JSONString:adapter.deviceDictionary] title:@"Device JSON"];
}

- (void)copyDeviceExtension {
    PBCrossAdRequestAdapter *adapter = [self makeAdapter];
    [self copyText:[adapter deviceExtensionJSONString] title:@"Device.ext"];
}

- (void)verifyCrossCompanyMatch {
    if (!self.identity) {
        [self showMessage:@"请先等待身份加载完成。" title:@"暂无身份"];
        return;
    }

    PBCrossAdRequestAdapter *adapter = [self makeAdapter];
    NSString *extensionJSON = [adapter deviceExtensionJSONString];
    NSDictionary *extension = extensionJSON.length > 0
        ? [NSJSONSerialization JSONObjectWithData:[extensionJSON dataUsingEncoding:NSUTF8StringEncoding]
                                          options:0 error:NULL]
        : nil;
    PBCrossIdentity *mediaIdentity = [PBCrossIdentity identityWithAdRequestExtension:extension];
    if (!mediaIdentity) {
        [self showMessage:@"Device.ext 解析失败，请重试。" title:@"匹配失败"];
        return;
    }

    NSMutableDictionary *withoutShared = nil;
    id crossApp = extension[@"pb_cross_app"];
    if ([crossApp isKindOfClass:[NSDictionary class]]) {
        withoutShared = [crossApp mutableCopy];
        withoutShared[@"shared_id"] = @"";
    }
    PBCrossIdentity *mediaIdentityWithoutShared =
        [PBCrossIdentity identityWithAdRequestExtension:@{@"pb_cross_app": withoutShared ?: @{}}];

    PBCrossIdentityMatcher *matcher = [[PBCrossIdentityMatcher alloc] init];
    PBCrossIdentityMatchResult *sharedResult = [matcher matchIdentity:self.identity
                                                         withIdentity:mediaIdentity];
    PBCrossIdentityMatchResult *versionResult = [matcher matchIdentity:self.identity
                                                          withIdentity:mediaIdentityWithoutShared];

    NSString *message = [NSString stringWithFormat:
        @"① 同一份 ext（含共享 ID）：%@\n"
        @"   原因：%@，置信度：%.2f\n\n"
        @"② 清空 shared_id 后（仅版本指纹）：%@\n"
        @"   原因：%@，置信度：%.2f，属性相似度：%.2f\n\n"
        @"说明：归因方可先用共享 ID，再回退到当前/上一版本指纹；双方 salt、版本和采集开关必须一致。",
        sharedResult.matched ? @"命中" : @"未命中",
        PBCrossIdentityMatchReasonDescription(sharedResult.reason),
        sharedResult.confidence,
        versionResult.matched ? @"命中" : @"未命中",
        PBCrossIdentityMatchReasonDescription(versionResult.reason),
        versionResult.confidence,
        versionResult.attributeSimilarity];
    [self showMessage:message title:@"跨公司匹配结果"];
}

- (void)confirmClearIdentity {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清除本地身份"
        message:@"将删除共享 ID、服务端下发 ID、当前服务的远端缓存与请求计数；下次加载会生成新的 UUID。\n同 Keychain Access Group / App Group 的其他 App 也会受影响。"
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"确认清除" style:UIAlertActionStyleDestructive
                                            handler:^(__unused UIAlertAction *action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [[PBCrossAppUniqueDeviceIdentifierManager sharedManager] clearStoredIdentity];
        strongSelf.identity = nil;
        strongSelf.lastError = nil;
        strongSelf.lastAction = @"身份已清除，正在重新生成…";
        [strongSelf loadIdentityForce:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return PBCrossDemoSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ((PBCrossDemoSection)section) {
        case PBCrossDemoSectionOverview:
            return 4;
        case PBCrossDemoSectionAttributes:
            return self.attributeKeys.count;
        case PBCrossDemoSectionActions:
            return self.actionTitles.count;
        case PBCrossDemoSectionAdRequest:
            return 2;
        case PBCrossDemoSectionCount:
            return 0;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch ((PBCrossDemoSection)section) {
        case PBCrossDemoSectionOverview:
            return @"身份概览（tap 复制）";
        case PBCrossDemoSectionAttributes:
            return @"设备属性（tap 复制）";
        case PBCrossDemoSectionActions:
            return @"验证操作";
        case PBCrossDemoSectionAdRequest:
            return @"广告请求示例（tap 复制）";
        case PBCrossDemoSectionCount:
            return nil;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch ((PBCrossDemoSection)section) {
        case PBCrossDemoSectionOverview:
            return @"当前版本包含启动时间，重启后会变化；同 Team / 同配置的 App 会得到相同的指纹。Demo 使用固定 salt，正式接入必须由合作方约定同一 salt。";
        case PBCrossDemoSectionAttributes:
            return @"字段来源为 CAID API v1.15 的 14 个设备公共信息 + 屏幕、CPU、IDFV 等扩展。设备名与 IDFA 只以 MD5 形式出现；空值表示本机/沙箱不可用。";
        case PBCrossDemoSectionActions:
            return @"Demo 不发送任何网络请求，也不主动请求 ATT。所有复制内容仅保存在剪贴板。";
        case PBCrossDemoSectionAdRequest:
            return @"把 ext.pb_cross_app 原样交给广告主，广告主用同一算法/salt 还原身份后即可匹配；trackingParameters 可追加到点击/曝光监测 URL。";
        case PBCrossDemoSectionCount:
            return nil;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"PBCrossDemoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont fontWithName:@"Menlo" size:12] ?: [UIFont systemFontOfSize:12];
        cell.detailTextLabel.numberOfLines = 0;
    }

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.text = nil;

    PBCrossDemoSection section = (PBCrossDemoSection)indexPath.section;
    if (section == PBCrossDemoSectionActions) {
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    } else {
        cell.detailTextLabel.font = [UIFont fontWithName:@"Menlo" size:12] ?: [UIFont systemFontOfSize:12];
    }
    if (section == PBCrossDemoSectionOverview) {
        [self configureOverviewCell:cell atRow:indexPath.row];
    } else if (section == PBCrossDemoSectionAttributes) {
        [self configureAttributeCell:cell atRow:indexPath.row];
    } else if (section == PBCrossDemoSectionActions) {
        [self configureActionCell:cell atRow:indexPath.row];
    } else if (section == PBCrossDemoSectionAdRequest) {
        [self configureAdRequestCell:cell atRow:indexPath.row];
    }

    cell.accessibilityIdentifier = [NSString stringWithFormat:@"pbCrossDemo.%ld.%ld",
                                    (long)indexPath.section, (long)indexPath.row];
    return cell;
}

- (void)configureOverviewCell:(UITableViewCell *)cell atRow:(NSInteger)row {
    NSString *value = nil;
    NSString *version = nil;
    NSString *title = nil;
    NSString *suffix = nil;

    if (row == 0) {
        title = @"当前版本指纹";
        value = self.identity.currentIdentifier;
        version = self.identity.currentVersion;
        suffix = @"当前算法版本；单次开机内稳定";
    } else if (row == 1) {
        title = @"上一版本指纹";
        value = self.identity.previousIdentifier;
        version = self.identity.previousVersion;
        suffix = @"用于兼容旧版本/旧合作方，归因时任一命中即可";
    } else if (row == 2) {
        title = @"共享自建 ID";
        value = self.identity.sharedID;
        suffix = @"Keychain / App Group 可跨同 Team App 共享";
    } else {
        title = self.busy ? @"加载中…" : @"状态";
        NSMutableArray<NSString *> *lines = [NSMutableArray array];
        [lines addObject:self.lastAction ?: @"就绪"];
        if (self.identity) {
            [lines addObject:[NSString stringWithFormat:@"来源：%@", PBCrossIdentitySourceDescription(self.identity.sources)]];
            [lines addObject:[NSString stringWithFormat:@"算法：%@，生成时间：%@", self.identity.algorithm, [self generatedAtString]]];
        }
        if (self.lastError) {
            [lines addObject:[NSString stringWithFormat:@"错误：%@", self.lastError.localizedDescription]];
        }
        cell.textLabel.text = title;
        cell.detailTextLabel.text = [lines componentsJoinedByString:@"\n"];
        cell.detailTextLabel.textColor = self.lastError ? [UIColor redColor] : [UIColor darkGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return;
    }

    cell.textLabel.text = title;
    if (value.length == 0) {
        cell.detailTextLabel.text = @"暂不可用（等待加载或本机采集失败）";
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return;
    }

    NSMutableString *detail = [NSMutableString stringWithFormat:@"%@", value];
    if (version.length > 0) {
        [detail appendFormat:@"\n版本 %@", version];
    }
    if (suffix.length > 0) {
        [detail appendFormat:@"\n%@", suffix];
    }
    cell.detailTextLabel.text = detail;
}

- (void)configureAttributeCell:(UITableViewCell *)cell atRow:(NSInteger)row {
    PBCrossAttributeKey key = self.attributeKeys[row];
    NSString *value = [self.identity.attributes valueForKey:key];
    cell.textLabel.text = key;
    NSString *usage = [self attributeUsageForKey:key];
    if (value.length == 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"不可用\n%@", usage];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", value, usage];
    }
}

- (void)configureActionCell:(UITableViewCell *)cell atRow:(NSInteger)row {
    cell.textLabel.text = self.actionTitles[row];
    cell.detailTextLabel.text = self.actionDetails[row];
    BOOL destructive = (row == (NSInteger)self.actionTitles.count - 1);
    cell.textLabel.textColor = destructive
        ? [UIColor colorWithRed:0.75 green:0.2 blue:0.15 alpha:1.0]
        : [UIColor colorWithRed:0.1 green:0.35 blue:0.75 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    if (self.busy) {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)configureAdRequestCell:(UITableViewCell *)cell atRow:(NSInteger)row {
    if (!self.identity) {
        cell.textLabel.text = row == 0 ? @"Device.ext 预览" : @"trackingParameters";
        cell.detailTextLabel.text = @"身份尚未加载";
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return;
    }

    PBCrossAdRequestAdapter *adapter = [self makeAdapter];
    if (row == 0) {
        cell.textLabel.text = @"Device.ext 预览";
        NSString *JSON = [adapter deviceExtensionJSONString];
        cell.detailTextLabel.text = [self previewString:JSON limit:600] ?: @"不可用";
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    } else {
        cell.textLabel.text = @"trackingParameters";
        cell.detailTextLabel.text = [self previewString:[self trackingQueryString] limit:600];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.busy) {
        return;
    }

    PBCrossDemoSection section = (PBCrossDemoSection)indexPath.section;
    if (section == PBCrossDemoSectionOverview) {
        NSString *value = nil;
        if (indexPath.row == 0) {
            value = self.identity.currentIdentifier;
        } else if (indexPath.row == 1) {
            value = self.identity.previousIdentifier;
        } else if (indexPath.row == 2) {
            value = self.identity.sharedID;
        } else {
            return;
        }
        [self copyText:value title:@"身份 ID"];
        return;
    }

    if (section == PBCrossDemoSectionAttributes) {
        PBCrossAttributeKey key = self.attributeKeys[indexPath.row];
        [self copyText:[self.identity.attributes valueForKey:key] title:key];
        return;
    }

    if (section == PBCrossDemoSectionActions) {
        switch (indexPath.row) {
            case 0:
                [self loadIdentityForce:NO];
                break;
            case 1:
                [self loadIdentityForce:YES];
                break;
            case 2:
                [self copyIdentityJSON];
                break;
            case 3:
                [self copyDeviceJSON];
                break;
            case 4:
                [self copyDeviceExtension];
                break;
            case 5:
                [self verifyCrossCompanyMatch];
                break;
            case 6:
                [self confirmClearIdentity];
                break;
            default:
                break;
        }
        return;
    }

    if (section == PBCrossDemoSectionAdRequest) {
        PBCrossAdRequestAdapter *adapter = [self makeAdapter];
        if (indexPath.row == 0) {
            [self copyText:[adapter deviceExtensionJSONString] title:@"Device.ext"];
        } else {
            [self copyText:[self trackingQueryString] title:@"trackingParameters"];
        }
    }
}

@end
