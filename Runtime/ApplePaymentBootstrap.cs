// ==========================================================================================
//   GameFrameX 组织及其衍生项目的版权、商标、专利及其他相关权利
//   GameFrameX organization and its derivative projects' copyrights, trademarks, patents, and related rights
//   均受中华人民共和国及相关国际法律法规保护。
//   are protected by the laws of the People's Republic of China and relevant international regulations.
//
//   使用本项目须严格遵守相关法律法规及开源许可证之规定。
//   Usage must strictly comply with applicable laws, regulations, and open-source licenses.
//   本项目采用 MIT License 和 Apache License 2.0 双许可证分发，
//   This project is dual-licensed under the MIT License and Apache License 2.0,
//   完整许可证文本请参见源代码树根目录中的 LICENSE 文件。
//   please refer to the LICENSE file at the root of the source tree for the full license text.
//
//   禁止利用本项目实施危害国家安全、破坏社会秩序、
//   It is prohibited to use this project to engage in any activities that endanger national security, disrupt social order,
//   侵犯他人合法权益等法律法规所禁止的活动！
//   or infringe upon the legitimate rights and interests of others, as prohibited by laws and regulations!
//   因基于本项目二次开发而产生的一切法律纠纷与责任，
//   Any disputes or liabilities arising from secondary development of this project
//   本项目组织与贡献者概不负责。
//   shall be borne solely by the developer; the project organization and contributors assume no responsibility.
//   GitHub 仓库：https://github.com/GameFrameX
//   GitHub Repository: https://github.com/GameFrameX
//   Gitee  仓库：https://gitee.com/GameFrameX
//   Gitee Repository: https://gitee.com/GameFrameX
//   CNB  仓库：https://cnb.cool/GameFrameX
//   CNB Repository: https://cnb.cool/GameFrameX
//   官方文档：https://gameframex.doc.alianblank.com/
//   Official Documentation: https://gameframex.doc.alianblank.com/
//  ==========================================================================================

#if UNITY_IOS && !UNITY_EDITOR
using GameFrameX.Payment.Runtime;

namespace GameFrameX.Payment.Apple.Runtime
{
    /// <summary>
    /// App Store 渠道启动注册
    /// </summary>
    /// <remarks>
    /// 在 BeforeSceneLoad 阶段（早于 PaymentComponent.Awake）将渠道注册进 PaymentChannelRegistry；
    /// 仅真机 iOS 注册——Editor 下不注册，保证 DefaultPaymentManager 的编辑器模拟生效；
    /// 未安装本包时代码被裁剪，注册不会发生。
    /// </remarks>
    [UnityEngine.Scripting.Preserve]
    internal static class ApplePaymentBootstrap
    {
        [UnityEngine.RuntimeInitializeOnLoadMethod(UnityEngine.RuntimeInitializeLoadType.BeforeSceneLoad)]
        [UnityEngine.Scripting.Preserve]
        private static void Register()
        {
            PaymentChannelRegistry.Register(new PaymentChannelRegistration(ApplePaymentManager.ChannelId, "App Store", () => new ApplePaymentManager()));
        }
    }
}
#endif
