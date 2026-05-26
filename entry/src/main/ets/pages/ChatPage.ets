/*
 * Copyright (C) 2024  即时通讯网(52im.net) & Jack Jiang.
 * The MobileIMSDK-鸿蒙Next客户端 Project. All rights reserved.
 *
 * 联系邮件：jack.jiang@52im.net
 * 联系微信：hellojackjiang
 * 联系QQ： 413980957
 * 技术社区：http://www.52im.net
 */

import {ErrorCode, ClientCoreSDK, PKickoutInfo} from 'mobileimsdk/Index'
import { ChatInputView } from './components/ChatInputView';
import { CustomeTitleBar } from './components/ChatTitleBar'
import { MsgView_normal } from './components/msg_view/NormalMsgView';
import { MsgView_system } from './components/msg_view/SystemMsgView';
import Message from './model/Message';
import MsgType from './constants/MsgType';
import MessagesDataSource from './model/MessagesDataSource';
import IMClientManager from '../IMClientManager';
import UIEvent from './constants/UIEvent';
import {router } from '@kit.ArkUI';
import ToolKits from './utils/ToolKits';
import { common } from '@kit.AbilityKit';
import { MsgTimeView } from './components/msg_view/MsgTimeView';

const TAG: string = '[ChatPage] '

/**
 * 主界面（聊天单页）。
 *
 * @author Jack Jiang(http://www.52im.net/thread-2792-1-1.html)
 */
@Entry
@Component
struct ChatPage {
  /** 聊天列表的滚动条组件 */
  private scroller: Scroller = new Scroller();

  /** 连接状态：false 连接断开、true 连接正常 */
  @State connectStatus: boolean = ClientCoreSDK.getInstance().connectedToServer;
  /** 心跳状态：true表示刚刚已发送心跳包，本心跳状态仅仅是为了在ui界面上实现心跳呼吸灯效果 */
  @State keepAliveStatus: boolean = false;

  /** 聊天消息列表对应的数据源对象（本对象与MessageProvider配合，用于实现UI界面与数据组的解偶）*/
  messagesDataSource: MessagesDataSource = new MessagesDataSource();

  /** 事件回调：增加了聊天消息 */
  meessageAddedEventCallback?: Function;
  /** 事件回调：更新了聊天消息（单条聊天消息） */
  meessageUpdateEventCallback?: Function;
  /** 事件回调：更新了聊天消息（多条聊天消息） */
  meessagesUpdateEventCallback?: Function;
  /** 事件回调：掉线重连完成 */
  loginCompleteEventCallback?: Function;
  /** 事件回调：掉线了 */
  disconnectedEventCallback?: Function;
  /** 事件回调：心跳了一次 */
  keepAliveEventCallback?: Function;
  /** 事件回调：你被踢了 */
  kickoutEventCallback?: Function;

  @State showSearch: boolean = false;  // 控制搜索框显隐
  @State searchKeyword: string = '';   // 搜索关键词
  @State contactId: string = '';
  @State contactName: string = '';
  @State simulatedMessages: Message[] = [];
  @State inputText: string = '';  // 输入框文本

  /**
   * 生命周期中只被调用一次，类似于iOS中的viewDidLoad、Android中的onCreate.
   */
  aboutToAppear() {
    // 添加事件监听
    this.addEvents();
    
    let params = router.getParams() as Record<string, Object>;
    if (params) {
      this.contactId = (params['contactId'] as string) || '';
      this.contactName = (params['contactName'] as string) || '';
      if (this.contactId) {
        this.loadSimulatedMessages();
      }
    }
  }

  loadSimulatedMessages() {
    // 获取当前登录用户ID
    let localUid = ToolKits.getLocalUserUid() || 'me';
    
    // 创建模拟消息，设置不同的时间戳
    let now = Date.now();
    let msg1 = new Message(this.contactId, this.contactName, now - 180000, `你好，我是${this.contactName}`, MsgType.TYPE_TEXT);
    msg1.showTopTime = true;  // 第一条消息总是显示时间
    
    let msg2 = new Message(localUid, '我', now - 60000, '今天天气真不错', MsgType.TYPE_TEXT);
    // 与上一条消息间隔 120000ms (2分钟)，不超过2分钟，不显示时间
    msg2.showTopTime = false;
    
    let msg3 = new Message(this.contactId, this.contactName, now, '是啊，下午出去走走吧', MsgType.TYPE_TEXT);
    // 与上一条消息间隔 60000ms (1分钟)，不超过2分钟，不显示时间
    msg3.showTopTime = false;
    
    this.simulatedMessages = [msg1, msg2, msg3];
  }

  /**
   * 界面被销毁时被调用。
   */
  aboutToDisappear() {
    // 取消事件通知
    this.removeEvents();
  }

  /**
   * 界面显示时被调用。
   */
  onPageShow(): void {
    // 本界面显示时，将输入法软键盘避让模式设置为KeyboardAvoidMode.RESIZE（即压缩窗体，而不是将窗体整体上移）
    ToolKits.setKeyboardAvoidModeToRESIZE(this.getUIContext(), true);
    // 设置全面屏状态栏颜色
    ToolKits.setStatusBarColor(getContext(this), ToolKits.chat_page_title_color, ToolKits.chat_page_title_background_color);
  }

