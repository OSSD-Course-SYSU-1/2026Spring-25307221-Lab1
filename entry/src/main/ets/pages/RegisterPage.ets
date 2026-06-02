/*
 * Copyright (C) 2024  即时通讯网(52im.net) & Jack Jiang.
 * The MobileIMSDK-鸿蒙Next客户端 Project. All rights reserved.
 *
 * 联系邮件：jack.jiang@52im.net
 * 联系微信：hellojackjiang
 * 联系QQ： 413980957
 * 技术社区：http://www.52im.net
 */

import { router } from '@kit.ArkUI';
import ToolKits from './utils/ToolKits';
import IMClientManager from '../IMClientManager';
import UIEvent from './constants/UIEvent';
import { LocalDataSender, PLoginInfo, ErrorCode } from 'mobileimsdk/Index';

const TAG: string = '[RegisterPage] ';

/**
 * 注册界面。
 */
@Entry({ routeName: 'RegisterPage' })
@Component
struct RegisterPage {

  /** 注册超时时间定义（单位：毫秒）*/
  readonly RETRY_DELAY: number = 6000;

  /** 密码输入框是否处于焦点状态 */
  @State passwordFocused: boolean = false;

  /** 手机号 */
  @State phoneNumber: string = '';
  /** 密码 */
  @State password: string = '';
  /** 确认密码 */
  @State confirmPassword: string = '';

  /** 是否正在注册中（true表示是，否则不是） */
  @State @Watch('watchRegisteringStatus') isRegistering: boolean = false;

  /** 保存注册超时定时器id */
  private registeringTimerId: number = -1;

  /** 注册成功后的回调 */
  private onRegisterSucessObserver: Function = (code: number) => {};

  /**
   * 生命周期中只被调用一次
   */
  aboutToAppear() {
    this.onRegisterSucessObserver = (code: number) => {
      // 已收到服务端反馈则取消显示进度提示
      this.isRegistering = false;

      // 服务端返回的注册结果值：成功
      if(code == ErrorCode.COMMON_CODE_OK) {
        ToolKits.showToast('注册成功！');
        // 返回登录页面
        router.back();
      }
      // 注册失败
      else {
        // 显示提示框
        ToolKits.showAlertDialog('注册失败，错误码='+ code, '知道了', undefined, () =>{}, '', undefined, () =>{});
      }
    };
  }

  /**
   * 注册。
   */
  doRegister(): void {
    // 输入检查
    if (ToolKits.isEmpty(this.phoneNumber, true)) {
      ToolKits.showToast('手机号不能为空!');
      return;
    }

    // 手机号格式检查
    if (!this.isValidPhoneNumber(this.phoneNumber)) {
      ToolKits.showToast('请输入正确的手机号!');
      return;
    }

    if (ToolKits.isEmpty(this.password, true)) {
      ToolKits.showToast('密码不能为空!');
      return;
    }

    if (this.password.length < 6) {
      ToolKits.showToast('密码长度至少6位!');
      return;
    }

    if (this.password !== this.confirmPassword) {
      ToolKits.showToast('两次输入的密码不一致!');
      return;
    }

    // 开始注册
    this.doRegisterImpl(this.phoneNumber, this.password);
  }

  /**
   * 验证手机号格式
   */
  isValidPhoneNumber(phone: string): boolean {
    // 简单的手机号验证：11位数字，以1开头
    const phoneRegex = /^1\d{10}$/;
    return phoneRegex.test(phone);
  }

  /*
   * 真正的注册信息发送实现方法。
   */
  doRegisterImpl(registerUserId: string, registerToken: string) {
    // 立即显示注册处理进度提示等
    this.isRegistering = true;

    // 将要提交的注册信息对象（使用登录接口模拟注册）
    let loginInfo: PLoginInfo = new PLoginInfo();
    loginInfo.loginUserId = registerUserId;
    loginInfo.loginToken = registerToken;

    // 发送注册数据包（使用登录接口）
    let code: number = LocalDataSender.getInstance().sendLogin(loginInfo);
    if(code == ErrorCode.COMMON_CODE_OK) {
      ToolKits.showToast('注册请求已发出。。。');
    } else {
      ToolKits.showToast('注册请求发送失败，错误码：'+ code);
      // 注册信息没有成功发出时取消显示进度条
      this.isRegistering = false;
    }
  }

  /**
   * Watch注册状态的改变。
   */
  watchRegisteringStatus(): void {
    if(this.isRegistering) {
      // 设置好服务端反馈的注册结果观察者
      IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_onIMAfterLoginComplete, this.onRegisterSucessObserver);

      // 开启注册超时计时器
      this.startRegisterTimer();
    } else {
      // 取消设置好服务端反馈的注册结果观察者
      IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_onIMAfterLoginComplete)

