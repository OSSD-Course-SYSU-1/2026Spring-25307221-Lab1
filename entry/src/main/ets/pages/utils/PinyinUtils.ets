/**
 * 拼音工具类 - 用于提取中文字符的拼音首字母
 * 
 * 使用常用汉字拼音映射表来实现
 */

export class PinyinUtils {
  // 常用汉字拼音首字母映射表
  private static pinyinMap: Map<string, string> = new Map([
    // A
    ['阿', 'A'], ['爱', 'A'], ['安', 'A'], ['艾', 'A'],
    // B
    ['白', 'B'], ['包', 'B'], ['北', 'B'], ['本', 'B'], ['边', 'B'], ['博', 'B'],
    // C
    ['陈', 'C'], ['程', 'C'], ['曹', 'C'], ['蔡', 'C'], ['常', 'C'], ['崔', 'C'], ['成', 'C'], ['楚', 'C'],
    // D
    ['大', 'D'], ['道', 'D'], ['德', 'D'], ['丁', 'D'], ['董', 'D'], ['杜', 'D'], ['戴', 'D'],
    // E
    ['恩', 'E'],
    // F
    ['方', 'F'], ['冯', 'F'], ['傅', 'F'], ['范', 'F'], ['费', 'F'], ['房', 'F'], ['福', 'F'],
    // G
    ['高', 'G'], ['葛', 'G'], ['龚', 'G'], ['顾', 'G'], ['郭', 'G'], ['谷', 'G'], ['关', 'G'], ['古', 'G'],
    // H
    ['韩', 'H'], ['何', 'H'], ['贺', 'H'], ['胡', 'H'], ['黄', 'H'], ['霍', 'H'], ['洪', 'H'], ['侯', 'H'], ['郝', 'H'],
    // J
    ['贾', 'J'], ['江', 'J'], ['姜', 'J'], ['金', 'J'], ['靳', 'J'], ['蒋', 'J'], ['焦', 'J'], ['康', 'K'],
    // K
    ['柯', 'K'], ['孔', 'K'], ['赖', 'L'],
    // L
    ['李', 'L'], ['梁', 'L'], ['林', 'L'], ['刘', 'L'], ['龙', 'L'], ['陆', 'L'], ['卢', 'L'], ['罗', 'L'], ['雷', 'L'], ['黎', 'L'], ['廖', 'L'], ['吕', 'L'],
    // M
    ['马', 'M'], ['毛', 'M'], ['孟', 'M'], ['梅', 'M'], ['莫', 'M'], ['苗', 'M'], ['穆', 'M'],
    // N
    ['南', 'N'], ['倪', 'N'], ['宁', 'N'], ['牛', 'N'], ['年', 'N'],
    // O
    ['欧', 'O'], ['欧阳', 'O'],
    // P
    ['潘', 'P'], ['庞', 'P'], ['裴', 'P'], ['彭', 'P'], ['平', 'P'], ['蒲', 'P'],
    // Q
    ['齐', 'Q'], ['钱', 'Q'], ['强', 'Q'], ['乔', 'Q'], ['秦', 'Q'], ['邱', 'Q'], ['丘', 'Q'], ['屈', 'Q'], ['仇', 'Q'],
    // R
    ['任', 'R'], ['阮', 'R'], ['容', 'R'], ['茹', 'R'],
    // S
    ['沙', 'S'], ['山', 'S'], ['尚', 'S'], ['邵', 'S'], ['申', 'S'], ['沈', 'S'], ['施', 'S'], ['石', 'S'], ['史', 'S'], ['宋', 'S'], ['苏', 'S'], ['孙', 'S'], ['司', 'S'],
    // T
    ['谈', 'T'], ['唐', 'T'], ['陶', 'T'], ['田', 'T'], ['童', 'T'], ['涂', 'T'],
    // W
    ['万', 'W'], ['汪', 'W'], ['王', 'W'], ['韦', 'W'], ['魏', 'W'], ['卫', 'W'], ['文', 'W'], ['温', 'W'], ['翁', 'W'], ['吴', 'W'], ['伍', 'W'], ['武', 'W'],
    // X
    ['夏', 'X'], ['向', 'X'], ['肖', 'X'], ['谢', 'X'], ['辛', 'X'], ['邢', 'X'], ['徐', 'X'], ['许', 'X'], ['薛', 'X'], ['熊', 'X'],
    // Y
    ['严', 'Y'], ['颜', 'Y'], ['阎', 'Y'], ['杨', 'Y'], ['姚', 'Y'], ['叶', 'Y'], ['易', 'Y'], ['殷', 'Y'], ['尹', 'Y'], ['于', 'Y'], ['俞', 'Y'], ['余', 'Y'], ['虞', 'Y'], ['元', 'Y'], ['岳', 'Y'], ['云', 'Y'],
    // Z
    ['曾', 'Z'], ['詹', 'Z'], ['张', 'Z'], ['章', 'Z'], ['赵', 'Z'], ['甄', 'Z'], ['郑', 'Z'], ['支', 'Z'], ['钟', 'Z'], ['周', 'Z'], ['朱', 'Z'], ['诸', 'Z'], ['祝', 'Z'], ['庄', 'Z'], ['卓', 'Z'], ['邹', 'Z'], ['左', 'Z'], ['祖', 'Z'],
  ]);
  
