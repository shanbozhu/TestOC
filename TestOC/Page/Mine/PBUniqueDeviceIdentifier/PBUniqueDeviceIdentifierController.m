#import "PBUniqueDeviceIdentifierController.h"
#import "PBDeviceIdentityManager.h"

@interface PBUniqueDeviceIdentifierController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PBDeviceIdentitySnapshot *snapshot;
@property (nonatomic, copy) NSDictionary *previousPayload;
@property (nonatomic, copy) NSString *lastAction;
@property (nonatomic, assign) BOOL busy;
@end

@implementation PBUniqueDeviceIdentifierController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // TestOC's menu hides its navigation bar; restore it for this page.
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设备标识 Demo";
    self.view.backgroundColor = UIColor.whiteColor;
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    table.translatesAutoresizingMaskIntoConstraints = NO;
    table.rowHeight = UITableViewAutomaticDimension;
    table.estimatedRowHeight = 90;
    table.dataSource = self;
    table.delegate = self;
    [self.view addSubview:table];
    [NSLayoutConstraint activateConstraints:@[
        [table.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [table.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [table.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [table.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
    self.tableView = table;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
        style:UIBarButtonItemStylePlain target:self action:@selector(refreshIdentity)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshIdentity)
        name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshIdentity)
        name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
    [self refreshIdentity];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)refreshIdentity {
    if (self.busy) { return; }
    self.busy = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    __weak typeof(self) weakSelf = self;
    [PBDeviceIdentityManager.sharedManager refreshWithCompletion:^(PBDeviceIdentitySnapshot *snapshot) {
        [weakSelf acceptSnapshot:snapshot action:@"已从存储重新读取；未主动请求 ATT"];
    }];
}

- (void)acceptSnapshot:(PBDeviceIdentitySnapshot *)snapshot action:(NSString *)action {
    self.previousPayload = self.snapshot.payload;
    self.snapshot = snapshot;
    self.lastAction = action;
    self.busy = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.tableView reloadData];
}

- (void)showMessage:(NSString *)message title:(NSString *)title {
    if (self.presentedViewController) { return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)JSONString:(id)object {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys error:&error];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : error.localizedDescription;
}

- (void)copyJSON {
    if (!self.snapshot) { return; }
    UIPasteboard.generalPasteboard.string = [self JSONString:self.snapshot.payload];
    [self showMessage:@"已复制当前 JSON 示例；Demo 没有发送网络请求。" title:@"已复制"];
}

- (void)requestATT {
    self.busy = YES;
    __weak typeof(self) weakSelf = self;
    [PBDeviceIdentityManager.sharedManager requestTrackingAuthorizationWithCompletion:^(NSError *error) {
        weakSelf.busy = NO;
        [weakSelf refreshIdentity];
        if (error) { [weakSelf showMessage:error.localizedDescription title:@"暂不能请求授权"]; }
    }];
}

- (void)confirmMutation:(BOOL)includingKeychain {
    NSString *message = includingKeychain
        ? @"将删除并重新生成本 Demo 的 app_device_id 和 installation_id。IDFV、IDFA 及其他模块的数据不变。"
        : @"仅删除并重新生成 installation_id，保留 app_device_id。这只是模拟安装文件丢失，不等于真实卸载或抹机。";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:includingKeychain ? @"重置 Demo 身份" : @"模拟重装"
        message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(__unused UIAlertAction *action) {
        weakSelf.busy = YES;
        PBDeviceIdentityMutationCompletion completion = ^(PBDeviceIdentitySnapshot *snapshot, NSError *error) {
            NSString *actionText = error ? @"操作未完全成功，请查看错误后重试"
                : includingKeychain ? @"已重置本 Demo 的两个标识" : @"已模拟重装：仅更新 installation_id";
            [weakSelf acceptSnapshot:snapshot action:actionText];
            if (error) { [weakSelf showMessage:error.localizedDescription title:@"操作未完成"]; }
        };
        if (includingKeychain) {
            [PBDeviceIdentityManager.sharedManager resetDemoIdentityWithCompletion:completion];
        } else {
            [PBDeviceIdentityManager.sharedManager simulateReinstallationWithCompletion:completion];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)checkConcurrentReads {
    self.busy = YES;
    self.lastAction = @"正在执行 50 次并发读取…";
    [self.tableView reloadData];
    dispatch_group_t group = dispatch_group_create();
    NSMutableSet *appIDs = [NSMutableSet set];
    NSMutableSet *installIDs = [NSMutableSet set];
    __block NSUInteger unavailable = 0;
    __block PBDeviceIdentitySnapshot *lastSnapshot = nil;
    for (NSUInteger index = 0; index < 50; index++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            [PBDeviceIdentityManager.sharedManager refreshWithCompletion:^(PBDeviceIdentitySnapshot *snapshot) {
                // All callbacks are delivered on the main thread.
                NSString *appID = snapshot.payload[@"app_device_id"];
                NSString *installID = snapshot.payload[@"installation_id"];
                if (appID) { [appIDs addObject:appID]; }
                if (installID) { [installIDs addObject:installID]; }
                if (!appID || !installID) { unavailable++; }
                lastSnapshot = snapshot;
                dispatch_group_leave(group);
            }];
        });
    }
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        BOOL passed = appIDs.count == 1 && installIDs.count == 1 && unavailable == 0;
        NSString *message = [NSString stringWithFormat:@"%@：50 次读取，app_device_id %lu 个、installation_id %lu 个，不可用 %lu 次。",
            passed ? @"通过" : @"未通过", (unsigned long)appIDs.count, (unsigned long)installIDs.count, (unsigned long)unavailable];
        [weakSelf acceptSnapshot:lastSnapshot action:message];
        [weakSelf showMessage:message title:@"并发稳定性验证"];
    });
}

