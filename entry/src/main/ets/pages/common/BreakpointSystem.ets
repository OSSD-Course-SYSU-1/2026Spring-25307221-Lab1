/**
 * 响应式断点系统 — 支持手机/平板/2in1 三种设备形态。
 *
 * 断点值遵循 HarmonyOS 官方设计指南：
 *   SM (phone): 320vp ~ 600vp
 *   MD (tablet): 600vp ~ 840vp
 *   LG (2in1/PC): > 840vp
 */

export enum BreakpointType {
  SM = 'sm',
  MD = 'md',
  LG = 'lg'
}

/**
 * 根据窗口宽度返回当前断点类型。
 * @param width 窗口宽度（vp）
 */
export function getBreakpoint(width: number): BreakpointType {
  if (width < 600) {
    return BreakpointType.SM;
  } else if (width < 840) {
    return BreakpointType.MD;
  }
  return BreakpointType.LG;
}

/**
 * 判断是否为平板及以上设备。
 */
export function isTabletOrLarger(breakpoint: BreakpointType): boolean {
  return breakpoint === BreakpointType.MD || breakpoint === BreakpointType.LG;
}

/**
 * 根据断点返回合适的数值。
 * @param smPhone 手机值
 * @param mdTablet 平板值
 * @param lg2in1 2in1/PC 值（可选，默认同平板）
 */
export function responsiveValue<T>(breakpoint: BreakpointType, smPhone: T, mdTablet: T, lg2in1?: T): T {
  switch (breakpoint) {
    case BreakpointType.SM:
      return smPhone;
    case BreakpointType.MD:
      return mdTablet;
    case BreakpointType.LG:
      return lg2in1 !== undefined ? lg2in1 : mdTablet;
  }
}