  /**
   * 获取字符串的拼音首字母
   * @param str 输入字符串
   * @returns 拼音首字母（大写）
   */
  static getFirstLetter(str: string): string {
    if (!str || str.length === 0) {
      return '#';
    }
    
    const firstChar = str.charAt(0);
    
    // 如果是英文字母，直接返回大写
    if (/[a-zA-Z]/.test(firstChar)) {
      return firstChar.toUpperCase();
    }
    
    // 如果是数字，返回 #
    if (/[0-9]/.test(firstChar)) {
      return '#';
    }
    
    // 如果是中文字符，获取拼音首字母
    return PinyinUtils.getPinyinFirstLetter(firstChar);
  }
  
  /**
   * 获取中文字符的拼音首字母
   * @param char 中文字符
   * @returns 拼音首字母（大写）
   */
  private static getPinyinFirstLetter(char: string): string {
    // 先在映射表中查找
    const letter = PinyinUtils.pinyinMap.get(char);
    if (letter) {
      return letter;
    }
    
    // 如果映射表中没有，使用 Unicode 编码范围估算
    const code = char.charCodeAt(0);
    
    // 如果不是中文字符，返回 #
    if (code < 0x4E00 || code > 0x9FA5) {
      return '#';
    }
    
    // 使用 Unicode 编码范围估算拼音首字母（作为后备方案）
    // 这是一个粗略的估算，可能不准确
    if (code >= 0x4E00 && code < 0x5000) return 'A';
    if (code >= 0x5000 && code < 0x6000) return 'B';
    if (code >= 0x6000 && code < 0x7000) return 'C';
    if (code >= 0x7000 && code < 0x8000) return 'D';
    if (code >= 0x8000 && code < 0x9000) return 'E';
    if (code >= 0x9000 && code < 0x9FA5) return 'F';
    
    return '#';
  }
  
  /**
   * 比较两个字符串的拼音首字母顺序
   * @param a 字符串1
   * @param b 字符串2
   * @returns 比较结果（-1, 0, 1）
   */
  static compareByFirstLetter(a: string, b: string): number {
    const letterA = PinyinUtils.getFirstLetter(a);
    const letterB = PinyinUtils.getFirstLetter(b);
    
    // # 排在最后
    if (letterA === '#' && letterB !== '#') {
      return 1;
    }
    if (letterA !== '#' && letterB === '#') {
      return -1;
    }
    
    // 按字母顺序比较
    if (letterA < letterB) {
      return -1;
    }
    if (letterA > letterB) {
      return 1;
    }
    
    // 首字母相同，按字符串本身比较
    return a.localeCompare(b, 'zh-CN');
  }
}