  /**
   * 界面隐藏时被调用。
   */
  onPageHide(): void {
    // 本界面不显示时，将输入法软键盘避让模式还原为系统默认的KeyboardAvoidMode.OFFSET
    ToolKits.setKeyboardAvoidModeToRESIZE(this.getUIContext(), false);
  }

  /**
   * 添加事件监听。
   */
  addEvents() {
    // 【1】增加了聊天消息
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_messageAdded, this.meessageAddedEventCallback = (index: number) => {
      // 通知ListView的数据源，刷新消息显示
      this.messagesDataSource.notifyDataAdd(index);
      // 滚动消息列表至底部（以备显示最新消息）
      this.scrollToBottom();
    });

    // 【2】更新了聊天消息（单条聊天消息）
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_messageUpdate, this.meessageUpdateEventCallback = (index: number) => {
      // 通知ListView的数据源，刷新消息显示
      this.messagesDataSource.notifyDataChange(index);
    });

    // 【3】更新了聊天消息（多条聊天消息）
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_messagesUpdate, this.meessagesUpdateEventCallback = (updateIndexes: number[]) => {
      // 通知ListView的数据源，刷新消息显示（多条消息就直接reload，这样简单直接）
      this.messagesDataSource.notifyDataReload();
    });

    // 【4】掉线重连完成
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_onIMAfterLoginComplete, this.loginCompleteEventCallback = (code: number) => {
      // 登陆或重连成功
      if(code == ErrorCode.COMMON_CODE_OK) {
        this.refreshConnecteStatus();
      }
    });

    // 【5】掉线了
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_onIMDisconnected, this.disconnectedEventCallback = () => {
      this.refreshConnecteStatus();
    });

    // 【6】心跳了一次
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_onIMPing, this.keepAliveEventCallback = () => {
      this.keepAliveStatus = true;
      setTimeout(() => {
        this.keepAliveStatus = false;
      }, 500);
    });

    // 【7】你被踢了
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_onKickout, this.kickoutEventCallback = (kickoutInfo: PKickoutInfo) => {
      this.beKickout(kickoutInfo);
    });
  }

  /**
   * 取消事件监听。
   */
  removeEvents() {
    // 【1】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_messageAdded, this.meessageAddedEventCallback);
    // 【2】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_messageUpdate, this.meessageUpdateEventCallback);
    // 【3】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_messagesUpdate, this.meessagesUpdateEventCallback);
    // 【4】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_onIMAfterLoginComplete, this.loginCompleteEventCallback);
    // 【5】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_onIMDisconnected, this.disconnectedEventCallback);
    // 【6】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_onIMPing, this.keepAliveEventCallback);
    // 【7】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_onKickout, this.kickoutEventCallback);
  }

  /**
   * 滚动消息列表到最底部，以备显示最新消息。
   */
  scrollToBottom() {
    this.scroller.scrollEdge(Edge.Bottom);
  }

  /**
   * 刷新连接状态。
   */
  refreshConnecteStatus() {
    this.connectStatus = ClientCoreSDK.getInstance().connectedToServer;
  }

  /**
   * 被踢的处理逻辑。
   */
  beKickout(kickoutInfo: PKickoutInfo) {
    // 首先释放IM所占资源
    IMClientManager.getInstance().releaseMobileIMSDK();

    // 提示信息
    let alertContent: string = '';
    if (kickoutInfo.code === PKickoutInfo.KICKOUT_FOR_DUPLICATE_LOGIN) {
      alertContent = '账号已在其它地方登陆，当前会话已断开，请退出后重新登陆！';
    } else if (kickoutInfo.code === PKickoutInfo.KICKOUT_FOR_ADMIN) {
      alertContent = '已被管理员强行踢出聊天，当前会话已断开！';
    } else {
      alertContent = '你已被踢出聊天，当前会话已断开（kickoutInfo=' + JSON.stringify(kickoutInfo) + '）！';
    }

    ClientCoreSDK.Log.error(TAG + alertContent);

    // 确认Action
    let primaryAction: Callback<void> = () => {
      this.switchToLoginPage();
    };

    // 取消Action
    let secondaryAction: Callback<void> = () => {
      let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      ToolKits.exitSystem(context);
    };

    // 显示对话框
    ToolKits.showAlertDialog(alertContent, '重新登录', undefined, primaryAction,'退出应用', $r('sys.color.ohos_id_color_badge_red'), secondaryAction);
  }

  /**
   * 切换到登陆界面。
   */
  switchToLoginPage() {
    // init MobileIMSDK first（必须保证此代码被调用，否则IM框架无法完成IM服务器的连接等工作）
    IMClientManager.getInstance().initMobileIMSDK(getContext(this).getApplicationContext(), getContext(this).eventHub);
    // goto login page!
    router.replaceUrl({ url: 'pages/LoginPage', });
  }

  build() {
    Column() {
      // 聊天界面自定义标题栏
      CustomeTitleBar({ connectStatus: this.connectStatus, keepAliveStatus: this.keepAliveStatus })
      // 标题栏 Row，比如：
      Row() {
        Text('聊天').fontSize(20).fontWeight(FontWeight.Bold)
        Blank()  // 把搜索按钮推到右侧
        Button({ type: ButtonType.Circle }) {
          // 如果没有图标，直接用文字
          Text('🔍').fontSize(24)
        }
        .width(40).height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.showSearch = !this.showSearch;
          this.searchKeyword = '';
        })
      }
      .width('100%').padding(10)
      if (this.showSearch) {
        TextInput({ placeholder: '搜索聊天记录...', text: this.searchKeyword })
          .width('90%')
          .margin(10)
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
      }
      // 聊天界面内容区
      Column() {
        // List性能需极致优化的情况下，还可使用"组件复用"技术，详见官方资料：
        // https://developer.huawei.com/consumer/cn/doc/best-practices-V5/bpta-best-practices-long-list-V5#section36781044162218
        if (this.contactId) {
          // 从联系人跳转来的，使用模拟消息（可在此也加入搜索过滤，但为了清晰暂不加）
          List({ scroller: this.scroller,space: 8 }) {
            ForEach(this.simulatedMessages, (m: Message, index: number) => {
              ListItem() {
                Column() {
                  MsgTimeView({ message: m })
                  if (m.msgType === MsgType.TYPE_TEXT) {
                    MsgView_normal({ message: m })
                  } // 其他类型酌情保留
                }
              }
            }, (m: Message, index: number) => index.toString())
          }
          .layoutWeight(1)
          // 监听组件触屏事件，确保触碰聊天列表时，能自动收起输入法软键盘，提升用户体验
          .onTouch((event: TouchEvent) => {
            // 收起软键盘
            ToolKits.hideSoftInputMethod(this.getUIContext());
          })
          // 监听组件大小变化事件（用于实现当软键盘显示时，列表高度被压缩后，消息不能自动显示最后一条的问题）
          .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
            let oldHeight = oldValue.height, newHeight = newValue.height;
            oldHeight = (oldHeight === undefined ? 0 : oldHeight);
            newHeight = (newHeight === undefined ? 0 : newHeight);
            // 列表高度变小，可以认为是软键盘显示了
            let toBeSmall = (newHeight > 0 && newHeight < oldHeight);
            if (toBeSmall) {
              // 消息列表滚动到底部，确保最新一条消息被显示
              this.scrollToBottom();
            }
          })
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .width("100%")
          .height('100%')
          .layoutWeight(1)
          .listDirection(Axis.Vertical)
        } else {
          // 原有逻辑（包含搜索功能）
          List({ scroller: this.scroller }) {
            LazyForEach(this.messagesDataSource, (m: Message, index: number) => {
              if (this.searchKeyword.length > 0 && !m.content.toLowerCase().includes(this.searchKeyword.toLowerCase())) {
                ListItem() {}.visibility(Visibility.None).height(0)
              } else {
                ListItem() {
                  Column() {
                    MsgTimeView({ message: m })
                    if (m.msgType === MsgType.TYPE_TEXT) {
                      MsgView_normal({ message: m })
                    } else {
                      MsgView_system({ message: m })
                    }
                  }
                  // 高亮：匹配关键词的消息添加淡黄色背景
                  .backgroundColor(
                    this.searchKeyword.length > 0 && m.content.toLowerCase().includes(this.searchKeyword.toLowerCase())
                      ? '#FFF3CD' : Color.Transparent
                  )
                }
              }
            }, (m: Message, index: number) => MessagesDataSource.messageItemKey(m))
          }
          // 监听组件触屏事件，确保触碰聊天列表时，能自动收起输入法软键盘，提升用户体验
          .onTouch((event: TouchEvent) => {
            // 收起软键盘
            ToolKits.hideSoftInputMethod(this.getUIContext());
          })
          // 监听组件大小变化事件（用于实现当软键盘显示时，列表高度被压缩后，消息不能自动显示最后一条的问题）
          .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
            let oldHeight = oldValue.height, newHeight = newValue.height;
            oldHeight = (oldHeight === undefined ? 0 : oldHeight);
            newHeight = (newHeight === undefined ? 0 : newHeight);
            // 列表高度变小，可以认为是软键盘显示了
            let toBeSmall = (newHeight > 0 && newHeight < oldHeight);
            if (toBeSmall) {
              // 消息列表滚动到底部，确保最新一条消息被显示
              this.scrollToBottom();
            }
          })
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .width("100%")
          .height('100%')
          .layoutWeight(1)
          .listDirection(Axis.Vertical)
        }
      }
      .backgroundColor("#f0f2f6")
      .layoutWeight(1)

      // 底部消息输入区
      ChatInputView()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    // 适配流海屏（顶部状态栏透明并穿过，并透过底部上划操作区）
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