      // 关闭注册超时计时器
      this.stopRegisterTimer();
    }
  }

  /**
   * 开启注册超时计时器。
   */
  startRegisterTimer() {
    // 先确保清除之前的计时器
    this.stopRegisterTimer();
    // 注册超时计时器
    this.registeringTimerId = setTimeout(() => {
      this.onRegisterTimeout();
    }, this.RETRY_DELAY);
  }

  /**
   * 关闭注册超时计时器。
   */
  stopRegisterTimer() {
    if(this.registeringTimerId != -1) {
      clearTimeout(this.registeringTimerId);
      this.registeringTimerId = -1;
    }
  }

  /**
   * 注册超时后要执行的逻辑。
   */
  onRegisterTimeout() {
    // 清除注册状态等
    this.isRegistering = false;

    // 确认Action
    let confrimAction: Callback<void> = () => {
      // 重试
      this.doRegister();
    };

    // 退出Action
    let cancelAction: Callback<void> = () => {
      // 取消注册中的状态
      this.isRegistering = false;
    };

    // 显示超时提示窗
    ToolKits.showAlertDialog('注册超时，可能是网络故障或服务器无法连接，是否重试？', '重试！', undefined, confrimAction, '取消', $r('sys.color.ohos_id_color_badge_red'), cancelAction);
  }

  build() {
    Stack() {
      GridRow({ columns: 4 }) {
        GridCol({ span: 4, offset: 0  }) {
          Column() {
            // 返回按钮和标题
            Row() {
              Image($r('app.media.app_icon'))
                .width(24)
                .height(24)
                .onClick(() => {
                  router.back();
                })

              Text('注册账号')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)

              // 占位，保持标题居中
              Row()
                .width(24)
                .height(24)
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
            .margin({ bottom: 20 })

            // 提示文字
            Text('请使用手机号注册账号')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ bottom: 30 })

            // 输入区
            Column() {
              this.TextLine({ bottom: 5 })
              Row() {
                Text('手机号')
                  .fontColor('#0e1a26')
                  .fontWeight(500)
                  .width(70)
                TextInput({ text: $$this.phoneNumber, placeholder: '请输入手机号' })
                  .inputStyle()
                  .type(InputType.Number)
                  .maxLength(11)
                  .margin({ right: 5 })
              }
              .height(52)

              this.TextLine({})

              Row() {
                Text('密码')
                  .fontColor('#0e1a26')
                  .fontWeight(500)
                  .width(70)

                TextInput({ text: $$this.password, placeholder: '请输入密码（至少6位）' })
                  .inputStyle()
                  .type(InputType.Password)
                  .margin({ right: 5 })
                  .passwordIcon({ onIconSrc: $r('app.media.login_showpass_on'), offIconSrc: $r('app.media.login_showpass_off'), })
                  .onFocus(() => {
                    this.passwordFocused = true;
                  })
                  .onBlur(() => {
                    this.passwordFocused = false;
                  })
              }
              .height(52)
              .margin({ top: 5, })

              this.TextLine({})

              Row() {
                Text('确认密码')
                  .fontColor('#0e1a26')
                  .fontWeight(500)
                  .width(70)

                TextInput({ text: $$this.confirmPassword, placeholder: '请再次输入密码' })
                  .inputStyle()
                  .type(InputType.Password)
                  .margin({ right: 5 })
                  .passwordIcon({ onIconSrc: $r('app.media.login_showpass_on'), offIconSrc: $r('app.media.login_showpass_off'), })
              }
              .height(52)
              .margin({ top: 5, })

              this.TextLine({})
            }
            .width('100%')
            .margin({ top: 20 })

            // 注册按钮
            Button({
              type: ButtonType.Normal,
              stateEffect: true
            }) {
              Row() {
                // 正在注册则显示一个进度条
                if(this.isRegistering) {
                  LoadingProgress().width(24).height(24).margin({ right: 5 }).color(0xFFFFFF)
                }

                Text(this.isRegistering  ? '正在注册 ...' : '注册')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
              }
            }
            .borderRadius(20)
            .width('100%')
            .backgroundColor('#07C160')
            .height(40)
            .margin({ top: 40 })
            .enabled(!this.isRegistering)
            .onClick(() => {
              // 收起软键盘
              ToolKits.hideSoftInputMethod(this.getUIContext());
              // 开始注册
              this.doRegister();
            })

            Blank()
          }
          .width('100%')
          .height('100%')
          .padding({ left: 12, right: 12 })
        }
      }
      .padding({ left: 16, right: 16 })
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    // 适配流海屏（顶部状态栏透明并穿过，并透过底部上划操作区）
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  TextLine(margin: Margin) {
    Line()
      .height(0.5)
      .width('100%')
      .backgroundColor('#d0d2d6')
      .padding({ left: 12, right: 12 })
      .margin(margin)
  }
}

@Extend(TextInput)
function inputStyle() {
  .width('100%')
  .height('100%')
  .layoutWeight(1)
  .fontColor('#353535')
  .placeholderColor('#a1a7af')
  .backgroundColor(Color.Transparent)
}
