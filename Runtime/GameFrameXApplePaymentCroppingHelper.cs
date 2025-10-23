using UnityEngine;
using UnityEngine.Scripting;

namespace GameFrameX.Payment.Apple.Runtime
{
    [Preserve]
    public class GameFrameXApplePaymentCroppingHelper : MonoBehaviour
    {
        [Preserve]
        void Start()
        {
            _ = typeof(GameFrameX.Payment.Apple.Runtime.ApplePaymentManager);
            _ = typeof(GameFrameX.Payment.Apple.Runtime.ApplePayStoreKit);
            _ = typeof(GameFrameX.Payment.Apple.Runtime.GameFrameXApplePaymentCroppingHelper);
            _ = typeof(GameFrameX.Payment.Apple.Runtime.PurchaseInfo);
            _ = typeof(GameFrameX.Payment.Apple.Runtime.SKPaymentMode);
            _ = typeof(GameFrameX.Payment.Apple.Runtime.SKProductDiscount);
            _ = typeof(GameFrameX.Payment.Apple.Runtime.SKProductInfo);
            _ = typeof(GameFrameX.Payment.Apple.Runtime.SKProductIntroductoryPrice);
            _ = typeof(GameFrameX.Payment.Apple.Runtime.SKSubscriptionPeriodUnit);
        }
    }
}