#pragma mark - Table

- (NSArray<NSString *> *)identityKeys {
    return @[@"app_device_id", @"installation_id", @"idfv", @"att_status", @"idfa"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 4; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : section == 1 ? self.identityKeys.count : section == 2 ? 6 : 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[@"应用范围的持久身份", @"当前标识 · 点击复制", @"验证操作", @"JSON 示例 · 点击复制"][section];
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) { return @"用于同一应用的身份延续；不承诺永久识别物理设备。Keychain 在删除重装后可能保留，也可能丢失。"; }
    if (section == 1) { return @"IDFV 可能在同 vendor 全部 App 删除后变化。标识不可用时会省略，不使用型号、时间或 IP 兜底拼接。"; }
    if (section == 2) { return @"ATT 只由按钮触发；从系统设置返回后自动刷新。模拟器不能替代真机重装、锁屏和换机测试。"; }
    return @"仅展示和手动复制，无网络上传。subject_id 由业务后端分配，本 Demo 不伪造后端关联结果。";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identity"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"identity"];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.numberOfLines = 0;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = UIColor.blackColor;
    cell.detailTextLabel.textColor = UIColor.darkGrayColor;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessibilityIdentifier = [NSString stringWithFormat:@"identity.%ld.%ld", (long)indexPath.section, (long)indexPath.row];
    if (indexPath.section == 0) {
        cell.textLabel.text = self.snapshot ? [NSString stringWithFormat:@"状态：%@", self.snapshot.payload[@"identity_status"]] : @"读取中…";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@", self.lastAction ?: @"初始化持久身份",
            self.snapshot.diagnostics[@"collected_at"] ?: @"", @"持久随机 ID + 安装记录 + 系统授权标识"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == 1) {
        NSString *key = self.identityKeys[indexPath.row];
        NSString *value = self.snapshot.payload[key];
        cell.textLabel.text = key;
        NSString *detail = @[@"Keychain · 当前 App · ThisDeviceOnly", @"沙盒文件 · 排除备份", @"系统 vendor 范围标识", @"当前授权状态", @"授权且非全零时才提供"][indexPath.row];
        NSString *change = @"";
        NSString *previous = self.previousPayload[key];
        if (previous && value) { change = [previous isEqual:value] ? @" · 与上次相同" : @" · 与上次不同"; }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@\n%@", value ?: @"不可用 / 未提供", change, detail];
    } else if (indexPath.section == 2) {
        cell.textLabel.text = @[@"重新读取标识", @"验证 50 次并发读取", @"请求 ATT 授权", @"复制 JSON", @"模拟重装（仅安装 ID）", @"重置 Demo 身份"][indexPath.row];
        cell.detailTextLabel.text = nil;
        cell.textLabel.textColor = indexPath.row >= 4 ? [UIColor colorWithRed:0.75 green:0.2 blue:0.15 alpha:1] : [UIColor colorWithRed:0.1 green:0.35 blue:0.75 alpha:1];
    } else {
        cell.textLabel.text = @"当前数据";
        NSMutableDictionary *preview = [NSMutableDictionary dictionary];
        if (self.snapshot) {
            preview[@"payload"] = self.snapshot.payload;
            preview[@"local_diagnostics"] = self.snapshot.diagnostics;
        }
        cell.detailTextLabel.text = [self JSONString:preview];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.busy) { return; }
    if (indexPath.section == 1) {
        NSString *key = self.identityKeys[indexPath.row];
        NSString *value = self.snapshot.payload[key];
        if (value) {
            UIPasteboard.generalPasteboard.string = value;
            [self showMessage:key title:@"已复制"];
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0: [self refreshIdentity]; break;
            case 1: [self checkConcurrentReads]; break;
            case 2: [self requestATT]; break;
            case 3: [self copyJSON]; break;
            case 4: [self confirmMutation:NO]; break;
            case 5: [self confirmMutation:YES]; break;
        }
    } else if (indexPath.section == 3) { [self copyJSON]; }
}

@end
