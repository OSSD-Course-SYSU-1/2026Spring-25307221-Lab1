/*
 * Copyright (C) 2024  即时通讯网(52im.net) & Jack Jiang.
 * The MobileIMSDK-鸿蒙Next客户端 Project. All rights reserved.
 *
 * 联系邮件：jack.jiang@52im.net
 * 联系微信：hellojackjiang
 * 联系QQ： 413980957
 * 技术社区：http://www.52im.net
 */

import { AbilityConstant, common, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import IMClientManager from '../IMClientManager';
import { ClientCoreSDK } from "mobileimsdk";

const TAG: string = '[EntryAbility] '

/**
 * 入口Ability — 支持二次流转（跨设备迁移）。
 */
export default class EntryAbility extends UIAbility {
  private currentPage: string = 'pages/SplashPage';

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    ClientCoreSDK.Log.debug(TAG+ 'Ability onCreate');
    IMClientManager.getInstance().initMobileIMSDK(this.context.getApplicationContext(), this.context.eventHub);

    // 从流转恢复
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      ClientCoreSDK.Log.info(TAG+ '从其他设备流转恢复');
      let savedPage = want.parameters?.['currentPage'] as string;
      if (savedPage) {
        this.currentPage = savedPage;
      }
    }
  }

  onDestroy(): void {
    ClientCoreSDK.Log.debug(TAG+ 'Ability onDestroy');
    IMClientManager.getInstance().releaseMobileIMSDK();
  }

  /**
   * 二次流转：设备A → 设备B，保存当前状态。
   */
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    ClientCoreSDK.Log.info(TAG+ 'onContinue — 保存状态迁移到新设备');
    wantParam['currentPage'] = this.currentPage;
    wantParam['timestamp'] = Date.now().toString();
    return AbilityConstant.OnContinueResult.AGREE;
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    ClientCoreSDK.Log.debug(TAG+ 'onNewWant');
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      let savedPage = want.parameters?.['currentPage'] as string;
      if (savedPage) {
        this.currentPage = savedPage;
      }
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    ClientCoreSDK.Log.debug(TAG+ 'Ability onWindowStageCreate');
    AppStorage.setOrCreate<window.WindowStage>('windowStage', windowStage);
    AppStorage.setOrCreate<window.Window>('window', windowStage.getMainWindowSync());
    AppStorage.setOrCreate<common.UIAbilityContext>('uiAbilityContext', this.context);

    windowStage.loadContent(this.currentPage, (err) => {
      if (err.code) {
        ClientCoreSDK.Log.error(TAG+ 'Failed to load content: '+ (JSON.stringify(err) ?? ''));
        return;
      }
      ClientCoreSDK.Log.debug(TAG+ 'Succeeded in loading content.');
    });
  }

  onWindowStageDestroy(): void {
    ClientCoreSDK.Log.debug(TAG+ 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    ClientCoreSDK.Log.debug(TAG+ 'Ability onForeground');
  }

  onBackground(): void {
    ClientCoreSDK.Log.debug(TAG+ 'Ability onBackground');
  }
}
